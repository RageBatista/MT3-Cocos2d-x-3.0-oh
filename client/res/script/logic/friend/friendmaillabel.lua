require "utils.mhsdutils"
require "logic.dialog"
require "logic.LabelDlg"
require "logic.friend.frienddialog"
require "logic.friend.maildialog"
require "logic.recruit.recruitdlg"

FriendMailLabel = {}
setmetatable(FriendMailLabel, Dialog)
FriendMailLabel.__index = FriendMailLabel

local _instance
local Dlgs =
{
	FriendDialog,
	MailDialog,
    RecruitDlg
}

local ZhaoMuVisibleLabel = 1

function FriendMailLabel.getInstance()
	if not _instance then
		_instance = FriendMailLabel:new()
		_instance:OnCreate()
	end
	return _instance
end

function FriendMailLabel.getInstanceNotCreate()
	return _instance
end

function FriendMailLabel.GetLayoutFileName()
	return "lablekkb.layout"
end

function FriendMailLabel:OnCreate()
	local prefix = enumLabel.enumFriendMailLabel
	Dialog.OnCreate(self,nil, prefix)
	self:GetWindow():setRiseOnClickEnabled(false)
	
	self.curDialog = nil
	
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pButton1 = CEGUI.toPushButton(winMgr:getWindow(tostring(prefix) .. "Lable/button"))
    self.m_pButton1:SetMouseLeaveReleaseInput(false)
	self.m_pButton2 = CEGUI.toPushButton(winMgr:getWindow(tostring(prefix) .. "Lable/button1"))
    self.m_pButton2:SetMouseLeaveReleaseInput(false)
	self.m_pButton3 = CEGUI.toPushButton(winMgr:getWindow(tostring(prefix) .. "Lable/button2"))
    self.m_pButton3:SetMouseLeaveReleaseInput(false)
	self.m_pButton4 = CEGUI.toPushButton(winMgr:getWindow(tostring(prefix) .. "Lable/button3"))
    self.m_pButton4:SetMouseLeaveReleaseInput(false)
	self.m_pButton5 = CEGUI.toPushButton(winMgr:getWindow(tostring(prefix) .. "Lable/button4"))
    self.m_pButton5:SetMouseLeaveReleaseInput(false)

    self.m_friendNotify = winMgr:getWindow(tostring(prefix) .. "Lable/button/image1")
    self.m_mailNotify = winMgr:getWindow(tostring(prefix) .. "Lable/button/image2")

	self.m_pButton1:setText(MHSD_UTILS.get_resstring(11599))
	self.m_pButton2:setText(MHSD_UTILS.get_resstring(11600))
	self.m_pButton3:setText(MHSD_UTILS.get_resstring(11631))

    if ZhaoMuVisibleLabel == 0 then
        self.m_pButton3:setVisible(false)
    end

	self.m_pButton4:setVisible(false)
	self.m_pButton5:setVisible(false)
	
	self.m_pButton1:EnableClickAni(false)
	self.m_pButton2:EnableClickAni(false)
	self.m_pButton3:EnableClickAni(false)
	self.m_pButton4:EnableClickAni(false)
	self.m_pButton5:EnableClickAni(false)
	
	self.m_pButton1:subscribeEvent("Clicked", FriendMailLabel.HandleLabel1BtnClicked, self)
	self.m_pButton2:subscribeEvent("Clicked", FriendMailLabel.HandleLabel2BtnClicked, self)
    self.m_pButton3:subscribeEvent("Clicked", FriendMailLabel.HandleLabel3BtnClicked, self)
    FriendMailLabel.checkRedPoint()
end

function FriendMailLabel.setZhaoMuOpenStatus(status)
    ZhaoMuVisibleLabel = status
end

function FriendMailLabel:new()
	local self={}
	self = Dialog:new()
	setmetatable(self, FriendMailLabel)
	return self
end

