require "logic.dialog"
require "logic.team.teammembermenu"
require "utils.mhsdutils"
require "logic.team.teammembercard"
require "logic.team.teamsettingdlg"
require "logic.team.teammatchdlg"
require "utils.commonutil"
require "logic.zhenfa.zhenfadlg"
require "logic.team.formationmanager"

TeamDialogNew = { }
setmetatable(TeamDialogNew, Dialog)
TeamDialogNew.__index = TeamDialogNew

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
local MAX_TEAMMEMBER = 5
local cellPerPage = 5

function TeamDialogNew.getInstance()
    LogInfo("enter get TeamDialogNew instance")
    if not _instance then
        _instance = TeamDialogNew:new()
        _instance:OnCreate()
    end

    return _instance
end

function TeamDialogNew.getInstanceAndShow()
    LogInfo("enter TeamDialogNew instance show")
    if not _instance then
        _instance = TeamDialogNew:new()
        _instance:OnCreate()
    else
        LogInfo("set TeamDialogNew visible")
        _instance:SetVisible(true)
    end

    return _instance
end

function TeamDialogNew.getInstanceNotCreate()
    return _instance
end


function TeamDialogNew.DestroyDialog()
    TeamDialogNew.CloseDialog()
end

function TeamDialogNew.CloseDialog()
    if _instance then
        NotificationCenter.removeObserver(Notifi_TeamListChange, TeamDialogNew.handleEventMemberChange)
        NotificationCenter.removeObserver(Notifi_TeamApplicantChange, TeamDialogNew.handleEventApplicationChange)
        NotificationCenter.removeObserver(Notifi_TeamSettingChange, TeamDialogNew.handleEventSettingChange)
        NotificationCenter.removeObserver(Notifi_TeamAutoMatchChange, TeamDialogNew.handleEventAutoMatchChange)
        NotificationCenter.removeObserver(Notifi_TeamMemberDataRefresh, TeamDialogNew.handleEventMemberChange)
        NotificationCenter.removeObserver(Notifi_TeamMemberComponentChange, TeamDialogNew.handleEventMemberComponentChange)

        if _instance.cards then
            for _, v in pairs(_instance.cards) do
                v:DestroyDialog()
            end
        end

        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function TeamDialogNew.ToggleOpenClose()
    if not _instance then
        _instance = TeamDialogNew:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

----/////////////////////////////////////////------

function TeamDialogNew.GetLayoutFileName()
    return "team.layout"
end

function TeamDialogNew:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, TeamDialogNew)
    return self
end

