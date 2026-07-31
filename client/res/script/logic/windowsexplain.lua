require "logic.dialog"

windowsexplain = {}
setmetatable(windowsexplain, Dialog)
windowsexplain.__index = windowsexplain

local _instance
function windowsexplain.getInstance()
	if not _instance then
		_instance = windowsexplain:new()
		_instance:OnCreate()
	end
	return _instance
end

function windowsexplain.getInstanceAndShow()
	if not _instance then
		_instance = windowsexplain:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function windowsexplain.getInstanceNotCreate()
	return _instance
end

function windowsexplain.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function windowsexplain.ToggleOpenClose()
	if not _instance then
		_instance = windowsexplain:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function windowsexplain.GetLayoutFileName()
	return "hutongshuoming.layout"
end

function windowsexplain:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, windowsexplain)
	return self
end

function windowsexplain:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.checkbox = CEGUI.toCheckbox(winMgr:getWindow("hutongshuoming/1"))
	self.btnIphone = CEGUI.toPushButton(winMgr:getWindow("hutongshuoming/IOS"))
	self.btnAndroid = CEGUI.toPushButton(winMgr:getWindow("hutongshuoming/anzhuo"))

    self.checkbox:subscribeEvent("CheckStateChanged", windowsexplain.HandleExplain, self)
    self.btnIphone:subscribeEvent("Clicked", windowsexplain.handleIphoneClicked, self)
    self.btnAndroid:subscribeEvent("Clicked", windowsexplain.handleAndroidClicked, self)
    self.btnIphone:setEnabled(false)
    self.btnAndroid:setEnabled(false)
    self:GetCloseBtn():setVisible(false)
    self.selected = false
end

function windowsexplain:HandleExplain()
    local enable = false
    if self.selected == false then
        enable = true
        self.selected = true
    else
        self.selected = false
        enable = false
    end
    self.btnIphone:setEnabled(enable)
    self.btnAndroid:setEnabled(enable)   
end

function windowsexplain:handleIphoneClicked(args)
    if false and Config.IsPointCardServerBeforeLogin() then
        gGetLoginManager():SetChannelId(Config.PlatformPointIOS)
    else
        gGetLoginManager():SetChannelId(Config.PlatformIOS)
    end
    
    local function ClickYes(args)        
        gGetMessageManager():CloseConfirmBox(eConfirmOK, false)
    end
    gGetMessageManager():AddConfirmBox(eConfirmOK, MHSD_UTILS.get_msgtipstring(174004), ClickYes, 0,ClickYes, 0)
    windowsexplain.DestroyDialog()
    return true
end

function windowsexplain:handleAndroidClicked(args)
    if false and Config.IsPointCardServerBeforeLogin() then
        gGetLoginManager():SetChannelId(Config.PlatformOfLocojoy[1])
    else
        gGetLoginManager():SetChannelId(Config.PlatformOfLocojoy[2])
    end
    windowsexplain.DestroyDialog()
    return true
end

return windowsexplain