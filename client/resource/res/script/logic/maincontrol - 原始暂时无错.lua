require "logic.dialog"
require "utils.mhsdutils"
require "logic.task.taskdialog"
require "logic.systemsettingdlgnew"
require "logic.settingmainframe"
require "logic.shop.hefubagdlg"

MainControl = { }
setmetatable(MainControl, Dialog)
MainControl.__index = MainControl

local MainControlBtn_Min	= 0
MainControlBtn_TmpBag		= 1	--临时背包按钮
MainControlBtn_HeFuBag		= 2	--合服背包按钮
MainControlBtn_Repair		= 3	--装备修改按钮
local MainControlBtn_Max	= 4


local _instance

local unlockFlyTime = 0.8
local totalAddTime = 1.0
local downTime = 0.5
local showSpeTime = 0.3
--local autoHideTime = 20.0

local State_Folded = 1
local State_Folding = 2
local State_UnFolded = 3
local State_UnFolding = 4

local State_NULL = 1
local State_StartUnLock = 2
local State_DownAdding = 3
local State_RightAdding = 4

local State_Show = 1
local State_Showing = 2
local State_Hide = 3
local State_Hiding = 4

local ePackPos = 0
local eRightPosMax = 1

local eProductPos = 0   ----强化
local eTaskPos = 1      ----法宝
local eXiakePos = 2     ----器灵
local ePaiHangPos = 3   ----
local eFriendPos = 4
local eSkillPos = 5
-- local eJewelryPos = 4
local eTeamPos = 6-- 7
local eDownPosMax = 7-- 8

local eMaincontrolTipStart = 0
local eMaincontrolPackTip = 1
local eMaincontrolTastTip = 2
-- local eMaincontrolAroundTip = 3
local eMaincontrolProductTip = 3
local eMaincontrolSkillTip = 4
local eMaincontrolXiakeTip = 5
local eMaincontrolTeamTip = 6
local eMaincontrolFriendTip = 7
local eMaincontrolSystemTip = 8
local eMaincontrolFactionTip = 9
local eMaincontrolTipMax = 10

local GUnFoldEffectTime = 0.35

local eMaincontrolJiangli = 1
local eMaincontrolHuodong = 2
local eMaincontrolChengjiu = 3
local eMaincontrolGuaji = 4
local eMaincontrolHongbao = 5
local eMaincontrolPaihang = 6
local eMaincontrolShezhi = 7
local eMaincontrolPaimai = 8
local eMaincontrolShangcheng = 9
local eMaincontrolZhuzhan = 10
local eMaincontrolJineng = 11
local eMaincontrolQianghua = 12
local eMaincontrolGonghui = 13

local eMaincontrolCount = 13

function MainControl.getInstance()
    LogInfo("enter get maincontrol instance")
    if not _instance then
        _instance = MainControl:new()
        _instance:OnCreate()
    end

    return _instance
end

function MainControl.getInstanceAndShow()
    LogInfo("enter maincontrol instance show")
    if not _instance then
        _instance = MainControl:new()
        _instance:OnCreate()
    else
        LogInfo("set maincontrol visible")
        _instance:SetVisible(true)
    end

    return _instance
end

function MainControl.getInstanceNotCreate()
    return _instance
end

function MainControl.DestroyDialog()
    if _instance then
        LogInfo("destroy maincontrol")

        local aniMan = CEGUI.AnimationManager:getSingleton()
        aniMan:destroyAnimationInstance(_instance.m_aniopen)
        aniMan:destroyAnimationInstance(_instance.m_aniclose)

        NotificationCenter.removeObserver(Notifi_TeamApplicantChange, MainControl.TeamApplyChange)

        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end

    end
end

function MainControl.ToggleOpenClose()
    if not _instance then
        _instance = MainControl:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function MainControl.SetPackBtnFlash()
    if _instance then
        gGetGameUIManager():AddUIEffect(_instance.m_pPackBtn, MHSD_UTILS.get_effectpath(10185), false)
    end
end

function MainControl.TeamApplyChange()
    if GetTeamManager() then
        if GetTeamManager():GetApplicationNum() == 0 then
            MainControl.setTeamTip(0)
        else
            MainControl.setTeamTip(0)
        end
    end
end


----/////////////////////////////////////////------

function MainControl.GetLayoutFileName()
    return "maincontrol.layout"
end

