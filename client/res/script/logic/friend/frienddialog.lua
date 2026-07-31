require "logic.dialog"
require "logic.friend.frienddialogrecent"
require "logic.friend.frienddialogcontact"
require "logic.friend.frienddialogmail"
require "logic.friend.frienddialogchatoutput"
require "logic.friend.frienddialogmailcontent"
require "logic.contactroledlg"
require "utils.mhsdutils"
require "logic.friendadddialog"
require "utils.bit"
require "system.maillistmanager"
require "logic.friend.Accqunliao"

FriendDialog = {
    m_nBlackDisplaySize = 8,
    m_nRecentDisplaySize = 8,
    m_nFriendDisplaySize = 8,
    m_vRecentDataList = { },
    m_vRecentCellList = { },
    m_vFriendDataList = { },
    m_vFriendCellList = { },
    m_vBlackDataList = { },
    m_vBlackCellList = { },
    m_vEnemyList = { },
    m_ChatRoleID = 0,
}

local CHAT_STR_SAVED = ""

setmetatable(FriendDialog, Dialog)
FriendDialog.__index = FriendDialog

local _instance;
function FriendDialog.getInstance()
    if not _instance then
        _instance = FriendDialog:new()
        _instance:OnCreate()
    end
    return _instance
end

function FriendDialog.getInstanceNotCreate()
    return _instance
end

function FriendDialog.getInstanceAndShow()
    if not _instance then
        _instance = FriendDialog:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
        _instance.m_pMainFrame:setAlpha(1)
    end

    return _instance
end

function FriendDialog.DestroyDialog()
    if _instance then
	_instance.m_SendChatBtn.animation:stop()
	_instance.m_TalkBtn.animation:stop()
	_instance.m_EmotionBtn.animation:stop()
	_instance.m_RelationCleanBtn.animation:stop()
	_instance.m_sendgift.animation:stop()
	_instance.m_AddFriendBtn.animation:stop()
	_instance.m_MySpaceBtn.animation:stop()
	_instance.cc_kefuBtn.animation:stop()
	_instance.cc_qunliaoBtn.animation:stop()
        if _instance then
            _instance:checkMessageNotSend()
            _instance:OnClose()
        end
    end
end

function FriendDialog:OnClose()
    Dialog.OnClose(self)
    _instance = nil
end

function FriendDialog.ToggleOpenClose()
    if not _instance then
        _instance = FriendDialog:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function FriendDialog.GetLayoutFileName()
    return "frienddialog.layout"
end

function FriendDialog:OnCreate()
    Dialog.OnCreate(self)

    --SetPositionOfWindowWithLabel(self:GetWindow())
    self:GetWindow():setZOrderingEnabled(false)

    self:initUIWindow()
	self:initUiEvent()
    self:initDataValue()

    self:freshRedPointState()
--    self:RefreshMailLabelNotify()  --mail
    if not require "logic.friend.friendmaillabel".getInstanceNotCreate() then
        require "logic.friend.friendmaillabel".getInstance():setButtonPushed(1)
    end
 
end

function FriendDialog:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, FriendDialog)

    return self
end

function FriendDialog.RefreshChatListForCpp()
    if _instance then
        if _instance:GetCurrentGroupSelectedID() == 2 then
            _instance:freshContactsByType(2)
            _instance:SelectRoleCellByList(_instance.m_ChatRoleID, FriendDialog.m_vRecentDataList, FriendDialog.m_vRecentCellList)
        end
    end
end

function FriendDialog.freshFriendsForCpp()
    if _instance then
        if _instance:GetCurrentGroupSelectedID() == 1 then
            _instance:freshContactsByType(1)
            _instance:SelectRoleCellByList(_instance.m_ChatRoleID, FriendDialog.m_vFriendDataList, FriendDialog.m_vFriendCellList)
        end
    end
end

function FriendDialog.refreshChatContentForCpp()
    if CChatOutBoxOperatelDlg.getInstanceNotCreate() then
        CChatOutBoxOperatelDlg.getInstanceNotCreate():RefreshNotify()
    end

    if _instance then
        local roleID = gGetFriendsManager():GetLastMsgRoleID()
        if roleID == _instance.m_ChatRoleID then
            _instance:OnSelectRoleCell(roleID)
        else
            _instance:freshRedPointState()
            if roleID ~= 0 then
                _instance:freshItemRoleByID(roleID)
            end
        end
    end
end

--ͨ���������ͷ������Ϣ�������죬��ʱ������л����������ѡ�еĺ���
function FriendDialog.GlobalSetChatRole()
    if not _instance then
        FriendDialog.getInstanceAndShow()
    end
    if _instance then
        local roleID = gGetFriendsManager():GetWantToChatRoleID()
        _instance.m_RecentGroupBtn:setSelected(true)
        _instance:SelectRoleCell(roleID)
    end
end

local displaySize = 8

function FriendDialog:HandleClickAddFriendBtn(args)
    FriendAddDialog.getInstanceAndShow()
    return true
end

function FriendDialog:HandleClickMySpaceBtn(args)

    --GetCTipsManager():AddMessageTipById(160061)

    local nnRoleId = gGetDataManager():GetMainCharacterID()
    getSpaceManager():openSpace(nnRoleId)


    return true
end

function FriendDialog:HandleClickSendChatBtn(args)
    local sendMsgContent = self.m_InputBox:GenerateParseText(false)

    if sendMsgContent == "" then
        GetCTipsManager():AddMessageTip(MHSD_UTILS.get_resstring(1446))
        return true
    end



  --���ѷ�������

    local hyviplevel = gGetDataManager():GetVipLevel()
    if 1 > hyviplevel then
        local param = {hyviplevel}
        GetChatManager():AddTipsMsg(140501, 0, param, true)
        return
    end
				




     local sendPureMsg = self.m_InputBox:GetPureText()
    if not string.find(sendMsgContent, "<P") and not string.find(sendMsgContent, "<E") then
        sendMsgContent = GetChatManager():ProcessChatLinks(sendPureMsg, self.m_InputBox)
    end

    CHAT_STR_SAVED = ""


    local sendRoleID = FriendDialog.m_ChatRoleID
    if BanListManager.getInstance():IsInBanList(sendRoleID) then
        GetCTipsManager():AddMessageTipById(145665)
        return true
    end

    if sendRoleID > 0 then
        self:SendMessageToRole(sendRoleID, sendMsgContent, sendPureMsg)
    end

    gGetFriendsManager():AddChatRecord(0, sendRoleID, "", "", sendMsgContent, "", 0)
    if sendRoleID == -1 then
        local strName = MHSD_UTILS.get_resstring(2773)
        local randIdx = math.random(0, 2)
        local strRespone = MHSD_UTILS.get_msgtipstring(142020 + randIdx)
        gGetFriendsManager():AddChatRecord(sendRoleID, sendRoleID, strName, "", strRespone, "", 0)
    end

    gGetFriendsManager():AddLastChat(sendRoleID)

    if GetChatManager() then
        GetChatManager():AddToChatHistory(sendMsgContent)
    end

    self:RefreshChatRecord(sendRoleID)

    self.m_InputBox:Clear()
    self.m_InputBox:Refresh()

    GetChatManager():ClearChatLinks()
end

function FriendDialog.SendMessageToRole__(roleID, strContent, strCheckText)
    local cmd = require "protodef.fire.pb.friends.csendmessagetorole":new()
    cmd.roleid = roleID
    cmd.content = strContent
    cmd.checkshiedmsg = strCheckText
    LuaProtocolManager.getInstance():send(cmd)
end

