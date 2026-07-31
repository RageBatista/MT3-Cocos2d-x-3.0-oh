require "logic.dialog"
--require "logic.selectserversdialog"
LoginWaitingDialog = {}
setmetatable(LoginWaitingDialog, Dialog)
LoginWaitingDialog.__index = LoginWaitingDialog

------------------- public: -----------------------------------
local _instance;
function LoginWaitingDialog.getInstance()
    if not _instance then
        _instance = LoginWaitingDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function LoginWaitingDialog.getInstanceAndShow()
    if not _instance then
        _instance = LoginWaitingDialog:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function LoginWaitingDialog.getInstanceNotCreate()
    return _instance
end

function LoginWaitingDialog.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
            gGetGameUIManager():RemoveUIEffect(_instance.effectWnd)
			_instance:OnClose()		
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function LoginWaitingDialog.ToggleOpenClose()
	if not _instance then 
		_instance = LoginWaitingDialog:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function LoginWaitingDialog.GetLayoutFileName()
    return "loginbackdialog.layout"
end

function LoginWaitingDialog:OnCreate()
	if gGetLoginManager() then
		gGetLoginManager():ClearConnections()
	end
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.effectWnd = winMgr:getWindow("loginbackdialog/diban/effet")

    gGetGameUIManager():AddUIEffect(self.effectWnd,  MHSD_UTILS.get_effectpath(11081), true)
end

------------------- private: -----------------------------------

function LoginWaitingDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, LoginWaitingDialog)
    return self
end

return LoginWaitingDialog
