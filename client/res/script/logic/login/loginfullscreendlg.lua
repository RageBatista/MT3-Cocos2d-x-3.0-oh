require "logic.dialog"

LoadingFullScreenDlg = {}
setmetatable(LoadingFullScreenDlg, Dialog)
LoadingFullScreenDlg.__index = LoadingFullScreenDlg

local _instance
function LoadingFullScreenDlg.getInstance()
	if not _instance then
		_instance = LoadingFullScreenDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function LoadingFullScreenDlg.getInstanceAndShow()
	if not _instance then
		_instance = LoadingFullScreenDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function LoadingFullScreenDlg.getInstanceNotCreate()
	return _instance
end

function LoadingFullScreenDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function LoadingFullScreenDlg.ToggleOpenClose()
	if not _instance then
		_instance = LoadingFullScreenDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function LoadingFullScreenDlg.GetLayoutFileName()
	return "loadingfullscreenwindow.layout"
end

function LoadingFullScreenDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, LoadingFullScreenDlg)
	return self
end

function LoadingFullScreenDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    self:GetWindow():setTopMost(true)

end

return LoadingFullScreenDlg