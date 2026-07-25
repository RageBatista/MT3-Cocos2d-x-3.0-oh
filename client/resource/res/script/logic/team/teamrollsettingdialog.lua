require "logic.dialog"

TeamrollSettingDlg = {}
setmetatable(TeamrollSettingDlg, Dialog)
TeamrollSettingDlg.__index = TeamrollSettingDlg

local _instance
function TeamrollSettingDlg.getInstance()
	if not _instance then
		_instance = TeamrollSettingDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function TeamrollSettingDlg.getInstanceAndShow()
	if not _instance then
		_instance = TeamrollSettingDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function TeamrollSettingDlg.getInstanceNotCreate()
	return _instance
end

function TeamrollSettingDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function TeamrollSettingDlg.ToggleOpenClose()
	if not _instance then
		_instance = TeamrollSettingDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function TeamrollSettingDlg.GetLayoutFileName()
	return "rollshezhi.layout"
end

function TeamrollSettingDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, TeamrollSettingDlg)
	return self
end

function TeamrollSettingDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.bg = winMgr:getWindow("rollshezhidiban")
    local scroll = CEGUI.Window.toScrollablePane(winMgr:getWindow("rollshezhidiban/list"))
    local bgSize = self.bg:getPixelSize()

    local cell = winMgr:loadWindowLayout("rollshezhicell.layout")
    local checkBtn = CEGUI.Window.toCheckbox(winMgr:getWindow("rollshezhicell/gouxuankuang"))
    checkBtn:subscribeEvent("CheckStateChanged", TeamrollSettingDlg.HandleCheckBoxClick, self)
    scroll:addChildWindow(cell)

    local SettingEnum = require "protodef.rpcgen.fire.pb.sysconfigtype":new()
    local record = GameTable.SysConfig.GetCGameconfigTableInstance():getRecorder(SettingEnum.rolldianshezhi)
    if record then
        local strKey = record.key
        local value = gGetGameConfigManager():GetConfigValue(strKey)

        if value == 1 then
            checkBtn:setSelectedNoEvent(true)
        else
            checkBtn:setSelectedNoEvent(false)
        end
    end

    self.bg:setSize(CEGUI.UVector2(CEGUI.UDim(0, bgSize.width), CEGUI.UDim(0, cell:getPixelSize().height + 10)))
end

function TeamrollSettingDlg:getFrameSize()
    return self.bg:getPixelSize()
end

function TeamrollSettingDlg:checkTouchInWnd()
    local guiSystem = CEGUI.System:getSingleton()
    local mousePos = CEGUI.MouseCursor:getSingleton():getPosition()
    local wndPos = self:GetWindow():GetScreenPos()
    local tw = self:GetWindow():getPixelSize().width
    local th = self:GetWindow():getPixelSize().height
    if mousePos.x > wndPos.x and mousePos.x < wndPos.x + tw and mousePos.y > wndPos.y and mousePos.y < wndPos.y + th then
        return true
    end
    return false

end

function TeamrollSettingDlg:HandleCheckBoxClick(arg)
    local winargs = CEGUI.toWindowEventArgs(arg)
    local checkBox = CEGUI.Window.toCheckbox(winargs.window)
    local saveValue = 0
    if checkBox:isSelected() then
        saveValue = 1
    else
        saveValue = 0
    end

    local SettingEnum = require "protodef.rpcgen.fire.pb.sysconfigtype":new()
    local record = GameTable.SysConfig.GetCGameconfigTableInstance():getRecorder(SettingEnum.rolldianshezhi)
	if record then
		local strKey = record.key
		gGetGameConfigManager():SetConfigValue(strKey, saveValue)
	end
	gGetGameConfigManager():SaveConfig()
end



return TeamrollSettingDlg