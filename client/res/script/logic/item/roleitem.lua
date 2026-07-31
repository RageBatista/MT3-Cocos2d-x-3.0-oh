
------------------------------------------------------------------
-- 角色道具类
------------------------------------------------------------------

RoleItem = {}
RoleItem.__index = RoleItem

function RoleItem:new(rRoleItem)
    local self = {}
    setmetatable(self, RoleItem)

    -- 没有参数的构造函数
    if not rRoleItem then
        self.m_bIsTreasure = false
        self.m_pObject = nil
        self.m_pBaseObject = nil
        self.m_bAshy = false
        self.m_vMirrorLoc = {}
    -- 有参数的构造函数
    else
        self.m_bIsTreasure = false

        self.m_pObject = nil
        if rRoleItem.m_pObject then
            self.m_pObject = rRoleItem.m_pObject:Clone()
        end

        self.m_pBaseObject = rRoleItem.m_pBaseObject
        self.m_bAshy = rRoleItem.m_bAshy
        self.m_vMirrorLoc = rRoleItem.m_vMirrorLoc
    end

    return self
end

-- operator=
function RoleItem:operatorEquals(rRoleItem)
    if self ~= rRoleItem then
        self.m_bIsTreasure = false

        self.m_pObject = nil
        if rRoleItem.m_pObject then
            self.m_pObject = rRoleItem.m_pObject:Clone()
        end

        self.m_pBaseObject = rRoleItem.m_pBaseObject
        self.m_bAshy = rRoleItem.m_bAshy
        self.m_vMirrorLoc = rRoleItem.m_vMirrorLoc
    end
end

function RoleItem:GetObject()
    return self.m_pObject
end

function RoleItem:GetBaseObject()
	return self.m_pBaseObject
end

function RoleItem:GetIsBattleUse()
	return self.m_pBaseObject.battleuse
end

function RoleItem:GetLocation()
	return self.m_pObject.loc
end

function RoleItem:GetObjectID()
	return self.m_pObject.data.id
end

function RoleItem:SetItemData(bagid, data)
	if not self:SetItemBaseData(data.id, bagid) then
		return false
	end

	self.m_pObject.data = data
	self.m_pObject.loc.tableType = bagid
	self.m_pObject.loc.position = data.position

	self:OnUpdate(self.m_pObject.loc, -1)
	self:UpdateAllMirrorItem()
		
	return true;
end

function RoleItem:SetAshy(bAshy)
	if self.m_bAshy == bAshy then
		return
	end
	self.m_bAshy = bAshy

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local itemCell = roleItemManager:GetItemCellByLoc(self.m_pObject.loc)
	if not itemCell then
		return
	end
	itemCell:SetAshy(bAshy)

	if not bAshy then
        for k,v in pairs(self.m_vMirrorLoc) do
            self:SetMirrorItemAshy(v, bAshy)
        end
	end
end

function RoleItem:IsAshy()
	return self.m_bAshy
end

function RoleItem:SetMirrorItemAshy(loc, bAshy)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local itemCell = roleItemManager:GetItemCellByLoc(self.m_pObject.loc)
	if not itemCell then
		return
    end
	itemCell:SetAshy(bAshy)
end

function RoleItem:CanUseToPet()
	return self.m_pBaseObject.outbattleuse == 2 or self.m_pBaseObject.outbattleuse == 3
end

function RoleItem:CanRepair()
	return self:GetFirstType() == eItemType_EQUIP and self:GetSecondType() <= eEquipType_BOOT
end

function RoleItem:CanUseInBattle()
	return self.m_pBaseObject.battleuse ~= 0
end

function RoleItem:CanUseToCharacter()
	if self:GetFirstType() == eItemType_GROCERY then
		if self:GetObjectID() == 36026 then
			return false
		end

		if self:GetObjectID() == 36070 then
			self:PrepareUseResetPointItemNotFree(36070)
			return false
		end
	end
	return self.m_pBaseObject.outbattleuse == 1 or self.m_pBaseObject.outbattleuse == 3
end

function RoleItem:GetIcon()
	return self.m_pBaseObject.icon
end

