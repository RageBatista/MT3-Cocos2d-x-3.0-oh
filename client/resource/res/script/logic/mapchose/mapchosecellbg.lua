MapChouseCellBg = {}

setmetatable(MapChouseCellBg, Dialog)
MapChouseCellBg.__index = MapChouseCellBg
local prefix = 0

function MapChouseCellBg.CreateNewDlg(parent)
	local newDlg = MapChouseCellBg:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function MapChouseCellBg.GetLayoutFileName()
	return "mapchousecellbg.layout"
end

function MapChouseCellBg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, MapChouseCellBg)
	return self
end

function MapChouseCellBg:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

    self.m_bg = winMgr:getWindow(prefixstr.."mapchousecellbg")

end
function MapChouseCellBg:SetMapID(id)
	local mapconfig = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(id)
    self.m_bg:setProperty("Image",mapconfig.mapbg)
end
return MapChouseCellBg