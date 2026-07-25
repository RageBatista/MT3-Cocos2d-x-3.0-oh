require "logic.dialog"


--成就左边的等级列表
GuideCourseCell = {}
setmetatable(GuideCourseCell, Dialog)
GuideCourseCell.__index = GuideCourseCell

local _instance
function GuideCourseCell.getInstance()
	if not _instance then
		_instance = GuideCourseCell:new()
		_instance:OnCreate()
	end
	return _instance
end
function GuideCourseCell.CreateNewDlg(parent, id)
	local newDlg = GuideCourseCell:new()
	newDlg:OnCreate(parent, id)
	return newDlg
end
function GuideCourseCell.getInstanceAndShow()
	if not _instance then
		_instance = GuideCourseCell:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function GuideCourseCell.getInstanceNotCreate()
	return _instance
end

function GuideCourseCell.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function GuideCourseCell.ToggleOpenClose()
	if not _instance then
		_instance = GuideCourseCell:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function GuideCourseCell.GetLayoutFileName()
	return "zhiyinlichengcell1.layout"
end

function GuideCourseCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, GuideCourseCell)
	return self
end

function GuideCourseCell:OnCreate(parent, id)
    local prefix = id
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

	self.window = CEGUI.toGroupButton(winMgr:getWindow(prefixstr .. "zhiyinlichengcell1"))
    self.m_NameText = CEGUI.toGroupButton(winMgr:getWindow(prefixstr .. "zhiyinlichengcell1/wenben"))
    self.window:EnableClickAni(false)
    self.status = 0

end
function GuideCourseCell:setNameById(id)
    local guidemanager = require "logic.guide.guidemanager".getInstance()
    self.m_NameText:setText(guidemanager.m_leftLabelData[id].name)
end

return GuideCourseCell