function MainControl:OnCreate()
    LogInfo("maincontrol oncreate begin")
    Dialog.OnCreate(self)
	self:GetWindow():setRiseOnClickEnabled(false)

    local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_isSimplipy = 0
    self.m_mTipNum = { }
    self.m_mTipWnd = { }
    for i = eMaincontrolTipStart, eMaincontrolTipMax - 1 do
        self.m_mTipNum[i] = 0
    end

    self.m_simplipyTips = {}
    for i = 1, eMaincontrolCount do
        self.m_simplipyTips[i] = 0
    end
    -- get windows
    self.m_pPackBtn = CEGUI.Window.toPushButton(winMgr:getWindow("MainControlDlg/back/pack"))
    self.m_pTeamBtn = CEGUI.Window.toPushButton(winMgr:getWindow("MainControlDlg/back/team"))
    self.m_pXiakeBtn = CEGUI.Window.toPushButton(winMgr:getWindow("MainControlDlg/back/friend"))
    self.m_pTaskBtn = CEGUI.Window.toPushButton(winMgr:getWindow("MainControlDlg/back/task"))
    self.m_pFriendBtn = CEGUI.Window.toPushButton(winMgr:getWindow("MainControlDlg/back/faction"))
    self.m_pSkillBtn = CEGUI.Window.toPushButton(winMgr:getWindow("MainControlDlg/back/skill"))
    self.m_pSystemBtn = CEGUI.Window.toPushButton(winMgr:getWindow("MainControlDlg/back/system"))
    self.m_pProductBtn = CEGUI.Window.toPushButton(winMgr:getWindow("MainControlDlg/back/production"))
    self.m_pPaihangBtn = CEGUI.Window.toPushButton(winMgr:getWindow("MainControlDlg/back/paihang"))

    self.m_pSystemBtn:setVisible(false)

    self.m_pDownPanel = winMgr:getWindow("MainControlDlg/down")
    self.m_pRightPanel = winMgr:getWindow("MainControlDlg/right")
    self.m_pSwitchFoldBtn = CEGUI.Window.toPushButton(winMgr:getWindow("MainControlDlg/control"))
    --self.m_pFriendMsgNotify = winMgr:getWindow("MainControlDlg/back/faction/mark")
    self.m_pTeamTipWnd = winMgr:getWindow("MainControlDlg/back/team/mark")
    self.m_pSwitchTipWnd = winMgr:getWindow("MainControlDlg/control/mark")
    self.m_pXiakeTipWnd = winMgr:getWindow("MainControlDlg/back/friend/mark")
    self.m_pFactionMark = winMgr:getWindow("MainControlDlg/back/faction/mark1")
    self.m_pTemporaryPackBtn = CEGUI.toPushButton(winMgr:getWindow("MainControlDlg/teamporarybackpack"))
    -- subscribe event
    --    self.m_pAroundBtn:subscribeEvent("Clicked", MainControl.HandleAroundBtnClick,self)
    self.m_pPackBtn:subscribeEvent("MouseClick", MainControl.HandlePackBtnClicked, self)
    self.m_pTeamBtn:subscribeEvent("Clicked", MainControl.HandleTeamBtnClicked, self)
    self.m_pXiakeBtn:subscribeEvent("MouseClick", MainControl.HandleXiakeBtnClicked, self)---器灵
    self.m_pFriendBtn:subscribeEvent("MouseClick", MainControl.HandleFriendBtnClicked, self)
    self.m_pTaskBtn:subscribeEvent("Clicked", MainControl.HandleTaskBtnClicked, self)---法宝
    self.m_pSkillBtn:subscribeEvent("MouseClick", MainControl.HandleSkillBtnClicked, self)
    self.m_pSystemBtn:subscribeEvent("Clicked", MainControl.HandleSystemBtnClicked, self)
    self.m_pProductBtn:subscribeEvent("MouseClick", MainControl.HandleProductBtnClicked, self)
    self.m_pSwitchFoldBtn:subscribeEvent("Clicked", MainControl.HandleSwitchFoldBtnClick, self)
    self.m_pTemporaryPackBtn:subscribeEvent("Clicked", MainControl.HandleTemporaryPackBtnClicked, self)
    self.m_pPaihangBtn:subscribeEvent("Clicked", MainControl.HandlePaiHangBtnClicked, self)

    self.m_SimplifyBtn = CEGUI.Window.toPushButton(winMgr:getWindow("MainControlDlg/control1"))
    self.m_SimplifyBtn:subscribeEvent("Clicked", MainControl.HandleSimplifyClicked, self)
    self.m_SimplifyTip = winMgr:getWindow("MainControlDlg/control/mark1")
    self.m_SimplifyTip:setVisible(false)
    self.m_btnXiuliEquip = CEGUI.Window.toPushButton(winMgr:getWindow("MainControlDlg/teamporarybackpack1")) 
    self.m_btnXiuliEquip:subscribeEvent("MouseClick", MainControl.clickXiuli, self)
    self.m_btnXiuliEquip:setVisible(false)

	self.m_btnHeFuBag = CEGUI.toPushButton(winMgr:getWindow("MainControlDlg/teamporarybackpack2"))
	self.m_btnHeFuBag:subscribeEvent("MouseClick", MainControl.clickHeFuBag, self)
    self.m_btnHeFuBag:setVisible(false)

	self.firstRowBtns = {}
	self.firstRowBtns[MainControlBtn_TmpBag] = self.m_pTemporaryPackBtn
	self.firstRowBtns[MainControlBtn_HeFuBag] = self.m_btnHeFuBag
	self.firstRowBtns[MainControlBtn_Repair] = self.m_btnXiuliEquip

	self.btnXPositions = {}
	local x = self.m_pTemporaryPackBtn:getXPosition()
	local s = self.m_pTemporaryPackBtn:getPixelSize()
	self.btnXPositions[1] = x.offset+s.width*0.5
	x = self.m_btnHeFuBag:getXPosition()
	s = self.m_btnHeFuBag:getPixelSize()
	self.btnXPositions[2] = x.offset+s.width*0.5
	x = self.m_btnXiuliEquip:getXPosition()
	s = self.m_btnXiuliEquip:getPixelSize()
	self.btnXPositions[3] = x.offset+s.width*0.5


    self.m_bShowingAni = false

    -- 播放动画
    self.m_imgFold = winMgr:getWindow("MainControlDlg/control/jia")
    local aniMan = CEGUI.AnimationManager:getSingleton()
    self.animationOpen = aniMan:getAnimation("zhujiemianduihuan")
    self.animationClose = aniMan:getAnimation("zhujiemianduihuan2")
    self.m_aniopen = aniMan:instantiateAnimation(self.animationOpen)
    self.m_aniclose = aniMan:instantiateAnimation(self.animationClose)

    -- self.m_pSwitchFoldBtn:subscribeEvent("AnimationStopped", MainControl.HandleFoldBtnAniStop, self)
    self.m_aniopen:setTargetWindow(self.m_imgFold)
    self.m_imgFold:subscribeEvent("AnimationEnded", self.HandleAnimationOver, self)
    -- self.m_aniopen:setEventReceiver( tolua.cast(self.m_pSwitchFoldBtn,"CEGUI::EventSet")  )
    self.m_aniclose:setTargetWindow(self.m_imgFold)
    self.m_imgFold:subscribeEvent("AnimationEnded", self.HandleAnimationOver, self)
    -- self.m_aniclose:setEventReceiver( tolua.cast(self.m_pSwitchFoldBtn,"CEGUI::EventSet")  )
    self.m_playState = 1

    self.m_aniclose:setPosition(GUnFoldEffectTime)

    --self.m_pFriendMsgNotify:setVisible(false)
    self.m_pFactionMark:setVisible(false)
    self.m_mTipWnd[eMaincontrolFriendTip] = self.m_pFriendMsgNotify
    self.m_mTipNum[eMaincontrolFriendTip] = 0

    self.m_pTeamTipWnd:setVisible(false)
    self.m_mTipWnd[eMaincontrolTeamTip] = self.m_pTeamTipWnd
    self.m_mTipNum[eMaincontrolTeamTip] = 0

    self.m_pSwitchTipWnd:setVisible(false)
    self.m_pSwitchTipNum = 0

    self.m_pXiakeTipWnd:setVisible(false)
    self.m_mTipWnd[eMaincontrolXiakeTip] = self.m_pXiakeTipWnd
    self.m_mTipNum[eMaincontrolXiakeTip] = 0

    self.m_mTipWnd[eMaincontrolFactionTip] =  self.m_pFactionMark
    self.m_mTipNum[eMaincontrolFactionTip]  = 0

    self.m_aRightWndSt = { }
    local packStat = { }
    packStat.pWnd = self.m_pPackBtn
    packStat.bUnlocked = true
    self.m_aRightWndSt[ePackPos] = packStat

    self.m_aDownWndSt = { }
    local skillStat = { }
    skillStat.pWnd = self.m_pSkillBtn
    skillStat.bUnlocked = true
    self.m_aDownWndSt[eSkillPos] = skillStat

    local taskStat = { }
    taskStat.pWnd = self.m_pTaskBtn----法宝
    taskStat.bUnlocked = true
    self.m_aDownWndSt[eTaskPos] = taskStat

    local xiakeStat = { }
    xiakeStat.pWnd = self.m_pXiakeBtn
    xiakeStat.bUnlocked = true
    self.m_aDownWndSt[eXiakePos] = xiakeStat

    local teamStat = { }
    teamStat.pWnd = self.m_pTeamBtn
    -- teamStat.bUnlocked = true
    self.m_aDownWndSt[eTeamPos] = teamStat

    local friendStat = { }
    friendStat.pWnd = self.m_pFriendBtn
    friendStat.bUnlocked = true
    self.m_aDownWndSt[eFriendPos] = friendStat

    local paihangStat = { }  
    paihangStat.pWnd = self.m_pPaihangBtn
    paihangStat.bUnlocked = true
    self.m_aDownWndSt[ePaiHangPos] = paihangStat

    local productStat = { }
    productStat.pWnd = self.m_pProductBtn
    productStat.bUnlocked = true
    self.m_aDownWndSt[eProductPos] = productStat

    self.m_pUnlockEndPos = { }
    self.m_pUnlockStartPos = { }

    self.m_aRightWnd = { }
    self.m_aDownWnd = { }

    self:InitBtnShowStat()
    self:InitFoldState()

    self.m_AddState = State_NULL

    self:RefreshTempPackBtn()

    LogInfo("maincontrol oncreate end")
    local p = require "protodef.fire.pb.clan.crequestapplylist":new()
    require "manager.luaprotocolmanager":send(p)

    
  
    self:GetWindow():setRiseOnClickEnabled(false)
    self:GetWindow():setAlwaysOnBottom(true)
    self:refreshTipInfo()
    self:initIsSimplify()
end
function MainControl:setSimplify(id, value)
    self.m_simplipyTips[id] = value
    local dlg = require"logic.framesimplipy".getInstanceNotCreate()
    if dlg then
        if value == 0 then
            dlg.m_tableWnd[id]:setVisible(false)
        else
            dlg.m_tableWnd[id]:setVisible(true)
        end
    end
    self.m_SimplifyTip:setVisible(false)
    for i = 1, eMaincontrolCount do
        if  self.m_simplipyTips[i] == 1 then
            self.m_SimplifyTip:setVisible(true)
        end
    end
end
function MainControl:getBtnForRightDow()
    local screenPos = self.m_SimplifyBtn:GetScreenPosOfCenter()
    return screenPos
end
function MainControl:initIsSimplify()
    local SettingEnum = require "protodef.rpcgen.fire.pb.sysconfigtype":new()
    local record = GameTable.SysConfig.GetCGameconfigTableInstance():getRecorder(SettingEnum.framesimplify)
    if record.id ~= -1 then
        local strKey = record.key
        local value = gGetGameConfigManager():GetConfigValue(strKey)
        if value == 1 then 
            self.m_pDownPanel:setVisible(false)
            self.m_pSwitchFoldBtn:setVisible(false)
            self.m_pSystemBtn:setVisible(false)
            self.m_SimplifyBtn:setVisible(true)
            self.m_isSimplipy = 1
	    else
            self.m_pDownPanel:setVisible(true)
            self.m_pSwitchFoldBtn:setVisible(true)
            self.m_pSystemBtn:setVisible(true)
            self.m_SimplifyBtn:setVisible(false)
            self:UnFoldButton()
            self:PlaySwitchFoldBtnOpenClose(1)
            self.m_fAutoHideTime = 0
            self.m_isSimplipy = 0        
        end
    end    
