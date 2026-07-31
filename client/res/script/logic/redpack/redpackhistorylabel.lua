require "utils.mhsdutils"
require "logic.dialog"
require "logic.redpack.redpackhistorydlg"

RedPackHistoryLabel = {}
setmetatable(RedPackHistoryLabel, Dialog)
RedPackHistoryLabel.__index = RedPackHistoryLabel

local _instance
local Dlgs =
{
	RedPackHistoryDlg
}
local TYPE_SEND =0  --·¢
local TYPE_RECEIVE = 1 --ÊÕ
function RedPackHistoryLabel.getInstance()
	if not _instance then
		_instance = RedPackHistoryLabel:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function RedPackHistoryLabel.getInstanceNotCreate()
	return _instance
end

function RedPackHistoryLabel.GetLayoutFileName()
	return "lable.layout"
end

function RedPackHistoryLabel:SetVisible(b)
	if self:IsVisible() ~= b and b then
	    
    end
	Dialog.SetVisible(self, b)
end

function RedPackHistoryLabel:OnCreate()
	Dialog.OnCreate(self,nil, "RedPackHistoryLabel")
	self:GetWindow():setRiseOnClickEnabled(false)
	
	self.dialogs = {}
	self.curDialog = nil

	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pButton1 = CEGUI.toPushButton(winMgr:getWindow("RedPackHistoryLabelLable/button"))
    self.m_pButton1:SetMouseLeaveReleaseInput(false)
	self.m_pButton2 = CEGUI.toPushButton(winMgr:getWindow("RedPackHistoryLabelLable/button1"))
    self.m_pButton2:SetMouseLeaveReleaseInput(false)
	self.m_pButton3 = CEGUI.toPushButton(winMgr:getWindow("RedPackHistoryLabelLable/button2"))
    self.m_pButton3:setVisible(false)
	self.m_pButton4 = CEGUI.toPushButton(winMgr:getWindow("RedPackHistoryLabelLable/button3"))
	self.m_pButton4:setVisible(false)
    self.m_pButton1:setRiseOnClickEnabled(false)
    self.m_pButton2:setRiseOnClickEnabled(false)
    self.m_pButton1:setPosition(CEGUI.UVector2(CEGUI.UDim(0.5, self.m_pButton1:getPosition().x.offset -38), CEGUI.UDim(0.5, self.m_pButton1:getPosition().y.offset + 60)))
    self.m_pButton2:setPosition(CEGUI.UVector2(CEGUI.UDim(0.5, self.m_pButton2:getPosition().x.offset -38), CEGUI.UDim(0.5, self.m_pButton2:getPosition().y.offset + 60)))
    
	self.buttons = {}
	self.buttons[1] = self.m_pButton1
	self.buttons[2] = self.m_pButton2
	
	self.m_pButton1:setID(1)
	self.m_pButton2:setID(2)
	
	self.m_pButton1:EnableClickAni(false)
	self.m_pButton2:EnableClickAni(false)

	self.m_pButton2:setText(MHSD_UTILS.get_resstring(11455))
	self.m_pButton1:setText(MHSD_UTILS.get_resstring(11456)) 

    
	self.m_pButton1:subscribeEvent("Clicked", RedPackHistoryLabel.handleLabelBtnClicked, self)
	self.m_pButton2:subscribeEvent("Clicked", RedPackHistoryLabel.handleLabelBtnClicked, self)
	self.isFirstOpenCommerceDlg = true

    self.m_index = 1
end
function RedPackHistoryLabel:new()
	local self={}
	self = Dialog:new()
	setmetatable(self, RedPackHistoryLabel)
	return self
end

function RedPackHistoryLabel.DestroyDialog()
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

function RedPackHistoryLabel.hide()
	if _instance then
        local index = _instance.m_index
		for _,v in pairs(_instance.dialogs) do
			v:SetVisible(false)
		end
		_instance:GetWindow():setVisible(false)
		_instance.isFirstOpenCommerceDlg = true
		
		if _instance.callbackWhenHide then
			_instance.callbackWhenHide()
			_instance.callbackWhenHide = nil
		end
        require("logic.redpack.redpacklabel")
        RedPackLabel.DestroyDialog()
        RedPackLabel.show(index)
	end
