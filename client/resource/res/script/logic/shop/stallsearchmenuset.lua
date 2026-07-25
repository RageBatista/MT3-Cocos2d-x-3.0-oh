------------------------------------------------------------------
-- 摆摊搜索菜单
------------------------------------------------------------------
require "logic.multimenu"



------------------------ 装备搜索菜单 ----------------------------

--类型
--对应摆摊二级菜单
StallSearchEquipTypeMenu = {
	columnCount = 4,
	btnw = 200,
	btnh = 80,
	font = "simhei-12"
}

function StallSearchEquipTypeMenu.toggleShowHide()
	return MultiMenu.toggleShowHide(StallSearchEquipTypeMenu)
end

function StallSearchEquipTypeMenu:getButtonCount()
	local firstConf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketfirsttable")):getRecorder(STALL_CATALOG1_T.GEM_EQUIP)
	return firstConf.secondmenus:size()
end

function StallSearchEquipTypeMenu:setButtonTitles(buttons)
	local firstConf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketfirsttable")):getRecorder(STALL_CATALOG1_T.GEM_EQUIP)
	for i=0, firstConf.secondmenus:size()-1 do
		local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketsecondtable")):getRecorder(firstConf.secondmenus[i])
		buttons[i+1]:setText(conf.name)
		buttons[i+1]:setID(conf.id)
	end
end


------------------------------------------------------------------
--等级
--对应摆摊三级菜单
StallSearchEquipLevelMenu = {
	columnCount = 1,
	btnw = 120,
	btnh = 50,
	font = "simhei-12"
}

function StallSearchEquipLevelMenu.toggleShowHide()
	return MultiMenu.toggleShowHide(StallSearchEquipLevelMenu)
end

function StallSearchEquipLevelMenu:getButtonCount()
	return 5
end

function StallSearchEquipLevelMenu:setButtonTitles(buttons)
	local levelChar = MHSD_UTILS.get_resstring(3) --级
	for k,v in pairs(buttons) do
		local level = 60 + (k-1)*10
		v:setText(level  .. levelChar)
		v:setID(level)
	end
end


------------------------------------------------------------------
--特效
StallSearchEquipEffectMenu = {
	columnCount = 4,
	btnw = 200,
	btnh = 80,
	font = "simhei-12"
}

function StallSearchEquipEffectMenu.toggleShowHide()
	return MultiMenu.toggleShowHide(StallSearchEquipEffectMenu)
end

function StallSearchEquipEffectMenu:getButtonCount()
	if not StallSearchEquipEffectMenu.effectIds then
		local equipAttrTable = BeanConfigManager.getInstance():GetTableByName("item.cequipaddattributelib")
		local ids = equipAttrTable:getAllID()
		StallSearchEquipEffectMenu.effectIds = {}
        StallSearchEquipEffectMenu.skillIds = {}
		for _,id in pairs(ids) do
			if math.floor(id / 1000) == 2 then
                local conf = equipAttrTable:getRecorder(id)
				if conf.isshow == 1 then
					table.insert(StallSearchEquipEffectMenu.effectIds, id)
					table.insert(StallSearchEquipEffectMenu.skillIds, conf.skillid)
				end
			end
		end
	end
	return #StallSearchEquipEffectMenu.effectIds + 1
end

function StallSearchEquipEffectMenu:setButtonTitles(buttons)
	for k,v in pairs(buttons) do
		if k == 1 then
			v:setText(MHSD_UTILS.get_resstring(3148)) --无
			v:setID(0)
		else
			local effectId = StallSearchEquipEffectMenu.effectIds[k-1]
			local conf = BeanConfigManager.getInstance():GetTableByName("item.cequipaddattributelib"):getRecorder(effectId)
			v:setText(conf.name)
			v:setID(StallSearchEquipEffectMenu.skillIds[k-1])
		end
	end
end


------------------------------------------------------------------
--特技
StallSearchEquipSkillMenu = {
	columnCount = 4,
	btnw = 200,
	btnh = 80,
	font = "simhei-12"
}

function StallSearchEquipSkillMenu.toggleShowHide()
	return MultiMenu.toggleShowHide(StallSearchEquipSkillMenu)
end