-- 处理洗点物品的代码
function RoleItem:SureResetPointFree(eventArgs)
	local windowargs = CEGUI.toWindowEventArgs(eventArgs)
	local pConfirmBoxInfo = tostConfirmBoxInfo(windowargs.window:getUserData())
	if pConfirmBoxInfo then
	    local roleItemManager = require("logic.item.roleitemmanager").getInstance()

        local itemid = pConfirmBoxInfo.userID
        local pItem = roleItemManager:FindItemByBagAndThisID(itemid)
        if pItem then
	        require "protodef.fire.pb.item.cappenditem"
			local useItem = CAppendItem.Create()
            useItem.keyinpack = pItem:GetThisID()               -- itemID
            useItem.idtype = fire.pb.item.IDType.ROLE           -- 对人用
            useItem.id = gGetDataManager():GetMainCharacterID() -- 自己的id
			LuaProtocolManager.getInstance():send(useItem)
			
			roleItemManager:PlayUseItemEffect(pItem, false)
		end

	    gGetMessageManager():RemoveConfirmBox(pConfirmBoxInfo)
	end

	return true
end

function RoleItem:PrepareUseResetPointItemNotFree(ItemID)
	local MessageID = 142543
    local AmenMessage = GameTable.message.GetCMessageTipTableInstance():getRecorder(MessageID)
	--local AmenMessage = BeanConfigManager.getInstance():GetTableByName("message.cmessagetip"):getRecorder(MessageID)
	gGetMessageManager():AddConfirmBox(eConfirmResetPoint, AmenMessage.msg,
		RoleItem.SureResetPointFree, self, MessageManager.HandleDefaultCancelEvent, MessageManager, self:GetThisID(), 0, nil, "", "")
end

-- 设置道具的状态标志
function RoleItem:SetFlag(flag)
	self.m_pObject.data.flags = flag
	self:OnUpdate(self.m_pObject.loc, eUpdateFlag_COUNT)
	self:UpdateAllMirrorItem(eUpdateFlag_COUNT)
end
function RoleItem:SetTimeout(timeout)
    self.m_pObject.data.loseeffecttime = timeout
end
function RoleItem:Update(delta)
    if bit.band(self.m_pObject.data.flags, fire.pb.Item.TIMEOUT) > 0 then
        if self.m_pObject.data.loseeffecttime < 0 and self.m_pObject.data.loseeffecttime ~= -1 then
            local p = require("protodef.fire.pb.item.citemloseeffect"):new()
            self.m_pObject.data.loseeffecttime = - 1
            p.packid = self.m_pObject.loc.tableType 
            p.itemkey = self.m_pObject.data.key
            LuaProtocolManager:send(p)
        elseif self.m_pObject.data.loseeffecttime > 0 then
            self.m_pObject.data.loseeffecttime = self.m_pObject.data.loseeffecttime - delta
        end
    end
