require "logic.dialog"
require "utils.mhsdutils"
require "protodef.fire.pb.item.cgetroleinfo"
require "logic.team.teaminvitedlg"

TeamMemberMenu = {}
setmetatable(TeamMemberMenu, Dialog)
TeamMemberMenu.__index = TeamMemberMenu

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function TeamMemberMenu.getInstance()
    LogInfo("enter get TeamMemberMenu instance")
    if not _instance then
        _instance = TeamMemberMenu:new()
        _instance:OnCreate()
    end

    return _instance
end

function TeamMemberMenu.getInstanceAndShow()
    LogInfo("enter TeamMemberMenu instance show")
    if not _instance then
        _instance = TeamMemberMenu:new()
        _instance:OnCreate()
    else
        LogInfo("set TeamMemberMenu visible")
        _instance:SetVisible(true)
    end

    return _instance
end

function TeamMemberMenu.getInstanceNotCreate()
    return _instance
end

function TeamMemberMenu.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function TeamMemberMenu.ToggleOpenClose()
    if not _instance then
        _instance = TeamMemberMenu:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function TeamMemberMenu:SetVisible(b)
    Dialog.SetVisible(self, b)
    if not b then
        self.triggerWnd = nil
    end
end
----/////////////////////////////////////////------

function TeamMemberMenu.GetLayoutFileName()
    return "teaminter.layout"
end

function TeamMemberMenu:OnCreate()
    LogInfo("TeamMemberMenu oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pButton = {}
    for i = 0, 6 do
        self.m_pButton[i] = CEGUI.Window.toPushButton(winMgr:getWindow("teaminter/" .. tostring(i)))
        self.m_pButton[i]:setVisible(false)
    end

    self.btnHeight = self.m_pButton[0]:getHeight()

    LogInfo("TeamMemberMenu oncreate end")
end

------------------- private: -----------------------------------


function TeamMemberMenu:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, TeamMemberMenu)
    self.TYPE = {
        TEAMLIST 		            = 0,	--队伍界面菜单
        MAINUI_SELF                 = 1,    --主界面点自己
        MAINUI_LEADER_SEE_MEMBER    = 2,    --主界面队长点队员
        MAINUI_MEMBER_SEE_MEMBER    = 3,    --主界面队员点队员
		INVITE			            = 4,	--邀请入队
		ORDER			            = 5		--委任指挥
    }
    return self
end

function TeamMemberMenu:getSelectedIdx()
    return self.m_iCurSelectMember
end