function TeamDialogNew:OnCreate()
    LogInfo("TeamDialogNew oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()

    self.closeBtn = CEGUI.toPushButton(winMgr:getWindow('teamdialognew/close'))
    self.myteamBtn = CEGUI.toGroupButton(winMgr:getWindow('teamdialognew/myteamBtn'))
    self.applylistBtn = CEGUI.toGroupButton(winMgr:getWindow('teamdialognew/applylistBtn'))
    self.cardContainer = CEGUI.toScrollablePane(winMgr:getWindow('teamdialognew/cardcontainer'))
    self.tipText = winMgr:getWindow('teamdialognew/tishi')
    self.tipDot = winMgr:getWindow('teamdialognew/applylistBtn/tipdot')

    self.tipDot:setVisible(GetTeamManager():GetApplicationNum() > 0)
    self.closeBtn:subscribeEvent("Clicked", self.handleCloseClicked, self)
    self.myteamBtn:subscribeEvent("SelectStateChanged", self.handleMyTeamClicked, self)
    self.applylistBtn:subscribeEvent("SelectStateChanged", self.handleApplylistBtnClicked, self)

    -- create team view
    self.createView = winMgr:getWindow('teamdialognew/createView')
    self.createTeamBtn = winMgr:getWindow('teamdialognew/createView/chuangjian')
    self.assistBtn1 = winMgr:getWindow('teamdialognew/createView/zhuzhan')
    self.applyJoinBtn = winMgr:getWindow('teamdialognew/createView/shenqingrudui')
    self.zhenXingBtn1 = winMgr:getWindow('teamdialognew/createView/zhenxing')
    self.zhenXingBtnc1 = winMgr:getWindow('teamdialognew/createView/zhenxing/name1')
    self.zhenXingBtnicon1 = winMgr:getWindow('teamdialognew/createView/zhenxing/zficon')
    self.redPackBtn = winMgr:getWindow("teamdialognew/applyView/hongbao")
    self.redPackBtn2 = winMgr:getWindow("teamdialognew/applyView/hongbao2")
    self.ordBtn = winMgr:getWindow("teamdialognew/applyView/hongbao21") 
    self.redPackBtn:subscribeEvent("Clicked", self.handleRedPackClicked, self)
    self.redPackBtn2:subscribeEvent("Clicked", self.handleRedPackClicked, self)
    self.ordBtn:subscribeEvent("Clicked", self.handleOrderClicked, self)
    local funopenclosetype = require("protodef.rpcgen.fire.pb.funopenclosetype"):new()
    local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        if manager.m_OpenFunctionList.info then
            for i,v in pairs(manager.m_OpenFunctionList.info) do
                if v.key == funopenclosetype.FUN_REDPACK then
                    if v.state == 1 then
                        self.redPackBtn:setVisible(false)
                        self.redPackBtn2:setVisible(false)
                    end
                end
            end
        end
    end
    
    -- 获取动画定义
    local btnPressAnimationDef = CEGUI.AnimationManager:getSingleton():getAnimation("studyBtnPress")

    -- 为 createTeamBtn 添加动画
    self:addButtonAnimation(self.createTeamBtn, btnPressAnimationDef)

    -- 为 assistBtn1 添加动画
    self:addButtonAnimation(self.assistBtn1, btnPressAnimationDef)

    -- 为 applyJoinBtn 添加动画
    self:addButtonAnimation(self.applyJoinBtn, btnPressAnimationDef)

    -- 为 zhenXingBtn1 添加动画
    self:addButtonAnimation(self.zhenXingBtn1, btnPressAnimationDef)
   -- self:addButtonAnimation(self.zhenXingBtnc1, btnPressAnimationDef)
  --  self:addButtonAnimation(self.zhenXingBtnicon1, btnPressAnimationDef)
	

    self.createTeamBtn:subscribeEvent("Clicked", self.handleCreateTeamClicked, self)
    self.assistBtn1:subscribeEvent("Clicked", self.handleAssistClicked, self)
    self.applyJoinBtn:subscribeEvent("Clicked", self.handleApplyJoinClicked, self)
    self.zhenXingBtn1:subscribeEvent("MouseClick", self.handleZhenXingClicked, self)
    self.zhenXingBtnc1:subscribeEvent("MouseClick", self.handleZhenXingClicked, self)
    self.zhenXingBtnicon1:subscribeEvent("MouseClick", self.handleZhenXingClicked, self)
    -- 阵型

    -- team view
    self.teamView = winMgr:getWindow('teamdialognew/teamView')
    self.zhenXingBtn2 = winMgr:getWindow('teamdialognew/teamView/zhenxing')
	self:addButtonAnimation(self.zhenXingBtn2, btnPressAnimationDef)---阵型2
    self.zhenXingBtnc2 = winMgr:getWindow('teamdialognew/teamView/zhenxing/name1')
    self.zhenXingBtnicon2 = winMgr:getWindow('teamdialognew/teamView/zhenxing/zficon')
    self.targetNameText = winMgr:getWindow('teamdialognew/teamView/mubiaoyaoqiu/mubiao')
    -- 行动目标
    self.levelRangeText = winMgr:getWindow('teamdialognew/teamView/mubiaoyaoqiu/dengji')
    self.settingBtn = winMgr:getWindow('teamdialognew/teamView/mubiaoyaoqiu/shezhi')
    self.autoMatchBtn = winMgr:getWindow('teamdialognew/teamView/pipei')
    self.inviteBtn = winMgr:getWindow('teamdialognew/teamView/yaoqing')
    self.quitBtn2 = winMgr:getWindow('teamdialognew/teamView/tuichu')
    self.assistBtn2 = winMgr:getWindow('teamdialognew/teamView/zhuzhan')
    self.chatBtn = winMgr:getWindow('teamdialognew/teamView/hanhua')
    self.settingBg = winMgr:getWindow('teamdialognew/teamView/mubiaoyaoqiu')
    self.smokeBg = winMgr:getWindow("teamdialognew/teamView/flagbg/smoke")-----动画
    local s = self.smokeBg:getPixelSize()
    local flagSmoke = gGetGameUIManager():AddUIEffect(self.smokeBg, "geffect/ui/mt_shengqishi/mt_duibiao", true, s.width*0.5, s.height)

    self.inviteBtn:setID(0)

    self.zhenXingBtn2:subscribeEvent("MouseClick", self.handleZhenXingClicked, self)
    self.zhenXingBtnc2:subscribeEvent("MouseClick", self.handleZhenXingClicked, self)
    self.zhenXingBtnicon2:subscribeEvent("MouseClick", self.handleZhenXingClicked, self)
    self.settingBtn:subscribeEvent("Clicked", self.handleSettingClicked, self)
    self.autoMatchBtn:subscribeEvent("Clicked", self.handleAutoMatchClicked, self)
    self.inviteBtn:subscribeEvent("Clicked", self.handleInviteClicked, self)
    self.quitBtn2:subscribeEvent("Clicked", self.handleQuitClicked, self)
    self.assistBtn2:subscribeEvent("Clicked", self.handleAssistClicked, self)
    self.chatBtn:subscribeEvent("Clicked", self.handleChatClicked, self)
    self.settingBg:subscribeEvent("MouseClick", self.handleSettingClicked, self)

    -- apply view
    self.applyView = winMgr:getWindow('teamdialognew/applyView')
    self.quitBtn3 = winMgr:getWindow('teamdialognew/applyView/tuichu')
    self.assistBtn3 = winMgr:getWindow('teamdialognew/applyView/zhuzhan')
    self.cleanBtn = winMgr:getWindow('teamdialognew/applyView/qingkongliebiao')
    self.emptyView = winMgr:getWindow('teamdialognew/applyView/empty')

    self.quitBtn3:subscribeEvent("Clicked", self.handleQuitClicked, self)
    self.assistBtn3:subscribeEvent("Clicked", self.handleAssistClicked, self)
    self.cleanBtn:subscribeEvent("Clicked", self.handleCleanClicked, self)

    self.SHOW_TYPE = {
        NONE = 0,
        MY_TEAM = 1,
        OTHERS_TEAM = 2,
        APPLY = 3
    }
    self.showType = self.SHOW_TYPE.MY_TEAM
    self.lastSelected = nil

    self.cardContainer:EnableHorzScrollBar(true)
    self:refreshContainer(self.SHOW_TYPE.MY_TEAM)

    if GetTeamManager():IsMatching() then
        self.autoMatchBtn:setText(MHSD_UTILS.get_resstring(10002))
        self.tipText:setText(MHSD_UTILS.get_resstring(10003))
    end

    NotificationCenter.addObserver(Notifi_TeamListChange, TeamDialogNew.handleEventMemberChange)
    NotificationCenter.addObserver(Notifi_TeamApplicantChange, TeamDialogNew.handleEventApplicationChange)
    NotificationCenter.addObserver(Notifi_TeamSettingChange, TeamDialogNew.handleEventSettingChange)
    NotificationCenter.addObserver(Notifi_TeamAutoMatchChange, TeamDialogNew.handleEventAutoMatchChange)
    NotificationCenter.addObserver(Notifi_TeamMemberDataRefresh, TeamDialogNew.handleEventMemberChange)
    NotificationCenter.addObserver(Notifi_TeamMemberComponentChange, TeamDialogNew.handleEventMemberComponentChange)
	
	self:addButtonAnimation(self.inviteBtn, btnPressAnimationDef)
    self:addButtonAnimation(self.settingBtn, btnPressAnimationDef)
    self:addButtonAnimation(self.quitBtn2, btnPressAnimationDef)
    self:addButtonAnimation(self.ordBtn, btnPressAnimationDef)
    self:addButtonAnimation(self.assistBtn2, btnPressAnimationDef)
    self:addButtonAnimation(self.chatBtn, btnPressAnimationDef)
	self:addButtonAnimation(self.autoMatchBtn, btnPressAnimationDef)

    self:refreshZhuzhanBtn()
end

-- 添加按钮动画的函数
function TeamDialogNew:addButtonAnimation(button, animationDef)
    if animationDef then
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        animation:setTargetWindow(button)
        animation:setSpeed(0.7)
        button:subscribeEvent("MouseButtonDown", function()
            animation:start()
        end, self)
    end
end

function TeamDialogNew:handleRedPackClicked(e)
    local dlg = require "logic.pointcardserver.messageforpointcarddlg".getInstance()
    if dlg then
    dlg:Show()
    end
end
function TeamDialogNew:handleOrderClicked(arg)
    local wnd = CEGUI.toWindowEventArgs(arg).window
    if TeamMemberMenu.checkTriggerWnd(wnd) then
        return
    end

    local btn = self.ordBtn
    local dlg = TeamMemberMenu.getInstanceAndShow()
    dlg:InitBtn(dlg.TYPE.ORDER, -1)
    dlg:setTriggerWnd(wnd)
    local p = btn:GetScreenPos()
    local s = btn:getPixelSize()
    p.x = p.x -(dlg:GetWindow():getPixelSize().width - s.width) * 0.5
    p.y = p.y - dlg:GetWindow():getPixelSize().height - 5
    dlg:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0, p.x), CEGUI.UDim(0, p.y)))
