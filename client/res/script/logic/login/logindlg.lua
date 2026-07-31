require "logic.dialog"

LoginQuickDialog = {}
setmetatable(LoginQuickDialog, Dialog)
LoginQuickDialog.__index = LoginQuickDialog

local _instance
function LoginQuickDialog.getInstance()
	if not _instance then
		_instance = LoginQuickDialog:new()
		_instance:OnCreate()
	end
	return _instance
end

function LoginQuickDialog.getInstanceAndShow()
	if not _instance then
		_instance = LoginQuickDialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function LoginQuickDialog.getInstanceNotCreate()
	return _instance
end

function LoginQuickDialog.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function LoginQuickDialog.ToggleOpenClose()
	if not _instance then
		_instance = LoginQuickDialog:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function LoginQuickDialog.GetLayoutFileName()
	return "loginquickdialog.layout"
end

function LoginQuickDialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, LoginQuickDialog)
	return self
end

function LoginQuickDialog:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pLogin = CEGUI.toPushButton(winMgr:getWindow("loginquick/LoginBtn1"))
    self.m_pLogin:subscribeEvent("Clicked", LoginQuickDialog.HandleLoginMouseClicked, self)
   -- self.smokeBg = winMgr:getWindow("loginquick/Back/flagbg/smoke")
	--local s = self.smokeBg:getPixelSize()
	--local flagSmoke = gGetGameUIManager():AddUIEffect(self.smokeBg, "geffect/ui/mt_shengqishi/mt_shengqishi5", true, s.width*0.5, s.height)
	local isShortcutLaunched = gGetLoginManager():isShortcutLaunched();
	if isShortcutLaunched then
		self:HandleLoginMouseClicked();
	end
end

function LoginQuickDialog:HandleLoginMouseClicked(args)
	local uiManager = gGetGameUIManager()
	if uiManager and uiManager.InitGameUIPostInit then
		uiManager:InitGameUIPostInit()
	end
	require('logic.switchaccountdialog').getInstanceAndShow()
	self.DestroyDialog()
end

return LoginQuickDialog