function FriendDialog:SendMessageToRole(roleID, strContent, strCheckText)
    local cmd = require "protodef.fire.pb.friends.csendmessagetorole":new()
	cmd.roleid = roleID
	cmd.content = strContent
	cmd.checkshiedmsg = strCheckText
	LuaProtocolManager.getInstance():send(cmd)
end

function FriendDialog:RefreshChatRecord(roleID)
    FriendDialogChatOutput.RefreshChatRecord(self, roleID)
end

function FriendDialog:HandleClickEmotionBtn(args)
    local dlg = require "logic.chat.insertdlg".getInstanceAndShow()
        local chatManager = GetChatManager()
        dlg:setDelegate(chatManager,CChatManager.inputCallBack)
    return true
end

function FriendDialog:HandleFriendOrBlackSelectChange(args)
    FriendDialog.m_ChatRoleID = 0

    local e = CEGUI.toWindowEventArgs(args)
    if e.window == self.m_MyFriendBtn then
        self.m_FriendRoleList:setVisible(true)
        self.m_BlackRoleList:setVisible(false)
        local h = self.m_MyBlackBtn:getParent():getPixelSize().height
        local y = h - self.m_MyBlackBtn:getPixelSize().height
        y = y - 5
        self.m_MyBlackBtn:setYPosition(CEGUI.UDim(0, y))

        self:freshContactsByType(1)
        self:ChangeChatFrameBySelectFriendOrBlack(true)

    elseif e.window == self.m_MyBlackBtn then

        self.m_FriendRoleList:setVisible(false)
        self.m_BlackRoleList:setVisible(true)
        local y = self.m_MyFriendBtn:getYPosition().offset
        local h = self.m_MyFriendBtn:getPixelSize().height
        y = y + h
        self.m_MyBlackBtn:setYPosition(CEGUI.UDim(0, y))
        self:freshContactsByType(3)
        self:ChangeChatFrameBySelectFriendOrBlack(false)
    end

    return true
end

function FriendDialog:HandleClickCleanBtn(args)
    local roleID = FriendDialog.m_ChatRoleID
    gGetFriendsManager():ClearChatRecord(roleID)
    FriendDialogChatOutput.RefreshChatRecord(self, roleID)
end

function FriendDialog:HandleClickBlackSearchBtn(args)
    local text = self.m_BlackInputBox:getText()
    local len = string.len(text)
    if len < 1 then
        GetCTipsManager():AddMessageTipById(145344)
        return
    end
    local allNum = true
    for i = 1, len do
        local ch = string.sub(text, i, i)
        if ch < '0' or ch > '9' then
            allNum = false
            break
        end
    end
    if not allNum then
        GetCTipsManager():AddMessageTipById(145344)
        return
    end

    local roleID = tonumber(text)
    local req = require "protodef.fire.pb.pingbi.csearchblackrole".Create()
    req.roleid = roleID
    LuaProtocolManager.getInstance():send(req)
    return true
end

function FriendDialog:OnInputTextFull(args)
    GetCTipsManager():AddMessageTip(MHSD_UTILS.get_resstring(2423))
    return true
end



function FriendDialog:OnTextChangedOfBlackInputBox()
    local longID = self.m_BlackInputBox:getText()
    if string.len(longID) > 14 then
        local shortID = string.sub(longID, 1, 14)
        self.m_BlackInputBox:setText(shortID)
    end
end

function FriendDialog:OnTextChangedOfBlackInputBox2(args)
    local strID = tostring(args)
    self.m_BlackInputBox:setText(strID)
end

function FriendDialog:GroupButtonClickCallback(args)
    local e = CEGUI.toWindowEventArgs(args)
    local id = e.window:getID()

    FriendDialog.m_vRecentDataList = { }
    FriendDialog.m_vRecentCellList = { }
    FriendDialog.m_vFriendDataList = { }
    FriendDialog.m_vFriendCellList = { }
    FriendDialog.m_vBlackDataList = { }
    FriendDialog.m_vBlackCellList = { }
    FriendDialog.m_vMailCellList = { }
    FriendDialog.m_nRecentDisplaySize = 8
    FriendDialog.m_nFriendDisplaySize = 8
    FriendDialog.m_ChatRoleID = 0

    self.m_ContactRoleList:cleanupNonAutoChildren()
    self.m_FriendRoleList:cleanupNonAutoChildren()
    self.m_BlackRoleList:cleanupNonAutoChildren()

    self:ChangeRoleListByFrameID(id)
    self:ChangeChatFrameByFrameID(id)
    self:freshContactsByType(0)
    return true
end

function FriendDialog:refreshFriendNumberShow()
    local maxNum = gGetFriendsManager():GetMaxFriendNumber() or 100
    self.m_MyFriendBtn:setText(MHSD_UTILS.get_resstring(11567).."("..(gGetFriendsManager():GetCurFriendNum() - 2).."/"..maxNum..")")
end

function FriendDialog:ChangeRoleListByFrameID(id)
    self.m_ContactRoleList:setVisible(false)
    self.m_FriendRoleList:setVisible(false)
    self.m_BlackRoleList:setVisible(false)
    self.m_MyFriendBtn:setVisible(false)
    self.m_MyBlackBtn:setVisible(false)

    if id == 1 then
        self.m_FriendRoleList:setVisible(true)
        self.m_MyFriendBtn:setVisible(true)
        self.m_MyBlackBtn:setVisible(true)
        if self.m_MyFriendBtn:isSelected() == false then
           self.m_MyFriendBtn:setSelected(true)
        end
    elseif id == 2 then
        self.m_ContactRoleList:setVisible(true)
    end
end

function FriendDialog:ChangeChatFrameByFrameID(id)  
    self.m_ChatFrame:setVisible(false)
    self.m_BlackFrame:setVisible(false)
    self.m_ChatBackgroundTips:setVisible(id == 1 or id == 2)
end

function FriendDialog:ChangeChatFrameByRoleID(roleID)
    self.m_ChatFrame:setVisible(true)
    self.m_ChatBackgroundTips:setVisible(false)
end

function FriendDialog:ChangeChatFrameBySelectFriendOrBlack(isSelectFriend)
    self.m_ChatFrame:setVisible(false)
    self.m_BlackFrame:setVisible(isSelectFriend == false)
    self.m_ChatBackgroundTips:setVisible(isSelectFriend == true)
end

function FriendDialog:ArrowClickCallback(args)
    local e = CEGUI.toWindowEventArgs(args)

    local strRoleId = e.window:getUserString("id")

    if not strRoleId then
         return true
    end

    local roleID = tonumber(strRoleId)
    if roleID <= 0 then
        return true
    end

    gGetFriendsManager():SetContactRole(roleID, true)
    return true
end

function FriendDialog:HandleClickDeleteToBlackList(args)
    local e = CEGUI.toWindowEventArgs(args)

    local strRoleId = e.window:getUserString("id")

    if not strRoleId then
        return true
    end

    local roleID = tonumber(strRoleId)
    if roleID <= 0 then
        return true
    end

    BanListManager.getInstance():RemoveRole(roleID)

    self.m_BlackSearchRoleList:cleanupNonAutoChildren()
    return true
end

function FriendDialog:ShowOrHideRoleWindow(roleID)
	local isShowChatBtnSet =(roleID > 0)
	local isShowRelationFrame =(roleID > 0)
	local isShowCcxttips = (roleID < 0)  

    self.m_ccxttips:setVisible(isShowCcxttips)

	self.m_ChatBtnSet:setVisible(isShowChatBtnSet)
	self.m_RelationFrame:setVisible(isShowRelationFrame)
	if isShowRelationFrame then
		self:RefreshRoleRelation(roleID)
	end