end
function TeamDialogNew:readyToChangeMemberPos(isChangeTeamMember)
    if not self.cards or #self.cards < 3 then
        return
    end
    self.readyToChangePos = false
    for _, v in pairs(self.cards) do
        if v.idx ~= 1 and v ~= self.lastSelected and v.cardType == self.lastSelected.cardType then
            v:showSwapButton(true)
            self.readyToChangePos = true
        end
    end
end
function TeamDialogNew:readyToChangeOrder(isChangeTeamMember)
    if not self.cards or #self.cards < 2 then
        return
    end
    self.readyToSetOrder = false
    local oID = GetTeamManager():getTeamOrder()
    for _, v in pairs(self.cards) do
        if v.idx ~= 1 and v.cardType == TeamMemberCard.MEMBER and v.id ~= oID then
            v:showWeiRenButton(true)
            self.readyToSetOrder = true
        end
    end
end

function TeamDialogNew:refreshContainer(showType)
    if self.showType ~= showType then
        if self.cards then
            for _, v in pairs(self.cards) do
                v:DestroyDialog()
            end
        end
        self.cardContainer:cleanupNonAutoChildren()
        self.cards = { }
    end

    self.showType = showType
    self.lastSelected = nil
    self.readyToChangePos = false
    self.readyToSetOrder = false

    if TeamMemberMenu.getInstanceNotCreate() then
        TeamMemberMenu.getInstanceNotCreate():SetVisible(false)
    end

    self.cards = self.cards or { }

    if showType == self.SHOW_TYPE.APPLY then
        self.cardContainer:getHorzScrollbar():EnbalePanGuesture(true)
        self.createView:setVisible(false)
        self.teamView:setVisible(false)
        self.applyView:setVisible(true)

        local teamlist = GetTeamManager():GetApplicantList()
        self.emptyView:setVisible(#teamlist == 0)

        for i = 1, #teamlist do
            if not self.cards[i] then
                local memberCard = TeamMemberCard.CreateNewDlg(self.cardContainer)
                memberCard:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0, 3 + (i-1) * memberCard:GetWindow():getPixelSize().width), CEGUI.UDim(0, 1)))
                memberCard:setSelectedCallFunc(self.handleCardSelected, self)
                table.insert(self.cards, memberCard)
            end
            self.cards[i]:loadApplyMemberData(GetTeamManager():GetApplication(i))
            self.cards[i]:setZhenfaEffect(nil)
        end

        if #self.cards > #teamlist then
            for i = #teamlist + 1, #self.cards do
                self.cards[i]:DestroyDialog()
                self.cards[i] = nil
            end
        end

    else
        self.cardContainer:getHorzScrollbar():EnbalePanGuesture(false)
        local cardIdx = 0
        self:refreshTeamSetting()
        if not GetTeamManager():IsOnTeam() then
            self.createView:setVisible(true)
            self.teamView:setVisible(false)
            self.myteamBtn:setVisible(false)
            self.applylistBtn:setVisible(false)

            if not self.cards[1] then
                local memberCard = TeamMemberCard.CreateNewDlg(self.cardContainer)
                memberCard:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0, 3), CEGUI.UDim(0, 1)))
                memberCard:setSelectedCallFunc(self.handleCardSelected, self)
                table.insert(self.cards, memberCard)
            end
            self.cards[1]:loadSelfData()
            cardIdx = 1

        else
            self.createView:setVisible(false)
            self.teamView:setVisible(true)
            self.myteamBtn:setVisible(true)
            self.applylistBtn:setVisible(true)

            self.chatBtn:removeEvent("Clicked")
            if GetTeamManager():IsMyselfLeader() then
                self.chatBtn:setText(MHSD_UTILS.get_resstring(10017)) -- 一键喊话
                self.chatBtn:subscribeEvent("Clicked", self.handleChatClicked, self)
            elseif GetTeamManager():GetMemberSelf().eMemberState == eTeamMemberAbsent then
                self.chatBtn:setText(MHSD_UTILS.get_resstring(2680)) -- 回归队伍
                self.chatBtn:subscribeEvent("Clicked", self.handleBackToTeamClicked, self)
            else
                self.chatBtn:setText(MHSD_UTILS.get_resstring(2681)) -- 暂离队伍
                self.chatBtn:subscribeEvent("Clicked", self.handleAbsentClicked, self)
            end

            local size = GetTeamManager():GetTeamMemberNum()
            for i = 1, size do
                if not self.cards[i] then
                    local memberCard = TeamMemberCard.CreateNewDlg(self.cardContainer)
                    memberCard:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0, 3 +(i - 1) * memberCard:GetWindow():getPixelSize().width), CEGUI.UDim(0, 1)))
                    memberCard:setSelectedCallFunc(self.handleCardSelected, self)
                    table.insert(self.cards, memberCard)
                end
                self.cards[i]:loadTeamMemberData(GetTeamManager():GetMember(i), i)
            end
            cardIdx = size
        end
        self.applyView:setVisible(false)


        -- 显示助战
        if not GetTeamManager():IsOnTeam() or GetTeamManager():IsMyselfLeader() then
            if XinGongNengOpenDLG.checkFeatureOpened(6) then
                local heroBaseInfoTable = BeanConfigManager.getInstance():GetTableByName("npc.cherobaseinfo")
                local activeGroupId = MT3HeroManager.getInstance():getActiveGroupId()
                local members = MT3HeroManager.getInstance():getGroupMember(activeGroupId)
                local n = math.min(members:size() -1, 5 - cardIdx - 1)
                for i = 0, n do
                    local memberId = members[i]
                    local record = heroBaseInfoTable:getRecorder(memberId)
                    if not self.cards[cardIdx + i + 1] then
                        local memberCard = TeamMemberCard.CreateNewDlg(self.cardContainer)
                        memberCard:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0, 3 +(cardIdx + i) * memberCard:GetWindow():getPixelSize().width), CEGUI.UDim(0, 1)))
                        memberCard:setSelectedCallFunc(self.handleCardSelected, self)
                        table.insert(self.cards, memberCard)
                    end
                    self.cards[cardIdx + i + 1]:loadAssistMember(record, cardIdx + i + 1)
                end
                cardIdx = cardIdx + n + 1
            end
        end

        if #self.cards > cardIdx then
            for i = cardIdx + 1, #self.cards do
                self.cards[i]:DestroyDialog()
                self.cards[i] = nil
            end
        end

        self:refreshZhenfaEffect()
    end
