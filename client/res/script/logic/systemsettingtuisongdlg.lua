require "logic.dialog"

SystemsettingTuiSongDlg = {}
setmetatable(SystemsettingTuiSongDlg, Dialog)
SystemsettingTuiSongDlg.__index = SystemsettingTuiSongDlg

function SystemsettingTuiSongDlg:OnCreate()
	Dialog.OnCreate(self)

	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_listbg = CEGUI.toScrollablePane(winMgr:getWindow("systemsettingts/liebiao"))
	local allid = BeanConfigManager.getInstance():GetTableByName("SysConfig.ctuisongsetting"):getAllID()

	local posY = 0
	
    for k, v in ipairs(allid) do
        local prefixName = tostring(k)
        local record = BeanConfigManager.getInstance():GetTableByName("SysConfig.ctuisongsetting"):getRecorder(v)
        local itemcell, cellSwitch, cellName, cellDay, cellTime, cellPCount

        if k % 2 == 0 then
            itemcell = winMgr:loadWindowLayout("systemsettingtscell.layout", prefixName)
            cellSwitch = CEGUI.toSwitch(winMgr:getWindow(prefixName.."SystemSettingtscell/5"))
            cellName = winMgr:getWindow(prefixName.."SystemSettingtscell/1")
            cellDay = winMgr:getWindow(prefixName.."SystemSettingtscell/2")
            cellTime = winMgr:getWindow(prefixName.."SystemSettingtscell/3")
            cellPCount = winMgr:getWindow(prefixName.."SystemSettingtscell/4")
        else 
            itemcell = winMgr:loadWindowLayout("SystemSettingtscell1.layout", prefixName)
            cellSwitch = CEGUI.toSwitch(winMgr:getWindow(prefixName.."systemsettingtscell1/5"))
            cellName = winMgr:getWindow(prefixName.."systemsettingtscell1/1")
            cellDay = winMgr:getWindow(prefixName.."systemsettingtscell1/2")
            cellTime = winMgr:getWindow(prefixName.."systemsettingtscell1/3")
            cellPCount = winMgr:getWindow(prefixName.."systemsettingtscell1/4")
        end
        local openStatus = SystemsettingTuiSongDlg.LoadConfigById(k)

        cellName:setText(record.name)
        cellDay:setText(record.day)
        cellTime:setText(record.time)
        cellPCount:setText(record.pcount)

		local cellWidth = itemcell:getPixelSize().width
		local cellHeight = itemcell:getPixelSize().height
		itemcell:setPosition(CEGUI.UVector2(CEGUI.UDim(0.5,-cellWidth*0.5), CEGUI.UDim(0.0, posY)))
		self.m_listbg:addChildWindow(itemcell)
        if openStatus == 0 then
            cellSwitch:setLookStatus(CEGUI.OFF)
        else
            cellSwitch:setLookStatus(CEGUI.ON)
        end
		posY = posY + cellHeight

		cellSwitch:setID(k)
		cellSwitch:subscribeEvent("StatusChanged", self.handleSwitchChanged,self)
	end
end


function SystemsettingTuiSongDlg:handleSwitchChanged(args)
    local e = CEGUI.toWindowEventArgs(args)
    local cell = CEGUI.toSwitch(e.window)
    local cellID = cell:getID()

    if cell:getStatus() == CEGUI.ON then
        self:saveConfig(cellID, 1)
    else
        self:saveConfig(cellID, 0)
    end
end

function SystemsettingTuiSongDlg:saveConfig(id, value)
    local SettingEnum = require "protodef.rpcgen.fire.pb.sysconfigtype":new()
    local rID = SettingEnum.refuseqiecuo + id
    if id == 9 then
        rID = SettingEnum.ts_gonghuizhan
    end
    local record = GameTable.SysConfig.GetCGameconfigTableInstance():getRecorder(rID)
    if record ~= nil then
        local strKey = record.key
        gGetGameConfigManager():SetConfigValue(strKey, value)
    end
    gGetGameConfigManager():ApplyConfig()
    gGetGameConfigManager():SaveConfig()
end

function SystemsettingTuiSongDlg.LoadConfigById(id)
    local SettingEnum = require "protodef.rpcgen.fire.pb.sysconfigtype":new()
   local rID = SettingEnum.refuseqiecuo + id
    if id == 9 then
        rID = SettingEnum.ts_gonghuizhan
    end
    local record = GameTable.SysConfig.GetCGameconfigTableInstance():getRecorder(rID)
    if record ~= nil then
        local strKey = record.key
        local value = -1
        if gGetGameConfigManager() then
            value = gGetGameConfigManager():GetConfigValue(strKey)
        end
        return value
    end
    return -1
end

function SystemsettingTuiSongDlg.LocalNotificationType(id)
    local m = require "protodef.fire.pb.game.clogpushtoken".Create()
	m.token = id
	LuaProtocolManager.getInstance():send(m)
end




--------------------------------------

local _instance

function SystemsettingTuiSongDlg.getInstance()
	if not _instance then
		_instance = SystemsettingTuiSongDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function SystemsettingTuiSongDlg.getInstanceAndShow()
	if not _instance then
		_instance = SystemsettingTuiSongDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end


function SystemsettingTuiSongDlg.getInstanceNotCreate()
	return _instance
end

function SystemsettingTuiSongDlg.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function SystemsettingTuiSongDlg.ToggleOpenClose()
	if not _instance then
		_instance = SystemsettingTuiSongDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end


function SystemsettingTuiSongDlg.GetLayoutFileName()
	return "systemsettingts.layout"
end

function SystemsettingTuiSongDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, SystemsettingTuiSongDlg)

	return self
end

return SystemsettingTuiSongDlg