end
function RoleItem:OnUpdate(loc, flag)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local itemCell = roleItemManager:GetItemCellByLoc(loc)
	if not itemCell then
		return false
    end

	if bit.band(flag, eUpdateFlag_IMAGE) ~= 0 then
		itemCell:SetCellTypeMask(1)
		itemCell:setID(self.m_pObject.data.id)
		itemCell:setID2(self:GetThisID())
		local pImage = gGetIconManager():GetItemIconByID(self.m_pBaseObject.icon)
		if not pImage then
			pImage = gGetIconManager():GetItemIconByID(1001)
		end
		itemCell:SetImage(pImage)

		local nQuality = self.m_pBaseObject.nquality
		SetItemCellBoundColorByQulityItem(itemCell, nQuality)
		
		local nBind = self:isBind()
		setItemCellBind(itemCell, nBind, 0, 0)

		if self:GetItemTypeID() == GetNumberValueForStrKey("ITEM_TYPE_HUOBAN") then
			itemCell:SetStyle(CEGUI.ItemCellStyle_IconExtend)
		end
	end

	self:updateEquipScore()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    roleItemManager:SetItemTreasure(self)
    if bit.band(self.m_pObject.data.flags, fire.pb.Item.TIMEOUT) > 0 and self.m_pObject.data.loseeffecttime == -1 then
        itemCell:SetCornerImageAtPos("ccui1", "newgq", 0, 1)
    else
    if self:isTreasure() then
            -- 穿戴和在包裹的特殊显示
            if loc.tableType == fire.pb.item.BagTypes.EQUIP then
                itemCell:SetCornerImageAtPos("ccui1", "tm", 0, 1) -- 穿戴显示 tm
            else
                itemCell:SetCornerImageAtPos("ccui1", "newzp", 0, 1)  -- 包裹显示 newzp
            end
        else
            itemCell:ClearCornerImage(0)
        end        
    end
	
	
	local b = bit.band(flag, eUpdateFlag_COUNT)
    if bit.band(flag, eUpdateFlag_COUNT) ~= 0 then
        if self.m_pObject.data.number > 1 then
            -- 引擎写死了，需要从新封装cegui的C++源码，太麻烦了，暂时搁置
            itemCell:SetTextUnit(CEGUI.PropertyHelper:intToString(self.m_pObject.data.number), CEGUI.ItemCellTextType_RightBottom, CEGUI.colour(1, 0.95, 0.87, 1)) 
            itemCell:setProperty("Font", "simhei-12")
            --itemCell:getFont():setOutlineSize(0) 			
        else
            itemCell:SetTextUnitText("")			
        end
    end 

	-- 加锁物品上写上“锁”
	if bit.band(self.m_pObject.data.flags, fire.pb.Item.LOCK) > 0 then
		local color
		if self.m_pObject.data.timeout == 0 then
			color = CEGUI.PropertyHelper:stringToColour("ffffff00") -- 普通锁的“锁”字颜色为黄色
		else
			color = CEGUI.PropertyHelper:stringToColour("ffff0000") -- 时间锁的“锁”字颜色为红色
		end
		itemCell:SetTextUnit(MHSD_UTILS.get_resstring(1169), CEGUI.ItemCellTextType_LeftTop, color)
	-- 加锁物品去掉“锁”字
    else
		itemCell:SetTextUnit("", CEGUI.ItemCellTextType_LeftTop)
	end

	-- 商会中上架物品与放入商店的物品要区分开
	if loc.tableType >= eClientTableType_TRADE_COUNTER_1 and loc.tableType <= eClientTableType_TRADE_COUNTER_10 then
		if bit.band(self.m_pObject.data.flags, fire.pb.Item.ONCOFCSELL) ~= 0 then
			local red = CEGUI.PropertyHelper:stringToColour("ffff0000")
			itemCell:SetTextUnit(MHSD_UTILS.get_resstring(1170), CEGUI.ItemCellTextType_LeftTop, red)
			itemCell:SetAshy(true)
		else
			itemCell:SetTextUnit("", CEGUI.ItemCellTextType_LeftTop)
			itemCell:SetAshy(false)
		end
	-- 如果是宠物使用道具物品栏，并且这个物品不能被宠物使用，那么这个格子要变灰，不能点击
    elseif loc.tableType == eClientTableType_PETUSEITEM and (not self:CanUseToPet()) then
		itemCell:setEnabled(false)
	-- 如果是战斗中包裹栏，如果不能在战斗中使用，则灰掉不能点击
    elseif (loc.tableType == eClientTableType_BATTLEBAG or loc.tableType == eClientTableType_BATTLE_QUEST_BAG) and (not self:CanUseInBattle()) then
		itemCell:setEnabled(false)
	elseif loc.tableType == eClientTableType_FAMILYREPAIRDLG and (not CanRepair()) then
		itemCell:setEnabled(false)
	elseif loc.tableType == eClientTableType_SKILLREPAIRDLG and (not CanRepair()) then
		itemCell:setEnabled(false)
	elseif loc.tableType == fire.pb.item.BagTypes.EQUIP then
		itemCell:SetBackGroundImage("ccui1", "kuang2")
		gGetGameUIManager():RemoveUIEffect(itemCell)
	elseif loc.tableType == eClientTableType_ANTIQUE then
		if not self:isAntique() then
			itemCell:setEnabled(false)
		end
    -- 自已的摆摊格子
    elseif loc.tableType == eClientTableType_PRIVATESTOREDLG then
		if self.m_pObject.data.flags == fire.pb.Item.ONSTALL then
			local red = CEGUI.PropertyHelper:stringToColour("ffff0000")
			itemCell:SetTextUnit(MHSD_UTILS.get_resstring(1171), CEGUI.ItemCellTextType_LeftTop, red)
			itemCell:SetAshy(true)
		end
	elseif loc.tableType == eClientTableType_ITEM_TRADE_MIRROR then
        local cansale = (ShopManager:getGoodsConfByItemID(self:GetBaseObject().id) and 1 or 0)
		if bit.band(self.m_pObject.data.flags, fire.pb.Item.LOCK) ~= 0 or bit.band(self.m_pObject.data.flags, fire.pb.Item.BIND) ~= 0 or cansale == 0 then
			itemCell:SetAshy(true)
		end
	else
		itemCell:SetBackGroundImage(nil)
	end

	-- 因为背包不是一直保留，会被销毁，流光重新设置
	if self:GetObject().data.isnew then
		gGetGameUIManager():AddUIEffect(itemCell, MHSD_UTILS.get_effectpath(10256), true, 0, 0, true)
		itemCell:SetFloodLight(true)
	end


	local nQuality = self.m_pBaseObject.nquality;
	SetItemCellBoundColorByQulityItem(itemCell, nQuality)

	RoleItem_OnUpdate(itemCell, self, 0, 0)

	return true