end



--刷新阵法效果
function TeamDialogNew:refreshZhenfaEffect()
    local zhenfaId = 0
    local level = 0

    if GetTeamManager():IsOnTeam() and not GetTeamManager():IsMyselfLeader() then
        zhenfaId = FormationManager.getInstance().m_iTeamFormation
        level = FormationManager.getInstance().m_iTeamFormationLevel
    else
        zhenfaId = MT3HeroManager.getInstance():getOpenedFormationId()
        if zhenfaId > 0 then
            level = FormationManager.getInstance():getFormationLevel(zhenfaId)
        end
    end

    if zhenfaId > 0 then
        local zhenfaEffect = FormationManager.getInstance():getZhenfaEffectConf(zhenfaId, level)
        if zhenfaEffect then
            for i=1, #self.cards do
                if zhenfaEffect.describe:size() < i then
                    self.cards[i]:setZhenfaEffect(nil)
			        break
		        end

                self.cards[i]:setZhenfaEffect(zhenfaEffect.describe[i-1])
            end
        end
    else
        for _,card in pairs(self.cards) do
            card:setZhenfaEffect(nil)
        end
    end
end

function TeamDialogNew:refreshTeamSetting()
    local setting = GetTeamManager():GetTeamMatchInfo()
    local matchinfo = BeanConfigManager.getInstance():GetTableByName(CheckTableName("team.cteamlistinfo")):getRecorder(setting.targetid)
    if matchinfo and matchinfo.id ~= -1 then
        self.targetNameText:setText(matchinfo.target)
        self.levelRangeText:setText('(' .. setting.minlevel .. '~' .. setting.maxlevel .. ')')
    else
        self.targetNameText:setText(MHSD_UTILS.get_resstring(3148))
        self.levelRangeText:setText('(' .. setting.minlevel .. '~' .. setting.maxlevel .. ')')
    end

    self:refreshZhenfaName()

    -- 光环名
    TeamDialogNew.handleEventAutoMatchChange()
    -- 自动匹配按钮显示