function StallSearchEquipSkillMenu:getButtonCount()
	if not StallSearchEquipSkillMenu.effectIds then
		local equipAttrTable = BeanConfigManager.getInstance():GetTableByName("item.cequipaddattributelib")
		local ids = equipAttrTable:getAllID()
		StallSearchEquipSkillMenu.effectIds = {}
        StallSearchEquipSkillMenu.skillIds = {}
		for _,id in pairs(ids) do
			if math.floor(id / 1000) == 3 then
                local conf = equipAttrTable:getRecorder(id)
				if conf.isshow == 1 then
					table.insert(StallSearchEquipSkillMenu.effectIds, id)
					table.insert(StallSearchEquipSkillMenu.skillIds, conf.skillid)
				end
			end
		end
	end
	return #StallSearchEquipSkillMenu.effectIds + 1
end

function StallSearchEquipSkillMenu:setButtonTitles(buttons)
	for k,v in pairs(buttons) do
		if k == 1 then
			v:setText(MHSD_UTILS.get_resstring(3148)) --无
			v:setID(0)
		else
			local id = StallSearchEquipSkillMenu.effectIds[k-1]
			local conf = BeanConfigManager.getInstance():GetTableByName("item.cequipaddattributelib"):getRecorder(id)
			v:setText(conf.name)
			v:setID(StallSearchEquipSkillMenu.skillIds[k-1])
		end
	end
end


------------------------------------------------------------------
--基础属性
StallSearchEquipBasicAttrMenu = {
	columnCount = 2,
	fixRow = 4,
	btnw = 120,
	btnh = 50,
	font = "simhei-12",
	allIds = {
        fire.pb.attr.EffectType.DAMAGE_ABL,		    --物理伤害
		fire.pb.attr.EffectType.MAGIC_ATTACK_ABL,	--法术伤害
		fire.pb.attr.EffectType.MEDICAL_ABL,		--治疗强度
		fire.pb.attr.EffectType.MAX_HP_ABL,		    --生命
		fire.pb.attr.EffectType.MAX_MP_ABL,	        --魔法
		fire.pb.attr.EffectType.DEFEND_ABL,			--物理防御
        fire.pb.attr.EffectType.MAGIC_DEF_ABL,		--法术防御
        fire.pb.attr.EffectType.SPEED_ABL			--速度
	}
}

function StallSearchEquipBasicAttrMenu.toggleShowHide(choosedIds)
	if TableUtil.tablelength(choosedIds) == #StallSearchEquipBasicAttrMenu.allIds then
		return nil
	end
	StallSearchEquipBasicAttrMenu.choosedIds = choosedIds
	return MultiMenu.toggleShowHide(StallSearchEquipBasicAttrMenu)
end

function StallSearchEquipBasicAttrMenu.getBasicAttrCount()
	return #StallSearchEquipBasicAttrMenu.allIds
end

function StallSearchEquipBasicAttrMenu:getButtonCount()
	self.ids = {}
	for _,id in pairs(self.allIds) do
		if not self.choosedIds[id] then
			table.insert(self.ids, id)
		end
	end
	return #self.ids
end

function StallSearchEquipBasicAttrMenu:setButtonTitles(buttons)
	local t = BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig")
	for k,v in pairs(buttons) do
        local id = self.ids[k] - self.ids[k] % 10 --EffectType --> AttrType
		local conf = t:getRecorder(id)
		if conf then
			v:setText(conf.name)
			v:setID(self.ids[k])
		end
	end
end







------------------------ 宠物搜索菜单 ----------------------------

--类型
StallSearchPetTypeMenu = {
	columnCount = 4,
	btnw = 200,
	btnh = 80,
	fixRow = 4,
	font = "simhei-12"
}

StallSearchPetTypeMenu.isBianYi = false
StallSearchPetTypeMenu.petTypeGroup = 1 --1.普通  2.灵兽  3.神兽
StallSearchPetTypeMenu.filterDatas = nil

--@idx1: 1.普通 2.变异
--@idx2: 1.宝宝 2.灵兽 3.神兽
--@idx3: 所选的宠物在数组中的序号
function StallSearchPetTypeMenu.getData(idx1, idx2, idx3)
    if StallSearchPetTypeMenu.filterDatas[idx1] and StallSearchPetTypeMenu.filterDatas[idx1][idx2] then
        return StallSearchPetTypeMenu.filterDatas[idx1][idx2][idx3]
    end
    return nil
end

