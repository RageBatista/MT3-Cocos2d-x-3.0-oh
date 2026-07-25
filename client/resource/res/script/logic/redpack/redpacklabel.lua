require "utils.mhsdutils"
require "logic.dialog"
require "logic.redpack.redpackdlg"

RedPackLabel = {}
setmetatable(RedPackLabel, Dialog)
RedPackLabel.__index = RedPackLabel

local _instance
local Dlgs =
{
	RedPackDlg,
    RedPackDlg,
    RedPackDlg
}
local TYPE_WORLD = 1 --世界红包
local TYPE_CLAN = 2 --公会红包
local TYPE_TEAM = 3 --队伍红包
function RedPackLabel.getInstance()
	if not _instance then
		_instance = RedPackLabel:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function RedPackLabel.getInstanceNotCreate()
	return _instance
end

function RedPackLabel.GetLayoutFileName()
	return "lable.layout"
end

function RedPackLabel:SetVisible(b)
	if self:IsVisible() ~= b and b then
	    
    end
	Dialog.SetVisible(self, b)
end

function RedPackLabel:OnCreate()
	Dialog.OnCreate(self,nil, "redpacklabel")
	self:GetWindow():setRiseOnClickEnabled(false)
	
	self.dialogs = {}
	self.curDialog = nil

	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pButton1 = CEGUI.toPushButton(winMgr:getWindow("redpacklabelLable/button"))
    self.m_pButton1:SetMouseLeaveReleaseInput(false)
	self.m_pButton2 = CEGUI.toPushButton(winMgr:getWindow("redpacklabelLable/button1"))
    self.m_pButton2:SetMouseLeaveReleaseInput(false)
	self.m_pButton3 = CEGUI.toPushButton(winMgr:getWindow("redpacklabelLable/button2"))
    self.m_pButton3:SetMouseLeaveReleaseInput(false)
	self.m_pButton4 = CEGUI.toPushButton(winMgr:getWindow("redpacklabelLable/button3"))
	self.m_pButton4:setVisible(false)

	self.buttons = {}
	self.buttons[1] = self.m_pButton1
	self.buttons[2] = self.m_pButton2
	self.buttons[3] = self.m_pButton3
	
	self.m_pButton1:setID(1)
	self.m_pButton2:setID(2)
	self.m_pButton3:setID(3)
	
	self.m_pButton1:EnableClickAni(false)
	self.m_pButton2:EnableClickAni(false)
	self.m_pButton3:EnableClickAni(false)

	self.m_pButton1:setText(MHSD_UTILS.get_resstring(11445))
	self.m_pButton2:setText(MHSD_UTILS.get_resstring(11446)) 
	self.m_pButton3:setText(MHSD_UTILS.get_resstring(11447)) 

    
	self.m_pButton1:subscribeEvent("Clicked", RedPackLabel.handleLabelBtnClicked, self)
	self.m_pButton2:subscribeEvent("Clicked", RedPackLabel.handleLabelBtnClicked, self)
    self.m_pButton3:subscribeEvent("Clicked", RedPackLabel.handleLabelBtnClicked, self)
	self.isFirstOpenCommerceDlg = true
end

function RedPackLabel:new()
	local self={}
	self = Dialog:new()
	setmetatable(self, RedPackLabel)
	return self
end

function RedPackLabel.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			for _,v in pairs(Dlgs) do
				local dlg = v.getInstanceNotCreate()
				if dlg then
					_instance:removeEvent(dlg:GetWindow())
					dlg.DestroyDialog()
				end
			end

			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function RedPackLabel.hide()
	if _instance then
		for _,v in pairs(_instance.dialogs) do
			v:SetVisible(false)
		end
		_instance:GetWindow():setVisible(false)
		_instance.isFirstOpenCommerceDlg = true
		
		if _instance.callbackWhenHide then
			_instance.callbackWhenHide()
			_instance.callbackWhenHide = nil
		end
	end
end