end

function FriendDialog:RefreshRoleRelation(roleID)
	if roleID > 0 and self.m_ChatRoleID == roleID then
		local isMyFriend = gGetFriendsManager():isMyFriend(roleID)

		local typeTxt = ""
		if isMyFriend then
			typeTxt = MHSD_UTILS.get_resstring(931)
		else
			typeTxt = MHSD_UTILS.get_resstring(334)
		end
		self.m_RelationTypeTxt:setText(typeTxt)

		local valueTxt = "0"
		if isMyFriend then
			local roleInf = gGetFriendsManager():GetContactRole(roleID)
			valueTxt = tostring(roleInf.friendLevel)
		end
		self.m_RelationValueTxt:setText(valueTxt)
	end
end

function FriendDialog:freshContactsByType(type)
	if type == 0 then
		local id = self:GetCurrentGroupSelectedID()
		if id == 0 then
			return
		end
		type = id
	end

	if type == 3 then
		self:RefreshBlackListView()
		return
	end

	local vDataIndexList = { }

	local index = 1
	local size = 0

	index = 1
	if type == 1 then
		size = gGetFriendsManager():GetCurFriendNum()
		for i = 1, size, 1 do
			vDataIndexList[index] = gGetFriendsManager():GetFriendRoleIDByIdx(i)
			index = index + 1
		end
	end

	index = 1
	if type == 2 then
		size = gGetFriendsManager():GetRecentChatListNum()
		for i = 1, size, 1 do
			vDataIndexList[index] = gGetFriendsManager().GetRecentChatRoleIDByIdx(i)
			index = index + 1
		end

		local vTempList = {}
		index = 1
		for i = 1, #vDataIndexList, 1 do
			local bHasNotReadMsg = gGetFriendsManager():RoleHasNotReadMsg(vDataIndexList[index])
			if bHasNotReadMsg == true or vDataIndexList[index] < 0 then
				vTempList[#vTempList + 1] = vDataIndexList[index]
				table.remove(vDataIndexList, index)
			else
				index = index + 1
			end
		end
		index = 1
		for i = 1, #vDataIndexList, 1 do
			local roleInf = gGetFriendsManager():GetContactRole(vDataIndexList[index])
			if roleInf.isOnline > 0 then
				vTempList[#vTempList + 1] = vDataIndexList[index]
				table.remove(vDataIndexList, index)
			else
				index = index + 1
			end
		end
		index = 1
		for i = 1, #vDataIndexList, 1 do
			vTempList[#vTempList + 1] = vDataIndexList[index]
			index = index + 1
		end
		vDataIndexList = vTempList
		vTempList = nil
	end

	if displaySize < 8 then
		displaySize = 8
	end

	if displaySize > size or type == 2 then
		displaySize = size
	end

	index = 1
	local vDataList = { }
	for i = 1, displaySize, 1 do
		vDataList[index] = gGetFriendsManager():GetContactRole(vDataIndexList[index])
		vDataList[index].roleid = vDataIndexList[index]
		index = index + 1
	end

	local params = { }
	params.m_strListName = ""
	params.m_nSize = displaySize
	params.m_vDataList = nil
	params.m_vCellList = nil
	params.m_pRoleListView = nil

	if type == 1 then
		FriendDialog.m_vFriendDataList = vDataList
		params.m_vDataList = FriendDialog.m_vFriendDataList
		params.m_vCellList = FriendDialog.m_vFriendCellList
		params.m_strListName = "friendlist"
		params.m_pRoleListView = self.m_FriendRoleList
	elseif type == 2 then
		FriendDialog.m_vRecentDataList = vDataList
		params.m_vDataList = FriendDialog.m_vRecentDataList
		params.m_vCellList = FriendDialog.m_vRecentCellList
		params.m_strListName = "recentlist"
		params.m_pRoleListView = self.m_ContactRoleList
	end

	self:RefreshRoleListByListView(params)

    self:refreshFriendNumberShow()
end

function FriendDialog:freshItemRoleByID(roleID)
    local winMgr = CEGUI.WindowManager:getSingleton()
    local hasNotReadMsg = gGetFriendsManager():RoleHasNotReadMsg(roleID)
    local index = 1
    local notifyWnd = nil
    for i = 1, #FriendDialog.m_vRecentDataList, 1 do
        if FriendDialog.m_vRecentDataList[index] ~= nil then
            if FriendDialog.m_vRecentDataList[index].roleid == roleID then
                local namePrefix = self:GetNamePrefixByListView(self.m_ContactRoleList) .. tostring(index)
                notifyWnd = winMgr:getWindow(namePrefix .. "friendcell/mark")
                break
            end
        end
        index = index + 1
    end

    if notifyWnd ~= nil then
            notifyWnd:setVisible(hasNotReadMsg)
    end
end

function FriendDialog:ItemRoleClickCallback(args)
    local e = CEGUI.toWindowEventArgs(args)
    local strRoleId = e.window:getUserString("id")
    local btn = CEGUI.toGroupButton(e.window)
    local roleID = tonumber(strRoleId)
    if roleID == -2 then
        local tipMsg =  MHSD_UTILS.get_msgtipstring(160061111)
        GetCTipsManager():AddMessageTip(tipMsg)
        self:ChangeChatFrameByFrameID(0)

        require "logic.jingling.jinglingdlg".getInstanceAndShow() -- ȥ��˵���ô�ʦ����
        btn:setSelected(false, false)
        return true
    end

    if not strRoleId then
        return true
    end

    if roleID == 0 then
        return true
    end

    self:OnSelectRoleCell(roleID)

    return true
end

function FriendDialog:SelectRoleCell(roleID)
	local index = 1
	for i = 1, #FriendDialog.m_vRecentDataList, 1 do
		if FriendDialog.m_vRecentDataList[index] ~= nil then
			if FriendDialog.m_vRecentDataList[index].roleid == roleID then
				local roleCell = FriendDialog.m_vRecentCellList[index]
				local roleCellBtn = CEGUI.Window.toGroupButton(roleCell)
				roleCellBtn:setSelected(true)
			end
		end
		index = index + 1
	end

end

function FriendDialog:SelectRoleCellByList(roleID, dataList, cellList)
	local index = 1
	for i = 1, #dataList, 1 do
		if dataList[index] ~= nil then
			if dataList[index].roleid == roleID then
				local roleCell = cellList[index]
				local roleCellBtn = CEGUI.Window.toGroupButton(roleCell)
				roleCellBtn:setSelected(true)
			end
		end
		index = index + 1
	end

end

function FriendDialog:freshRedPointState()
	local hasFriendMsg = false
	local hasRecentChatMsg = false
	local friendNum = 0

	friendNum = gGetFriendsManager():GetCurFriendNum()
	local friendNotReadMsgNum = 0
	local recentChatNotReadMsgNum = 0
	for i = 1, friendNum do
		local roleID = gGetFriendsManager():GetFriendRoleIDByIdx(i)
		if gGetFriendsManager():RoleHasNotReadMsg(roleID) then
			hasFriendMsg = true
			friendNotReadMsgNum = friendNotReadMsgNum + gGetFriendsManager().GetRoleNotReadMsgNum(roleID)
		end
	end

	friendNum = gGetFriendsManager():GetRecentChatListNum()
	for i = 1, friendNum do
		local roleID = 0
		roleID = gGetFriendsManager().GetRecentChatRoleIDByIdx(i)
		if gGetFriendsManager():RoleHasNotReadMsg(roleID) then
			hasRecentChatMsg = true
			recentChatNotReadMsgNum = recentChatNotReadMsgNum + gGetFriendsManager().GetRoleNotReadMsgNum(roleID)
		end
	end

	self.m_RecentGroupNotify:setVisible(hasRecentChatMsg)

end

function FriendDialog:HandleClickBlackInputBox(args)
    NumKeyboardDlg.DestroyDialog()
    local dlg = NumKeyboardDlg.getInstanceAndShow()
    SetPositionScreenCenter(dlg:GetWindow())
    dlg:setInputChangeCallFunc(FriendDialog.OnTextChangedOfBlackInputBox2, self)
    dlg:setMaxLength(14)
end

function FriendDialog:InitBlackSearchList(roleBean)
	local params = { }
	params.m_nSize = 1
	params.m_vDataList = { }
	params.m_vCellList = { }
	params.m_pRoleListView = self.m_BlackSearchRoleList

	params.m_vDataList[1] = roleBean

	self.m_BlackSearchRoleList:cleanupNonAutoChildren()

	self:RefreshSearchListListView(params)
end


function FriendDialog:RefreshRoleListByListView(params)
	local strListName = params.m_strListName
	local nSize = params.m_nSize
	local vDataList = params.m_vDataList
	local vCellList = params.m_vCellList
	local pRoleListView = params.m_pRoleListView

	local index = 1
	for i = 1, nSize do
		local roleid = vDataList[index].roleid
		local name = vDataList[index].name
		local level = vDataList[index].rolelevel
		local school = vDataList[index].school
		local isOnline = vDataList[index].isOnline
		local shape = vDataList[index].shape
		local camp = vDataList[index].camp
		local relation = vDataList[index].relation

        if name ~= "" then
            if strListName == "blacklist" then
                level = vDataList[index].level
            end

            local namePrefix = self:GetNamePrefixByListView(pRoleListView) .. tostring(index)
		    local winMgr = CEGUI.WindowManager:getSingleton()
		    local curCell = vCellList[index]
		    if curCell == nil then
			    curCell = winMgr:loadWindowLayout("friendcell.layout", namePrefix)
			    pRoleListView:addChildWindow(curCell)
			    vCellList[index] = curCell
			    local height = curCell:getPixelSize().height
			    local yPos = (height - 2) *(index - 1)
			    local xPos = 5.0
			    curCell:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, xPos), CEGUI.UDim(0.0, yPos)))
		    end

            local strRoleID = tostring(roleid)
		    local roleCellBtn = CEGUI.Window.toGroupButton(curCell)
		    if strListName == "blacklist" then
			    roleCellBtn:EnableClickAni(false)
			    roleCellBtn:setProperty("StateImageExtendID", 1)
		    else
			    if roleCellBtn:isEventPresent("SelectStateChanged") == false then
				   roleCellBtn:subscribeEvent("SelectStateChanged", FriendDialog.ItemRoleClickCallback, self)
			    end
			    roleCellBtn:setUserString("id", strRoleID)
			    roleCellBtn:EnableClickAni(false)
		    end

            local headWndName = namePrefix .. "friendcell/icon"
		    local headWnd = winMgr:getWindow(headWndName)
		    local strHead = ""

            if strListName == "blacklist" then
			    local shapeConf = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(shape)
			    if shapeConf.id ~= -1 then
				    strHead = gGetIconManager():GetImagePathByID(shapeConf.littleheadID):c_str()
			    end
		    else
			    if roleid == -1 then
                    strHead = gGetIconManager():GetImagePathByID(30395):c_str()
                elseif roleid == -2 then
				    strHead = gGetIconManager():GetImagePathByID(30396):c_str()
			    else
                    if isOnline == 0 then
                        strHead = gGetFriendsManager():GetContactRoleIcon(roleid, isOnline)
			        else
                        strHead = gGetFriendsManager():GetContactRoleIcon(roleid, isOnline)
			        end
			    end
		    end
		    headWnd:setProperty("Image", strHead)

            local nameWndName = namePrefix .. "friendcell/name"
		    local nameWnd = winMgr:getWindow(nameWndName)
		    nameWnd:setText(name)
            if roleid == -2  then
                nameWnd:setProperty("TextColours", "ffa12cec")
            end

		    local levelWndName = namePrefix .. "friendcell/level"
		    local levelWnd = winMgr:getWindow(levelWndName)

		    if roleid == -1 or roleid == -2 then
			    levelWnd:setText("")
		    else
			    levelWnd:setText(tostring(level))
		    end

            local schoolWndName = namePrefix .. "friendcell/zhiye"
		    local schoolWnd = winMgr:getWindow(schoolWndName)
		    if roleid == -1 or roleid == -2 then
			    schoolWnd:setVisible(false)
			    nameWnd:setXPosition(schoolWnd:getXPosition())
		    else
			    local schoolConf = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(school)
			    if schoolConf then
				    schoolWnd:setProperty("Image", schoolConf.schooliconpath)
			    end

		    end

		    local moreBtnName = namePrefix .. "friendcell/more"
		    local moreBtn = CEGUI.Window.toPushButton(winMgr:getWindow(moreBtnName))

		    if strListName == "blacklist" then
			    moreBtn:setVisible(false)
		    else
			    moreBtn:setUserString("id", strRoleID)
			    if moreBtn:isEventPresent("Clicked") == false then
				    moreBtn:subscribeEvent("Clicked", FriendDialog.ArrowClickCallback, self)
			    end
			    moreBtn:setVisible(roleid ~= -1 and roleid ~= -2)
		    end

		    local deleteBtnName = namePrefix .. "friendcell/delete"
		    local deleteBtn = CEGUI.Window.toPushButton(winMgr:getWindow(deleteBtnName))

		    if strListName == "blacklist" then
			    deleteBtn:setUserString("id", strRoleID)
			    if deleteBtn:isEventPresent("Clicked") == false then
				    deleteBtn:subscribeEvent("Clicked", FriendDialog.HandleClickDeleteToBlackList, self)
			    end
			    deleteBtn:setVisible(roleid ~= -1 and roleid ~= -2)
		    else
			    deleteBtn:setVisible(false)
		    end

		    local notifyWndName = namePrefix .. "friendcell/mark"
		    local notifyWnd = winMgr:getWindow(notifyWndName)

		    if strListName == "blacklist" then
			    notifyWnd:setVisible(false)
		    elseif strListName == "friendlist" then
			    notifyWnd:setVisible(false)
		    elseif strListName == "recentlist" then
			    local bHasNotReadMsg = gGetFriendsManager():RoleHasNotReadMsg(roleid)
			    notifyWnd:setVisible(bHasNotReadMsg)
			    local num = gGetFriendsManager().GetRoleNotReadMsgNum(roleid)
		    end

		    local signWndName = namePrefix .. "friendcell/qianming"
		    local signWnd = winMgr:getWindow(signWndName)

		    if strListName == "blacklist" then
			    signWnd:setVisible(false)
		    else
			    signWnd:setVisible(roleid == -2)
                if roleid == -2 then
                    signWnd:setText(require("utils.mhsdutils").get_resstring(11504))
                    --kongjiannpc

                    
                    local btnSpaceName = namePrefix .. "friendcell/btnkongjian"
		            local btnSpaceNpc = CEGUI.Window.toPushButton(winMgr:getWindow(btnSpaceName))
                    btnSpaceNpc:subscribeEvent("MouseClick", FriendDialog.clickSpaceNpc, self)
                    btnSpaceNpc:setVisible(true)
                end
		    end

            if roleid > 0 then
                local sName = gGetFriendsManager():getSignByRoleID(roleid)
                local isShiled, sName = MHSD_UTILS.ShiedText(sName)
                if sName ~= "" then
                    local qmName = namePrefix .. "friendcell/qianming1"
                    local qmWnd = winMgr:getWindow(qmName)
                    qmWnd:setText(sName)
                else
                    signWnd:setVisible(true)
                end
            end


		    vCellList[index]:setVisible(true)
		    index = index + 1
        end
	end

	for i = index, #vCellList, 1 do
		vCellList[index]:setVisible(false)
		index = index + 1
	end

