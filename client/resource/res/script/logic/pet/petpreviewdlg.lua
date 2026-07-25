------------------------------------------------------------------
-- 宠物合成预览
------------------------------------------------------------------
require "logic.dialog"

PetPreviewDlg = {}
setmetatable(PetPreviewDlg, Dialog)
PetPreviewDlg.__index = PetPreviewDlg

local _instance
function PetPreviewDlg.getInstance()
	if not _instance then
		_instance = PetPreviewDlg:new()
		_instance:OnCreate()
	end
	return _instance
end


function PetPreviewDlg.getInstanceAndShow()
	if not _instance then
		_instance = PetPreviewDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end



function PetPreviewDlg.getInstanceNotCreate()
	return _instance
end

function PetPreviewDlg.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end



function PetPreviewDlg.ToggleOpenClose()
	if not _instance then
		_instance = PetPreviewDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end



function PetPreviewDlg.GetLayoutFileName()
	return "petpropertyyulan_mtg.layout"
end

function PetPreviewDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, PetPreviewDlg)
	return self
end


function PetPreviewDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.frameWindow = CEGUI.toFrameWindow(winMgr:getWindow("petpropertyyulan_mtg/frame"))
	SetPositionScreenCenter(self.frameWindow)
	
	self.skillScroll = CEGUI.toScrollablePane(winMgr:getWindow("petpropertyyulan_mtg/skillScroll"))
	
	self.tizi = winMgr:getWindow("petpropertyyulan_mtg/tilizhi")
	self.suzi = winMgr:getWindow("petpropertyyulan_mtg/suduzhi")
	self.gongzi = winMgr:getWindow("petpropertyyulan_mtg/gongjizhi")
	self.fazi = winMgr:getWindow("petpropertyyulan_mtg/falizhi")
	self.fangzi = winMgr:getWindow("petpropertyyulan_mtg/fangyuzhi")
	self.grow = winMgr:getWindow("petpropertyyulan_mtg/chongwuzhi")
	
	self.petmob1 = winMgr:getWindow("petpropertyyulan_mtg/mob1")
	self.petmob2 = winMgr:getWindow("petpropertyyulan_mtg/mob2")
	
	self.petItemCell1 = CEGUI.toItemCell(winMgr:getWindow("petpropertyyulan_mtg/text1bg/item1"))
	self.petItemCell2 = CEGUI.toItemCell(winMgr:getWindow("petpropertyyulan_mtg/text1bg/item2"))
	self.ratioText1 = winMgr:getWindow("petpropertyyulan_mtg/text1bg/textgailv1")
	self.ratioText2 = winMgr:getWindow("petpropertyyulan_mtg/text1bg/textgailv2")
	self.petName1 = winMgr:getWindow("petpropertyyulan_mtg/text1bg/textchongwuname1")
	self.petName2 = winMgr:getWindow("petpropertyyulan_mtg/text1bg/textchongwuname2")
	self.levelRange = winMgr:getWindow("petpropertyyulan_mtg/text1bg/text4bg/textzhi")
	
	self.moreSkillTip = winMgr:getWindow("petpropertyyulan_mtg/frame/textzuiduohuode")
	self.cancelBtn = CEGUI.toPushButton(winMgr:getWindow("petpropertyyulan_mtg/frame/btn"))
	self.combineBtn = CEGUI.toPushButton(winMgr:getWindow("petpropertyyulan_mtg/frame/btn1"))


	self.skillBoxes = {}
	for i=1,12 do
		self.skillBoxes[i] = CEGUI.toSkillBox(winMgr:getWindow("petpropertyyulan_mtg/Skill" .. i))
		self.skillBoxes[i]:subscribeEvent("MouseClick", PetPreviewDlg.handleSkillClicked, self)
        self.skillBoxes[i]:SetBackGroupOnTop(true)
	end
	
	self.moreSkillTip:setVisible(false)
	self.skillScroll:EnableAllChildDrag(self.skillScroll)
	self.cancelBtn:subscribeEvent("Clicked", PetPreviewDlg.handleCancelClicked, self)
	self.combineBtn:subscribeEvent("Clicked", PetPreviewDlg.handleCombineClicked, self)
	self.frameWindow:getCloseButton():subscribeEvent("Clicked", PetPreviewDlg.DestroyDialog, nil)
end

function PetPreviewDlg:handleSkillClicked(args)
	local cell = CEGUI.toSkillBox(CEGUI.toWindowEventArgs(args).window)
	if cell:GetSkillID() == 0 then
		return
	end
	local dlg = PetSkillTipsDlg.ShowTip(cell:GetSkillID())
	local s = GetScreenSize()
	SetPositionOffset(dlg:GetWindow(), s.width*0.5, s.height*0.5, 1, 0.5)
end