end
function MainControl:HandleSimplifyClicked(e)
    require"logic.framesimplipy".getInstanceAndShow()
	if MainControl.getInstanceNotCreate() then
		MainControl.getInstanceNotCreate():SetVisible(false)
	end
    if LogoInfoDialog.getInstanceNotCreate() then
        LogoInfoDialog.getInstanceNotCreate():MoveWifiLeft()
        LogoInfoDialog.getInstanceNotCreate():HideAllButton()
    end
	if Renwulistdialog.getSingleton() then
		Renwulistdialog.getSingleton():SetVisible(false)
	end
    local dlg = require "logic.petandusericon.userandpeticon".getInstanceNotCreate()
    if dlg then
        dlg:GetWindow():setVisible(false)
    end
    dlg = require ("logic.chat.cchatoutboxoperateldlg").getInstanceNotCreate()
    if dlg then
        dlg:GetWindow():setVisible(false)
    end
    -- 开启菜单关闭聊天框，杨斌
    if CChatOutputDialog:getInstance() then
        CChatOutputDialog:getInstance():OnClose()
    end
end
function MainControl.ShowBtnInFirstRow(btntype, visible)
	if not _instance then
		return
	end

	if btntype <= MainControlBtn_Min or btntype >= MainControlBtn_Max then
		return
	end

	if visible == nil then
		visible = true
	end

	if _instance.firstRowBtns[btntype]:isVisible() == visible then
		return
	end

	_instance.firstRowBtns[btntype]:setVisible(visible)

	local adjustBtns = {}
	local visibleBtnNum = 0
	for i=MainControlBtn_Min+1, MainControlBtn_Max-1 do
		if _instance.firstRowBtns[i]:isVisible() then
			if i >= btntype then
				table.insert(adjustBtns, _instance.firstRowBtns[i])
			end
			visibleBtnNum = visibleBtnNum + 1
		end
	end

	for i=visibleBtnNum-#adjustBtns+1, MainControlBtn_Max-1 do
		if #adjustBtns > 0 then
			local x = _instance.btnXPositions[i]
			local btn = adjustBtns[1]
			btn:setXPosition(CEGUI.UDim(0, x-btn:getPixelSize().width*0.5))
			table.remove(adjustBtns, 1)
		else
			break
		end
	end
end

function MainControl:clickXiuli()
    local bSelBroken = true
    local nBagId,nItemKey = require("logic.workshop.workshopmanager").getToXiuliItemBagAndKey(bSelBroken)
    if nBagId==-1 then
        return
    end
    local Openui = require("logic.openui")
    Openui.OpenUI(Openui.eUIId.zhuangbeixiuli_08, nBagId, nItemKey)

end

function MainControl:clickHeFuBag()
	HeFuBagDlg.getInstanceAndShow()
end
------------------- private: -----------------------------------

function MainControl:RefreshTempPackBtn()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local cap = roleItemManager:GetBagCapacity(fire.pb.item.BagTypes.TEMP)
    local empty = true
    for i = 0, cap - 1 do
        local pItem = roleItemManager:FindItemByBagIDAndPos(fire.pb.item.BagTypes.TEMP, i)
        if pItem then
            empty = false
            break
        end
    end

    if empty == false then
        MainControl.ShowBtnInFirstRow(MainControlBtn_TmpBag)
    else
        MainControl.ShowBtnInFirstRow(MainControlBtn_TmpBag, false)
    end
end

function MainControl:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, MainControl)
    return self
end

function MainControl:HandleTemporaryPackBtnClicked(e)
    CTemporaryPack:ToggleOpenHide()
end

function MainControl:HandlePaiHangBtnClicked(e)
    require "logic.workshop.workshopaq1".getInstanceAndShow()
end

function MainControl:HandlePackBtnClicked(args)
    LogInfo("maincontrol pack button clicked")

    -- 开启菜单关闭聊天框，杨斌
    if CChatOutputDialog:getInstance() then
        CChatOutputDialog:getInstance():OnClose()
    end

    CMainPackLabelDlg:GetSingletonDialogAndShowIt():Show()
    self.m_fAutoHideTime = 0

   local Taskuseitemdialog = require("logic.task.taskuseitemdialog")
   local useItemDlg = Taskuseitemdialog.getInstanceNotCreate()
   if useItemDlg then
      if useItemDlg.nType == Taskuseitemdialog.eUseType.chuanzhuangbei then
            Taskuseitemdialog.DestroyDialog()
      end
   end
    return true
end

function MainControl:HandleXiakeBtnClicked(args)-----器灵
   require "logic.workshop.Attunement".getInstanceAndShow()
end
  --  LogInfo("maincontrol xiake btn clicked")
    -- self.m_fAutoHideTime = 0

    -- 开启菜单关闭聊天框，杨斌
   -- if CChatOutputDialog:getInstance() then
   --     CChatOutputDialog:getInstance():OnClose()
   -- end

  --  require "logic.team.huobanzhuzhandialog"
   -- HuoBanZhuZhanDialog.getInstanceAndShow()
    
    --local cgethuobanlist = require "protodef.fire.pb.huoban.cgethuobanlist":new()
   -- require "manager.luaprotocolmanager":send(cgethuobanlist)

 --   return true
--end

function MainControl:HandleTaskBtnClicked(args)----法宝进阶
	require "logic.workshop.workshopaq".getInstanceAndShow()
end

--function MainControl:HandleTaskBtnClicked(args)
 --   LogInfo("maincontrol task btn clicked")

    -- 开启菜单关闭聊天框，杨斌
   -- if CChatOutputDialog:getInstance() then
    --    CChatOutputDialog:getInstance():OnClose()
    --end

   -- Renwudialog.ToggleOpenHide()
   -- self.m_fAutoHideTime = 0
   -- return true
--end

function MainControl:HandleTeamBtnClicked(args)
    LogInfo("maincontrol team btn clicked")

    -- 开启菜单关闭聊天框，杨斌
    if CChatOutputDialog:getInstance() then
        CChatOutputDialog:getInstance():OnClose()
    end

    self.m_mTipNum[eMaincontrolTeamTip] = 0
    TeamDialogNew.getInstanceAndShow()


    self.m_fAutoHideTime = 0
    return true
end

function MainControl:HandleFriendBtnClicked(args)
    LogInfo("maincontrol friend btn clicked")

    -- 开启菜单关闭聊天框，杨斌
    if CChatOutputDialog:getInstance() then
        CChatOutputDialog:getInstance():ToHide()
    end

    -- 打开公会UI
    require "logic.faction.factiondatamanager".OpenFamilyUI()

    self.m_fAutoHideTime = 0
    return true
end

function MainControl:HandleSkillBtnClicked(args)
    LogInfo("maincontrol skill btn clicked")
    require "logic.skill.skilllable"

    -- 开启菜单关闭聊天框，杨斌
    if CChatOutputDialog:getInstance() ~= nil then
        CChatOutputDialog:getInstance():OnClose()
    end
    local skillIndex = gCommon.skillIndex or 1
    SkillLable.Show(skillIndex)
    self.m_fAutoHideTime = 0
    return true
end

function MainControl:HandleSystemBtnClicked(args)
    LogInfo("maincontrol system btn clicked")

    -- 开启菜单关闭聊天框，杨斌
    if CChatOutputDialog:getInstance() ~= nil then
        CChatOutputDialog:getInstance():OnClose()
    end

    -- hjw
    SystemSettingNewDlg.getInstanceAndShow()
--    SettingMainFrame.show(1)
    self.m_fAutoHideTime = 0
    return true
end

function MainControl.SetFriendBtnFlash(bFlash)
    if _instance then
        LogInfo("maincontrol set friend btn flash")
        if bFlash then
            _instance.m_mTipNum[eMaincontrolFriendTip] = 0
            _instance:setSimplify(13, 0)
        else
            _instance.m_mTipNum[eMaincontrolFriendTip] = 0
            _instance:setSimplify(13, 0)
        end

        _instance:refreshTipInfo()
    end
end

function MainControl.RefreshFriendBtnFlashState()
    LogInfo("maincontrol refresh friend btn flash state")
    local hasFriendChatMsg = gGetFriendsManager():HasNotShowMsg()
    MainControl.SetFriendBtnFlash(hasFriendChatMsg)
end

function MainControl:HandleProductBtnClicked(args)
    LogInfo("maincontrol product btn clicked")

    -- 开启菜单关闭聊天框，杨斌
    if CChatOutputDialog:getInstance() ~= nil then
        CChatOutputDialog:getInstance():OnClose()
    end

    local waManager = require "logic.workshop.workshopmanager".getInstance()
    local nShowType = waManager.nShowType
    WorkshopLabel.Show(nShowType, 3, 0)
    -- CWorkshopManager:GetSingletonDialog():Show()
    self.m_fAutoHideTime = 0
    return true
end