function TeamMemberMenu:InitBtn(state, idx)

    self.m_iCurSelectMember = idx

    for i = 0, 6 do
        self.m_pButton[i]:removeEvent("Clicked")
        self.m_pButton[i]:setVisible(false)
    end

    local isLeader = GetTeamManager():IsMyselfLeader()

    --队伍界面菜单
    if state == self.TYPE.TEAMLIST then	--team member menu
        self:setButtonCount(7)

        for i = 0, 6 do
            self.m_pButton[i]:setVisible(true)
            if i == 0 or i == 1 then
                self.m_pButton[i]:setEnabled(true)
            else
                self.m_pButton[i]:setEnabled(isLeader)
            end
        end
        self.m_pButton[5]:setEnabled(true)
        self:setButtonText(0, 10005)		--发送消息
		self:setButtonText(1, 10006)		--添加好友
		self:setButtonText(2, 10007)		--升为队长
		self:setButtonText(3, 10008)		--调整站位
		self:setButtonText(4, 10009)		--请离队伍
        self:setButtonText(5, 11375)		--查看装备
        
        local tLID = GetTeamManager():GetTeamLeader().id
        local tOID = GetTeamManager():getTeamOrder()
        local mID = GetTeamManager():GetMember(idx).id

        if tOID == 0 or tOID ~= mID then
            self:setButtonText(6, 11627)		--委任指挥
        else
            self:setButtonText(6, 11628)		--取消指挥
        end

        self:setButtonFunc(0, self.HandleSendMsgBtnClicked)
        self:setButtonFunc(1, self.HandleAddFriendBtnClicked)
        if isLeader then
            self:setButtonFunc(2, self.HandleSetLeaderBtnClicked)
            self:setButtonFunc(3, self.HandleChangePosBtnClicked)
            self:setButtonFunc(4, self.HandleExpelBtnClicked)            
            if tOID == 0 or tOID ~= mID then
		        self:setButtonFunc(6, self.HandleSetOrder)
            else
		        self:setButtonFunc(6, self.HandleCancelOrder)
            end
        end
        self:setButtonFunc(5, self.HandleViewEquipBtnClicked)

    --主界面队长点队员
    elseif state == self.TYPE.MAINUI_LEADER_SEE_MEMBER then
        self:setButtonCount(5)

        self.m_pButton[0]:setVisible(true)
        self.m_pButton[1]:setVisible(true)
        self.m_pButton[2]:setVisible(true)
        self.m_pButton[3]:setVisible(true)
        self.m_pButton[4]:setVisible(true)

        local memberInfo = GetTeamManager():GetMember(idx)
		if memberInfo and memberInfo.eMemberState == eTeamMemberAbsent then
			self:setButtonText(0, 10016)	--召回队员
			self:setButtonFunc(0, self.HandleCallbackBtnClicked)
		else
			self:setButtonText(0, 10007)	--升为队长
			self:setButtonFunc(0, self.HandleSetLeaderBtnClicked)
		end
		self:setButtonText(1, 10009)		--请离队伍
        self:setButtonText(2, 10005)		--发送消息
		self:setButtonText(3, 10006)		--添加好友
        self:setButtonText(4, 11375)		--查看装备

        self:setButtonFunc(1, self.HandleExpelBtnClicked)
        self:setButtonFunc(2, self.HandleSendMsgBtnClicked)
        self:setButtonFunc(3, self.HandleAddFriendBtnClicked)
        self:setButtonFunc(4, self.HandleViewEquipBtnClicked)
        

    --主界面队员点队员
    elseif state == self.TYPE.MAINUI_MEMBER_SEE_MEMBER then
        self:setButtonCount(3)

        self.m_pButton[0]:setVisible(true)
        self.m_pButton[1]:setVisible(true)
        self.m_pButton[2]:setVisible(true)

        self:setButtonText(0, 10005)		--发送消息
		self:setButtonText(1, 10006)		--添加好友
        self:setButtonText(2, 11375)		--查看装备

        self:setButtonFunc(0, self.HandleSendMsgBtnClicked)
        self:setButtonFunc(1, self.HandleAddFriendBtnClicked)
        self:setButtonFunc(2, self.HandleViewEquipBtnClicked)
        

    --主界面点自己
    elseif state == self.TYPE.MAINUI_SELF then
        self:setButtonCount(3)

        self.m_pButton[0]:setVisible(true)
        self.m_pButton[1]:setVisible(true)
        self.m_pButton[2]:setVisible(true)

        if GetTeamManager():GetMemberSelf().eMemberState == eTeamMemberAbsent then
			self:setButtonText(0, 2680)			--回归队伍
			self:setButtonFunc(0, self.HandleBackBtnClicked)
		else
			self:setButtonText(0, 2681)			--暂离队伍
			self:setButtonFunc(0, self.HandleAbsentBtnClicked)
		end
		
		self:setButtonText(1, 2679)			--退出队伍		
        self:setButtonFunc(1, self.HandleQuitTeamBtnClicked)
        
        self:setButtonText(2, 11800)         --申请队长      
        self:setButtonFunc(2, self.HandleGetLeaderBtnClicked)

    --邀请入队
    elseif state == self.TYPE.INVITE then
        self:setButtonCount(2)

        self.m_pButton[0]:setVisible(true)
        self.m_pButton[1]:setVisible(true)

        self.m_pButton[0]:setEnabled(true)
        self.m_pButton[1]:setEnabled(true)

        self:setButtonText(0, 10010)		--邀请好友
		self:setButtonText(1, 10011)		--邀请帮会成员

		self:setButtonFunc(0, self.HandleInviteFriendBtnClicked)
        self:setButtonFunc(1, self.HandleInviteGangMemberBtnClicked)
        
    --委任指挥
    elseif state == self.TYPE.ORDER then
        self:setButtonCount(2)

        self.m_pButton[0]:setVisible(true)
        self.m_pButton[1]:setVisible(true)

        self.m_pButton[0]:setEnabled(true)
        self.m_pButton[1]:setEnabled(true)

        self:setButtonText(0, 11627)		--委任指挥
		self:setButtonFunc(0, self.HandleSetOrderBtnClicked)
		self:setButtonText(1, 11630)		--编辑指令
        self:setButtonFunc(1, self.HandleEditOrderBtnClicked)
    end