end

function TeamDialogNew:refreshZhenfaName()
    local id = 0
    local name1 = ""
    local level = 0

    if GetTeamManager():IsOnTeam() and not GetTeamManager():IsMyselfLeader() then
        id = FormationManager.getInstance().m_iTeamFormation
        level = FormationManager.getInstance().m_iTeamFormationLevel

    else
        id = MT3HeroManager.getInstance():getOpenedFormationId()
        if id > 0 then
            level = FormationManager.getInstance():getFormationLevel(id)
        end
    end

    if id == 0 then
        name1 = MHSD_UTILS.get_resstring(1731)
    else
        local baseconf = BeanConfigManager.getInstance():GetTableByName("battle.cformationbaseconfig"):getRecorder(id)
        name1 = baseconf.name
        icon = baseconf.imagepath
    end

    if level > 0 then
        name1 = level.. MHSD_UTILS.get_resstring(3).. name1
    end

    self.zhenXingBtn1:setText(name)
    self.zhenXingBtnc1:setText(name1)
    self.zhenXingBtn2:setText(name)
    self.zhenXingBtnc2:setText(name1)

    self:SetZhenfaImage(id, self.zhenXingBtnicon2)
    self:SetZhenfaImage(id, self.zhenXingBtnicon1)	-- 使用新的设置函数

    self:refreshZhenfaEffect()
