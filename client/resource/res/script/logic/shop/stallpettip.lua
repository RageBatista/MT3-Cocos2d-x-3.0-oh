------------------------------------------------------------------
-- 摆摊宠物tip
------------------------------------------------------------------
require "logic.dialog"

StallPetTip = {}
setmetatable(StallPetTip, Dialog)
StallPetTip.__index = StallPetTip

local _instance
function StallPetTip.getInstance()
	if not _instance then
		_instance = StallPetTip:new()
		_instance:OnCreate()
	end
	return _instance
end

function StallPetTip.getInstanceAndShow(parent)
	if not _instance then
		_instance = StallPetTip:new()
		_instance:OnCreate(parent)
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function StallPetTip.getInstanceNotCreate()
	return _instance
end

function StallPetTip.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function StallPetTip.ToggleOpenClose()
	if not _instance then
		_instance = StallPetTip:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function StallPetTip.GetLayoutFileName()
	return "petbuytips.layout"
end

function StallPetTip:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, StallPetTip)
	return self
end

function StallPetTip:OnCreate(parent)
	Dialog.OnCreate(self, parent)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self:GetWindow():setRiseOnClickEnabled(false)

	self.itemCell = CEGUI.toItemCell(winMgr:getWindow("petbuytips/wupin"))
	self.name = winMgr:getWindow("petbuytips/mingzi")
	self.levelText = winMgr:getWindow("petbuytips/dengji")
	self.groupBtnSkill = CEGUI.toGroupButton(winMgr:getWindow("petbuytips/jineng"))
	self.groupBtnZizhi = CEGUI.toGroupButton(winMgr:getWindow("petbuytips/jineng1"))
	self.groupBtnAttr = CEGUI.toGroupButton(winMgr:getWindow("petbuytips/jineng11"))
	self.groupBtnNeidan = CEGUI.toGroupButton(winMgr:getWindow("petbuytips/jineng112"))
	
	self.skillView = winMgr:getWindow("petbuytips/fenye1")
	self.skillScroll = CEGUI.toScrollablePane(winMgr:getWindow("petbuytips/fenye1/skillscroll"))
	
	self.zizhiView = winMgr:getWindow("petbuytips/fenye2")
	self.gongziBar = CEGUI.toProgressBar(winMgr:getWindow("petbuytips/fenye2/1/jindu"))
	self.fangziBar = CEGUI.toProgressBar(winMgr:getWindow("petbuytips/fenye2/2/jindu"))
	self.tiziBar = CEGUI.toProgressBar(winMgr:getWindow("petbuytips/fenye2/3/jindu"))
	self.faziBar = CEGUI.toProgressBar(winMgr:getWindow("petbuytips/fenye2/4/jindu"))
	self.suziBar = CEGUI.toProgressBar(winMgr:getWindow("petbuytips/fenye2/5/jindu"))
	self.grow = CEGUI.toProgressBar(winMgr:getWindow("petbuytips/fenye2/6/wenben2"))
	self.zizhidanNum = winMgr:getWindow("petbuytips/fenye2/7/wenben1")
	self.growItemUseNum = winMgr:getWindow("petbuytips/fenye2/7/wenben2")
	self.attrView = winMgr:getWindow("petbuytips/fenye3")
	self.hp = winMgr:getWindow("petbuytips/fenye3/zhi1")
	self.tizhi = winMgr:getWindow("petbuytips/fenye3/zhi2")
	self.mp = winMgr:getWindow("petbuytips/fenye3/zhi3")
	self.moli = winMgr:getWindow("petbuytips/fenye3/zhi4")
	self.phyAttack = winMgr:getWindow("petbuytips/fenye3/zhi5")
	self.power = winMgr:getWindow("petbuytips/fenye3/zhi6")
	self.phyDefend = winMgr:getWindow("petbuytips/fenye3/zhi7")
	self.naili = winMgr:getWindow("petbuytips/fenye3/zhi8")
	self.magicAttack = winMgr:getWindow("petbuytips/fenye3/zhi9")
	self.minjie = winMgr:getWindow("petbuytips/fenye3/zhi10")
	self.magicDefend = winMgr:getWindow("petbuytips/fenye3/zhi11")
	self.qianneng = winMgr:getWindow("petbuytips/fenye3/zhi12")
	self.speed = winMgr:getWindow("petbuytips/fenye3/zhi13")
	self.life = winMgr:getWindow("petbuytips/fenye3/zhi14")
	
	
	-- 内丹、装备
	self.ccskillView = winMgr:getWindow("petbuytips/fenye4")
	self.ccskillScroll = CEGUI.toScrollablePane(winMgr:getWindow("petbuytips/fenye4/skillscroll"))
	
	------------------ event ------------------
	self.groupBtnSkill:subscribeEvent("SelectStateChanged", StallPetTip.handleGroupBtnClicked, self)
	self.groupBtnZizhi:subscribeEvent("SelectStateChanged", StallPetTip.handleGroupBtnClicked, self)
	self.groupBtnAttr:subscribeEvent("SelectStateChanged", StallPetTip.handleGroupBtnClicked, self)
	self.groupBtnNeidan:subscribeEvent("SelectStateChanged", StallPetTip.handleGroupBtnClicked, self)

	------------------ init ------------------
	self.skillBoxes = {}
	for i=1,25 do
		self.skillBoxes[i] = CEGUI.toSkillBox(winMgr:getWindow("petbuytips/fenye1/skillscroll/skill" .. i))
		self.skillBoxes[i]:subscribeEvent("MouseClick", StallPetTip.handleSkillClicked, self)
	end
	self.skillBoxes[25]:setVisible(false)
	self.skillScroll:EnableAllChildDrag(self.skillScroll)
	
	self.skillBoxes2 = {}
	for i=1,6 do
		self.skillBoxes2[i] = CEGUI.toSkillBox(winMgr:getWindow("petbuytips/fenye4/skillscroll/skill" .. i))
		self.skillBoxes2[i]:subscribeEvent("MouseClick", StallPetTip.handleSkillClicked, self)
	end
	self.ccskillScroll:EnableAllChildDrag(self.ccskillScroll)