end

function RoleItem:ClearItemByLoc(loc)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local itemCell = roleItemManager:GetItemCellByLoc(loc)
	if not itemCell then
		return
    end

	-- 如果此时位置上放置的道具不是自己本身，则不清除，最典型的情况是物品A和B互换位位置，首先
	-- 服务器会发来A的位置改变消息，这时B的位置上存放了A的信息，然后服务器会发来B的位置改变消息，
	-- 如果B再去清除对应格子上的信息，那么这时删除的就是格子上A的物品信息，会导致出错，所以加了此判断
	if roleItemManager:FindItemByBagAndThisID(itemCell:getID2(), loc.tableType) == self then
		itemCell:Clear();

		itemCell:setID(-1);
		itemCell:setID2(-1);

		-- 卸装备，更换装备格子的背景图
        if loc.tableType == fire.pb.item.BagTypes.EQUIP and 1 == GetMainPackDlg() then
			-- 如果新增道具1， 8 位， 需要修改GetEquipTabBackImage， 否则会崩溃
            ItemCell_SetImage_ccui1(itemCell, loc.position)

			SetItemCellBoundColorByQulityItem(itemCell, -1)

			setItemCellBind(itemCell, 0, 0, 0)

			-- 时效性物品失效
			gGetGameUIManager():RemoveUIEffect(itemCell)
		else
			itemCell:SetBackGroundImage(nil)
		end

		-- 去除流光效果
		if itemCell:HasFloodLight() then
			gGetGameUIManager():RemoveUIEffect(itemCell)
			itemCell:SetFloodLight(false)
		end
		itemCell:CheckGuideEnd(CEGUI.RightButton)
	end
    
--[[	if loc.tableType == fire.pb.item.BagTypes.EQUIP and self:isTreasure() then
        itemCell:SetCornerImageAtPos("ccui1", "tm", 0, 1) -- 穿戴时显示
    end--]]
	
    -- 卸装备，更换装备格子的背景图
	if loc.tableType == fire.pb.item.BagTypes.EQUIP and 1 == GetMainPackDlg() then
		-- 带上面具替换口罩时，口罩删除后，背景图片要变为X
		if self:GetSecondType() == eEquipType_RESPIRATOR then
			local vellloc = stObjLocation:new()
			vellloc.tableType = fire.pb.item.BagTypes.EQUIP
			vellloc.position = eEquipType_VEIL
			local pCell = roleItemManager:GetItemCellByLoc(vellloc)
			if pCell and roleItemManager:FindItemByBagAndThisID(pCell:getID2(), vellloc.tableType) then
				local pVellItem = roleItemManager:FindItemByBagAndThisID(pCell:getID2(), vellloc.tableType)
				if not pVellItem then
					itemCell:SetBackGroundImage("common", "common_biaoshi_cc")
				elseif pVellItem:GetSecondType() == eEquipType_EYEPATCH then
					itemCell:SetBackGroundImage("common", "common_biaoshi_cc")
				else
					itemCell:SetBackGroundImage("MainControl5", "EquipX")
                end
			end
		-- 卸掉面具时，口罩背景图要根据当前是否有面具
		elseif self:GetSecondType() == eEquipType_VEIL then
			local vellloc = stObjLocation:new()
			vellloc.tableType = fire.pb.item.BagTypes.EQUIP
			vellloc.position = eEquipType_RESPIRATOR
			local pCell = roleItemManager:GetItemCellByLoc(vellloc)
			if pCell and (not roleItemManager:FindItemByBagAndThisID(pCell:getID2(), vellloc.tableType)) then
                local pVellItem = roleItemManager:FindItemByBagAndThisID(itemCell:getID2(), vellloc.tableType)
				if not pVellItem then
					itemCell:SetBackGroundImage("BaseControl", "goods_packkuang1")
					itemCell:SetBackGroundImage("common", "common_biaoshi_cc")

					pCell:SetBackGroundImage("BaseControl", "goods_packkuang1")
					pCell:SetBackGroundImage("common", "common_biaoshi_cc")
				else
					-- 判断当前格子上的道具类型是面具还是眼睛，如果是眼睛，口罩上的X去掉
					if pVellItem:GetSecondType() == eEquipType_EYEPATCH then
						pCell:SetBackGroundImage("common", "common_biaoshi_cc")
					else
						pCell:SetBackGroundImage("MainControl5", "EquipX")
					end
				end
			end
		end
	end

	self:SetAshy(false)
	self:SetSelected(false)