end

function TeamDialogNew:SetZhenfaImage(id, targetControl)----读取阵法
    local baseconf = BeanConfigManager.getInstance():GetTableByName("battle.cformationbaseconfig"):getRecorder(id)
    targetControl:setProperty("Image", baseconf.imagepath)
end

function TeamDialogNew:DestroyDialogc()
	if self._instance then
        if self.sprite then
            self.sprite:delete()
            self.sprite = nil
        end
		if self.smokeBg then
		    gGetGameUIManager():RemoveUIEffect(self.smokeBg)
		end
		if self.roleEffectBg then
		    gGetGameUIManager():RemoveUIEffect(self.roleEffectBg)
		end
		self:OnClose()
		getmetatable(self)._instance = nil
        _instance = nil
	end
end

function TeamDialogNew:recvZhenRongChanged()
    if self.showType == self.SHOW_TYPE.APPLY then
        return
    end

    self:refreshTeamSetting()

    local cardIdx = 0
    for i = 1, #self.cards do
        if self.cards[i].cardType == TeamMemberCard.ASSIST then
            break
        end
        cardIdx = i
    end

    if not GetTeamManager():IsOnTeam() or GetTeamManager():IsMyselfLeader() then
        local heroBaseInfoTable = BeanConfigManager.getInstance():GetTableByName("npc.cherobaseinfo")
        local activeGroupId = MT3HeroManager.getInstance():getActiveGroupId()
        local members = MT3HeroManager.getInstance():getGroupMember(activeGroupId)
        local n = math.min(members:size() -1, 5 - cardIdx - 1)
        for i = 0, n do
            local memberId = members[i]
            local record = heroBaseInfoTable:getRecorder(memberId)
            if not self.cards[cardIdx + i + 1] then
                local memberCard = TeamMemberCard.CreateNewDlg(self.cardContainer)
                memberCard:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0, 3 +(cardIdx + i) * memberCard:GetWindow():getPixelSize().width), CEGUI.UDim(0, 1)))
                memberCard:setSelectedCallFunc(self.handleCardSelected, self)
                table.insert(self.cards, memberCard)
            end
            self.cards[cardIdx + i + 1]:loadAssistMember(record, cardIdx + i + 1)
        end
        cardIdx = cardIdx + n + 1
    end

    if #self.cards > cardIdx then
        for i = cardIdx + 1, #self.cards do
            self.cards[i]:DestroyDialog()
            self.cards[i] = nil
        end
    end

    self:refreshZhenfaEffect()
end

function TeamDialogNew:handleCloseClicked(arg)
    self.DestroyDialog()
end

-- 我的队伍
function TeamDialogNew:handleMyTeamClicked(arg)
    if self.showType == self.SHOW_TYPE.MY_TEAM then
        return
    end
    self.cardContainer:getHorzScrollbar():Stop()
    self.cardContainer:getHorzScrollbar():setScrollPosition(0)
    self.cardContainer:setHeight(CEGUI.UDim(0, 423))
    self.cardContainer:setYPosition(CEGUI.UDim(0, 142))
    self:refreshContainer(self.SHOW_TYPE.MY_TEAM)
end

-- 申请列表
function TeamDialogNew:handleApplylistBtnClicked(arg)
    if self.showType == self.SHOW_TYPE.APPLY then
        return
    end
    self.cardContainer:getHorzScrollbar():Stop()
    self.cardContainer:getHorzScrollbar():setScrollPosition(0)
    self.cardContainer:setHeight(CEGUI.UDim(0, 500))
    self.cardContainer:setYPosition(CEGUI.UDim(0, 142))
    self:refreshContainer(self.SHOW_TYPE.APPLY)
end

-- 创建队伍
function TeamDialogNew:handleCreateTeamClicked(arg)
    GetTeamManager():RequestCreateTeam()
    local setting = GetTeamManager():GetTeamMatchInfo()
    if setting.targetid ~= 0 then
        local p = require('protodef.fire.pb.team.crequestsetteammatchinfo').Create()
        p.targetid = setting.targetid
        p.levelmin = setting.minlevel
        p.levelmax = setting.maxlevel
        LuaProtocolManager:send(p)
    end