end

function TeamMemberMenu:setButtonText(btnIdx, strId)
    self.m_pButton[btnIdx]:setText(MHSD_UTILS.get_resstring(strId))
end

function TeamMemberMenu:setButtonFunc(btnIdx, callfunc)
    self.m_pButton[btnIdx]:subscribeEvent("Clicked", callfunc, self)
end

function TeamMemberMenu:setButtonCount(count)
    local h = self.btnHeight
    local newh = CEGUI.UDim(h.scale, (h.offset) * count)
    self:GetWindow():setHeight(newh + CEGUI.UDim(0, 0 - (count- 1) * 0 + 15))
end

function TeamMemberMenu:setTriggerWnd(wnd)
    -- 触发菜单弹出的窗口
    self.triggerWnd = wnd
end

function TeamMemberMenu:getTriggerWnd()
    return self.triggerWnd
end

-- 返回true表示菜单已被wnd触发显示
function TeamMemberMenu.checkTriggerWnd(wnd)
    if _instance and _instance:IsVisible() and _instance:getTriggerWnd() == wnd then
        _instance:SetVisible(false)
        _instance:setTriggerWnd(nil)
        return true
    end
    return false
end

function TeamMemberMenu:HandleCallbackBtnClicked(args)
    LogInfo("TeamMemberMenu handle callback btn clicked")
    local memberId = GetTeamManager():GetMember(self.m_iCurSelectMember).id
    GetTeamManager():RequestCallbackMember(memberId)
    self:SetVisible(false)
    return true
end

-- 升为队长
function TeamMemberMenu:HandleSetLeaderBtnClicked(args)
    LogInfo("TeamMemberMenu handle setleader btn clicked")
    GetTeamManager():RequestSetLeader(self.m_iCurSelectMember)
    self:SetVisible(false)
    return true
end
-- 申请队长
function TeamMemberMenu:HandleGetLeaderBtnClicked(args)
    LogInfo("TeamMemberMenu handle setleader btn clicked")
    GetTeamManager():RequestGetLeader(self.m_iCurSelectMember)
    self:SetVisible(false)
    return true
end
-- 请离队伍
function TeamMemberMenu:HandleExpelBtnClicked(args)
    LogInfo("TeamMemberMenu handle expel btn clicked")
    GetTeamManager():RequestExpelMember(self.m_iCurSelectMember)
    self:SetVisible(false)
    return true
end

function TeamMemberMenu:HandleDismissTeamBtnClicked(args)
    LogInfo("TeamMemberMenu handle dismiss btn clicked")
    if GetTeamManager():IsOnTeam() and GetTeamManager():IsMyselfLeader() then
        if GetBattleManager():IsInBattle() then
            if GetChatManager() then
                GetChatManager():AddTipsMsg(141363)  	--战斗中不能进行此项操作
            end
        else
            GetTeamManager():RequestDismissTeam()
        end
    end
    self:SetVisible(false);
    return true;
end

function TeamMemberMenu:HandleQuitTeamBtnClicked(args)
    LogInfo("TeamMemberMenu handle quit btn clicked")
    GetTeamManager():RequestQuitTeam()
    self:SetVisible(false)
    return true
end

-- 暂离队伍
function TeamMemberMenu:HandleAbsentBtnClicked(args)
    LogInfo("TeamMemberMenu handle absent btn clicked")
    GetTeamManager():RequestAbsentReturnTeam(true)
    self:SetVisible(false)
    return true
end

function TeamMemberMenu:HandleBackBtnClicked(args)
    LogInfo("TeamMemberMenu handle back btn clicked")
    GetTeamManager():RequestAbsentReturnTeam(false)
    self:SetVisible(false)
    return true
