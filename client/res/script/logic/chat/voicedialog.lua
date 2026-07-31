require "logic.dialog"

VoiceDialog = {}
setmetatable(VoiceDialog, Dialog)
VoiceDialog.__index = VoiceDialog

local _instance
function VoiceDialog.getInstance()
	if not _instance then
		_instance = VoiceDialog:new()
		_instance:OnCreate()
	end
	return _instance
end

function VoiceDialog.getInstanceAndShow()
	if not _instance then
		_instance = VoiceDialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function VoiceDialog.getInstanceNotCreate()
	return _instance
end

function VoiceDialog.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function VoiceDialog.ToggleOpenClose()
	if not _instance then
		_instance = VoiceDialog:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function VoiceDialog.GetLayoutFileName()
	return "insetyuyindialog.layout"
end

function VoiceDialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, VoiceDialog)
	return self
end

function VoiceDialog:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.enableWnd1 = winMgr:getWindow("insetyuyindialog/huakai")
	self.enableWnd2 = winMgr:getWindow("insetyuyindialog/huakaitishi")
	self.disableWnd1 = winMgr:getWindow("insetyuyindialog/songkai")
	self.disableWnd2 = winMgr:getWindow("insetyuyindialog/songkaitishi")

    local wnd = self:GetWindow()
    if wnd then
        wnd:setTopMost(true)
    end
end

function VoiceDialog:setPosition(x,y)
    local wnd = self:GetWindow()
    if wnd then
        wnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0, x), CEGUI.UDim(0, y)))
    end
end

function VoiceDialog:setVoiceRecordUI(enabled)
	local winMgr = CEGUI.WindowManager:getSingleton()

	-- 按住录音图标时，提示滑开
	if self.enableWnd1 then
		self.enableWnd1:setVisible(enabled)
	end
	if self.enableWnd2 then
		self.enableWnd2:setVisible(enabled)
	end

	-- 从录音图标滑开后，提示松开
	if self.disableWnd1 then
		self.disableWnd1:setVisible(not enabled)
	end
	if self.disableWnd2 then
		self.disableWnd2:setVisible(not enabled)
	end
end

return VoiceDialog