function MainControl:HandleSwitchFoldBtnClick(args)
    LogInfo("maincontrol switchfold btn clicked")
    print("MainControl:HandleSwitchFoldBtnClick-----------------Click")
    local aniMan = CEGUI.AnimationManager:getSingleton()
    if self.m_AddState ~= State_NULL then
        return true
    end
    print("fold state ", self.m_FoldState)
    if self.m_FoldState == State_Folded or self.m_FoldState == State_Folding then
        -- or self.m_ShowSpeBtnState == State_Hiding then
        print("MainControl:HandleSwitchFoldBtnClick State_Folded")
        self:UnFoldButton()

        self:PlaySwitchFoldBtnOpenClose(1)

    elseif self.m_FoldState == State_UnFolded or self.m_FoldState == State_UnFolding then
        self:FoldButton()
        self:PlaySwitchFoldBtnOpenClose(2)
        -- if CChatOutBoxOperatelDlg.getInstanceNotCreate() then --new add
        -- CChatOutBoxOperatelDlg.getInstanceNotCreate():ShowChatContent()
        -- end
    end
    self.m_fAutoHideTime = 0
    return true
end

function MainControl:FoldButton()
    LogInfo("maincontrol foldbutton")
    self.m_FoldState = State_Folding
    self.m_fFoldElapseTime = 0
    self.m_playState = 2
    
    -- self:UpdateFoldState(0.005)
    -- self.m_imgFold:setVisible( false )	
end

function MainControl:UnFoldButton()
    LogInfo("maincontrol unfoldebutton")
    self.m_FoldState = State_UnFolding
    self.m_fShowSpecialBtnTime = 0
    self.m_playState = 1
end

function MainControl:InitFoldState()
    LogInfo("maincontrol initfoldstate")
    self.m_pDownPanel:setXPosition(CEGUI.UDim(0, self.m_fSwitchBtnLeft))
    -- self.m_pRightPanel:setYPosition(CEGUI.UDim(0, self.m_fSwitchBtnTop))	

    self.m_pDownPanel:SetAllChildrenVis(false)
    -- self.m_pRightPanel:SetAllChildrenVis(false)

    --防止it had not to hide m_pDownPanel， prevent unvisible first
    --self.m_pDownPanel:setVisible(false)
    -- self.m_pRightPanel:setVisible(false)
    self.m_fFoldElapseTime = 0
    self.m_FoldState = State_Folded

    -- self:EndShowSpecialBtn()
end

function MainControl:UpdateFoldState(elapse)
    print("MainControl:UpdateFoldState")
    if self.m_FoldState ~= State_Folding and self.m_FoldState ~= State_UnFolding then
        return
    end
    local totaltime = 0.2
    if self.m_FoldState == State_UnFolding then
        totaltime = 0.2
    end
    local graveTime = 0.05
    self.m_fFoldElapseTime = self.m_fFoldElapseTime + elapse

    -- 直接根据状态增加距离
    local v_x =(self.m_pSwitchFoldBtn:getPixelSize().width + 1) * self.m_iDownNum / GUnFoldEffectTime
    local DownPanelPos = self.m_pDownPanel:GetTopLeftPosOnParent().x
    if self.m_FoldState == State_Folding then
        DownPanelPos = DownPanelPos + v_x * elapse
    elseif self.m_FoldState == State_UnFolding then
        DownPanelPos = DownPanelPos - v_x * elapse
    end

    local n = self.m_fDownPanelLeft
    local switchBtnScreenLeft = self.m_pSwitchFoldBtn:GetScreenPos().x

    local nCnt = #self.m_aDownWnd

    if self.m_FoldState == State_Folding then
        local lastLeftPos = self.m_fDownPanelLeft + self.m_iDownNum * self.m_pSwitchFoldBtn:getPixelSize().width
        if DownPanelPos >= lastLeftPos then
            self.m_FoldState = State_Folded
            
            self:EndFoldButton()
        end
    elseif self.m_FoldState == State_UnFolding then
        if DownPanelPos <= self.m_fDownPanelLeft then
            self.m_FoldState = State_UnFolded
            DownPanelPos = self.m_fDownPanelLeft
            print("MainControl:UpdateFoldState" .. DownPanelPos)
            
            self:EndUnFoldButton()
        end
    end

    self.m_pDownPanel:setXPosition(CEGUI.UDim(0, DownPanelPos))

    self:CheckFoldStateWndVis()
end

function MainControl:CheckFoldStateWndVis()
    local switchBtnScreenLeft = self.m_pSwitchFoldBtn:GetScreenPos().x
    local switchBtnScreenTop = self.m_pSwitchFoldBtn:GetScreenPos().y

    if self.m_FoldState == State_UnFolding then
        for i = 0, self.m_iDownNum - 1 do
            if self.m_aDownWnd[i]:GetScreenPos().x < switchBtnScreenLeft then
                self.m_aDownWnd[i]:setVisible(true)
            end
        end
        for i = 0, self.m_iRightNum - 1 do
            if self.m_aRightWnd[i]:GetScreenPos().y < switchBtnScreenTop then
                self.m_aRightWnd[i]:setVisible(true)
            end
        end
    elseif self.m_FoldState == State_Folding then
        for i = 0, self.m_iDownNum - 1 do
            if self.m_aDownWnd[i]:GetScreenPos().x > switchBtnScreenLeft then
                self.m_aDownWnd[i]:setVisible(false)
            end
        end
        for i = 0, self.m_iRightNum - 1 do
            if self.m_aRightWnd[i]:GetScreenPos().y > switchBtnScreenTop then
                self.m_aRightWnd[i]:setVisible(false)
            end
        end
    end

end

function MainControl:EndFoldButton()
    LogInfo("maincontrol endfoldbutton")

    self.m_FoldState = State_Folded
    self.m_fFoldElapseTime = 0
    self.m_pDownPanel:SetAllChildrenVis(false)
    self.m_pDownPanel:setVisible(false)

    self.m_pDownPanel:setXPosition(CEGUI.UDim(0, self.m_fSwitchBtnLeft))
    self.m_pSwitchFoldBtn:setProperty("NormalImage", "set:mainui image:main_open")
    self.m_pSwitchFoldBtn:setProperty("HoverImage", "set:mainui image:main_open")
    self.m_pSwitchFoldBtn:setProperty("PushedImage", "set:mainui image:main_open")

    self.m_ShowSpeBtnState = State_Showing
    self.m_fShowSpecialBtnTime = 0
    self.m_pProductBtn:setVisible(self:IsBtnAlreadyExist(self.m_pProductBtn, 1))

    self.m_pDownPanel:setVisible(true)
    self.m_pRightPanel:setVisible(true)
end

function MainControl:EndUnFoldButton()
    LogInfo("maincontrol endunfoldbutton")

    self.m_FoldState = State_UnFolded
    self.m_fFoldElapseTime = 0
    self.m_fAutoHideTime = 0

    for i = 0, self.m_iDownNum - 1 do
        self.m_aDownWnd[i]:setVisible(true)
    end
    self.m_pDownPanel:setVisible(true)

    for i = 0, self.m_iRightNum - 1 do
        self.m_aRightWnd[i]:setVisible(true)
    end
    self.m_pRightPanel:setVisible(true)

    self.m_pDownPanel:setXPosition(CEGUI.UDim(0, self.m_fDownPanelLeft))
    self.m_pSwitchFoldBtn:setProperty("NormalImage", "set:mainui image:main_open")
    self.m_pSwitchFoldBtn:setProperty("HoverImage", "set:mainui image:main_open")
    self.m_pSwitchFoldBtn:setProperty("PushedImage", "set:mainui image:main_open")


    if self.m_pAddWnd then
        self:AddBtn(self.m_pAddWnd, self:GetInsertPos(self.m_pAddWnd), self:GetButtonPos(self.m_pAddWnd))
        self.m_pAddWnd = nil
    end

    if self.m_iAfterShowGuideId then
        NewRoleGuideManager.getInstance():StartGuide(self.m_iAfterShowGuideId)
        self.m_iAfterShowGuideId = nil
    end

    NotificationCenter.addObserver(Notifi_TeamApplicantChange, MainControl.TeamApplyChange)

end

