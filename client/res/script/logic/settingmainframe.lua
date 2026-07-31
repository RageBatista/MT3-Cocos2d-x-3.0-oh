require "logic.dialog"
require "logic.systemsettingdlgnew"
require "logic.systemsettingtuisongdlg"
require "logic.LabelDlg"

SettingMainFrame = {}

setmetatable(SettingMainFrame, Dialog)
SettingMainFrame.__index = SettingMainFrame

local _instance;

function SettingMainFrame.getInstance()
	if not _instance then
		_instance = SettingMainFrame:new()
		_instance:OnCreate()
	end
	
	return _instance
end

function SettingMainFrame.getInstanceAndShow()
	LogInfo("____SettingMainFrame.getInstanceAndShow")
	if not _instance then
		_instance = SettingMainFrame:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	
	return _instance
end

function SettingMainFrame.getInstanceNotCreate()
	return _instance
end

function SettingMainFrame.DestroyDialog()
	LogInfo("____SettingMainFrame.DestroyDialog")

	if _instance then
		_instance:OnClose()
		_instance = nil		
		
		local dlg = SystemSettingNewDlg.getInstanceNotCreate()
		if dlg then
			dlg.DestroyDialog()
		end
		
		dlg = SystemsettingTuiSongDlg.getInstanceNotCreate()
		if dlg then
			dlg.DestroyDialog()
		end
	end
end

function SettingMainFrame.GetLayoutFileName()
	return "Lable.layout"
end

function SettingMainFrame:OnCreate()
	LogInfo("____enter SettingMainFrame:OnCreate")
	
	--xiaolong dabao need to modify
	local prefix = enumLabel.enumSettingLabel
	Dialog.OnCreate(self, nil, prefix)
	self:GetWindow():setRiseOnClickEnabled(false)
	--Dialog.OnCreate(self, nil, prefix)
	
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pButton1 = CEGUI.toPushButton(winMgr:getWindow(tostring(prefix) .. "Lable/button"))
    self.m_pButton1:SetMouseLeaveReleaseInput(false)

	self.m_pButton2 = CEGUI.toPushButton(winMgr:getWindow(tostring(prefix) .. "Lable/button1"))
    self.m_pButton2:SetMouseLeaveReleaseInput(false)

	self.m_pButton3 = winMgr:getWindow(tostring(prefix) .. "Lable/button2")
--    self.m_pButton3:SetMouseLeaveReleaseInput(false)
	self.m_pButton4 = winMgr:getWindow(tostring(prefix) .. "Lable/button3")
	self.m_pButton5 = winMgr:getWindow(tostring(prefix) .. "Lable/button4")
    self.m_pButton3:setVisible(false)
	self.m_pButton4:setVisible(false)
	self.m_pButton5:setVisible(false)

    self.m_pButton1:EnableClickAni(false)
    self.m_pButton2:EnableClickAni(false)
--    self.m_pButton3:EnableClickAni(false)
	
	self.m_pButton1:setText(BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(2889).msg)
	self.m_pButton2:setText(BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(2993).msg)
--	self.m_pButton3:setText(BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(2890).msg)
	
	self.m_pButton1:subscribeEvent("Clicked", SettingMainFrame.HandleLabel1BtnClicked, self)
    --self.m_pButton2:subscribeEvent("Clicked", SettingMainFrame.HandleLabel2BtnClicked, self)
	--self.m_pButton3:subscribeEvent("Clicked", SettingMainFrame.HandleButton3Clicked, self)
	
	LogInfo("____exit SettingMainFrame:OnCreate")
end

function SettingMainFrame:setButtonPushed(idx)
	if idx == 1 then
		self.m_pButton1:SetPushState(true)
		self.m_pButton2:SetPushState(false)
	elseif idx == 2 then
		self.m_pButton1:SetPushState(false)
		self.m_pButton2:SetPushState(true)
	end
end

function SettingMainFrame:ShowOnly(index)
	self:setButtonPushed(index)
	
	if SystemSettingNewDlg.getInstanceNotCreate() then
		SystemSettingNewDlg.getInstanceNotCreate():GetWindow():setVisible(false)
	end
	if SystemsettingTuiSongDlg.getInstanceNotCreate() then
		SystemsettingTuiSongDlg.getInstanceNotCreate():GetWindow():setVisible(false)
	end
	
	if index == 1 then
		local dlg = SystemSettingNewDlg.getInstanceNotCreate()
		if not dlg then
			dlg = SystemSettingNewDlg.getInstanceAndShow()
			self:SubscribeEvent(dlg:GetWindow())
		else
			dlg:SetVisible(true)
		end

		self:GetWindow():getParent():bringWindowAbove(self:GetWindow(), dlg:GetWindow())
		
	elseif index == 2 then
		local dlg = SystemsettingTuiSongDlg.getInstanceNotCreate()
		if not dlg then
			dlg = SystemsettingTuiSongDlg.getInstanceAndShow()
			self:SubscribeEvent(dlg:GetWindow())
		else
			dlg:SetVisible(true)
		end

		self:GetWindow():getParent():bringWindowAbove(self:GetWindow(), dlg:GetWindow())
	end

	self:SetVisible(true)
end

function SettingMainFrame:HandleLabel1BtnClicked(e)
	SettingMainFrame.getInstance():ShowOnly(1)
	return true
end
function SettingMainFrame:HandleLabel2BtnClicked(e)
	SettingMainFrame.getInstance():ShowOnly(2)
	return true
end

function SettingMainFrame:SubscribeEvent(wnd)
	wnd:subscribeEvent("AlphaChanged", SettingMainFrame.HandleDlgStateChange, self)
	wnd:subscribeEvent("Shown", SettingMainFrame.HandleDlgStateChange, self)
	wnd:subscribeEvent("Hidden", SettingMainFrame.HandleDlgStateChange, self)
	wnd:subscribeEvent("InheritAlphaChanged", SettingMainFrame.HandleDlgStateChange, self)
end

function SettingMainFrame:RemoveEvent(wnd)
	wnd:removeEvent("AlphaChanged")
	wnd:removeEvent("Shown")
	wnd:removeEvent("Hidden")
	wnd:removeEvent("InheritAlphaChanged")
end

function SettingMainFrame:HandleDlgStateChange(args)
	local dlg = SystemSettingNewDlg.getInstanceNotCreate()
	if dlg and dlg:IsVisible() and dlg:GetWindow():getEffectiveAlpha() > 0.95 then
		self:SetVisible(true)
		return
	end
	
	dlg = SystemsettingTuiSongDlg.getInstanceNotCreate()
	if dlg and dlg:IsVisible() and dlg:GetWindow():getEffectiveAlpha() > 0.95 then
		self:SetVisible(true)
		return
	end
	
	self:SetVisible(false)
end

function SettingMainFrame.show(index)
	index = index or 1
	SettingMainFrame.getInstance()
	_instance:ShowOnly(index)
end

function SettingMainFrame:SetVisible(b)
	self.m_pButton1:setVisible(b)
	self.m_pButton2:setVisible(b)
--	self.m_pButton3:setVisible(b)
--	self.m_pMainFrame:setVisible(b)
end

function SettingMainFrame:ShowWindow(w)

end
function SettingMainFrame:CheckLockHandler(status)

end

function SettingMainFrame:HandleButton1Clicked(arg)
end
function SettingMainFrame:HandleButton2Clicked(arg)
end
function SettingMainFrame:HandleButton3Clicked(arg)
end

function SettingMainFrame:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, SettingMainFrame)
	return self
end

return SettingMainFrame