function PetPreviewDlg:getAttrMaxValue(petBaseId, attrType)
	local conf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petBaseId)
    if conf then
	    if attrType == fire.pb.attr.AttrType.PET_ATTACK_APT then --攻资
		    return conf.attackaptmax
	    elseif attrType == fire.pb.attr.AttrType.PET_DEFEND_APT then --防资
		    return conf.defendaptmax
	    elseif attrType == fire.pb.attr.AttrType.PET_PHYFORCE_APT then --体资
		    return conf.phyforceaptmax
	    elseif attrType == fire.pb.attr.AttrType.PET_MAGIC_APT then --法资
		    return conf.magicaptmax
	    elseif attrType == fire.pb.attr.AttrType.PET_SPEED_APT then --速资
		    return conf.speedaptmax
	    end
    end
	return 0
end

function PetPreviewDlg:getAttrRange(attrType)
	local v1 = self.petData1:getAttribute(attrType)
	local v2 = self.petData2:getAttribute(attrType)
	
	--通用取值范围
	local low = GameTable.common.GetCCommonTableInstance():getRecorder(102).value --宠物合成资质下限取值
	local up = GameTable.common.GetCCommonTableInstance():getRecorder(103).value --宠物合成资质上限取值

	local min = math.floor((v1 + v2) / 2 * low)
	local max = math.floor((v1 + v2) / 2 * up)

	--如果2只宠都是变异宠, 最终生成的资质≤两只宠之间资质上限高的宠的资质上限
	if self.petData1.kind == fire.pb.pet.PetTypeEnum.VARIATION and
	   self.petData2.kind == fire.pb.pet.PetTypeEnum.VARIATION then
		local maxAttr1 = self:getAttrMaxValue(self.petData1.baseid, attrType)
		local maxAttr2 = self:getAttrMaxValue(self.petData2.baseid, attrType)
		max = math.min(max, math.max(maxAttr1, maxAttr2))

	--如果1只宠是变异1只宠是普通:
	--把普通宠资质上限*1.08后与变异宠资质比较，以高的一方作为不可超过的资质上限
	elseif self.petData1.kind == fire.pb.pet.PetTypeEnum.BABY and
		   self.petData2.kind == fire.pb.pet.PetTypeEnum.VARIATION then
		local maxAttr1 = math.floor(self:getAttrMaxValue(self.petData1.baseid, attrType) * up)
		local maxAttr2 = self:getAttrMaxValue(self.petData2.baseid, attrType)
		max = math.min(max, math.max(maxAttr1, maxAttr2))

	elseif self.petData1.kind == fire.pb.pet.PetTypeEnum.VARIATION and
		   self.petData2.kind == fire.pb.pet.PetTypeEnum.BABY then
		local maxAttr1 = self:getAttrMaxValue(self.petData1.baseid, attrType)
		local maxAttr2 = math.floor(self:getAttrMaxValue(self.petData2.baseid, attrType) * up)
		max = math.min(max, math.max(maxAttr1, maxAttr2))
	end

	return min .. " - " .. max
end

function PetPreviewDlg:getGrowRange()
	local v1 = self.petData1.growrate
	local v2 = self.petData2.growrate
	
	local low = GameTable.common.GetCCommonTableInstance():getRecorder(104).value/1000 --宠物合成成长下限减少值
	local up = GameTable.common.GetCCommonTableInstance():getRecorder(105).value/1000 --宠物合成成长上限增加值
	
	local min = math.floor(((v1 + v2) / 2 - low)*1000)/1000
	local max = math.floor(((v1 + v2) / 2 + up)*1000)/1000
	return min .. " - " .. max
end

