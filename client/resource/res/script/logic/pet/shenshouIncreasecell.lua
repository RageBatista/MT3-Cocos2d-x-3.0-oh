require "logic.dialog"

ShenShouIncreaseCell = {}
setmetatable(ShenShouIncreaseCell, Dialog)
ShenShouIncreaseCell.__index = ShenShouIncreaseCell

local _instance
function ShenShouIncreaseCell.getInstance()
	if not _instance then
		_instance = ShenShouIncreaseCell:new()
		_instance:OnCreate()
	end
	return _instance
end

function ShenShouIncreaseCell.getInstanceAndShow()
	if not _instance then
		_instance = ShenShouIncreaseCell:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ShenShouIncreaseCell.getInstanceNotCreate()
	return _instance
end

function ShenShouIncreaseCell.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ShenShouIncreaseCell.ToggleOpenClose()
	if not _instance then
		_instance = ShenShouIncreaseCell:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ShenShouIncreaseCell.GetLayoutFileName()
	return "tishengshenshoucell.layout"
end

function ShenShouIncreaseCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ShenShouIncreaseCell)
	return self
end

function ShenShouIncreaseCell:OnCreate(parent, id)
    Dialog.OnCreate(self, parent, id)
	local winMgr = CEGUI.WindowManager:getSingleton()
    local prefixstr = tostring(id)

    self.m_Btn = CEGUI.toGroupButton(winMgr:getWindow(prefixstr .. "tishengshenshoucell"))
	self.m_touxiang = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "tishengshenshoucell/touxiang"))
	self.m_name = winMgr:getWindow(prefixstr .. "tishengshenshoucell/mingzi")
	self.m_level = winMgr:getWindow(prefixstr .. "tishengshenshoucell/dengji")
	self.m_numSkill = winMgr:getWindow(prefixstr .. "tishengshenshoucell/jineng1")
end

-- 创建cell
function ShenShouIncreaseCell.CreateNewDlg(parent, id)
    LogInfo("enter ShenShouIncreaseCell.CreateNewDlg")
    local newCell = ShenShouIncreaseCell:new()
    newCell:OnCreate(parent, id)
    return newCell
end

-- 设置神兽信息
function ShenShouIncreaseCell:SetPetInfo(petInfo)
    -- 头像
	local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(petInfo:GetShapeID())
	local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
    self.m_touxiang:SetImage(image)

    -- 名字
    self.m_name:setText(petInfo.name)

    -- 等级
    self.m_level:setText(petInfo:getAttribute(fire.pb.attr.AttrType.LEVEL)..MHSD_UTILS.get_resstring(3))

    -- 技能数
    self.m_numSkill:setText(petInfo:getSkilllistlen())

    local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petInfo.baseid)
    local bTreasure = isPetTreasure(petInfo)
	if bTreasure then
		self.m_touxiang:SetCornerImageAtPos("ccui1", "tm", 0, 1)
	end
    if petAttr then
        SetItemCellBoundColorByQulityPettmdi(self.m_touxiang, petAttr.quality)
    end
end

return ShenShouIncreaseCell