function RedPackLabel.show(index)
	if not _instance then
		RedPackLabel.getInstance():showOnly(index)
	else
		_instance:GetWindow():setVisible(true)
		_instance.curDialog:SetVisible(true)
        if _instance.curIdx == 1 then 
            local dlg = RedPackDlg.getInstance()
        end
		_instance:GetWindow():getParent():bringWindowAbove(_instance:GetWindow(), _instance.curDialog:GetWindow())
	end
end



function RedPackLabel:showOnly(index)
    self:setButtonPushed(index)
    if self.curIdx == index then
        return
    end 

	local manager = require"logic.redpack.redpackmanager".getInstance()
    

	if self.curDialog and self.curDialog:IsVisible() and self.curIdx == index then
        --manager.m_RedPacks = {}
        local dlg = RedPackDlg.getInstance()
        local p = require("protodef.fire.pb.fushi.redpack.csendredpackview"):new()
	    local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
        p.modeltype =index
        p.redpackid = 0
        LuaProtocolManager:send(p)
		return
	end
	self.curIdx = index
	self.curDialog = self:getDialog(RedPackDlg)

    local dlg = RedPackDlg.getInstance()
    dlg:Clear()
    dlg.m_TableView:setContentOffset(0)
    --manager.m_RedPacks = {}
    
    dlg:InitData(index)
    dlg:InitTable()
    local blnSend = false
    if index == 1 and not dlg.m_blnOpenLabel1 then
        blnSend = true
    elseif index == 2 and not dlg.m_blnOpenLabel2 then
        blnSend = true
    elseif index == 3 and not dlg.m_blnOpenLabel3 then
        blnSend = true
    end
    if blnSend then
        local p = require("protodef.fire.pb.fushi.redpack.csendredpackview"):new()
        p.modeltype =index
        p.redpackid = 0
        LuaProtocolManager:send(p)
    end

    if index == 1 then
        dlg.m_blnOpenLabel1 = true
    elseif index == 2 then
        dlg.m_blnOpenLabel2 = true
    elseif index == 3 then
        dlg.m_blnOpenLabel3 = true
    end
	self:SetVisible(true)
	self.dialogs[1] = self.curDialog
	self:GetWindow():getParent():bringWindowAbove(self:GetWindow(), self.curDialog:GetWindow())
end

function RedPackLabel:getDialog(Dlg)
	local dlg = Dlg.getInstanceNotCreate()
	if not dlg then
		dlg = Dlg.getInstanceAndShow()
		self:subscribeEvent(dlg:GetWindow())
	else
		dlg:SetVisible(true)
	end
	return dlg
end

function RedPackLabel:setButtonPushed(idx)
	for i,v in pairs(self.buttons) do
		v:SetPushState(i==idx)
	end
end

function RedPackLabel:subscribeEvent(wnd)
	wnd:subscribeEvent("AlphaChanged", RedPackLabel.handleDlgStateChange, self)
	wnd:subscribeEvent("Shown", RedPackLabel.handleDlgStateChange, self)
	wnd:subscribeEvent("Hidden", RedPackLabel.handleDlgStateChange, self)
	wnd:subscribeEvent("InheritAlphaChanged", RedPackLabel.handleDlgStateChange, self)
    wnd:subscribeEvent("ZChanged", RedPackLabel.handleDlgStateChange, self)
end

function RedPackLabel:removeEvent(wnd)
	wnd:removeEvent("AlphaChanged")
	wnd:removeEvent("Shown")
	wnd:removeEvent("Hidden")
	wnd:removeEvent("InheritAlphaChanged")
    wnd:removeEvent("ZChanged")
end

function RedPackLabel:handleDlgStateChange(args)
	for _,v in pairs(Dlgs) do
		local dlg = v.getInstanceNotCreate()
        local curWnd = dlg.getInstanceNotCreate():GetWindow()
		if dlg and dlg:IsVisible() and dlg:GetWindow():getEffectiveAlpha() > 0.95 then
			self:SetVisible(true)
			self:GetWindow():getParent():bringWindowAbove(self:GetWindow(), curWnd)
			return true
		end
	end
	self:SetVisible(false)
end

function RedPackLabel:handleLabelBtnClicked(e)
	local idx = CEGUI.toWindowEventArgs(e).window:getID()
	self:showOnly(idx)
end

return RedPackLabel