end

function FriendDialog:clickSpaceNpc(args)
    local strValue = GameTable.common.GetCCommonTableInstance():getRecorder(334).value
    local nOpenSpaceLevel = tonumber(strValue)
    local nMyLevel = gGetDataManager():GetMainCharacterLevel()
    if nMyLevel < nOpenSpaceLevel then
         local strNotOpen = require("utils.mhsdutils").get_resstring(11541)
         GetCTipsManager():AddMessageTip(strNotOpen)
         return
    end

    require("logic.space.spacenpcdialog").getInstanceAndShow()
 
end

function FriendDialog:GetNamePrefixByListView(view)
	if view == self.m_ContactRoleList then
		return "c"
	elseif view == self.m_FriendRoleList then
		return "f"
	elseif view == self.m_BlackRoleList then
		return "b"
	elseif view == self.m_BlackSearchRoleList then
		return "bs"
	end
	return ""
end

function FriendDialog:GetCurrentGroupSelectedID()
	local selectedBtn = self.m_ContactGroupBtn:getSelectedButtonInGroup()
	if selectedBtn then
		return selectedBtn:getID()
	end

	return 0
end

function FriendDialog:HandleFriendListNextPage(args)
    if displaySize < gGetFriendsManager():GetCurFriendNum() then
        displaySize = displaySize + 8
        self:freshContactsByType(0)
    end