end

function RoleItem:SetSelected(bSelected)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local itemCell = roleItemManager:GetItemCellByLoc(self.m_pObject.loc)
	if not itemCell then
		return
    end
	itemCell:SetSelected(bSelected)
end

function RoleItem:IsSelected()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local itemCell = roleItemManager:GetItemCellByLoc(self.m_pObject.loc)
	if not itemCell then
		return false
    end
	return itemCell:isSelected()
end

function RoleItem:OnRemove()
	self:ClearItemByLoc(self.m_pObject.loc)
	self:RemoveAllMirrorItem()
	
	return true;
end

function RoleItem:ChangePos(pos)
	self:SetAshy(false)

	-- 第一步 将原位置的信息清除
	self:ClearItemByLoc(self.m_pObject.loc)

	-- 第二步 赋予新的位置
	self.m_pObject.loc.position = pos
	self:OnUpdate(self.m_pObject.loc,-1)

	-- 第三步 改变镜像位置
	self:ChangeMirrorItemLoc(pos)
end

function RoleItem:ChangeNum(num)
	self.m_pObject.data.number = num
	self:SetAshy(false)
	self:OnUpdate(self.m_pObject.loc, eUpdateFlag_COUNT)

	self:UpdateAllMirrorItem(eUpdateFlag_COUNT)
end

function RoleItem:CopyTo(loc)
    table.insert(self.m_vMirrorLoc, loc)
	self:OnUpdate(loc, -1)
end

function RoleItem:UpdateAllMirrorItem(flag)
    -- 默认值
    if not flag then
        flag = -1
    end

    for k,v in pairs(self.m_vMirrorLoc) do
		OnUpdate(v, flag)
	end
	return true;
end

function RoleItem:ChangeMirrorItemLoc(pos)
    for k,v in pairs(self.m_vMirrorLoc) do
        -- 第一步 将原位置的信息清除
		self:ClearItemByLoc(v)

		-- 第二步 赋予新的位置
		v.position = pos
		 
        self:OnUpdate(v, -1)
	end
end

function RoleItem:RemoveMirrorItemLoc(loc)
    for k,v in pairs(self.m_vMirrorLoc) do
		if v == loc then
			self:ClearItemByLoc(loc)
			self.m_vMirrorLoc[k] = nil
			return
		end
	end
end

function RoleItem:RemoveAllMirrorItem()
    for k,v in pairs(self.m_vMirrorLoc) do
		self:ClearItemByLoc(v)
	end
	self.m_vMirrorLoc = {}
end

function RoleItem:GetNameColour()
	if gIsAntiqueItem(self:GetBaseObject().itemtypeid) then
	    return "ff000000"
	elseif self:GetFirstType() == eItemType_EQUIP then
		return self.m_pBaseObject.colour
	elseif self:GetObjectID() == Pet_Star then
        return "ff000000"
	else
		return self.m_pBaseObject.colour
	end

    return "ff000000"
end

function RoleItem:GetDestribe()
	return self.m_pBaseObject.destribe
end

function RoleItem:GetName()
	return self.m_pBaseObject.name
end

function RoleItem:GetNeedLevel()
	return self.m_pBaseObject.needLevel
end

function RoleItem:GetThisID()
	return self.m_pObject.data.key
end

function RoleItem:GetNum()
	return self.m_pObject.data.number
end

