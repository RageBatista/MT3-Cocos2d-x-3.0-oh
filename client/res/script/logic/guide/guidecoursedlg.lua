require "logic.dialog"
require "logic.guide.guidecoursecell"
require "logic.guide.guidecourserightcell"

--成就主界面
GuideCourseDlg = {}
setmetatable(GuideCourseDlg, Dialog)
GuideCourseDlg.__index = GuideCourseDlg

local _instance
local prefix = 0
function GuideCourseDlg.getInstance()
	if not _instance then
		_instance = GuideCourseDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function GuideCourseDlg.getInstanceAndShow()
	if not _instance then
		_instance = GuideCourseDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function GuideCourseDlg.getInstanceNotCreate()
	return _instance
end

function GuideCourseDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
            if _instance.tableviewCell then
                _instance.tableviewCell:destroyCells()
            end
            if _instance.tableviewLabel then
                _instance.tableviewCell:destroyCells()
            end
			_instance:OnClose()
			_instance = nil

		else
			_instance:ToggleOpenClose()
		end
	end
end

function GuideCourseDlg.ToggleOpenClose()
	if not _instance then
		_instance = GuideCourseDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function GuideCourseDlg.GetLayoutFileName()
	return "zhiyinlicheng.layout"
end

function GuideCourseDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, GuideCourseDlg)
	return self
end

function GuideCourseDlg:OnCreate()
	Dialog.OnCreate(self)
    SetPositionOfWindowWithLabel1(self:GetWindow())

	local winMgr = CEGUI.WindowManager:getSingleton()
    self.LeftTablelistBg = CEGUI.toScrollablePane(winMgr:getWindow("zhiyinlicheng/liebiao1"))
    self.CellTableListBg = CEGUI.toScrollablePane(winMgr:getWindow("zhiyinlicheng/di2/liebiao2"))
    self:GetCloseBtn():removeEvent("Clicked")
	self:GetCloseBtn():subscribeEvent("Clicked", GuideLabel.hide, nil)
    self.m_selectedCellIdx = 0
    self.m_selectedLabelIdx = 0
    self.m_LabelCount = 0
    self.m_CellCount = 0
    local manager = require "logic.guide.guidemanager".getInstance()
    manager:getData()
    self:refreshLabelData()
    self:refreshLabel()
    self:refreshCellData()
    self:refreshCell()
end

function GuideCourseDlg:refresh()
    local manager = require "logic.guide.guidemanager".getInstance()
    manager:getData()
    self:refreshLabelData()
    self:refreshLabel()
    self:refreshCellData()
    self:refreshCell()
end
function GuideCourseDlg:refreshCell()
    self.CellTableListBg:cleanupNonAutoChildren()
    local posX = 0
    local posY = 0
    local guidemanager = require "logic.guide.guidemanager".getInstance()
    local j = 0
    for i,v in pairs(guidemanager.m_CellData) do
        local cell = GuideCourseRightCell.CreateNewDlg(self.CellTableListBg,v.id)
        cell:setData(i)
        local height = cell:GetWindow():getHeight().offset
        local x = CEGUI.UDim(0, 1)
        --10为间距
		local y = CEGUI.UDim(0, posY + 0)
		local pos = CEGUI.UVector2(x,y)
		cell:GetWindow():setPosition(pos)
        posY = posY + height
    end

end
function GuideCourseDlg:refreshLabel()
    self.LeftTablelistBg:cleanupNonAutoChildren()
    local posX = 0
    local posY = 0
    local guidemanager = require "logic.guide.guidemanager".getInstance()
    for i,v in pairs(guidemanager.m_leftLabelData) do
        local cell = GuideCourseCell.CreateNewDlg(self.LeftTablelistBg,v.id)
        cell.window:subscribeEvent("SelectStateChanged", GuideCourseDlg.handleLabelClicked, self)
        cell.window:setID(i)
        cell:setNameById(i)
        cell.window:setSelected(self.m_selectedLabelIdx == i)
        local height = cell.window:getHeight().offset
        local x = CEGUI.UDim(0, 1)
        --10为间距
        local y = CEGUI.UDim(0, posY + 0)
        posY = posY + height + 5 
        local pos = CEGUI.UVector2(x,y)
        cell.window:setPosition(pos)
    end
end
function GuideCourseDlg:handleLabelClicked(args)
	local idx = CEGUI.toWindowEventArgs(args).window:getID()
    local guidemananger = require "logic.guide.guidemanager".getInstance()
    self.m_selectedLabelIdx = idx
    if guidemananger then
        guidemananger.m_SelectLabel = self.m_selectedLabelIdx
        guidemananger:getCellData()
    end
    self:refreshCellData()
    self:refreshCell()
end
function GuideCourseDlg:handleCellClicked(args)

end

function GuideCourseDlg:refreshLabelData()
    local guidemananger = require "logic.guide.guidemanager".getInstance()
    if guidemananger then
        self.m_selectedLabelIdx = guidemananger.m_SelectLabel
        self.m_LabelCount = guidemananger.m_leftLabelCount
    end
    
end
function GuideCourseDlg:refreshCellData()
    local guidemananger = require "logic.guide.guidemanager".getInstance()
    if guidemananger then
        self.m_selectedCellIdx = guidemananger.m_SelectCell
        self.m_CellCount = guidemananger.m_CellCount
    end
    
end
return GuideCourseDlg