end

-- 伙伴助战
function TeamDialogNew:handleAssistClicked(arg)
    require "logic.team.huobanzhuzhandialog"
    HuoBanZhuZhanDialog.getInstanceAndShow()
end

-- 申请加入
function TeamDialogNew:handleApplyJoinClicked(arg)
    require('logic.team.teammatchdlg').getInstanceAndShow()
end

-- 阵型
function TeamDialogNew:handleZhenXingClicked(arg)
    if FormationManager.getInstance().m_iTeamFormation ~= 0 then -- 学习过阵法
        local dlg = ZhenFaDlg.getInstanceAndShow()
        dlg:focusOnZhenfaById(FormationManager.getInstance().m_iTeamFormation) 
    else -- 没学过阵法
        local roleItemManager = require("logic.item.roleitemmanager").getInstance()
        local vItemList = roleItemManager:GetItemListByType(ITEM_TYPE.FORMATION_BOOK, fire.pb.item.BagTypes.BAG)
        if vItemList:size() > 0 then
            for i=0, vItemList:size()-1 do
                require "logic.zhenfa.zhenfadlg".useZhenfaBookItemFromBag(vItemList[i]:GetObjectID())
                break
            end
        else
            local dlg = ZhenFaDlg.getInstanceAndShow()
            dlg:focusOnZhenfaById(FormationManager.getInstance().m_iTeamFormation) 
        end
    end
end

-- 队伍设置
function TeamDialogNew:handleSettingClicked(arg)
    if not GetTeamManager():IsMyselfLeader() then
        return
    end
    require("logic.team.teamsettingdlg").getInstance()
end

-- 自动匹配
function TeamDialogNew:handleAutoMatchClicked(arg)
    if not GetTeamManager():IsMyselfLeader() then
        GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(162138)) --只有队长才能自动匹配
        return
    end

    if not GetTeamManager():IsMatching() then
        -- 自动匹配
        local matchinfo = GetTeamManager():GetTeamMatchInfo()
        GetTeamManager():RequestTeamMatch(1, matchinfo.targetid, matchinfo.minlevel, matchinfo.maxlevel)

    else
        -- 取消匹配
        GetTeamManager():StopTeamMatch()
    end
end

-- 邀请队员
function TeamDialogNew:handleInviteClicked(arg)
    require('logic.team.teaminvitedlg')

    local wnd = CEGUI.toWindowEventArgs(arg).window
    if TeamMemberMenu.checkTriggerWnd(wnd) then
        return
    end

    local btn = self.inviteBtn
    local dlg = TeamMemberMenu.getInstanceAndShow()
    dlg:InitBtn(dlg.TYPE.INVITE, -1)
    dlg:setTriggerWnd(wnd)
    local p = btn:GetScreenPos()
    local s = btn:getPixelSize()
    p.x = p.x -(dlg:GetWindow():getPixelSize().width - s.width) * 0.5
    p.y = p.y - dlg:GetWindow():getPixelSize().height + 210
    dlg:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0, p.x), CEGUI.UDim(0, p.y)))
end

-- 退出队伍
function TeamDialogNew:handleQuitClicked(arg)
    GetTeamManager():RequestQuitTeam()
end

-- 一键喊话
function TeamDialogNew:handleChatClicked(arg)
    local setting = GetTeamManager():GetTeamMatchInfo()
    local matchinfo = BeanConfigManager.getInstance():GetTableByName(CheckTableName("team.cteamlistinfo")):getRecorder(setting.targetid)
    if not matchinfo then
        --未选择目标
        GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(150023))
    else
        --打开喊话编辑界面
	    require("logic.team.teamhanhuaedit").getInstanceAndShow()
    end
end

function TeamDialogNew:handleBackToTeamClicked(arg)
    GetTeamManager():RequestAbsentReturnTeam(false)
end

function TeamDialogNew:handleAbsentClicked(arg)
    GetTeamManager():RequestAbsentReturnTeam(true)
end

-- 清除列表
function TeamDialogNew:handleCleanClicked(arg)
    self.lastSelected = nil
    self.cardContainer:cleanupNonAutoChildren()
    GetTeamManager():ClearTeamApplicantList()
end

