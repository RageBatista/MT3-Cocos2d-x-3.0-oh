require "utils.mhsdutils"
require "logic.dialog"
require "logic.guide.guidecoursedlg"

--成就系统label
GuideLabel = {}
setmetatable(GuideLabel, Dialog)
GuideLabel.__index = GuideLabel

local _instance
local Dlgs =
{
	GuideCourseDlg
}

function GuideLabel.getInstance()
	if not _instance then
		_instance = GuideLabel:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function GuideLabel.getInstanceNotCreate()
	return _instance
end

function GuideLabel.GetLayoutFileName()
	return "lablekong.layout"
end

function GuideLabel:SetVisible(b)
	if self:IsVisible() ~= b and b then
	    
    end
	Dialog.SetVisible(self, b)
end

function GuideLabel:OnCreate()
	Dialog.OnCreate(self,nil, "guidelable")
	self:GetWindow():setRiseOnClickEnabled(false)
	
	self.dialogs = {}
	self.curDialog = nil

	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pButton1 = CEGUI.toPushButton(winMgr:getWindow("guidelableLable/button"))
    self.m_pButton1:SetMouseLeaveReleaseInput(false)
	self.m_pButton2 = CEGUI.toPushButton(winMgr:getWindow("guidelableLable/button1"))
    self.m_pButton2:SetMouseLeaveReleaseInput(false)
	self.m_pButton3 = CEGUI.toPushButton(winMgr:getWindow("guidelableLable/button2"))
    self.m_pButton3:SetMouseLeaveReleaseInput(false)
	self.m_pButton4 = CEGUI.toPushButton(winMgr:getWindow("guidelableLable/button3"))
	self.m_pButton4:setVisible(false)
    self.m_pButton2:setVisible(false)
    self.m_pButton3:setVisible(false)

    --self.m_pButton1:setPosition(CEGUI.UVector2(CEGUI.UDim(0, self.m_pButton1:getPosition().x.offset +30), CEGUI.UDim(0, self.m_pButton1:getPosition().y.offset)))
    --self.m_pButton2:setPosition(CEGUI.UVector2(CEGUI.UDim(0, self.m_pButton2:getPosition().x.offset +30), CEGUI.UDim(0, self.m_pButton2:getPosition().y.offset)))
    --self.m_pButton3:setPosition(CEGUI.UVector2(CEGUI.UDim(0, self.m_pButton3:getPosition().x.offset +30), CEGUI.UDim(0, self.m_pButton3:getPosition().y.offset)))

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

	self.m_pButton1:setText(MHSD_UTILS.get_resstring(11304))
	self.m_pButton2:setText(MHSD_UTILS.get_resstring(11303)) 
	self.m_pButton3:setText(MHSD_UTILS.get_resstring(11305)) 

    
	self.m_pButton1:subscribeEvent("Clicked", GuideLabel.handleLabelBtnClicked, self)
	
	self.isFirstOpenCommerceDlg = true
end

function GuideLabel:new()
	local self={}
	self = Dialog:new()
	setmetatable(self, GuideLabel)
	return self
end

function GuideLabel.DestroyDialog()
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

function GuideLabel.hide()
	if _instance then
		for _,v in pairs(_instance.dialogs) do
			v:SetVisible(false)
		end
        if _instance.curIdx == 1 then 
            local manager = require "logic.guide.guidemanager".getInstance()
		    manager:HasHongdian()
        end
		_instance:GetWindow():setVisible(false)
		_instance.isFirstOpenCommerceDlg = true
		
		if _instance.callbackWhenHide then
			_instance.callbackWhenHide()
			_instance.callbackWhenHide = nil
		end
	end
end

function GuideLabel.show()
	if not _instance then
		GuideLabel.getInstance():showOnly(1)
	else
		_instance:GetWindow():setVisible(true)
		_instance.curDialog:SetVisible(true)
        if _instance.curIdx == 1 then 
            local dlg = GuideCourseDlg.getInstance()
	        if dlg then
                dlg:refresh()
            end
        end
		_instance:GetWindow():getParent():bringWindowAbove(_instance:GetWindow(), _instance.curDialog:GetWindow())
	end
end



function GuideLabel:showOnly(index)
    self:setButtonPushed(index)
    if self.curIdx == index then
        return
    end 

	
	if self.curDialog and self.curDialog:IsVisible() and self.curIdx == index then
        if index == 1 then
            local dlg = GuideCourseDlg.getInstance()
	        if dlg then
                dlg:refresh()
            end
        end
		return
	end
	self.curIdx = index
	
	if self.curDialog then
		self.curDialog:SetVisible(false)
	end
	
	if index == 1 then
		self.curDialog = self:getDialog(GuideCourseDlg)
        local dlg = GuideCourseDlg.getInstance()
	    if dlg then
            dlg:refresh()
        end
	elseif index == 2 then
--		self.curDialog = self:getDialog(GuideCourseDlg)
--        local dlg = GuideCourseDlg.getInstance()
--	    if dlg then
--            dlg:refresh()
--        end
	elseif index == 3 then
		--self.curDialog = self:getDialog(GuideCourseDlg)
	end
	
	self:SetVisible(true)
	self.dialogs[index] = self.curDialog
	self:GetWindow():getParent():bringWindowAbove(self:GetWindow(), self.curDialog:GetWindow())
end

function GuideLabel:getDialog(Dlg)
	local dlg = Dlg.getInstanceNotCreate()
	if not dlg then
		dlg = Dlg.getInstanceAndShow()
		self:subscribeEvent(dlg:GetWindow())
	else
		dlg:SetVisible(true)
	end
	return dlg
end

function GuideLabel:setButtonPushed(idx)
	for i,v in pairs(self.buttons) do
		v:SetPushState(i==idx)
	end
end

function GuideLabel:subscribeEvent(wnd)
	wnd:subscribeEvent("AlphaChanged", GuideLabel.handleDlgStateChange, self)
	wnd:subscribeEvent("Shown", GuideLabel.handleDlgStateChange, self)
	wnd:subscribeEvent("Hidden", GuideLabel.handleDlgStateChange, self)
	wnd:subscribeEvent("InheritAlphaChanged", GuideLabel.handleDlgStateChange, self)
end

function GuideLabel:removeEvent(wnd)
	wnd:removeEvent("AlphaChanged")
	wnd:removeEvent("Shown")
	wnd:removeEvent("Hidden")
	wnd:removeEvent("InheritAlphaChanged")
end

function GuideLabel:handleDlgStateChange(args)
	for _,v in pairs(Dlgs) do
		local dlg = v.getInstanceNotCreate()
		if dlg and dlg:IsVisible() and dlg:GetWindow():getEffectiveAlpha() > 0.95 then
			self:SetVisible(true)
			return true
		end
	end
	self:SetVisible(false)
end

function GuideLabel:handleLabelBtnClicked(e)
	local idx = CEGUI.toWindowEventArgs(e).window:getID()
	self:showOnly(idx)
end

return GuideLabel