end

function StallPetTip:setGoodsData(goods)
	self.willCheckTipsWnd = false
	if self.goodskey == goods.key then
		return
	end
	self.goodskey = goods.key

	local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(goods.itemid)
    if petAttr then
	    self.name:setText(petAttr.name)
	
	    local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(petAttr.modelid)
	    local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
	    self.itemCell:SetImage(image)
    end
	
	--请求详细信息
	local p = require("protodef.fire.pb.shop.cmarketpettips"):new()
	p.roleid = goods.saleroleid
	p.key = goods.key
	p.tipstype = PETTIPS_T.STALL_PET_TIP
	LuaProtocolManager:send(p)
	
	--[[print('------------- cmarketpettips --------------')
	for k,v in pairs(p) do
		print(k,v)
	end--]]
end

function StallPetTip:refreshPetData(petData)
	
	self.levelText:setText(petData:getAttribute(fire.pb.attr.AttrType.LEVEL))
	
	--技能
	local skillnum = (petData and petData:getSkilllistlen() or 0)
	self.skillBoxes[25]:setVisible(skillnum==25)
	for i = 1, 25 do
		self.skillBoxes[i]:Clear()
		if i <= skillnum then
			local skill = petData:getSkill(i)
			SetPetSkillBoxInfo(self.skillBoxes[i], skill.skillid, petData, true, skill.certification)
		end
	end
	
	local neidannum = (petData and petData:getInternallistlen() or 0)
	for i = 1, 6 do
		self.skillBoxes2[i]:Clear()
		if i <= neidannum then
			local neidan = petData:getInternal(i)
			SetPetSkillBoxInfond(self.skillBoxes2[i], neidan.skillid, petData, true, neidan.certification)
		end
	end

	--资质
	local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
    if petAttr then
	    local curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_ATTACK_APT)
	    self.gongziBar:setText(curVal)
	    self.gongziBar:setProgress((curVal-petAttr.attackaptmin)/(petAttr.attackaptmax-petAttr.attackaptmin))

	    curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_DEFEND_APT)
	    self.fangziBar:setText(curVal)
	    self.fangziBar:setProgress((curVal-petAttr.defendaptmin)/(petAttr.defendaptmax-petAttr.defendaptmin))
	
	    curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_PHYFORCE_APT)
	    self.tiziBar:setText(curVal)
	    self.tiziBar:setProgress((curVal-petAttr.phyforceaptmin)/(petAttr.phyforceaptmax-petAttr.phyforceaptmin))
	
	    curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_MAGIC_APT)
	    self.faziBar:setText(curVal)
	    self.faziBar:setProgress((curVal-petAttr.magicaptmin)/(petAttr.magicaptmax-petAttr.magicaptmin))
	
	    curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_SPEED_APT)
	    self.suziBar:setText(curVal)
	    self.suziBar:setProgress((curVal-petAttr.speedaptmin)/(petAttr.speedaptmax-petAttr.speedaptmin))
	
	    curVal = math.floor(petData.growrate*1000) / 1000
	    self.grow:setText(curVal)
		if petAttr.growrate:size() > 1 then
			local maxgrow = petAttr.growrate[petAttr.growrate:size()-1] - petAttr.growrate[0]
			if maxgrow > 0 then
				self.grow:setProgress((math.floor(petData.growrate*1000) - petAttr.growrate[0]) / maxgrow)
            else
				self.grow:setProgress(1)
			end
		end
    end
	
	self.zizhidanNum:setText(petData.aptaddcount)
	self.growItemUseNum:setText(petData.growrateaddcount)
	
	--属性
	self.hp:setText(petData:getAttribute(fire.pb.attr.AttrType.HP))
	self.mp:setText(petData:getAttribute(fire.pb.attr.AttrType.MP))
	self.phyAttack:setText(petData:getAttribute(fire.pb.attr.AttrType.ATTACK))
	self.phyDefend:setText(petData:getAttribute(fire.pb.attr.AttrType.DEFEND))
	self.magicAttack:setText(petData:getAttribute(fire.pb.attr.AttrType.MAGIC_ATTACK))
	self.magicDefend:setText(petData:getAttribute(fire.pb.attr.AttrType.MAGIC_DEF))
	self.speed:setText(petData:getAttribute(fire.pb.attr.AttrType.SPEED))
	self.tizhi:setText(petData:getAttribute(fire.pb.attr.AttrType.CONS))
	self.moli:setText(petData:getAttribute(fire.pb.attr.AttrType.IQ))
	self.power:setText(petData:getAttribute(fire.pb.attr.AttrType.STR))
	self.naili:setText(petData:getAttribute(fire.pb.attr.AttrType.ENDU))
	self.minjie:setText(petData:getAttribute(fire.pb.attr.AttrType.AGI))
	self.qianneng:setText(petData:getAttribute(fire.pb.attr.AttrType.POINT))

    if petData:getAttribute(fire.pb.attr.AttrType.PET_LIFE) < 0 then
        self.life:setFont("simhei-10")
        self.life:setText(MHSD_UTILS.get_resstring(11548)) --永生
    else
	    self.life:setText(petData:getAttribute(fire.pb.attr.AttrType.PET_LIFE))
    end
end

function StallPetTip:handleSkillClicked(args)
	local cell = CEGUI.toSkillBox(CEGUI.toWindowEventArgs(args).window)
	if cell:GetSkillID() == 0 then
		return
	end
	local tip = PetSkillTipsDlg.ShowTip(cell:GetSkillID())
	local s = GetScreenSize()
	SetPositionOffset(tip:GetWindow(), s.width*0.5, s.height*0.5, 1, 0.5)
end

function StallPetTip:handleGroupBtnClicked(args)
	local btn = CEGUI.toWindowEventArgs(args).window
	self.skillView:setVisible(btn == self.groupBtnSkill)
	self.zizhiView:setVisible(btn == self.groupBtnZizhi)
	self.attrView:setVisible(btn == self.groupBtnAttr)
	self.ccskillView:setVisible(btn == self.groupBtnNeidan)
end

return StallPetTip