function StallSearchPetTypeMenu.toggleShowHide(isBianYi)
	StallSearchPetTypeMenu.isBianYi = isBianYi
	StallSearchPetTypeMenu.petTypeGroup = 1

	if not StallSearchPetTypeMenu.filterDatas then
		StallSearchPetTypeMenu.filterDatas = {{{},{}}, {{},{},{}}} --1.普通(宝宝，灵兽)  2.变异(变异宝宝，变异灵兽，神兽)

        local dataTable = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketthreetable"))
        local ids = dataTable:getAllID()
        for _,id in pairs(ids) do
            local conf = dataTable:getRecorder(id)
			if conf.itemtype == STALL_GOODS_T.PET and conf.cansale == 1 then
				local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(conf.itemid)
				if petAttr then
					local data = {id=id, name=petAttr.name}
					--print('pet kind ' .. petAttr.kind .. ' ' .. petAttr.unusualid .. ' ' .. petAttr.name)
					if petAttr.kind == fire.pb.pet.PetTypeEnum.BABY then --普通
						if petAttr.unusualid == 0 then --宝宝
							table.insert(StallSearchPetTypeMenu.filterDatas[1][1], data)
						elseif petAttr.unusualid == 1 then --灵兽
							table.insert(StallSearchPetTypeMenu.filterDatas[1][2], data)
						end
					elseif petAttr.kind == fire.pb.pet.PetTypeEnum.VARIATION then --变异
						if petAttr.unusualid == 0 then --宝宝
							table.insert(StallSearchPetTypeMenu.filterDatas[2][1], data)
						elseif petAttr.unusualid == 1 then --灵兽
							table.insert(StallSearchPetTypeMenu.filterDatas[2][2], data)
						end
                    elseif petAttr.kind == fire.pb.pet.PetTypeEnum.SACREDANIMAL then --神兽
                        table.insert(StallSearchPetTypeMenu.filterDatas[2][3], data)
					end
				end
			else
				break
			end
		end
	end

	local menu = MultiMenu.toggleShowHide(StallSearchPetTypeMenu)
	if menu then
		local btnw = 200
		local btnh = 50

		menu.window:setHeight(CEGUI.UDim(0, menu.window:getPixelSize().height+btnh+10))
		menu.scroll:setYPosition(CEGUI.UDim(0, menu.scroll:getYPosition().offset+btnh+10))
        local w = menu.window:getPixelSize().width

		local winMgr = CEGUI.WindowManager:getSingleton()

		local btn1 = CEGUI.toGroupButton(winMgr:createWindow("TaharezLook/GroupButtontj"))
		btn1:setID(1)
		btn1:setSize(NewVector2(btnw, btnh))
		btn1:setText(MHSD_UTILS.get_resstring(11429)) --普通
		btn1:EnableClickAni(false)
		btn1:setSelected(true, false)
		menu.window:addChildWindow(btn1)
		btn1:subscribeEvent("SelectStateChanged", StallSearchPetTypeMenu.handlePetTypeGroupChanged, menu)

		local btn2 = CEGUI.toGroupButton(winMgr:createWindow("TaharezLook/GroupButtontj"))
		btn2:setID(2)
		btn2:setSize(NewVector2(btnw, btnh))
		btn2:setText(MHSD_UTILS.get_resstring(11430)) --灵兽
		btn2:EnableClickAni(false)
		menu.window:addChildWindow(btn2)
		btn2:subscribeEvent("SelectStateChanged", StallSearchPetTypeMenu.handlePetTypeGroupChanged, menu)

        if StallSearchPetTypeMenu.isBianYi then
            local btn3 = CEGUI.toGroupButton(winMgr:createWindow("TaharezLook/GroupButtontj"))
		    btn3:setID(3)
		    btn3:setSize(NewVector2(btnw, btnh))
		    btn3:setText(MHSD_UTILS.get_resstring(11522)) --神兽
		    btn3:EnableClickAni(false)
		    menu.window:addChildWindow(btn3)
		    btn3:subscribeEvent("SelectStateChanged", StallSearchPetTypeMenu.handlePetTypeGroupChanged, menu)

            btn1:setPosition(NewVector2(w*0.5-btnw*1.5, 10))
            btn2:setPosition(NewVector2(w*0.5-btnw*0.5, 10))
            btn3:setPosition(NewVector2(w*0.5+btnw*0.5, 10))
        else
            btn1:setPosition(NewVector2(w*0.5-btnw, 10))
            btn2:setPosition(NewVector2(w*0.5, 10))
        end
	end
	return menu
end

function StallSearchPetTypeMenu:getButtonCount()
    local idx1 = (StallSearchPetTypeMenu.isBianYi and 2 or 1)
	local idx2 = StallSearchPetTypeMenu.petTypeGroup
    return #StallSearchPetTypeMenu.filterDatas[idx1][idx2]