-- 根据等级初始化按钿
function MainControl:InitBtnShowStat()
    LogInfo("maincontrol init btn showstat")
    self.m_iDownNum = 0
    self.m_iRightNum = 0
    
    local data = gGetDataManager():GetMainCharacterData()
	local curLevel = data:GetValue(1230)
    local beanTabel = BeanConfigManager.getInstance():GetTableByName("mission.cnewfunctionopen")

    --强化
    if curLevel >= beanTabel:getRecorder(11).needlevel then
        self.m_aDownWndSt[eProductPos].bUnlocked = true
    end

    --坐骑
    if curLevel >= beanTabel:getRecorder(8).needlevel then
        self.m_aDownWndSt[ePaiHangPos].bUnlocked = true
    end

    --技能
    if curLevel >= beanTabel:getRecorder(4).needlevel then
        self.m_aDownWndSt[eSkillPos].bUnlocked = true
    end

   --帮派
    if curLevel >= beanTabel:getRecorder(5).needlevel then
        self.m_aDownWndSt[eFriendPos].bUnlocked = true
    end
	
	--法宝
	if curLevel > beanTabel:getRecorder(11).needlevel then
        self.m_aDownWndSt[eTaskPos].bUnlocked = true
    end

    --助战
    if curLevel >= beanTabel:getRecorder(6).needlevel then
        self.m_aDownWndSt[eXiakePos].bUnlocked = true
    end

    for i = 0, eRightPosMax - 1 do
        if self.m_aRightWndSt[i].bUnlocked then
            self.m_aRightWnd[self.m_iRightNum] = self.m_aRightWndSt[i].pWnd
            self.m_iRightNum = self.m_iRightNum + 1
        end
    end

    for i = 0, eDownPosMax - 1 do
        if self.m_aDownWndSt[i].bUnlocked then
            self.m_aDownWnd[self.m_iDownNum] = self.m_aDownWndSt[i].pWnd
            self.m_iDownNum = self.m_iDownNum + 1
        end
    end

    local switchBtnPos = self.m_pSwitchFoldBtn:GetTopLeftPosOnParent()
    self.m_fSwitchBtnLeft = switchBtnPos.x
    self.m_fSwitchBtnTop = switchBtnPos.y
    self.m_fDownPanelLeft = self.m_fSwitchBtnLeft -(self.m_pSwitchFoldBtn:getPixelSize().width + 1) * self.m_iDownNum
    self.m_fRightPanelTop = self.m_fSwitchBtnTop -(self.m_pSwitchFoldBtn:getPixelSize().height + 1) * self.m_iRightNum

    for i = 0, self.m_iDownNum - 1 do
        self.m_aDownWnd[i]:setXPosition(CEGUI.UDim(0, i *(self.m_pSwitchFoldBtn:getPixelSize().width + 1)))
    end


end

-- 最终显示按钮位罿
function MainControl:ShowBtnFinish()
    LogInfo("maincontrol showbtn finish")
    self.m_pDownPanel:SetAllChildrenVis(false)

    local switchBtnPos = self.m_pSwitchFoldBtn:GetTopLeftPosOnParent()
    self.m_fSwitchBtnLeft = switchBtnPos.x
    self.m_fSwitchBtnTop = switchBtnPos.y

    self.m_fDownPanelLeft = self.m_fSwitchBtnLeft -(self.m_pSwitchFoldBtn:getPixelSize().width + 1) * self.m_iDownNum
    self.m_pDownPanel:setXPosition(CEGUI.UDim(0, self.m_fDownPanelLeft))
    for i = 0, self.m_iDownNum - 1 do
        self.m_aDownWnd[i]:setXPosition(CEGUI.UDim(0, i *(self.m_pSwitchFoldBtn:getPixelSize().width + 1)))
        self.m_aDownWnd[i]:setVisible(true)
    end

end

function MainControl:run(elapsed)
    if self.m_isSimplipy == 1 then
        return
    end
    local elapse = elapsed / 1000

    if self.m_AddState ~= State_NULL then
        self:UpdateAddBtn(elapse)
    end

    if self.m_FoldState == State_Folding or self.m_FoldState == State_UnFolding then
        self:UpdateFoldState(elapse)
    end

    if self.m_FoldState == State_Folded then
        if not self.m_pSystemBtn:isVisible() then
            self.m_pSystemBtn:setVisible(true)
        end
    else
        if self.m_pSystemBtn:isVisible() then
            self.m_pSystemBtn:setVisible(false)
        end
    end

    if self.m_FoldState == State_UnFolded and self.m_AddState == State_NULL then
        if NewRoleGuideManager.getInstance() then
            if NewRoleGuideManager.getInstance():NeedLockScreen() then
                self.m_fAutoHideTime = 0
            else
                self.m_fAutoHideTime = self.m_fAutoHideTime + elapse
                if self.m_fAutoHideTime > autoHideTime then
                    self:FoldButton()
                    self:PlaySwitchFoldBtnOpenClose(2)
                end
            end
        else
            self.m_fAutoHideTime = self.m_fAutoHideTime + elapse
            if self.m_fAutoHideTime > autoHideTime then
                self:FoldButton()
                self:PlaySwitchFoldBtnOpenClose(2)
            end
        end
    else
        self.m_fAutoHideTime = 0
    end

    self.refreshTipInfo()
end

function MainControl:UpdateAddBtn(elapse)
    if not self.m_fUnlockFlyTime then
        return
    end
    self.m_fUnlockFlyTime = self.m_fUnlockFlyTime + elapse
    if self.m_fUnlockFlyTime >= unlockFlyTime then
        self.m_fAddElapseTime = self.m_fAddElapseTime + elapse
    end

    if self.m_AddState == State_DownAdding then
        if self.m_fUnlockFlyTime < unlockFlyTime then
            self.m_aDownWnd[self.m_iAddPos]:setXPosition(CEGUI.UDim(0, self.m_pUnlockStartPos.x +(self.m_pUnlockEndPos.x - self.m_pUnlockStartPos.x) *(self.m_fUnlockFlyTime / unlockFlyTime) - self.m_aDownWnd[self.m_iAddPos]:getParent():GetScreenPos().x))
            self.m_aDownWnd[self.m_iAddPos]:setYPosition(CEGUI.UDim(0, self.m_pUnlockStartPos.y +(self.m_pUnlockEndPos.y - self.m_pUnlockStartPos.y) *(self.m_fUnlockFlyTime / unlockFlyTime) *(self.m_fUnlockFlyTime / unlockFlyTime) - self.m_aDownWnd[self.m_iAddPos]:getParent():GetScreenPos().y))
        else
            if self.m_fAddElapseTime >= totalAddTime then
                self:ShowBtnFinish()
                self.m_AddState = State_NULL
                self.m_pAddWnd = nil
                if not self.m_iGuideId then return end
                local record = BeanConfigManager.getInstance():GetTableByName("mission.carroweffect"):getRecorder(self.m_iGuideId)
                if record then
                    local winMgr = CEGUI.WindowManager:getSingleton()
                    local pWnd = winMgr:getWindow(record.button)
                    if pWnd then
                        local pEffect = gGetGameUIManager():AddUIEffect(pWnd, MHSD_UTILS.get_effectpath(10362), false)
                        if pEffect then
                            local notify = GameUImanager:createNotify(self.ChangeEffect)
                            pEffect:AddNotify(notify)
                        end
                    end
                end
            elseif self.m_fAddElapseTime <(totalAddTime - downTime) then
                self.m_aDownWnd[self.m_iAddPos]:setYPosition(CEGUI.UDim(0, self.m_pUnlockEndPos.y - self.m_aDownWnd[self.m_iAddPos]:getParent():GetScreenPos().y))
                self.m_pDownPanel:setXPosition(CEGUI.UDim(0, self.m_fDownPanelLeft -(self.m_fAddElapseTime /(totalAddTime - downTime)) * self.m_pSwitchFoldBtn:getPixelSize().width))
                for i = self.m_iAddPos, self.m_iDownNum - 1 do
				    self.m_aDownWnd[i]:setXPosition(CEGUI.UDim(0,(i - 1) *(self.m_pSwitchFoldBtn:getPixelSize().width + 1) +(self.m_fAddElapseTime /(totalAddTime - downTime)) * self.m_pSwitchFoldBtn:getPixelSize().width))				
                --    self.m_aDownWnd[i]:setXPosition(CEGUI.UDim(0,(i - 1) *(self.m_pSwitchFoldBtn:getPixelSize().width + 1) +(self.m_fAddElapseTime /(totalAddTime - downTime)) * self.m_pSwitchFoldBtn:getPixelSize().width))
				--	self.m_aDownWnd[self.m_iAddPos]:setYPosition(CEGUI.UDim(0, - self.m_pSwitchFoldBtn:getPixelSize().height +((self.m_fAddElapseTime - totalAddTime + downTime) / downTime) * self.m_pSwitchFoldBtn:getPixelSize().height))

                end
            elseif self.m_fAddElapseTime >(totalAddTime - downTime) and self.m_fAddElapseTime < totalAddTime then
                self.m_aDownWnd[self.m_iAddPos]:setYPosition(CEGUI.UDim(0, - self.m_pSwitchFoldBtn:getPixelSize().height +((self.m_fAddElapseTime - totalAddTime + downTime) / downTime) * self.m_pSwitchFoldBtn:getPixelSize().height))
            end
        end
    elseif self.m_AddState == State_RightAdding then
        if self.m_fUnlockFlyTime < unlockFlyTime then
            self.m_aRightWnd[self.m_iAddPos]:setXPosition(CEGUI.UDim(0, self.m_pUnlockStartPos.x +(self.m_pUnlockEndPos.x - self.m_pUnlockStartPos.x) *(self.m_fUnlockFlyTime / unlockFlyTime) - self.m_aRightWnd[self.m_iAddPos]:getParent():GetScreenPos().x))
            self.m_aRightWnd[self.m_iAddPos]:setYPosition(CEGUI.UDim(0, self.m_pUnlockStartPos.y +(self.m_pUnlockEndPos.y - self.m_pUnlockStartPos.y) *(self.m_fUnlockFlyTime / unlockFlyTime) *(self.m_fUnlockFlyTime / unlockFlyTime) - self.m_aRightWnd[self.m_iAddPos]:getParent():GetScreenPos().y))
        else
            if self.m_fAddElapseTime >= totalAddTime then
                self:ShowBtnFinish()
                self.m_AddState = State_NULL
                self.m_pAddWnd = nil
                if not self.m_iGuideId then return end
                local record = BeanConfigManager.getInstance():GetTableByName("mission.carroweffect"):getRecorder(self.m_iGuideId)
                if record then
                    local winMgr = CEGUI.WindowManager:getSingleton()
                    local pWnd = winMgr:getWindow(record.button)
                    if pWnd then
                        local pEffect = gGetGameUIManager:AddUIEffect(pWnd, MHSD_UTILS.get_effectpath(10362))
                        if pEffect then
                            local notify = GameUImanager:createNotify(self.ChangeEffect)
                            pEffect:AddNotify(notify)
                        end
                    end
                end
            elseif self.m_fAddElapseTime <(totalAddTime - downTime) then
                self.m_aRightWnd[self.m_iAddPos]:setXPosition(CEGUI.UDim(0, self.m_pUnlockEndPos.y - self.m_aRightWnd[self.m_iAddPos]:getParent():GetScreenPos().x))
                -- 			self.m_pRightPanel:setYPosition(CEGUI.UDim(0, self.m_fRightPanelTop - (self.m_fAddElapseTime / (totalAddTime - downTime)) * self.m_pSwitchFoldBtn:getPixelSize().height))
                for i = self.m_iAddPos, self.m_iRightNum - 1 do
                    self.m_aRightWnd[i]:setYPosition(CEGUI.UDim(0,(i - 1) *(self.m_pSwitchFoldBtn:getPixelSize().height + 1) +(self.m_fAddElapseTime /(totalAddTime - downTime)) * self.m_pSwitchFoldBtn:getPixelSize().height))
                end
            elseif self.m_fAddElapseTime >(totalAddTime - downTime) and self.m_fAddElapseTime < totalAddTime then
                self.m_aRightWnd[self.m_iAddPos]:setXPosition(CEGUI.UDim(0, - self.m_pSwitchFoldBtn:getPixelSize().width +((self.m_fAddElapseTime - totalAddTime + downTime) / downTime) * self.m_pSwitchFoldBtn:getPixelSize().width))
            end
        end
    end