end

function FriendDialog:RefreshSearchListListView(params)
	local nSize = params.m_nSize
	local vDataList = params.m_vDataList
	local vCellList = params.m_vCellList
	local pRoleListView = params.m_pRoleListView

	local index = 1
	for i = 1, nSize do
		local roleid = vDataList[index].roleid
		local name = vDataList[index].name
		local level = vDataList[index].rolelevel
		local school = vDataList[index].school
		local isOnline = vDataList[index].online
		local shape = vDataList[index].shape
		local camp = vDataList[index].camp

		local isInList = BanListManager.getInstance():IsInBanList(roleid)

		local curCellAddWidth = 0

        local namePrefix = self:GetNamePrefixByListView(pRoleListView) .. tostring(index)
        local isBlackSearch = false
        local searchCellName = "friendaddcell"
        if namePrefix == "bs"..tostring(index) then
            searchCellName = "friendheimingdancell"
            isBlackSearch = true
        end
		local winMgr = CEGUI.WindowManager:getSingleton()
		local curCell = vCellList[index]
		if curCell == nil then
			curCell = winMgr:loadWindowLayout(searchCellName..".layout", namePrefix)
			pRoleListView:addChildWindow(curCell)
			vCellList[index] = curCell
			local height = curCell:getPixelSize().height
			local yPos = 1.0 +(height + 2.0) *(index - 1)
			local xPos = 5.0
			curCell:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, xPos), CEGUI.UDim(0.0, yPos)))
			local listWidth = pRoleListView:getWidth().offset
			local cellWidth = listWidth - 5.0 - xPos
			curCellAddWidth = cellWidth - curCell:getWidth().offset
            if not isBlackSearch then
			    curCell:setWidth(CEGUI.UDim(0.0, cellWidth))
            end
		end

		local strRoleID = tostring(roleid)

		local headWndName = namePrefix .. searchCellName.."/icon"
		local headWnd = winMgr:getWindow(headWndName)
		do
			local shapeConf = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(shape)
			if shapeConf.id ~= -1 then
				local strHeadImg = gGetIconManager():GetImagePathByID(shapeConf.littleheadID):c_str()
				if strHeadImg ~= "" then
					headWnd:setProperty("Image", strHeadImg)
				end
			end
		end

		local nameWndName = namePrefix .. searchCellName.."/name"
		local nameWnd = winMgr:getWindow(nameWndName)
		nameWnd:setText(name)

		local levelWndName = namePrefix  .. searchCellName.."/level"
		local levelWnd = winMgr:getWindow(levelWndName)
		levelWnd:setText(tostring(level))

		local schoolWndName = namePrefix  .. searchCellName.."/zhiye"
		local schoolWnd = winMgr:getWindow(schoolWndName)
		local schoolConf = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(school)
		if schoolConf then
			schoolWnd:setProperty("Image", schoolConf.schooliconpath)
		end

		local addBtnName = namePrefix  .. searchCellName.."/tianjia"
		local addBtn = winMgr:getWindow(addBtnName)
		addBtn:setUserString("id", strRoleID)
		addBtn:subscribeEvent("Clicked", FriendDialog.HandleClickAddToBlackListBtn, self)
		addBtn:setVisible(isInList == false)
		if curCellAddWidth ~= 0 and not isBlackSearch then
			addBtn:setXPosition(CEGUI.UDim(0.0, addBtn:getXPosition().offset + curCellAddWidth))
		end

		local delBtnName = namePrefix  .. searchCellName.."/shanchu"
		local delBtn = winMgr:getWindow(delBtnName)
		delBtn:setUserString("id", strRoleID)
		delBtn:subscribeEvent("Clicked", FriendDialog.HandleClickDeleteToBlackList, self)
		delBtn:setVisible(isInList == true)
		if curCellAddWidth ~= 0 and not isBlackSearch then
			delBtn:setXPosition(CEGUI.UDim(0.0, delBtn:getXPosition().offset + curCellAddWidth))
		end

		local selectedWndName = namePrefix .. searchCellName.."/gouxuan"
		local selectedWnd = winMgr:getWindow(selectedWndName)
		selectedWnd:setVisible(false)
		if curCellAddWidth ~= 0 and not isBlackSearch then
			selectedWnd:setXPosition(CEGUI.UDim(0.0, selectedWnd:getXPosition().offset + curCellAddWidth))
		end
		addBtn:setUserString("selectedWndName", selectedWndName)

		vCellList[index]:setVisible(true)
		index = index + 1
	end

	for i = index, #vCellList, 1 do
		vCellList[index]:setVisible(false)
		index = index + 1
	end
end

function FriendDialog:HandleClickAddToBlackListBtn(args)
	local e = CEGUI.toWindowEventArgs(args)

	local strRoleID = e.window:getUserString("id")

	if strRoleID == nil then
		return true
	end

	local roleID = tonumber(strRoleID)
	if roleID <= 0 then
		return true
	end

	BanListManager.getInstance():AddRole(roleID)
	self.m_BlackSearchRoleList:cleanupNonAutoChildren()
	return true
end

function FriendDialog:RefreshBlackListView()
	local vBlackRoleList = { }
	if BanListManager.getInstance() then
		vBlackRoleList = BanListManager.getInstance():GetBanList()
	end

	local size = table.getn(vBlackRoleList)

	local params = { }
	params.m_strListName = "blacklist"
	params.m_nSize = size
	params.m_vDataList = vBlackRoleList
	params.m_vCellList = FriendDialog.m_vBlackCellList
	params.m_pRoleListView = self.m_BlackRoleList

	self:RefreshRoleListByListView(params)

	self.m_BlackLengthValueTxt:setText(tostring(size))