end

function StallSearchPetTypeMenu:setButtonTitles(buttons)
	local idx1 = (StallSearchPetTypeMenu.isBianYi and 2 or 1)
	local idx2 = StallSearchPetTypeMenu.petTypeGroup
	local datas = StallSearchPetTypeMenu.filterDatas[idx1][idx2]

	for k,v in pairs(buttons) do
		if datas[k] then
			v:setText(datas[k].name)
			--v:setID(datas[k].id)
            v:setID(StallSearchPetTypeMenu.petTypeGroup) --保存是宝宝还是灵兽
            v:setID2(k) --保存数据序号
		end
	end
end

function StallSearchPetTypeMenu.handlePetTypeGroupChanged(menu, args)
	StallSearchPetTypeMenu.petTypeGroup = CEGUI.toWindowEventArgs(args).window:getID()
	menu:init()
end



--资质成长
StallSearchPetZizhiMenu = {
	columnCount = 2,
	fixRow = 4,
	btnw = 120,
	btnh = 50,
	font = "simhei-12",
	allIds = {
		fire.pb.attr.AttrType.PET_ATTACK_APT,	--攻资
		fire.pb.attr.AttrType.PET_DEFEND_APT,	--防资
		fire.pb.attr.AttrType.PET_PHYFORCE_APT,	--体资
		fire.pb.attr.AttrType.PET_MAGIC_APT,	--法资
		fire.pb.attr.AttrType.PET_SPEED_APT,	--速资
		fire.pb.attr.AttrType.PET_GROW_RATE		--成长
	},
	nameStrIds = {
		11417,	--攻击资质
		11418,	--防御资质
		11419,	--体力资质
		11420,	--法力资质
		11421,	--速度资质
		11422	--成长
	}
}

function StallSearchPetZizhiMenu.toggleShowHide(choosedIds)
	if TableUtil.tablelength(choosedIds) == 6 then
		return nil
	end
	StallSearchPetZizhiMenu.choosedIds = choosedIds
	return MultiMenu.toggleShowHide(StallSearchPetZizhiMenu)
end

function StallSearchPetZizhiMenu:getButtonCount()
	return 6 - TableUtil.tablelength(self.choosedIds)
end

function StallSearchPetZizhiMenu:setButtonTitles(buttons)
	local idx = 1
	for i,v in pairs(self.allIds) do
		if not self.choosedIds[v] then
			if buttons[idx] and self.nameStrIds[i] then
				buttons[idx]:setText(MHSD_UTILS.get_resstring(self.nameStrIds[i]))
				buttons[idx]:setID(v)
			end
			idx = idx + 1
		end
	end
end


--基础属性
StallSearchPetAttrMenu = {
	columnCount = 2,
	fixRow = 4,
	btnw = 120,
	btnh = 50,
	font = "simhei-12",
	allIds = {
		fire.pb.attr.AttrType.ATTACK,		--物理伤害
		fire.pb.attr.AttrType.MAGIC_ATTACK,	--法术伤害
		fire.pb.attr.AttrType.MAX_HP,		--生命
		fire.pb.attr.AttrType.DEFEND,		--物理防御
		fire.pb.attr.AttrType.MAGIC_DEF,	--法术防御
		fire.pb.attr.AttrType.SPEED			--速度
	},
	nameStrIds = {
		11423,	--物理伤害
		11424,	--法术伤害
		11425,	--生命
		11426,	--物理防御
		11427,	--法术防御
		11428	--速度
	}
}

function StallSearchPetAttrMenu.toggleShowHide(choosedIds)
	if TableUtil.tablelength(choosedIds) == 6 then
		return nil
	end
	StallSearchPetAttrMenu.choosedIds = choosedIds
	return MultiMenu.toggleShowHide(StallSearchPetAttrMenu)
end

function StallSearchPetAttrMenu:getButtonCount()
	return 6 - TableUtil.tablelength(self.choosedIds)
end

function StallSearchPetAttrMenu:setButtonTitles(buttons)
	local idx = 1
	for i,v in pairs(self.allIds) do
		if not self.choosedIds[v] then
			if buttons[idx] and self.nameStrIds[i] then
				buttons[idx]:setText(MHSD_UTILS.get_resstring(self.nameStrIds[i]))
				buttons[idx]:setID(v)
			end
			idx = idx + 1
		end
	end
end