end

-- 解锁添加一个按钿 flag :0加在下面＿加在右边,pos仿开姿
function MainControl:AddBtn(wnd, pos, flag)
    LogInfo("maincontrol addbtn")
    if self:IsBtnAlreadyExist(wnd, flag) then
        return
    end

    if flag == 0 then
        self.m_AddState = State_DownAdding
        self.m_fAddElapseTime = 0
        self.m_fUnlockFlyTime = 0
        wnd:setXPosition(CEGUI.UDim(0, self.m_pUnlockStartPos.x - wnd:getParent():GetScreenPos().x))
        wnd:setYPosition(CEGUI.UDim(0, self.m_pUnlockStartPos.y - wnd:getParent():GetScreenPos().y))
        wnd:setVisible(true)

        self.m_pUnlockEndPos.y = - self.m_pSwitchFoldBtn:getPixelSize().height + wnd:getParent():GetScreenPos().y
        if pos < 0 or pos > self.m_iDownNum then
            self.m_aDownWnd[self.m_iDownNum] = wnd
            self.m_iAddPos = self.m_iDownNum
            self.m_pUnlockEndPos.x =(self.m_iAddPos - 1) *(self.m_pSwitchFoldBtn:getPixelSize().width + 1) + wnd:getParent():GetScreenPos().x
            self.m_iDownNum = self.m_iDownNum + 1
        else
            for i = self.m_iDownNum, pos + 1, -1 do
                self.m_aDownWnd[i] = self.m_aDownWnd[i - 1]
            end
            self.m_aDownWnd[pos] = wnd
            self.m_iAddPos = pos
            self.m_iDownNum = self.m_iDownNum + 1
            if self.m_iAddPos == 0 then
                self:ShowBtnFinish()
                self.m_fAddElapseTime = totalAddTime - downTime
                self.m_pUnlockEndPos.x = self.m_iAddPos *(self.m_pSwitchFoldBtn:getPixelSize().width + 1) + wnd:getParent():GetScreenPos().x
            else
                self.m_pUnlockEndPos.x =(self.m_iAddPos - 1) *(self.m_pSwitchFoldBtn:getPixelSize().width + 1) + wnd:getParent():GetScreenPos().x
            end
        end
    elseif flag == 1 then
        self.m_AddState = State_RightAdding
        self.m_fAddElapseTime = 0
        wnd:setXPosition(CEGUI.UDim(0, self.m_pUnlockStartPos.x - wnd:getParent():GetScreenPos().x))
        wnd:setYPosition(CEGUI.UDim(0, self.m_pUnlockStartPos.y - wnd:getParent():GetScreenPos().y))
        wnd:setVisible(true)
        self.m_pUnlockEndPos.x = - self.m_pSwitchFoldBtn:getPixelSize().width + wnd:getParent():GetScreenPos().x
        if pos > 0 or pos > self.m_iRightNum then
            self.m_aRightWnd[self.m_iRightNum] = wnd
            self.m_iAddPos = self.m_iRightNum
            self.m_pUnlockEndPos.y =(self.m_iAddPos - 1) *(self.m_pSwitchFoldBtn:getPixelSize().height + 1) + wnd:getParent():GetScreenPos().y
            self.m_iRightNum = self.m_iRightNum + 1
        else
            for i = self.m_iRightNum, pos + 1, -1 do
                self.m_aRightWnd[i] = self.m_aRightWnd[i - 1]
            end
            self.m_aRightWnd[pos] = wnd
            self.m_iAddPos = pos
            self.m_iRightNum = self.m_iRightNum + 1
            if self.m_iAddPos == 0 then
                self:ShowBtnFinish()
                self.m_fAddElapseTime = totalAddTime - downTime
                self.m_pUnlockEndPos.y = self.m_iAddPos *(self.m_pSwitchFoldBtn:getPixelSize().height + 1) + wnd:getParent():GetScreenPos().y
            else
                self.m_pUnlockEndPos.y =(self.m_iAddPos - 1) *(self.m_pSwitchFoldBtn:getPixelSize().height + 1) + wnd:getParent():GetScreenPos().y
            end
        end
    end
end

function MainControl:IsBtnAlreadyExist(wnd, flag)
    LogInfo("maincontrol isbtn already exist")
    if flag == 0 then
        for i = 0, self.m_iDownNum - 1 do
            if wnd == self.m_aDownWnd[i] then
                return true
            end
        end
    elseif flag == 1 then
        for i = 0, self.m_iRightNum - 1 do
            if wnd == self.m_aRightWnd[i] then
                return true
            end
        end
    end
    return false
end

function MainControl:GuideBtn(guideId)
    LogInfo("maincontrol guide btn")
    self.m_iGuideId = guideId
    self:ShowUnlockDlg()

    if self.m_FoldState ~= State_UnFolded then
        self:EndFoldButton()
        self:EndShowSpecialBtn()
        self:UnFoldButton()
        self:PlaySwitchFoldBtnOpenClose(1)
    end
    self.m_AddState = State_StartUnLock
end

