require "logic.dialog"

RoleAccusation = { }
setmetatable(RoleAccusation, Dialog)
RoleAccusation.__index = RoleAccusation

local _instance
function RoleAccusation.getInstance()
	if not _instance then
		_instance = RoleAccusation:new()
		_instance:OnCreate()
	end
	return _instance
end

function RoleAccusation.getInstanceAndShow()
	if not _instance then
		_instance = RoleAccusation:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function RoleAccusation.getInstanceNotCreate()
	return _instance
end

function RoleAccusation.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function RoleAccusation.ToggleOpenClose()
	if not _instance then
		_instance = RoleAccusation:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function RoleAccusation.GetLayoutFileName()
	return "jubao_mtg.layout"
end

function RoleAccusation:new()
	local self = { }
	self = Dialog:new()
	setmetatable(self, RoleAccusation)
	return self
end

function RoleAccusation:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_Name = winMgr:getWindow("jubao_mtg/name")
	self.placeHolder = winMgr:getWindow("jubao_mtg/part2/bg/text")

	self.m_Reason = CEGUI.toRichEditbox(winMgr:getWindow("jubao_mtg/part2/bg/richeditbox"))
	self.m_Reason:setMaxTextLength(100)
	self.m_Reason:subscribeEvent("EditboxFullEvent", RoleAccusation.OnInputBoxFull, self)
	self.m_Reason:subscribeEvent("KeyboardTargetWndChanged", RoleAccusation.OnKeyboardTargetWndChanged, self)

	self.m_CancelBtn = CEGUI.toPushButton(winMgr:getWindow("jubao_mtg/part3/btn1"))
	self.m_CancelBtn:subscribeEvent("Clicked", RoleAccusation.CancelBtnCallBack, self)

	self.m_CorfimBtn = CEGUI.toPushButton(winMgr:getWindow("jubao_mtg/part3/btn2"))
	self.m_CorfimBtn:subscribeEvent("Clicked", RoleAccusation.CorfimBtnCallBack, self)

	self.m_ReasonBtn_1 = CEGUI.toGroupButton(winMgr:getWindow("jubao_mtg/part1/btn1"))
	self.m_ReasonBtn_2 = CEGUI.toGroupButton(winMgr:getWindow("jubao_mtg/part1/btn2"))
	self.m_ReasonBtn_3 = CEGUI.toGroupButton(winMgr:getWindow("jubao_mtg/part1/btn3"))
	self.m_ReasonBtn_4 = CEGUI.toGroupButton(winMgr:getWindow("jubao_mtg/part1/btn4"))
	self.m_ReasonBtn_5 = CEGUI.toGroupButton(winMgr:getWindow("jubao_mtg/part1/btn5"))
	self.m_ReasonBtn_6 = CEGUI.toGroupButton(winMgr:getWindow("jubao_mtg/part1/btn6"))
	self.m_ReasonBtn_1:subscribeEvent("SelectStateChanged", RoleAccusation.ReasonBtnCallBack, self)
	self.m_ReasonBtn_2:subscribeEvent("SelectStateChanged", RoleAccusation.ReasonBtnCallBack, self)
	self.m_ReasonBtn_3:subscribeEvent("SelectStateChanged", RoleAccusation.ReasonBtnCallBack, self)
	self.m_ReasonBtn_4:subscribeEvent("SelectStateChanged", RoleAccusation.ReasonBtnCallBack, self)
	self.m_ReasonBtn_5:subscribeEvent("SelectStateChanged", RoleAccusation.ReasonBtnCallBack, self)
	self.m_ReasonBtn_6:subscribeEvent("SelectStateChanged", RoleAccusation.ReasonBtnCallBack, self)

	self.m_ReasonID = 0
	self.m_RoleID = 0
	self.m_Content = 0
	self.m_Fushi = 0
	self.m_RoleLv = 0
end

function RoleAccusation:Init(roleid, rolename)
	self.m_RoleID = roleid

	self.m_Name:setText(rolename)
end

function RoleAccusation:OnInputBoxFull(e)
	local tips = MHSD_UTILS.get_resstring(1449)
	GetCTipsManager():AddMessageTip(tips)
end

function RoleAccusation:OnKeyboardTargetWndChanged(e)
	local wnd = CEGUI.toWindowEventArgs(e).window
	if wnd == self.m_Reason then
		self.placeHolder:setVisible(false)
	else
		if self.m_Reason:GetCharCount() == 0 then
			self.placeHolder:setVisible(true)
		end
	end
end

function RoleAccusation:CancelBtnCallBack(e)
	RoleAccusation.DestroyDialog()
end

function RoleAccusation:CorfimBtnCallBack(e)
	if self.m_ReasonID == 6 and self.m_Reason:GetCharCount() == 0 then
		GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(162139))
		return
	end

	if self.m_ReasonID == 0 then
		GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(162140))
		return
	end

	self.m_Content = self.m_Reason:GetPureText()
	if self.m_Reason:GetCharCount() == 0 then 
		self.m_Content = "NULL"
	end

	local roleInf = gGetFriendsManager():GetContactRole(self.m_RoleID)
	self.m_RoleLv = roleInf.rolelevel

	local chatCmd = require "protodef.fire.pb.game.croleaccusationcheck".Create()
	LuaProtocolManager.getInstance():send(chatCmd)
end

function RoleAccusation:ReasonBtnCallBack(e)
	local wndArgs = CEGUI.toWindowEventArgs(e)
	local strWndName = wndArgs.window:getName()
	if strWndName == "jubao_mtg/part1/btn1" then
		self.m_ReasonID = 1
	elseif strWndName == "jubao_mtg/part1/btn2" then
		self.m_ReasonID = 2
	elseif strWndName == "jubao_mtg/part1/btn3" then
		self.m_ReasonID = 3
	elseif strWndName == "jubao_mtg/part1/btn4" then
		self.m_ReasonID = 4
	elseif strWndName == "jubao_mtg/part1/btn5" then
		self.m_ReasonID = 5
	elseif strWndName == "jubao_mtg/part1/btn6" then
		self.m_ReasonID = 6
	end
end

return RoleAccusation