-- 根据物品的baseid设置其基本属性
function RoleItem:SetItemBaseData(baseid, packid)
    -- 默认值
    if (not baseid) and (not packid) then
        baseid = 0
        packid = 0
    end

	self.m_pBaseObject = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(baseid)
	if not self.m_pBaseObject then
		return false
	end

    local iconPath = gGetIconManager():GetItemIconPathByID(self.m_pBaseObject.icon)
    if iconPath == "" then
        iconPath = gGetIconManager():GetItemIconPathByID(1001)
    end

	if baseid == Pet_Star then
		self.m_pObject = PetStarObject:new()
		return true
	elseif baseid == Pet_Soul
		or baseid == Pet_Holy_Soul
		or self.m_pBaseObject.itemtypeid == WEAPON_SYMBOL
		or self.m_pBaseObject.itemtypeid == ARMORS_SYMBOL
		or self.m_pBaseObject.itemtypeid == ORNAMENT_SYMBOL then
		self.m_pObject = PetSoulObject:new()
		return true;
	end

    local firstType = self:GetFirstType()
	if firstType == eItemType_PETITEM then
		self.m_pObject = PetItemObject:new()
	elseif firstType == eItemType_PETEQUIPITEM then
	    self.m_pObject = PetEquipItemObject:new()	
	elseif firstType ==  eItemType_FOOD then
		self.m_pObject = FoodObject:new()
	elseif firstType ==  eItemType_DRUG then
		-- 存储类物品单独处理
		if self:GetSecondType() == 4 then
			self.m_pObject = ResumeObject:new()				
		else
			self.m_pObject = DrugObject:new()	
		end		
	elseif firstType ==  eItemType_DIMARM then
		self.m_pObject = DimarmObiect:new()		
	elseif firstType ==  eItemType_GEM then -- 宝石
		self.m_pObject = GemObject:new()	
	elseif firstType ==  eItemType_GROCERY then -- 杂货
		self.m_pObject = GroceryObject:new()	

	    if baseid == c_iTreasureMapBaseID or baseid == c_iSuperTreasureMapBaseID or baseid == c_iHuoDongTreasureMapBaseID then -- 宝图要向服务器请求tips
		    self.m_pObject.bNeedRequireData = true
	    elseif baseid >= FLY_FLAG_LINAN and baseid <= FLY_FLAG_JIAXING then
		    self.m_pObject.bNeedRequireData = true
	    elseif baseid >= WUXING_FLY_FLAG_EMPTY and baseid <= WUXING_FLY_FLAG_JIAXING then
		    self.m_pObject.bNeedRequireData = true
	    elseif baseid == c_iBaoChanBaseID then
		    self.m_pObject.bNeedRequireData = true
	    elseif baseid >= FIRE_FOOD_MIN and baseid <= FIRE_FOOD_MAX then
		    self.m_pObject.bNeedRequireData = true
	    end

	    if self:isAntique() then
		    self.m_pObject.bNeedRequireData = true
	    end

	    local grocery = BeanConfigManager.getInstance():GetTableByName("item.cgroceryeffect"):getRecorder(baseid)
	    if grocery then
		    self.m_pObject.effectName = grocery.effect
	    end
	elseif firstType ==  eItemType_EQUIP_RELATIVE then -- 装备相关
		self.m_pObject = EquipRelativeObject:new()
	elseif firstType ==  eItemType_EQUIP then -- 装备
		self.m_pObject = EquipObject:new()
        self.m_pObject.data.id = baseid
		local equip = GameTable.item.GetCEquipEffectTableInstance():getRecorder(baseid)
		if equip.id ~= -1 then
			if packid == eClientTableType_NPC_SELL then
				for i = 0, equip.baseEffectType.size()-1 do
					self.m_pObject.baseEffect[equip.baseEffectType[i]] = equip.baseEffect[i]
				end 
			end
			self.m_pObject.roleNeed = equip.roleNeed
			self.m_pObject.sexNeed = equip.sexNeed
		end
	elseif firstType ==  eItemType_TASKITEM then -- 任务物品
		self.m_pObject = TaskObject:new()
		local taskObject = BeanConfigManager.getInstance():GetTableByName("item.ctaskrelative"):getRecorder(baseid)
		if taskObject then
			self.m_pObject.effectName = taskObject.task
			self.m_pObject.readBarTime = taskObject.readtime
			self.m_pObject.readBarText = taskObject.readtext
		end
	else
		return false
	end

	if packid == 0
        or (packid >= eClientTableType_TRADE_COUNTER_1 and packid <= eClientTableType_TRADE_COUNTER_10)
		or packid == eClientTableType_COFC_SELL_SHOP
		or packid == eClientTableType_RANKLIST_DISCOVERANTIQUE then
		self.m_pObject.bNeedRequireData = false
	end

	return true
end

function RoleItem:isTreasure()
	return self.m_bIsTreasure
end