function MainControl:GetButtonPos(wnd)
    if wnd == self.m_pSkillBtn or wnd == self.m_pTaskBtn or wnd == self.m_pFriendBtn or wnd == self.m_pXiakeBtn or wnd == self.m_pPaihangBtn or wnd == self.m_pTeamBtn or wnd == self.m_pJewelryBtn then
        return 0
    elseif wnd == self.m_pPackBtn then
        return 1
    end
    return -1
end

function MainControl:GetInsertPos(wnd)
    LogInfo("maincontrol getinsert pos")
    local pos = 0
    if self:GetButtonPos(wnd) == 1 then
        for i = 0, eRightPosMax - 1 do
            if self.m_aRightWndSt[i].pWnd == wnd then
                break
            end
            if self.m_aRightWndSt[i].bUnlocked then
                pos = pos + 1
            end
        end
        return pos
    elseif self:GetButtonPos(wnd) == 0 then
        for i = 0, eDownPosMax - 1 do
            if self.m_aDownWndSt[i].pWnd == wnd then
                break
            end
            if self.m_aDownWndSt[i].bUnlocked then
                pos = pos + 1
            end
        end
        return pos
    end
    return 0
end

function MainControl:EndShowSpecialBtn()
    self.m_pDownPanel:SetAllChildrenVis(false)

    self.m_pDownPanel:setXPosition(CEGUI.UDim(0, self.m_fSwitchBtnLeft))

    self.m_pProductBtn:setXPosition(CEGUI.UDim(0, 0))
    self.m_pProductBtn:setVisible(self:IsBtnAlreadyExist(self.m_pProductBtn, 1))


    self.m_pDownPanel:setVisible(true)
    self.m_pRightPanel:setVisible(true)

    self.m_ShowSpeBtnState = State_Show
    self.m_fShowSpecialBtnTime = 0
end

function MainControl:EndHideSpecialBtn()
    self.m_pProductBtn:setVisible(false)
    -- self.m_pPackBtn:setVisible(false)
    self.m_ShowSpeBtnState = State_Hide
    self.m_fShowSpecialBtnTime = 0

    self:InitBtnShowStat()
    self.m_FoldState = State_UnFolding
    self.m_fFoldElapseTime = 0
end

function MainControl:UpdateSpeBtnShow(elapse)
    LogInfo("maincontrol updatespecbtn show")

    self.m_fShowSpecialBtnTime = self.m_fShowSpecialBtnTime + elapse
    print(self.m_fShowSpecialBtnTime)
    if self.m_ShowSpeBtnState == State_Showing then
        if self.m_fShowSpecialBtnTime > showSpeTime then
            self:EndShowSpecialBtn()
        else
            self.m_pProductBtn:setXPosition(CEGUI.UDim(0,(1 -(self.m_fShowSpecialBtnTime / showSpeTime)) * self.m_pSwitchFoldBtn:getPixelSize().width))
        end
    elseif self.m_ShowSpeBtnState == State_Hiding then
        if self.m_fShowSpecialBtnTime > showSpeTime then
            self:EndHideSpecialBtn()
        else
            self.m_pProductBtn:setXPosition(CEGUI.UDim(0,(self.m_fShowSpecialBtnTime / showSpeTime) * self.m_pSwitchFoldBtn:getPixelSize().width))
        end
    end
    self:CheckFoldStateWndVis()
end

function MainControl:ShowBtnByGuide()
    if self.m_iGuideId then
        return
    end
    self:InitBtnShowStat()
    if self.m_FoldState == State_Folded or self.m_FoldState == State_Folding then
        --这个是固定值， 不妥
        self:EndShowSpecialBtn()
    else
        --self:EndUnFoldButton()
        
        -- local presentFoldState = self.m_FoldState
        -- self:UnFoldButton()
        -- --防止一直播放
        -- if ( presentFoldState == State_Folded or presentFoldState == State_Folding  ) then
        --     self:PlaySwitchFoldBtnOpenClose(1)
        -- end
        
    end
end

function MainControl:IsInMainControl(pWnd)
    if pWnd == self.m_pSkillBtn or pWnd == self.m_pFriendBtn or pWnd == self.m_pXiakeBtn or pWnd == self.m_pProductBtn or pWnd == self.m_pTeamBtn or pWnd == self.m_pPaihangBtn or pWnd == self.m_pPackBtn or pWnd == self.m_pTaskBtn or pWnd == self.m_pJewelryBtn then
        return true
    end
    return false
end

function MainControl:ShowUnlockDlg()
    
end

function MainControl:StartUnlock(x, y)
    if not self.m_iGuideId then return end
    local record = BeanConfigManager.getInstance():GetTableByName("mission.carroweffect"):getRecorder(self.m_iGuideId)
    if not record then return end
    local winMgr = CEGUI.WindowManager:getSingleton()
    local pWnd = winMgr:getWindow(record.button)
    self.m_pUnlockStartPos.x = x
    self.m_pUnlockStartPos.y = y
    if self.m_FoldState ~= State_UnFolded then
        self.m_pAddWnd = pWnd
        return
    end
    self:AddBtn(pWnd, self:GetInsertPos(pWnd), self:GetButtonPos(pWnd));
end

function MainControl.ChangeEffect()
    if not _instance then
        return
    end
    if not _instance.m_iGuideId then return end
    local record = BeanConfigManager.getInstance():GetTableByName("mission.carroweffect"):getRecorder(_instance.m_iGuideId)
    if not record then return end
    if _instance.m_iGuideId == 30025 then
        gGetNetConnection():send(fire.pb.xiake.COpenXiakeJiuguan())
    end
    if record.cleareffect == 1 then
        local winMgr = CEGUI.WindowManager:getSingleton()
        local pWnd = winMgr:getWindow(record.button)
        gGetGameUIManager():RemoveUIEffect(pWnd)
        gGetGameUIManager():AddUIEffect(pWnd, MHSD_UTILS.get_effectpath(10305))
        pWnd:SetGuideState(true)
        pWnd:removeEvent("GuideEnd")
        pWnd:subscribeEvent("GuideEnd", MainControl.HandleUnLockGuideEnd, _instance)
    end

    if record.step ~= 0 then
        NewRoleGuideManager.getInstance():StartGuide(record.step)
    end
    _instance.m_iGuideId = nil
end

function MainControl:HandleUnLockGuideEnd(args)
    LogInfo("maincontrol handle unlock guide end")
    local wndArgs = CEGUI.toWindowEventArgs(args)
    if wndArgs.window then
        gGetGameUIManager():RemoveUIEffect(wndArgs.window)
    end
    return true
end

-- 引导需要显示所有按钮
function MainControl:ShowAllBtns(guideId)
    local SettingEnum = require "protodef.rpcgen.fire.pb.sysconfigtype":new()
    local record = GameTable.SysConfig.GetCGameconfigTableInstance():getRecorder(SettingEnum.framesimplify)
    if record.id ~= -1 then
        local strKey = record.key
        local value = gGetGameConfigManager():GetConfigValue(strKey)
        if value == 0 then 
            if self.m_FoldState ~= State_UnFolded and self.m_FoldState ~= State_UnFolding then
                self:EndFoldButton()
                self:EndShowSpecialBtn()
                self:UnFoldButton()
            end
            self.m_iAfterShowGuideId = guideId
        end
    end
end

function MainControl:IsBtnShown(pWnd)
    return self:IsBtnAlreadyExist(pWnd, self:GetButtonPos(pWnd))
end

function MainControl:refreshTipInfo()
    -- print("____MainControl:refreshTipInfo")
    --显示红点公会
    if  _instance  then 
        local datamanager = require "logic.faction.factiondatamanager"
        if datamanager then
            if datamanager.bonus > 0 or  ( datamanager.m_FactionTips and datamanager.m_FactionTips[1]>0 )  then
                _instance.m_mTipNum[eMaincontrolFactionTip] = 1
                _instance:setSimplify(13, 1)
            else
                _instance.m_mTipNum[eMaincontrolFactionTip] = 0
            end
        else
             _instance.m_mTipNum[eMaincontrolFactionTip] = 0
        end
    end 

    local num = 0
    for i = eMaincontrolTipStart, eMaincontrolTipMax - 1 do
        if _instance.m_mTipWnd[i] then
            if _instance.m_mTipNum[i] > 0 then
                _instance.m_mTipWnd[i]:setVisible(true)
                num = num + 1
            else
                _instance.m_mTipWnd[i]:setVisible(false)
            end
        end
    end
    if num > 0 then
        _instance.m_pSwitchTipWnd:setVisible(true)
    else
        _instance.m_pSwitchTipWnd:setVisible(false)
    end
end