function PetPreviewDlg:setPetData(petData1, petData2)
	self.petData1 = petData1
	self.petData2 = petData2

    local petAttr1 = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData1.baseid)
    local petAttr2 = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData2.baseid)
    if not petAttr1 or not petAttr2 then
        return
    end
	
	local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(petData1:GetShapeID())
    SetItemCellBoundColorByQulityPet(self.petItemCell1, petAttr1.quality)
	local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
	self.petItemCell1:SetImage(image)
	self.petItemCell1:SetTextUnit(petData1:getAttribute(fire.pb.attr.AttrType.LEVEL))
	self.petName1:setText(petData1.name)
	
	local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(petData2:GetShapeID())
    SetItemCellBoundColorByQulityPet(self.petItemCell2, petAttr2.quality)
	local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
	self.petItemCell2:SetImage(image)
	self.petItemCell2:SetTextUnit(petData2:getAttribute(fire.pb.attr.AttrType.LEVEL))
	self.petName2:setText(petData2.name)
	
	local lv1 = petData1:getAttribute(fire.pb.attr.AttrType.LEVEL)
	local lv2 = petData2:getAttribute(fire.pb.attr.AttrType.LEVEL)
	if lv1 == lv2 then
		self.levelRange:setText(lv1)
	else
		self.levelRange:setText( math.min(lv1, lv2) .. " - " .. math.max(lv1, lv2) )
	end

	self.gongzi:setText( self:getAttrRange(fire.pb.attr.AttrType.PET_ATTACK_APT) )
	self.fangzi:setText( self:getAttrRange(fire.pb.attr.AttrType.PET_DEFEND_APT) )
	self.tizi:setText( self:getAttrRange(fire.pb.attr.AttrType.PET_PHYFORCE_APT) )
	self.fazi:setText( self:getAttrRange(fire.pb.attr.AttrType.PET_MAGIC_APT) )
	self.suzi:setText( self:getAttrRange(fire.pb.attr.AttrType.PET_SPEED_APT) )
	self.grow:setText( self:getGrowRange() )
	

	self.allSkills = {}
	self.skillidMap = {}

    --添加宠物1技能
	local skillnum = petData1:getSkilllistlen()
	for i=1, skillnum do
		local skill = petData1:getSkill(i)
		local t = {[1]=skill, [2]=petData1}
		table.insert(self.allSkills, t)
		self.skillidMap[skill.skillid] = t
	end
	
    --添加宠物2的技能
	skillnum = petData2:getSkilllistlen()
	for i=1, skillnum do
		local skill = petData2:getSkill(i)
		if not self.skillidMap[skill.skillid] then
			local t = {[1]=skill, [2]=petData2}
			table.insert(self.allSkills, t)
			self.skillidMap[skill.skillid] = t
		end
	end

     --检查必带技能
    local pos = 1
    for i=0, petAttr1.skillid:size()-1 do
        local skillid = petAttr1.skillid[i]
		if skillid ~= 0 and petAttr1.skillrate[i] >= tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(323).value) and not self.skillidMap[skillid] then
			local skill = {skillid=skillid, certification=0}
            local t = {[1]=skill, [2]=petData1}
			table.insert(self.allSkills, pos, t)
			self.skillidMap[skillid] = t
            pos = pos+1
		end
	end

    for i=0, petAttr2.skillid:size()-1 do
        local skillid = petAttr2.skillid[i]
		if skillid ~= 0 and petAttr2.skillrate[i] >= tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(323).value) and not self.skillidMap[skillid] then
			local skill = {skillid=skillid, certification=0}
            local t = {[1]=skill, [2]=petData2}
			table.insert(self.allSkills, pos, t)
			self.skillidMap[skillid] = t
            pos = pos+1
		end
	end

	
	--技能大于12个，创建新的格子
	local more = 0
	if #self.allSkills > 12 then
        local left = self.skillBoxes[1]:getXPosition().offset
        local top = self.skillBoxes[1]:getYPosition().offset
        local deltaX = self.skillBoxes[2]:getXPosition().offset - left
        local deltaY = self.skillBoxes[5]:getYPosition().offset - top
		self.moreSkillTip:setVisible(true)
		local winMgr = CEGUI.WindowManager:getSingleton()
		more = #self.allSkills-12
		for i=0, more-1 do
			local skillbox = CEGUI.toSkillBox(winMgr:createWindow("TaharezLook/SkillBox1"))
			skillbox:setSize(CEGUI.UVector2(CEGUI.UDim(0,90), CEGUI.UDim(0,90)))
			local row = math.floor(i/4)
			local col = i%4
			SetPositionOffset(skillbox, left+col*deltaX, top+(row+3)*deltaY)
			skillbox:subscribeEvent("MouseClick", PetPreviewDlg.handleSkillClicked, self)
			self.skillBoxes[12+i+1] = skillbox
			self.skillScroll:addChildWindow(skillbox)
		end
	end
	
	for i = 1, 12+more do
		self.skillBoxes[i]:Clear()
		if i <= #self.allSkills then
			local skill = self.allSkills[i][1]
			SetPetSkillBoxInfo(self.skillBoxes[i], skill.skillid, self.allSkills[i][2], true, skill.certification)
			
			--[[local skillexpiretime = self.allSkills[i][2]:getPetSkillExpires(skill.skillid)
			SkillBoxControl.SetSkillInfo(self.skillBoxes[i], skill.skillid, skillexpiretime)
			self.skillBoxes[i]:SetBackgroundDynamic(true)
			self.skillBoxes[i]:setID(0)--]]
		end
	end
		local s1 = self.petmob1:getPixelSize()
	gGetGameUIManager():AddWindowSprite(self.petmob1,  tonumber(petAttr1.modelid), Nuclear.XPDIR_BOTTOMRIGHT, s1.width * 0.5, s1.height * 0.5 + 50, true)
		local s1 = self.petmob2:getPixelSize()
	gGetGameUIManager():AddWindowSprite(self.petmob2,  tonumber(petAttr2.modelid), Nuclear.XPDIR_BOTTOMRIGHT, s1.width * 0.5, s1.height * 0.5 + 50, true)
end

function PetPreviewDlg:handleCancelClicked(args)
	PetPreviewDlg.DestroyDialog()
end

function PetPreviewDlg:handleCombineClicked(args)
	PetPreviewDlg.DestroyDialog()
	PetLianYaoDlg.getInstance():handleCombineClicked()
end

return PetPreviewDlg