end

function FriendDialog:OnSelectRoleCell(roleID)
    FriendDialog.m_ChatRoleID = roleID

    gGetFriendsManager():PopRoleMsg(roleID)

    self:ChangeChatFrameByRoleID(roleID)
    self:ShowOrHideRoleWindow(roleID)
    self:RefreshChatRecord(roleID)

    self:freshItemRoleByID(roleID)
    self:freshRedPointState()
    CChatOutBoxOperatelDlg.getInstanceNotCreate():RefreshNotify()

    if roleID == -1 then
        self.m_friendshipTop:setVisible(false)
        self.m_ChatRecordList:setYPosition(CEGUI.UDim(0, self.m_friendshipTop:getPosition().y.offset))
        self.m_ChatRecordList:setSize(CEGUI.UVector2(CEGUI.UDim(0, self.m_ChatRecordSizeOrg.width), CEGUI.UDim(0, self.m_ChatRecordSizeOrg.height + 48)))
    else
        self.m_friendshipTop:setVisible(true)
        self.m_ChatRecordList:setYPosition(CEGUI.UDim(0, self.m_friendshipTop:getPosition().y.offset + self.m_friendshipTop:getPixelSize().height))
        self.m_ChatRecordList:setSize(CEGUI.UVector2(CEGUI.UDim(0, self.m_ChatRecordSizeOrg.width), CEGUI.UDim(0, self.m_ChatRecordSizeOrg.height)))
    end
end

--����Ƿ���δ���͵��ı���Ϣ���ٴδ򿪽��棬δ���͵Ļ��ٴ�����
function FriendDialog:checkMessageNotSend()
    local text = self.m_InputBox:GenerateParseText(false)
    if text ~= "" then
        CHAT_STR_SAVED = text
    end
end

function FriendDialog:HandleVoiceBegin(args)
    -- ��ť�������ж�
    local lastClickTime = self.m_VoiceBtnLastClickTime
    local curTime = gGetServerTime()
    self.m_VoiceBtnLastClickTime = curTime
    if curTime - lastClickTime < VOICE_BTN_CLICK_INTERVAL then
        gGetGameUIManager():AddMessageTipById(160172)
        return
    end

    require("logic.chat.voicedialog").DestroyDialog()

    local bCanRecord = gGetWavRecorder():canRecord()
    if bCanRecord then
        if gGetWavRecorder():start() then
            gGetVoiceManager():registerAutoClose(VOICE_RECORD_TYPE_JINGLING)
            self.m_bRecording = true

            -- Ϊ�˷�ֹ¼��������������gGetWavRecorder():start()ʱ���ã����ﲻ����
            --gGetVoiceManager():PauseMusicAndEffectForLua()

			self.m_voiceBeginTime = gGetServerTime()

			-- ����¼��������ʾ����
            local pVoiceUI = require("logic.chat.voicedialog").getInstanceAndShow()
            pVoiceUI:setPosition(600, 280)
            pVoiceUI:setVoiceRecordUI(true)
		end
	else
		gGetVoiceManager():showTip_RequirePermission()
	end
end

function FriendDialog:HandleVoiceEnd(args)
    if not self.m_bRecording then
        return
    end

    self.m_bRecording = false

    require("logic.chat.voicedialog").DestroyDialog()

    gGetVoiceManager():ResumeEffectForLua()
    local BackMusic = gGetGameConfigManager():GetConfigValue("sound")
    if BackMusic ~= 0 then
        gGetVoiceManager():ResumeMusicForLua()
    end

    gGetWavRecorder():stop()
    gGetVoiceManager():unregisterAutoClose()

    local mouseEvent = CEGUI.toMouseEventArgs(args)

    if mouseEvent.handled == 0 then
        local wndArgs = CEGUI.toWindowEventArgs(args)
        local pVoiceBtn = CEGUI.toPushButton(wndArgs.window)
        if not self:isHitVoiceRecordUI(pVoiceBtn, mouseEvent.position.x, mouseEvent.position.y) then
            return
        end
    end

	if mouseEvent.handled == 0 or mouseEvent.handled == 2 then
        local recordTime = gGetServerTime() - self.m_voiceBeginTime
        if recordTime < 500 then
            gGetGameUIManager():AddMessageTipById(160141)
            return
        end

        gGetVoiceManager():ProcessVoiceDataForLua(recordTime, GetNumberValueForStrKey("VOICE_FRIEND_CHANNEL"), self.m_ChatRoleID)
    end
end

function FriendDialog.HandleVoiceEnd_(args)
	if not _instance then
		return
	end
	_instance:HandleVoiceEnd(args)
end

function FriendDialog:HandleVoiceMove(args)
    if self.m_bRecording then
        local wndArgs = CEGUI.toWindowEventArgs(args)
        local pVoiceBtn = CEGUI.toPushButton(wndArgs.window)
        local mouseEvent = CEGUI.toMouseEventArgs(args)

        local pVoiceUI = require("logic.chat.voicedialog").getInstanceNotCreate()
        if pVoiceUI then
		    pVoiceUI:setVoiceRecordUI(self:isHitVoiceRecordUI(pVoiceBtn, mouseEvent.position.x, mouseEvent.position.y));
        end
	end

end

function FriendDialog:isHitVoiceRecordUI(pVoiceBtn, mouseX, mouseY)
    local pos = pVoiceBtn:GetScreenPos()
    local sz = pVoiceBtn:getPixelSize()

    local x = mouseX - pos.x;
    local y = mouseY - pos.y;
    local radii = sz.width / 2;
    local absX = radii - x;
    local absY = radii - y;

    return(absX * absX + absY * absY) <(radii * radii)
end

function FriendDialog.GetVoiceUuid(chatText)
	local text = chatText:match("link=\"([^\"]+)\"")
	return text or ""
end

function FriendDialog.GetVoiceTime(chatText)
	local t = string.match(chatText, "time=([%d%.]+)")
    if t then
        local n = tonumber(t)
        if n then
            return math.min(math.floor(n + 0.5), 30)
        end
    end
    return 1
end

function FriendDialog.SendVoiceMsgToFriend_(sendRoleID, strChatContent, shiedText)
	if _instance then
		if sendRoleID ~= 0 then
            local voiceUUID = FriendDialog.GetVoiceUuid(strChatContent)
            local voiceTime = FriendDialog.GetVoiceTime(strChatContent)

            if GetChatCellManager():HasVoiceContent(strChatContent) and voiceUUID == "" then
                return
            end

            _instance:SendMessageToRole(sendRoleID, strChatContent, shiedText)

            gGetFriendsManager():AddChatRecord(0, sendRoleID, "", "", strChatContent, voiceUUID, voiceTime)
            if sendRoleID == -1 then
                local strName = MHSD_UTILS.get_resstring(2773)
                local randIdx = math.random(0, 2)
                local strRespone = MHSD_UTILS.get_msgtipstring(142020 + randIdx)
                gGetFriendsManager():AddChatRecord(sendRoleID, sendRoleID, strName, "", strRespone, "", 0)
            end

            _instance:RefreshChatRecord(sendRoleID)
        end
    else
        if sendRoleID ~= 0 then
            local voiceUUID = FriendDialog.GetVoiceUuid(strChatContent)
            local voiceTime = FriendDialog.GetVoiceTime(strChatContent)

            if GetChatCellManager():HasVoiceContent(strChatContent) and voiceUUID == "" then
                return
            end

            FriendDialog.SendMessageToRole__(sendRoleID, strChatContent, shiedText)

            gGetFriendsManager():AddChatRecord(0, sendRoleID, "", "", strChatContent, voiceUUID, voiceTime)
            if sendRoleID == -1 then
                local strName = MHSD_UTILS.get_resstring(2773)
                local randIdx = math.random(0, 2)
                local strRespone = MHSD_UTILS.get_msgtipstring(142020 + randIdx)
                gGetFriendsManager():AddChatRecord(sendRoleID, sendRoleID, strName, "", strRespone, "", 0)
            end
        end
    end