function FriendMailLabel.DestroyDialog()	
	if _instance then
		for _,v in pairs(Dlgs) do
			local dlg = v.getInstanceNotCreate()
			if dlg then
				_instance:removeEvent(dlg:GetWindow())
				dlg.DestroyDialog()
			end
		end
		_instance:OnClose()
		_instance = nil
	end
end

function FriendMailLabel.Show(index)
	FriendMailLabel.getInstance()
	index = index or  1
	_instance:ShowOnly(index)
end

function FriendMailLabel.checkRedPoint()
        if _instance then
            local nFriendMsgNum = gGetFriendsManager():GetNotReadMsgNum()
            local nMailMsgNum = require("logic.friend.maildialog").GlobalGetMailNotReadNum()

            if nMailMsgNum > 0 then
                _instance.m_mailNotify:setVisible(true)
            else
                _instance.m_mailNotify:setVisible(false)
            end

            if nFriendMsgNum > 0 then
                _instance.m_friendNotify:setVisible(true)
            else
                _instance.m_friendNotify:setVisible(false)
	        end
        end
end


function FriendMailLabel:setButtonPushed(idx)
	for i=1,4 do
		self["m_pButton" .. i]:SetPushState(i==idx)
	end
end

function FriendMailLabel:ShowOnly(index)
	self:setButtonPushed(index)
	
	if self.curDialog then
		self.curDialog:SetVisible(false)
	end

	self.curIdx = index

	if index == 1 then
		self.curDialog = self:getDialog(FriendDialog)
	elseif index == 2 then
		self.curDialog = self:getDialog(MailDialog)
    elseif index == 3 then
        self.curDialog = self:getDialog(RecruitDlg)
	end

	self:SetVisible(true)
	self:GetWindow():getParent():bringWindowAbove(self:GetWindow(), self.curDialog:GetWindow())
end

function FriendMailLabel:getDialog(Dlg)
	local dlg = Dlg.getInstanceNotCreate()
	if not dlg then
		dlg = Dlg.getInstanceAndShow()
		self:subscribeEvent(dlg:GetWindow())
	else
		dlg:SetVisible(true)
	end
	return dlg
end

function FriendMailLabel:HandleLabel1BtnClicked(e)
	FriendMailLabel.getInstance():ShowOnly(1)
	return true
end

function FriendMailLabel:HandleLabel2BtnClicked(e)
	FriendMailLabel.getInstance():ShowOnly(2)
	return true
end

function FriendMailLabel:HandleLabel3BtnClicked(e)
	FriendMailLabel.getInstance():ShowOnly(3)
	return true
end
function FriendMailLabel:subscribeEvent(wnd)
	wnd:subscribeEvent("AlphaChanged", FriendMailLabel.HandleDlgStateChange, self)
	wnd:subscribeEvent("Shown", FriendMailLabel.HandleDlgStateChange, self)
	wnd:subscribeEvent("Hidden", FriendMailLabel.HandleDlgStateChange, self)
	wnd:subscribeEvent("InheritAlphaChanged", FriendMailLabel.HandleDlgStateChange, self)
end

function FriendMailLabel:removeEvent(wnd)
	wnd:removeEvent("AlphaChanged")
	wnd:removeEvent("Shown")
	wnd:removeEvent("Hidden")
	wnd:removeEvent("InheritAlphaChanged")
end

function FriendMailLabel:HandleDlgStateChange(args)
	if not self.curIdx or not Dlgs[self.curIdx] or not Dlgs[self.curIdx].getInstanceNotCreate() then
		return
	end
	local curWnd = Dlgs[self.curIdx].getInstanceNotCreate():GetWindow()
	for _,v in pairs(Dlgs) do
		local dlg = v.getInstanceNotCreate()
		if dlg and dlg:IsVisible() and dlg:GetWindow():getEffectiveAlpha() > 0.95 then
			self:SetVisible(true)
			self:GetWindow():getParent():bringWindowAbove(self:GetWindow(), curWnd)
			return true
		end
	end
	
	self:SetVisible(false)
end




return FriendMailLabel