end
function TeamMemberMenu:HandleViewEquipBtnClicked(args)
	if not GetTeamManager() or not GetTeamManager():GetMember(self.m_iCurSelectMember) then
		return
	end
    local id = GetTeamManager():GetMember(self.m_iCurSelectMember).id
    local send = require "protodef.fire.pb.item.cgetroleequip":new()
    send.roleid = id
    send.sendmsg = 0
    require "manager.luaprotocolmanager":send(send)
    self:SetVisible(false)
end
function TeamMemberMenu:HandleSetOrder(args)
    local id = GetTeamManager():GetMember(self.m_iCurSelectMember).id
    local send = require "protodef.fire.pb.battle.battleflag.csetcommander":new()
    send.roleid = id
    send.opttype = 0
    require "manager.luaprotocolmanager":send(send)
    self:SetVisible(false)

    GetTeamManager():setTeamOrder(id)
    local dlg = TeamDialogNew.getInstanceNotCreate()
    if dlg then
        dlg:refreshContainer(dlg.showType)
    end
end
function TeamMemberMenu:HandleCancelOrder(args)
    local id = GetTeamManager():GetMember(self.m_iCurSelectMember).id
    local send = require "protodef.fire.pb.battle.battleflag.csetcommander":new()
    send.roleid = GetTeamManager():GetTeamLeader().id
    send.opttype = 1
    require "manager.luaprotocolmanager":send(send)
    self:SetVisible(false)

    GetTeamManager():setTeamOrder(0)
    local dlg = TeamDialogNew.getInstanceNotCreate()
    if dlg then
        dlg:refreshContainer(dlg.showType)
    end
end
-- 添加好友
function TeamMemberMenu:HandleAddFriendBtnClicked(args)
    LogInfo("TeamMemberMenu handle addfriend btn clicked")
    gGetFriendsManager():RequestAddFriend(GetTeamManager():GetMember(self.m_iCurSelectMember).id)
    self:SetVisible(false)
    return true
end

function TeamMemberMenu:HandleViewBtnClicked(args)
    LogInfo("TeamMemberMenu handle view btn clicked")
    local getOtherRoleInfo = CGetRoleInfo.Create()
    getOtherRoleInfo.roleid = GetTeamManager():GetMember(self.m_iCurSelectMember).id
    LuaProtocolManager.getInstance():send(getOtherRoleInfo)
    self:SetVisible(false)
    return true
end

-- 发送消息
function TeamMemberMenu:HandleSendMsgBtnClicked(args)
    gGetFriendsManager():RequestSetChatRoleID(GetTeamManager():GetMember(self.m_iCurSelectMember).id)
    self:SetVisible(false)
    return true
end

-- 调整站位
function TeamMemberMenu:HandleChangePosBtnClicked(args)
    if TeamDialogNew.getInstanceNotCreate() then
        TeamDialogNew.getInstanceNotCreate():readyToChangeMemberPos()
    end
    self:SetVisible(false)
    return true
end

-- 邀请好友
function TeamMemberMenu:HandleInviteFriendBtnClicked(args)
    local dlg = TeamInviteDlg.getInstanceAndShow()
    dlg:setType(dlg.TYPE.FRIEND)
    self:SetVisible(false)
    return true
end

-- 邀请帮会成员
function TeamMemberMenu:HandleInviteGangMemberBtnClicked(args)
    if not require("logic.faction.factiondatamanager"):IsHasFaction() then
        GetCTipsManager():AddMessageTipById(150027) --你没有加入公会
        return
    end
    local dlg = TeamInviteDlg.getInstanceAndShow()
    dlg:setType(dlg.TYPE.GONGHUI)
    self:SetVisible(false)
    return true
end

-- 委任指挥
function TeamMemberMenu:HandleSetOrderBtnClicked(args)
    if TeamDialogNew.getInstanceNotCreate() then
        TeamDialogNew.getInstanceNotCreate():readyToChangeOrder()
    end
    self:SetVisible(false)
    return true
end
-- 编辑指令
function TeamMemberMenu:HandleEditOrderBtnClicked(args)
    
    OrderEditorDlg.getInstanceAndShow()
    self:SetVisible(false)
    return true
end


return TeamMemberMenu