-- 装备是否满足角色需求 true 满足
function RoleItem:IsEquipRoleNeed()
	if self:GetFirstType() ~= eItemType_EQUIP then
		return false
    end

	if self:GetSecondType() ~= eEquipType_ARMS then
		return true
    end

	local pObject = self.m_pObject

	-- 似曾相识的武器谁都不能装备
	if self:GetObjectID() == TASKCOMMON_WEAPON then
		return false
    end

	if pObject.roleNeed:size() == 0 then
		return true
    end

	for i = 0, pObject.roleNeed:size() - 1 do
		-- 现在主角的shape值可能是11-20，21-30了
		if gGetDataManager():GetMainCharacterCreateShape() == pObject.roleNeed[i] then
			return true
        end
	end

	return false
end

-- 查看是否绑定 true bind, false unbind
function RoleItem:isBind()
    local nBind = bit.band(self.m_pObject.data.flags, fire.pb.Item.BIND)
    if nBind ~= 0 then
        return true
    end
    return false
end

function RoleItem:GetEquipScore()
	local pObject = self.m_pObject

	return pObject.equipscore
end



-- 根据分数装备是否是珍品
function RoleItem:updateEquipScore()
    if self:GetFirstType() == eItemType_EQUIP then

        local pObject = self.m_pObject

        local reduceScore = 0

        local gemvector = pObject:GetGemlist()

        for i = 1, gemvector:size() do
            local gemid = gemvector[i - 1]
            local itemTable = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(gemid)
            if itemTable then
                reduceScore = reduceScore + itemTable.level * 15
            end
        end

        local roleItemManager = require("logic.item.roleitemmanager").getInstance()
        local pCell = roleItemManager:GetItemCellByItem(self)
        if not pCell then
            return
        end
        pCell:ClearCornerImage(0)

        local equipConfig = BeanConfigManager.getInstance():GetTableByName("item.cequipitemattr"):getRecorder(self:GetObjectID())
        if equipConfig and equipConfig.treasureScore <= (pObject.equipscore - reduceScore) then
            self:setTreasure(true)
        end

        if self:isTreasure() then
            if self:GetLocation().tableType == fire.pb.item.BagTypes.EQUIP then
                pCell:SetCornerImageAtPos("ccui1", "tm", 0, 1) -- 穿戴时显示 tm
            else
                pCell:SetCornerImageAtPos("ccui1", "newzp", 0, 1)  -- 包裹中显示 newzp
            end
        end
    end
end

function RoleItem:GetGemCountByLevel(level)
	local count = 0;
	if self:GetFirstType() == eItemType_EQUIP then

		local pObject = self.m_pObject;
		local gemvector = pObject:GetGemlist();

	    for i = 1, gemvector:size() do
		    local gemid = gemvector[i - 1];
			local itemTable = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(gemid)
			if itemTable then
				if itemTable.level == level then
					count = count + 1;
				end
			end
		end
	end
	return count;
end

-- 是否可以增加当前HP
function RoleItem:CanAddHp()
	local foodDrugConfig = BeanConfigManager.getInstance():GetTableByName("item.cfoodanddrugeffect"):getRecorder(self.m_pBaseObject.id)
	if not foodDrugConfig then
		return false
    end

	-- 战斗外不可使用或只能宠物使用，返回false
	if self.m_pBaseObject.outbattleuse == 0 or self.m_pBaseObject.outbattleuse == 2 then
		return false
    end

	-- 功能id 1：加血 4：加血加蓝 5：加血加伤
	if foodDrugConfig.funtionid == 1 or foodDrugConfig.funtionid == 4 or foodDrugConfig.funtionid == 5 then
		return true
    end

	return false
end

function RoleItem:isAntique()
	local typeID = self:GetBaseObject().itemtypeid
	return gIsAntiqueItem(typeID)
end

function RoleItem:isWordPuzzleAntique()
	local baseID = self:GetBaseObject().id
	if baseID >= c_iWorldPuzzleAntiqueIDMin and baseID <= c_iWorldPuzzleAntiqueIDMax then
		return true
	end
	return false
end

-- 是否可以恢复伤势
function RoleItem:CanResumeInjury()
	local foodDrugConfig = BeanConfigManager.getInstance():GetTableByName("item.cfoodanddrugeffect"):getRecorder(self.m_pBaseObject.id)
	if not foodDrugConfig then
		return false
    end

	-- 战斗外不可使用或只能宠物使用，返回false
	if self.m_pBaseObject.outbattleuse == 0 or self.m_pBaseObject.outbattleuse == 2 then
		return false
    end

	-- 功能id 3：治疗伤势 5：加血加伤
	if foodDrugConfig.funtionid == 3 or foodDrugConfig.funtionid == 5 then
		return true
    end

	return false
