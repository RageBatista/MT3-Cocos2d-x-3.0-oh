require "logic.dialog"
require "logic.workshop.tipsguajiimgcell"

TipsGuajiImg = {}
setmetatable(TipsGuajiImg, Dialog)
TipsGuajiImg.__index = TipsGuajiImg

local _instance
function TipsGuajiImg.getInstance()
	if not _instance then
		_instance = TipsGuajiImg:new()
		_instance:OnCreate()
	end
	return _instance
end

function TipsGuajiImg.getInstanceAndShow( mapid, sculptList )
	if not _instance then
		_instance = TipsGuajiImg:new()
		_instance:OnCreate( mapid,  sculptList )
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function TipsGuajiImg.getInstanceNotCreate()
	return _instance
end

function TipsGuajiImg.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
            for index in pairs( _instance.m_mapCell ) do
		        local cell = _instance.m_mapCell[index]
		        if cell then
			        cell:OnClose()
		        end
	        end
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function TipsGuajiImg.ToggleOpenClose()
	if not _instance then
		_instance = TipsGuajiImg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function TipsGuajiImg.GetLayoutFileName()
	return "mapchooosetouxiang.layout"
end

function TipsGuajiImg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, TipsGuajiImg)
	return self
end

function TipsGuajiImg:OnCreate(mapID, sculptList )
	
	self.m_mapSculptID = {}
	self.m_mapCell = {}
	
	self.m_mapID = mapID
	
	if sculptList then
		self.m_mapSculptID = sculptList
	end
	
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_txtName = winMgr:getWindow("mapchooosetouxiang/text")
	self.m_scrollPane = CEGUI.toScrollablePane(winMgr:getWindow("mapchooosetouxiang/lists"))
		
	self.m_scrollPane:EnableHorzScrollBar(true)
	self.m_scrollPane:EnablePageScrollMode(true)
	
	local mapconfig = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(self.m_mapID)
	self.m_txtName:setText(mapconfig.mapName)

	self:InitMapCell()	
end

function TipsGuajiImg:InitMapCell()
	self.m_mapCell = {}
	self.m_scrollPane:cleanupNonAutoChildren()
	local width = 125
	local height = 180
	
	local xO = 1
	local yO = 1
	
	for index , id in pairs( self.m_mapSculptID ) do
		local cell = TipGuajiImgCell.CreateNewDlg( self.m_scrollPane )
		cell:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim( 0, (index-1)*width + xO ), CEGUI.UDim(0,  yO  )))
		cell:SetRoleID(id)
		cell:GetWindow():setID( index )					
		--cell:GetWindow():subscribeEvent("MouseClick", MapChoseDlg.HandleCellClicked , self)	
		table.insert(self.m_mapCell, cell)		
		cell:Refresh()
	end
	
end

return TipsGuajiImg
