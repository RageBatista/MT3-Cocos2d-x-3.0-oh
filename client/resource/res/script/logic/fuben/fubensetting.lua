require "logic.dialog"

JYFubenSetting = {}
setmetatable(JYFubenSetting, Dialog)
JYFubenSetting.__index = JYFubenSetting

local _instance
function JYFubenSetting.getInstance()
	if not _instance then
		_instance = JYFubenSetting:new()
		_instance:OnCreate()
	end
	return _instance
end

function JYFubenSetting.getInstanceAndShow()
	if not _instance then
		_instance = JYFubenSetting:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function JYFubenSetting.getInstanceNotCreate()
	return _instance
end

function JYFubenSetting.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function JYFubenSetting.ToggleOpenClose()
	if not _instance then
		_instance = JYFubenSetting:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function JYFubenSetting.GetLayoutFileName()
	return "jingyingfubenshezhi.layout"
end

function JYFubenSetting:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, JYFubenSetting)
	return self
end

function JYFubenSetting:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.bg = winMgr:getWindow("jyfubenshezhi")
    local scroll = CEGUI.Window.toScrollablePane(winMgr:getWindow("jyfubenshezhi/scroll"))
    local bgSize = self.bg:getPixelSize()

    self.m_fbCells = {}

    local viewHeight = 0
    local vAllTableId = BeanConfigManager.getInstance():GetTableByName("mission.cshiguangzhixueconfig"):getAllID()
	for i = 1, #vAllTableId do
        local info = BeanConfigManager.getInstance():GetTableByName("mission.cshiguangzhixueconfig"):getRecorder(i)
        if info and info.enterLevel <= gGetDataManager():GetMainCharacterLevel() then
            local cell = winMgr:loadWindowLayout("jingyingfubenshezhicell.layout", i)
            local text = winMgr:getWindow(i .. "jingyingfuben/fubenmingcheng")
            local checkBtn = CEGUI.Window.toCheckbox(winMgr:getWindow(i .. "jingyingfuben/gouxuankuang"))
            checkBtn:subscribeEvent("CheckStateChanged", JYFubenSetting.HandleCheckBoxClick, self)
            text:setText(info.name)
            checkBtn:setID(info.enterLevel)
            local cellHeight = cell:getPixelSize().height
            cell:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 0), CEGUI.UDim(0, (i - 1) * cellHeight)))
            scroll:addChildWindow(cell)
            self.m_fbCells[info.enterLevel] = checkBtn

            viewHeight = viewHeight + cellHeight
        end
    end

    self.bg:setSize(CEGUI.UVector2(CEGUI.UDim(0, bgSize.width), CEGUI.UDim(0, viewHeight + 10)))

    self:UpdateSettingShow()
end

function JYFubenSetting:UpdateSettingShow()
    for i, j in pairs(gGetDataManager().m_fubenSettingMap) do
        for k, v in pairs(self.m_fbCells) do
            if i == k then
                if j == 1 then
                    self.m_fbCells[k]:setSelectedNoEvent(true)
                else
                    self.m_fbCells[k]:setSelectedNoEvent(false)
                end
                break
            end
        end
    end
end

function JYFubenSetting:getFrameSize()
    return self.bg:getPixelSize()
end

function JYFubenSetting:checkTouchInWnd()
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

function JYFubenSetting:HandleCheckBoxClick(args)
    local winargs = CEGUI.toWindowEventArgs(args)
    local checkBox = CEGUI.Window.toCheckbox(winargs.window)
    local enterLevel = checkBox:getID()
    local sMap = gGetDataManager().m_fubenSettingMap
    if checkBox:isSelected() then
        sMap[enterLevel] = 1
    else
        sMap[enterLevel] = 0
    end

    local sendConfig = require "protodef.fire.pb.csetlineconfig"
    local req = sendConfig.Create()
    req.configmap = sMap
    LuaProtocolManager.getInstance():send(req)
end

return JYFubenSetting