end

function FriendDialog:HandleSendGiftClick(arg)
    if self.m_ChatRoleID and self.m_ChatRoleID > 0 then
         local sendgift = require "logic.friend.sendgiftdialog".getInstanceAndShow()
         local role = gGetFriendsManager():GetContactRole(self.m_ChatRoleID)
         local shapeConf = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(role.shape)
         sendgift:insertCharacterWithParams(role.roleID, role.name, role.rolelevel, role.school, shapeConf.littleheadID)
         sendgift:createContactList(self.m_ChatRoleID)
    end
end

function FriendDialog:addButtonAnimation(button, animationName)
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation(animationName)
    if animationDef then
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        animation:setTargetWindow(button)
        animation:setSpeed(0.5)
        button.animation = animation
        button:subscribeEvent("MouseButtonDown", function()
            animation:start()
        end, self)
    end
end

function FriendDialog:OnLButtonUp()
    local targetWnd = CheckTipsWnd.GetCursorWindow()
    if self.CCtipsUI:isVisible() and targetWnd ~= self.CCtipsUI and not targetWnd:isAncestor(self.CCtipsUI) then
        self.CCtipsUI:setVisible(false)
    end
end

function FriendDialog:OnLButtonDown()
    local targetWnd = CheckTipsWnd.GetCursorWindow()
    if self.CCtipsUI:isVisible() and targetWnd ~= self.CCtipsUI and not targetWnd:isAncestor(self.CCtipsUI) then
        self.CCtipsUI:setVisible(false)
    end
end

function FriendDialog:initUIWindow()
    local winMgr = CEGUI.WindowManager:getSingleton()
	self.ccFrienddia = winMgr:getWindow("Frienddialog")
	
	self.m_ccteshuck = winMgr:getWindow("Frienddialog/botcc1")

    local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen = aniMan:getAnimation("FrameWindowani") 
    self.animationInstance = aniMan:instantiateAnimation(animationOpen) 
    self.animationInstance:setTargetWindow(self.m_ccteshuck)
    self.animationInstance:start()
	
    self.m_ContactGroupBtn = CEGUI.Window.toGroupButton(winMgr:getWindow("Frienddialog/right/back/part1"))
    self.m_ContactGroupBtn:setID(1)
    self.m_ContactGroupNotify = winMgr:getWindow("Frienddialog/right/back/part1/mark1")
    self.m_ContactGroupNotify:setVisible(false)
    self.m_RecentGroupBtn = CEGUI.Window.toGroupButton(winMgr:getWindow("Frienddialog/right/back/part2"))
    self.m_RecentGroupBtn:setID(2)
    self.m_RecentGroupNotify = winMgr:getWindow("Frienddialog/right/back/part2/mark2")
    self.m_RecentGroupNotify:setVisible(false)
	
	self.cctipsc = CEGUI.toRichEditbox(winMgr:getWindow("Frienddialog/cctstips"))
	self.cctipsc:Clear()
    self.cctipsc:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7560)))
    self.cctipsc:Refresh()
	
    self.m_ContactRoleList = CEGUI.Window.toScrollablePane(winMgr:getWindow("Frienddialog/liebiao/diban/contactlist"))
    self.m_FriendRoleList = CEGUI.Window.toScrollablePane(winMgr:getWindow("Frienddialog/liebiao/diban/friendlist"))
    self.m_BlackRoleList = CEGUI.Window.toScrollablePane(winMgr:getWindow("Frienddialog/liebiao/diban/blacklist"))

    self.m_MyFriendBtn = CEGUI.Window.toGroupButton(winMgr:getWindow("Frienddialog/liebiao/diban/myfriendbtn"))
    self.m_MyBlackBtn = CEGUI.Window.toGroupButton(winMgr:getWindow("Frienddialog/liebiao/diban/myblackbtn"))
    self.m_MyFriendBtn:EnableClickAni(false)
    self.m_MyBlackBtn:EnableClickAni(false)
    self.m_AddFriendBtn = CEGUI.Window.toPushButton(winMgr:getWindow("Frienddialog/tianjia"))
	self:addButtonAnimation(self.m_AddFriendBtn, "studyBtnPress")
    self.m_MySpaceBtn = CEGUI.Window.toPushButton(winMgr:getWindow("Frienddialog/kongjian"))
	self:addButtonAnimation(self.m_MySpaceBtn, "studyBtnPress")
    self.m_ChatFrame = winMgr:getWindow("Frienddialog/chatframe")
    self.m_ChatBtnSet = winMgr:getWindow("Frienddialog/chatframe/anniu")
	
	self.m_ccxttips = winMgr:getWindow("Frienddialog/chatframe/cctips")
	
	
	
	
	self.btnClose = CEGUI.toPushButton(winMgr:getWindow("Frienddialog/Close"))
    self.btnClose:subscribeEvent("Clicked", FriendMailLabel.DestroyDialog, self)
	

	
	
	self.cc_qunliaoBtn = CEGUI.Window.toPushButton(winMgr:getWindow("Frienddialog/qunliao"))
	self:addButtonAnimation(self.cc_qunliaoBtn, "studyBtnPress")
    self.cc_qunliaoBtn:subscribeEvent("Clicked", FriendDialog.qunliaoBtnClicked, self)

	
	self.cc_kefuBtn = CEGUI.Window.toPushButton(winMgr:getWindow("Frienddialog/kefu"))
	self:addButtonAnimation(self.cc_kefuBtn, "studyBtnPress")
	self.cc_kefuBtn:subscribeEvent("Clicked", FriendDialog.qunliaoBtnClicked, self)
	
    self.m_SendChatBtn = CEGUI.Window.toPushButton(winMgr:getWindow("Frienddialog/chatframe/anniu/fasong"))
	self:addButtonAnimation(self.m_SendChatBtn, "studyBtnPress")
	--������Ϣ
    self.m_TalkBtn = CEGUI.Window.toPushButton(winMgr:getWindow("Frienddialog/chatframe/anniu/yuyin"))
	self:addButtonAnimation(self.m_TalkBtn, "studyBtnPress")
	--����
    self.m_EmotionBtn = CEGUI.Window.toPushButton(winMgr:getWindow("Frienddialog/chatframe/anniu/biaoqing"))
	self:addButtonAnimation(self.m_EmotionBtn, "studyBtnPress")
	--����
    self.m_InputBox = CEGUI.Window.toRichEditbox(winMgr:getWindow("Frienddialog/chatframe/anniu/shurukuang/input"))
    self.m_InputBox:setMaxTextLength(70)
    self.m_InputBox:setWordWrapping(false)
    local inputColor = self.m_InputBox:getProperty("NormalTextColour")
    self.m_InputBox:SetColourRect(CEGUI.PropertyHelper:stringToColour(inputColor))
    if CHAT_STR_SAVED ~= "" then
        self.m_InputBox:AppendParseText(CEGUI.String(CHAT_STR_SAVED))
        self.m_InputBox:Refresh()
    end
    self.m_ContentFrame = winMgr:getWindow("Frienddialog/chatframe/xinxi")
    self.m_ChatRecordList = CEGUI.Window.toScrollablePane(winMgr:getWindow("Frienddialog/chatframe/xinxi/contentoutput"))
    self.m_ChatRecordListOrgPos = self.m_ChatRecordList:getPosition()
    self.m_ChatRecordSizeOrg = self.m_ChatRecordList:getPixelSize()
    self.m_RelationFrame = winMgr:getWindow("Frienddialog/chatframe/jiaohu")
    self.m_RelationTypeTxt = winMgr:getWindow("Frienddialog/chatframe/jiaohu/haoyouguanxi")
    self.m_RelationValueTxt = winMgr:getWindow("Frienddialog/chatframe/jiaohu/shuju")
    self.m_RelationCleanBtn = CEGUI.Window.toPushButton(winMgr:getWindow("Frienddialog/chatframe/jiaohu/qingkong"))
	self:addButtonAnimation(self.m_RelationCleanBtn, "studyBtnPress")
	----�����Ϣ
    self.m_BlackFrame = winMgr:getWindow("Frienddialog/blackframe")
    self.m_BlackBtnSet = winMgr:getWindow("Frienddialog/blackframe/anniu")
    self.m_BlackSearchBtn = winMgr:getWindow("Frienddialog/blackframe/anniu/search")
    self.m_BlackInputBox = CEGUI.Window.toEditbox(winMgr:getWindow("Frienddialog/blackframe/anniu/shurukuang/input"))
    self.m_BlackInputBox:setReadOnly(true)
    local blackInputColor = "0x" .. self.m_BlackInputBox:getProperty("NormalTextColour")
    local blackInputColorValue = tonumber(blackInputColor)
    self.m_BlackInputBox:SetNormalColourRect(blackInputColorValue)
    self.m_BlackSearchRoleFrame = winMgr:getWindow("Frienddialog/blackframe/xinxi")
    self.m_BlackSearchRoleList = winMgr:getWindow("Frienddialog/blackframe/xinxi/blacklist")
    self.m_BlackTextFrame = winMgr:getWindow("Frienddialog/blackframe/text")
    self.m_BlackLengthValueTxt = winMgr:getWindow("Frienddialog/blackframe/text/blacklengthvalue")

    self.m_ChatBackgroundTips = winMgr:getWindow("Frienddialog/chatbackgroundtips")
    self.m_sendgift = CEGUI.Window.toPushButton(winMgr:getWindow("Frienddialog/chatframe/jiaohu/sendgift"))
	self:addButtonAnimation(self.m_sendgift, "studyBtnPress")
	----��������

    self.m_friendshipTop = winMgr:getWindow("Frienddialog/chatframe/xinxi/di2")