end

function RedPackHistoryLabel.show(index)
	if not _instance then
		RedPackHistoryLabel.getInstance():showOnly(1)
        RedPackHistoryLabel.getInstance().m_index = index
	else
		_instance:GetWindow():setVisible(true)
		_instance.curDialog:SetVisible(true)
        if _instance.curIdx == 1 then 
            local dlg = RedPackHistoryLabel.getInstance()
--	        if dlg then
--                dlg:refresh()
--            end
        end
		_instance:GetWindow():getParent():bringWindowAbove(_instance:GetWindow(), _instance.curDialog:GetWindow())
	end
end

function RedPackHistoryLabel:showOnly(index)
    self:setButtonPushed(index)
    if self.curIdx == index then
        return
    end 

	local manager = require"logic.redpack.redpackmanager".getInstance()
    

	if self.curDialog and self.curDialog:IsVisible() and self.curIdx == index then
        --manager.m_RedPacks = {}
        local dlg = m_HistoryRedPack.getInstance()

        local p = require("protodef.fire.pb.fushi.redpack.csendredpackrolerecordview"):new()
        p.modeltype = index - 1
        p.redpackid = 0
        LuaProtocolManager:send(p)
		return
	end
	self.curIdx = index
	self.curDialog = self:getDialog(RedPackHistoryDlg)

    local dlg = RedPackHistoryDlg.getInstance()
    dlg:Clear()
    dlg.m_TableView:setContentOffset(0)
    manager.m_HistoryRedPack = {}
    
    dlg:InitData(index)
    local p = require("protodef.fire.pb.fushi.redpack.csendredpackrolerecordview"):new()
    p.modeltype = index - 1
    p.redpackid = 0
    LuaProtocolManager:send(p)
	self:SetVisible(true)
	self.dialogs[1] = self.curDialog
	self:GetWindow():getParent():bringWindowAbove(self:GetWindow(), self.curDialog:GetWindow())
end

function RedPackHistoryLabel:getDialog(Dlg)
	local dlg = Dlg.getInstanceNotCreate()
	if not dlg then
		dlg = Dlg.getInstanceAndShow()
		self:subscribeEvent(dlg:GetWindow())
	else
		dlg:SetVisible(true)
	end
	return dlg
end

function RedPackHistoryLabel:setButtonPushed(idx)
	for i,v in pairs(self.buttons) do
		v:SetPushState(i==idx)
	end
end

function RedPackHistoryLabel:subscribeEvent(wnd)
	wnd:subscribeEvent("AlphaChanged", RedPackHistoryLabel.handleDlgStateChange, self)
	wnd:subscribeEvent("Shown", RedPackHistoryLabel.handleDlgStateChange, self)
	wnd:subscribeEvent("Hidden", RedPackHistoryLabel.handleDlgStateChange, self)
	wnd:subscribeEvent("InheritAlphaChanged", RedPackHistoryLabel.handleDlgStateChange, self)
end

function RedPackHistoryLabel:removeEvent(wnd)
	wnd:removeEvent("AlphaChanged")
	wnd:removeEvent("Shown")
	wnd:removeEvent("Hidden")
	wnd:removeEvent("InheritAlphaChanged")
end

function RedPackHistoryLabel:handleDlgStateChange(args)
	for _,v in pairs(Dlgs) do
		local dlg = v.getInstanceNotCreate()
		if dlg and dlg:IsVisible() and dlg:GetWindow():getEffectiveAlpha() > 0.95 then
			self:SetVisible(true)
			return true
		end
	end
	self:SetVisible(false)
end

function RedPackHistoryLabel:handleLabelBtnClicked(e)
	local idx = CEGUI.toWindowEventArgs(e).window:getID()
	self:showOnly(idx)
end

return RedPackHistoryLabel