function TeamDialogNew:handleCardSelected(card)

    if self.showType == self.SHOW_TYPE.APPLY then
        if self.lastSelected == card then
            return
        end

        self.lastSelected = card
    elseif card.id ~= gGetDataManager():GetMainCharacterID() then
        if self.readyToChangePos == true then
            if card ~= self.lastSelected then
                if card.cardType == self.lastSelected.cardType then
                    if card.cardType == TeamMemberCard.ASSIST then
                        local memberNum = GetTeamManager():GetMemberNum()
                        local cardIdx =(memberNum > 0 and memberNum or 1)
                        local activeGroupId = MT3HeroManager.getInstance():getActiveGroupId()
                        MT3HeroManager.getInstance():swapGroupMember(activeGroupId, card.idx - cardIdx-1, self.lastSelected.idx - cardIdx-1)
                    elseif GetBattleManager():IsInBattle() then
                        GetCTipsManager():AddMessageTipById(131451)
                        -- 战斗中不能进行此操作。
                    else
                        GetTeamManager():RequestSwapMember(card.idx, self.lastSelected.idx)
                    end

                    for _, v in pairs(self.cards) do
                        v:showSwapButton(false)
                    end
                    self.readyToChangePos = false
                end
            else
                for _, v in pairs(self.cards) do
                    v:showSwapButton(false)
                end
                self.readyToChangePos = false
            end
            return
        end
        if self.readyToSetOrder == true then            
            local send = require "protodef.fire.pb.battle.battleflag.csetcommander":new()
            send.roleid = card.id
            send.opttype = 0
            require "manager.luaprotocolmanager":send(send)
            GetTeamManager():setTeamOrder(card.id)
            self:refreshContainer(self.showType)

            for _, v in pairs(self.cards) do
                v:showWeiRenButton(false)
            end
            self.readyToSetOrder = false
            return
        end
        self.lastSelected = card

        -- 如果点击的是助战，显示交换位置按钮
        if card.cardType == TeamMemberCard.ASSIST then
            self:readyToChangeMemberPos()
        else
            if TeamMemberMenu.checkTriggerWnd(card.back) then
                return
            end
            local dlg = TeamMemberMenu.getInstanceAndShow()
            dlg:InitBtn(dlg.TYPE.TEAMLIST, card.idx)
            dlg:setTriggerWnd(card.back)
            local p = card:GetWindow():GetScreenPos()
            if card.idx == 5 then
                p.x = p.x - dlg:GetWindow():getPixelSize().width
            else
                p.x = p.x + card:GetWindow():getPixelSize().width
            end
            dlg:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0, p.x), CEGUI.UDim(0, p.y)))
        end
    end
end

function TeamDialogNew.handleEventMemberChange()
    local isOnTeam = GetTeamManager():IsOnTeam()
    _instance.myteamBtn:setVisible(isOnTeam)
    _instance.applylistBtn:setVisible(isOnTeam)

    if _instance and _instance.showType == _instance.SHOW_TYPE.MY_TEAM or not isOnTeam then
        _instance:refreshContainer(_instance.SHOW_TYPE.MY_TEAM)
    end
end

function TeamDialogNew.handleEventApplicationChange()
    if _instance and _instance.showType == _instance.SHOW_TYPE.APPLY then
        _instance:refreshContainer(_instance.SHOW_TYPE.APPLY)
    end

    if _instance then
        local applicantNum = GetTeamManager():GetApplicationNum()
        _instance.tipDot:setVisible(applicantNum > 0)
    end
end

function TeamDialogNew.handleEventSettingChange()
    if _instance then
        _instance:refreshTeamSetting()
    end
end

function TeamDialogNew.handleEventAutoMatchChange()
    if _instance then
        if GetTeamManager():IsMatching() then
            _instance.autoMatchBtn:setText(MHSD_UTILS.get_resstring(10002))
            _instance.tipText:setText(MHSD_UTILS.get_resstring(10003))
        else
            _instance.autoMatchBtn:setText(MHSD_UTILS.get_resstring(10001))
            _instance.tipText:setText(MHSD_UTILS.get_resstring(10004))
        end
    end
end

function TeamDialogNew.handleEventMemberComponentChange(memberid)
    if _instance and _instance.showType == _instance.SHOW_TYPE.MY_TEAM then
        for _, v in pairs(_instance.cards) do
            if v.id == memberid then
                v:refreshSpriteComponent()
                break
            end
        end
    end
end

-- 伙伴助战显示
function TeamDialogNew:refreshZhuzhanBtn()
    if XinGongNengOpenDLG.checkFeatureOpened(6) then
        self.assistBtn1:setVisible(true)
        self.assistBtn2:setVisible(true)
        self.assistBtn3:setVisible(true)
    else
        self.assistBtn1:setVisible(false)
        self.assistBtn2:setVisible(false)
        self.assistBtn3:setVisible(false)
    end
end

function TeamDialogNew.onInternetReconnected()
    if _instance then
        _instance:refreshContainer(_instance.showType)
    end
end

return TeamDialogNew
