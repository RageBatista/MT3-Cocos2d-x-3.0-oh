require "logic.dialog"

ShenShouResetCell = {}
setmetatable(ShenShouResetCell, Dialog)
ShenShouResetCell.__index = ShenShouResetCell

local _instance
function ShenShouResetCell.getInstance()
	if not _instance then
		_instance = ShenShouResetCell:new()
		_instance:OnCreate()
	end
	return _instance
end

function ShenShouResetCell.getInstanceAndShow()
	if not _instance then
		_instance = ShenShouResetCell:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ShenShouResetCell.getInstanceNotCreate()
	return _instance
end

function ShenShouResetCell.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ShenShouResetCell.ToggleOpenClose()
	if not _instance then
		_instance = ShenShouResetCell:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ShenShouResetCell.GetLayoutFileName()
	return "shenshouchongzhicell.layout"
end

function ShenShouResetCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ShenShouResetCell)
	return self
end

function ShenShouResetCell:OnCreate(parent, id)
    Dialog.OnCreate(self, parent, id)
	local winMgr = CEGUI.WindowManager:getSingleton()
    local prefixstr = tostring(id)

    self.m_Btn = CEGUI.toGroupButton(winMgr:getWindow(prefixstr .. "shenshouchongzhicell"))
	self.m_touxiang = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "shenshouchongzhicell/touxiang"))
	self.m_name = winMgr:getWindow(prefixstr .. "shenshouchongzhicell/mingzi")
	self.m_level = winMgr:getWindow(prefixstr .. "shenshouchongzhicell/dengji")
	self.m_IncreaseTimes = winMgr:getWindow(prefixstr .. "shenshouchongzhicell/tishen1")
	self.m_skill_1 = CEGUI.toSkillBox(winMgr:getWindow(prefixstr .. "shenshouchongzhicell/skill1"))
	self.m_skill_2 = CEGUI.toSkillBox(winMgr:getWindow(prefixstr .. "shenshouchongzhicell/skill2"))
	self.m_skill_3 = CEGUI.toSkillBox(winMgr:getWindow(prefixstr .. "shenshouchongzhicell/skill3"))
	self.m_skill_4 = CEGUI.toSkillBox(winMgr:getWindow(prefixstr .. "shenshouchongzhicell/skill4"))
	self.m_skill_5 = CEGUI.toSkillBox(winMgr:getWindow(prefixstr .. "shenshouchongzhicell/skill5"))
end

-- 创建cell
function ShenShouResetCell.CreateNewDlg(parent, id)
    LogInfo("enter ShenShouResetCell.CreateNewDlg")
    local newCell = ShenShouResetCell:new()
    newCell:OnCreate(parent, id)
    return newCell
end

-- 设置神兽信息
function ShenShouResetCell:SetPetInfo(petInfo)
    -- 头像
	local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(petInfo:GetShapeID())
	local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
    self.m_touxiang:SetImage(image)

    -- 名字
    self.m_name:setText(petInfo.name)

    -- 等级
    self.m_level:setText(petInfo:getAttribute(fire.pb.attr.AttrType.LEVEL))

    -- 提升次数
    self.m_IncreaseTimes:setText(tostring(petInfo.shenshouinccount))
    local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petInfo.baseid)
    local bTreasure = isPetTreasure(petInfo)
	if bTreasure then
		self.m_touxiang:SetCornerImageAtPos("ccui1", "newzp", 0, 1)
	end
    if petAttr then
        SetItemCellBoundColorByQulityPet(self.m_touxiang, petAttr.quality)
    end
    -- 技能
    local skillNum = petInfo:getSkilllistlen()
    for i = 1, skillNum do
        local skill = petInfo:getSkill(i)
        if skill then
	        local petskill = BeanConfigManager.getInstance():GetTableByName("skill.cpetskillconfig"):getRecorder(skill.skillid)
	        if petskill then
                if i == 1 then
                    self.m_skill_1:SetBackgroundDynamic(true)
		            self.m_skill_1:SetImage(gGetIconManager():GetSkillIconByID(petskill.icon))
                    local skillconf = BeanConfigManager.getInstance():GetTableByName("skill.cpetskillconfig"):getRecorder(skill.skillid)
                    if skillconf and skillconf.id ~= -1 then
                        local img = (skillconf.skilltype==1 and "beiji" or "zhuji")
                        img = img .. (skillconf.color==1 and 1 or 2)
                        self.m_skill_1:SetBackGroundImage(CEGUI.String("ccui"), CEGUI.String(img))
                    end
                elseif i == 2 then
                    self.m_skill_2:SetBackgroundDynamic(true)
		            self.m_skill_2:SetImage(gGetIconManager():GetSkillIconByID(petskill.icon))
                    local skillconf = BeanConfigManager.getInstance():GetTableByName("skill.cpetskillconfig"):getRecorder(skill.skillid)
                    if skillconf and skillconf.id ~= -1 then
                        local img = (skillconf.skilltype==1 and "beiji" or "zhuji")
                        img = img .. (skillconf.color==1 and 1 or 2)
                        self.m_skill_2:SetBackGroundImage(CEGUI.String("ccui"), CEGUI.String(img))
                    end
                elseif i == 3 then
                    self.m_skill_3:SetBackgroundDynamic(true)
		            self.m_skill_3:SetImage(gGetIconManager():GetSkillIconByID(petskill.icon))
                    local skillconf = BeanConfigManager.getInstance():GetTableByName("skill.cpetskillconfig"):getRecorder(skill.skillid)
                    if skillconf and skillconf.id ~= -1 then
                        local img = (skillconf.skilltype==1 and "beiji" or "zhuji")
                        img = img .. (skillconf.color==1 and 1 or 2)
                        self.m_skill_3:SetBackGroundImage(CEGUI.String("ccui"), CEGUI.String(img))
                    end
                elseif i == 4 then
                    self.m_skill_4:SetBackgroundDynamic(true)
		            self.m_skill_4:SetImage(gGetIconManager():GetSkillIconByID(petskill.icon))
                    local skillconf = BeanConfigManager.getInstance():GetTableByName("skill.cpetskillconfig"):getRecorder(skill.skillid)
                    if skillconf and skillconf.id ~= -1 then
                        local img = (skillconf.skilltype==1 and "beiji" or "zhuji")
                        img = img .. (skillconf.color==1 and 1 or 2)
                        self.m_skill_4:SetBackGroundImage(CEGUI.String("ccui"), CEGUI.String(img))
                    end
                elseif i == 5 then
                    self.m_skill_5:SetBackgroundDynamic(true)
		            self.m_skill_5:SetImage(gGetIconManager():GetSkillIconByID(petskill.icon))
                    local skillconf = BeanConfigManager.getInstance():GetTableByName("skill.cpetskillconfig"):getRecorder(skill.skillid)
                    if skillconf and skillconf.id ~= -1 then
                        local img = (skillconf.skilltype==1 and "beiji" or "zhuji")
                        img = img .. (skillconf.color==1 and 1 or 2)
                        self.m_skill_5:SetBackGroundImage(CEGUI.String("ccui"), CEGUI.String(img))
                    end
                end
	        end
        end
    end
end

return ShenShouResetCell