end

-- 是否可以增加当前MP
function RoleItem:CanAddMp()
	local foodDrugConfig = BeanConfigManager.getInstance():GetTableByName("item.cfoodanddrugeffect"):getRecorder(self.m_pBaseObject.id)
	if not foodDrugConfig then
		return false
    end

	-- 战斗外不可使用或只能宠物使用，返回false
	if self.m_pBaseObject.outbattleuse == 0 or self.m_pBaseObject.outbattleuse == 2 then
		return false
    end

	-- 功能id 2：加蓝 4：加血加蓝
	if foodDrugConfig.funtionid == 2 or foodDrugConfig.funtionid == 4 then
		return true
    end

	return false
end

function RoleItem:GetProgressBarText()
	local pObject = self.m_pObject
	return pObject.readBarText
end

-- 任务物品使用时读进度条的时间
function RoleItem:GetProgressBarTime()
	local pObject = self.m_pObject
	return pObject.readBarTime
end

-- 使用时是否需要二次确认
function RoleItem:IsNeedSecondConfirmUse()
	if self:GetFirstType() == eItemType_DRUG then
		if self:GetSecondType() == 3 and self.m_pBaseObject.itemtypeid ~= 307 then
			return true
        end
	end

	return false;
end

-- 是否在战斗中使用 true 只能在战斗中使用，否则false
function RoleItem:isUseInBattle()
	return self.m_pBaseObject.outbattleuse == 0 and self.m_pBaseObject.battleuse ~= 0
end

-- 查看是否锁定 true lock,false unlock
function RoleItem:isLock()
	return bit.band(self.m_pObject.data.flags, fire.pb.Item.LOCK) ~= 0
end

function RoleItem:setTreasure(treasure)
	self.m_bIsTreasure = treasure
end

function RoleItem:SetObjectID(baseid)
	self.m_pBaseObject = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(baseid)
	if self.m_pObject then
		self.m_pObject.data.id = baseid
    end
end

-- 得到修理失败次数
function RoleItem:GetRepairFailCount()
	if self:GetFirstType() ~= eItemType_EQUIP then
		return 0
    end

	local pObject = self.m_pObject
	if not pObject then
		return 0
    end
	return pObject.repairTimes
end

-- 刷新修理失败次数
function RoleItem:SetRepairFailCount(failcount)
	if self:GetFirstType() ~= eItemType_EQUIP then
		return
    end

	local pObject = self.m_pObject
	if not pObject then
		return
    end
	pObject.repairTimes = failcount
end

-- 得到装备耐久度上限
function RoleItem:GetEndureUpperLimit()
	if self:GetFirstType() ~= eItemType_EQUIP then
		return 0
    end

	local pObject = self.m_pObject
	if not pObject then
		return 0
    end
	return pObject.endureuplimit
end

-- 刷新装备耐久度上限
function RoleItem:SetEndureUpperLimit(endureupper)
	if self:GetFirstType() ~= eItemType_EQUIP then
		return
    end

	local pObject = self.m_pObject
	if not pObject then
		return
    end
	pObject.endureuplimit = endureupper
end

-- 得到装备耐久
function RoleItem:GetEndure()
	if self:GetFirstType() ~= eItemType_EQUIP then
		return 0
    end

	local pObject = self.m_pObject
	if not pObject then
		return 0
    end
	return pObject.endure
end

-- 设置装备耐久
function RoleItem:SetEndure(endure)
	if self:GetFirstType() == eItemType_EQUIP then
		self.m_pObject.endure = endure
	elseif self:GetFirstType() == eItemType_DIMARM then
		self.m_pObject.endure = endure
	end
end

function RoleItem:GetItemLevel()
	return self.m_pBaseObject.level
end

function RoleItem:GetSecondType()
	if IsNewEquip(self:GetItemTypeID()) then
		return NewEquippos(self:GetItemTypeID())
	else
	return bit.band(bit.brshift(self.m_pBaseObject.itemtypeid, 4), 15)
	end
end

function RoleItem:GetFirstType()
	return bit.band(self.m_pBaseObject.itemtypeid, 15)
end

function RoleItem:GetItemTypeID()
	return self.m_pBaseObject.itemtypeid
end

return RoleItem