function MainControl.setTeamTip(num)
    if _instance then
        _instance.m_mTipNum[eMaincontrolTeamTip] = num
        _instance:refreshTipInfo();
    end
end

function MainControl:HandleJewelryBtnClicked(args)
    LogInfo("MainControl HandleJewelryBtnClicked")
end

function MainControl:HandleAnimationOver()
    self.m_aniopen:stop()
    self.m_aniclose:stop()
end

function MainControl:PlaySwitchFoldBtnOpenClose(playState)
    local aniMan = CEGUI.AnimationManager:getSingleton()

    if playState == 1 then
        print("MainControl:PlaySwitchFoldBtnOpenClose playState == 1")
        self.m_aniclose:pause()
        local pos = self.m_aniclose:getPosition()

        self.m_aniopen:setPosition(GUnFoldEffectTime - pos)
        self.m_aniopen:unpause()

    else
        print("MainControl:PlaySwitchFoldBtnOpenClose playState == 2")
        self.m_aniopen:pause()
        local pos = self.m_aniopen:getPosition()
        self.m_aniclose:setPosition(GUnFoldEffectTime - pos)
        self.m_aniclose:unpause()
    end


end

function MainControl:getBtnScreenPos(btindex)
    local screenPos = self.m_pSwitchFoldBtn:GetScreenPosOfCenter()

    local wnd = self.m_aDownWndSt[btindex].pWnd
    local pos = self:GetInsertPos(wnd) --只考虑下排按钮的位置
    
    screenPos.x = screenPos.x - (self.m_iDownNum + 1 - pos) *(self.m_pSwitchFoldBtn:getPixelSize().width + 1)
    return screenPos
end

function MainControl:checkBtnShow()
    self.m_iDownNum = 0

    local data = gGetDataManager():GetMainCharacterData()
	local curLevel = data:GetValue(1230)
    local beanTabel = BeanConfigManager.getInstance():GetTableByName("mission.cnewfunctionopen")

    --强化
    if curLevel > beanTabel:getRecorder(11).needlevel then
        self.m_aDownWndSt[eProductPos].bUnlocked = true
    end

    --法宝
    if curLevel > beanTabel:getRecorder(11).needlevel then
        self.m_aDownWndSt[eTaskPos].bUnlocked = true
    end
	
    --坐骑
    if curLevel > beanTabel:getRecorder(8).needlevel then
        self.m_aDownWndSt[ePaiHangPos].bUnlocked = true
    end

    --技能
    if curLevel > beanTabel:getRecorder(4).needlevel then
        self.m_aDownWndSt[eSkillPos].bUnlocked = true
    end

   --帮派
    if curLevel > beanTabel:getRecorder(5).needlevel then
        self.m_aDownWndSt[eFriendPos].bUnlocked = true
    end

    --器灵
    if curLevel > beanTabel:getRecorder(6).needlevel then
        self.m_aDownWndSt[eXiakePos].bUnlocked = true
    end

    for i = 0, eDownPosMax - 1 do
        if self.m_aDownWndSt[i].bUnlocked then
            self.m_aDownWnd[self.m_iDownNum] = self.m_aDownWndSt[i].pWnd
            self.m_iDownNum = self.m_iDownNum + 1
        end
    end

    self:resetBtnPos()
end

function MainControl:resetBtnPos()
    local switchBtnPos = self.m_pSwitchFoldBtn:GetTopLeftPosOnParent()
    self.m_fSwitchBtnLeft = switchBtnPos.x
    self.m_fSwitchBtnTop = switchBtnPos.y

    self.m_fDownPanelLeft = self.m_fSwitchBtnLeft -(self.m_pSwitchFoldBtn:getPixelSize().width + 1) * self.m_iDownNum
    self.m_pDownPanel:setXPosition(CEGUI.UDim(0, self.m_fDownPanelLeft))
    for i = 0, self.m_iDownNum - 1 do
        self.m_aDownWnd[i]:setXPosition(CEGUI.UDim(0, i *(self.m_pSwitchFoldBtn:getPixelSize().width + 1)))
        if not self.m_aDownWnd[i]:isVisible() and self.m_FoldState == State_UnFolded or self.m_FoldState == State_UnFolding then
            self.m_aDownWnd[i]:setVisible(true)
        end
    end
end

function MainControl:addBtnResetPos(btnIndex)

    if self.m_FoldState ~= State_UnFolded then
        self:EndFoldButton()
        self:EndShowSpecialBtn()
        self:UnFoldButton()
        self:PlaySwitchFoldBtnOpenClose(1)
    end
    
    local wnd = self.m_aDownWndSt[btnIndex].pWnd
    if self.m_aDownWndSt[btnIndex].bUnlocked then
        return
    end

    self.m_aDownWndSt[btnIndex].bUnlocked = true
    local pos = self:GetInsertPos(wnd)

    if pos < 0 or pos > self.m_iDownNum then
        self.m_aDownWnd[self.m_iDownNum] = wnd
        self.m_iDownNum = self.m_iDownNum + 1
    else
        for i = self.m_iDownNum, pos + 1, -1 do
            self.m_aDownWnd[i] = self.m_aDownWnd[i - 1]
        end
        self.m_aDownWnd[pos] = wnd
        self.m_iDownNum = self.m_iDownNum + 1
        self:ShowBtnFinish()
    end
end

function MainControl:setBtnOpenStatus(id, status)
    local bOpened = false
    if status == 1 then
        bOpened = true
    end

    local data = gGetDataManager():GetMainCharacterData()
	local curLevel = data:GetValue(1230)
    local beanTabel = BeanConfigManager.getInstance():GetTableByName("mission.cnewfunctionopen")

    --如果等级达到， 这里未开启也进行开启
    if id == 25 then
        if self.m_aDownWndSt[eSkillPos].bUnlocked  then return end  --如果已经是开启状态 不向下执行

        if curLevel >= beanTabel:getRecorder(4).needlevel or bOpened then
            self.m_aDownWndSt[eSkillPos].bUnlocked = true
        else 
            self.m_aDownWndSt[eSkillPos].bUnlocked = false
        end
    elseif id == 26 then
        if self.m_aDownWndSt[eFriendPos].bUnlocked  then return end

        if curLevel >= beanTabel:getRecorder(5).needlevel or bOpened then
            self.m_aDownWndSt[eFriendPos].bUnlocked = true
        else
            self.m_aDownWndSt[eFriendPos].bUnlocked = false
        end
    elseif id == 28 then
         if self.m_aDownWndSt[eXiakePos].bUnlocked  then return end

        if curLevel >= beanTabel:getRecorder(6).needlevel or bOpened then
            self.m_aDownWndSt[eXiakePos].bUnlocked = true
        else
            self.m_aDownWndSt[eXiakePos].bUnlocked = false
        end
    elseif id == 27 then
        XinGongNengOpenDLG.setPetOpen(status)

        local dlg = require  "logic.petandusericon.userandpeticon".getInstanceNotCreate()
        if dlg then
            dlg:UpdateBattlePetState()
        end
    end

    self.m_iDownNum = 0

    for i = 0, eDownPosMax - 1 do
        if self.m_aDownWndSt[i].bUnlocked then
            self.m_aDownWnd[self.m_iDownNum] = self.m_aDownWndSt[i].pWnd
            self.m_iDownNum = self.m_iDownNum + 1
        end
    end

    self:resetBtnPos()
end

function MainControl:isCurrentBtnShown(wnd)
    if wnd == self.m_aDownWndSt[ePaiHangPos].pWnd then  --坐骑
        if self.m_aDownWndSt[ePaiHangPos].bUnlocked then
            return true
        else
            return false
        end
    end


    if wnd == self.m_aDownWndSt[eSkillPos].pWnd then  --技能
        if self.m_aDownWndSt[eSkillPos].bUnlocked then
            return true
        else
            return false
        end
    end

    if wnd == self.m_aDownWndSt[eFriendPos].pWnd then --帮派
        if self.m_aDownWndSt[eFriendPos].bUnlocked then
            return true
        else
            return false
        end
    end

    if wnd == self.m_aDownWndSt[eXiakePos].pWnd then --器灵
        if self.m_aDownWndSt[eXiakePos].bUnlocked then
            return true
        else
            return false
        end
    end
	
	if wnd == self.m_aDownWndSt[eTaskPos].pWnd then --法宝
        if self.m_aDownWndSt[eTaskPos].bUnlocked then
            return true
        else
            return false
        end
    end

   if wnd == self.m_aDownWndSt[eProductPos].pWnd then --强化
        if self.m_aDownWndSt[eProductPos].bUnlocked then
            return true
        else
            return false
        end
    end

    return false
end

return MainControl
