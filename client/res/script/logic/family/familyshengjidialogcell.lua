require "logic.dialog"

FamilyShengjiDialogCell = {}
setmetatable(FamilyShengjiDialogCell, Dialog)
FamilyShengjiDialogCell.__index = FamilyShengjiDialogCell

local _instance
function FamilyShengjiDialogCell.getInstance()
	if not _instance then
		_instance = FamilyShengjiDialogCell:new()
		_instance:OnCreate()
	end
	return _instance
end

function FamilyShengjiDialogCell.getInstanceAndShow()
	if not _instance then
		_instance = FamilyShengjiDialogCell:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function FamilyShengjiDialogCell.getInstanceNotCreate()
	return _instance
end

function FamilyShengjiDialogCell.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function FamilyShengjiDialogCell.ToggleOpenClose()
	if not _instance then
		_instance = FamilyShengjiDialogCell:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function FamilyShengjiDialogCell.GetLayoutFileName()
	return "familyshengjidialogcell.layout"
end

function FamilyShengjiDialogCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, FamilyShengjiDialogCell)
	return self
end

function FamilyShengjiDialogCell:OnCreate(parent, id)
	Dialog.OnCreate(self, parent, id)
	local winMgr = CEGUI.WindowManager:getSingleton()
    local prefixstr = tostring(id)

    self.m_Btn = CEGUI.toGroupButton(winMgr:getWindow(prefixstr .. "familyshengjidialogcell"))
	self.m_Image = winMgr:getWindow(prefixstr .. "familyshengjidialogcell/image")
	self.m_Name = winMgr:getWindow(prefixstr .. "familyshengjidialogcell/name")
	self.m_Level = winMgr:getWindow(prefixstr .. "familyshengjidialogcell/dengji")
end

-- 创建cell
function FamilyShengjiDialogCell.CreateNewDlg(parent, id)
    LogInfo("enter FamilyShengjiDialogCell.CreateNewDlg")
    local newCell = FamilyShengjiDialogCell:new()
    newCell:OnCreate(parent, id)
    return newCell
end

-- 设置公会建筑信息
function FamilyShengjiDialogCell:SetBuildInfo(imageSet, name, level)
	self.m_Image:setProperty("Image", imageSet)
    self.m_Name:setText(name)
    self.m_Level:setText("" .. tostring(level))
end

return FamilyShengjiDialogCell