end

function FriendDialog:btnCloseCallBack(args)
    FriendDialog.DestroyDialog()
end

function FriendDialog:qunliaoBtnClicked( args )
	GetCTipsManager():AddMessageTipById(201062)
end	

--[[function FriendDialog:qunliaoBtnClicked(args)
     -- Ⱥ����Ҫ�޸�-Ŀǰ�Ǽ�Ⱥ
     -- ����һ����һ�������ڹٷ���������Ⱥ������
     -- ��������ʹ����ת���ӽ���������̳-��CE�汾��֧����Ϸ������ҳ����
      IOS_MHSD_UTILS.OpenURL("http://qm.qq.com/cgi-bin/qm/qr?_wv=1027&k=csyL5L3Zgy1pL9AvF1_nOQZMG7dEp6ee&authKey=eWjYNOk%2Fvnc1wTiVX9ChMJW%2Ba4CKrVqK5nPHoyIeuN8Su9orTBWQstTvUcVmlwfx&noverify=0&group_code=765090848")
end--]]

function FriendDialog:kefuBtnClicked(args)
     -- �ͷ�Ŀǰ�Ǽ�QQ
     -- ����һ����һ����������-����api���Խ���Ϸ����
      IOS_MHSD_UTILS.OpenURL("https://www.baidu.com")
end

function FriendDialog:initDataValue()
    FriendDialog.m_vRecentDataList = { }
    FriendDialog.m_vRecentCellList = { }
    FriendDialog.m_vFriendDataList = { }
    FriendDialog.m_vFriendCellList = { }
    FriendDialog.m_vBlackDataList = { }
    FriendDialog.m_vBlackCellList = { }
    FriendDialog.m_vMailCellList = { }
    FriendDialog.m_ChatRoleID = 0
    self.m_ContactRoleList:setVisible(false)
    self.m_FriendRoleList:setVisible(false)
    self.m_BlackRoleList:setVisible(false)
    self.m_MyFriendBtn:setVisible(false)
    self.m_MyBlackBtn:setVisible(false)
    self.m_ChatFrame:setVisible(false)
    self.m_BlackFrame:setVisible(false)
    self.m_ChatBackgroundTips:setVisible(true)
    self.m_RecentGroupBtn:setSelected(true)

    self.m_VoiceBtnLastClickTime = 0
    self.m_bRecording = false
end

function FriendDialog:initUiEvent()
    self.m_ContactGroupBtn:subscribeEvent("SelectStateChanged", FriendDialog.GroupButtonClickCallback, self)
    self.m_RecentGroupBtn:subscribeEvent("SelectStateChanged", FriendDialog.GroupButtonClickCallback, self)
    self.m_FriendRoleList:subscribeEvent("ContentPaneScrolled", FriendDialog.HandleFriendListNextPage, self)
    self.m_MyFriendBtn:subscribeEvent("SelectStateChanged", FriendDialog.HandleFriendOrBlackSelectChange, self)
    self.m_MyBlackBtn:subscribeEvent("SelectStateChanged", FriendDialog.HandleFriendOrBlackSelectChange, self)
    self.m_AddFriendBtn:subscribeEvent("Clicked", FriendDialog.HandleClickAddFriendBtn, self)
    self.m_MySpaceBtn:subscribeEvent("Clicked", FriendDialog.HandleClickMySpaceBtn, self)
    self.m_SendChatBtn:subscribeEvent("Clicked", FriendDialog.HandleClickSendChatBtn, self)
    self.m_EmotionBtn:subscribeEvent("Clicked", FriendDialog.HandleClickEmotionBtn, self)
    self.m_InputBox:subscribeEvent("EditboxFullEvent", FriendDialog.OnInputTextFull, self)
    self.m_RelationCleanBtn:subscribeEvent("Clicked", FriendDialog.HandleClickCleanBtn, self)
    self.m_BlackSearchBtn:subscribeEvent("Clicked", FriendDialog.HandleClickBlackSearchBtn, self)
    self.m_BlackInputBox:subscribeEvent("MouseClick", FriendDialog.HandleClickBlackInputBox, self)
    self.m_BlackInputBox:subscribeEvent("TextChanged", FriendDialog.OnTextChangedOfBlackInputBox, self)

    self.m_TalkBtn:subscribeEvent("MouseButtonDown", FriendDialog.HandleVoiceBegin, self)
    self.m_TalkBtn:subscribeEvent("MouseButtonUp", FriendDialog.HandleVoiceEnd, self)
    self.m_TalkBtn:subscribeEvent("MouseMove", FriendDialog.HandleVoiceMove, self)
    self.m_TalkBtn:SetMouseLeaveReleaseInput(false)
    self.m_sendgift:subscribeEvent("Clicked", FriendDialog.HandleSendGiftClick, self)

    self:GetCloseBtn():removeEvent("Clicked")
	self:GetCloseBtn():subscribeEvent("Clicked", FriendMailLabel.DestroyDialog, nil)
end

return FriendDialog
