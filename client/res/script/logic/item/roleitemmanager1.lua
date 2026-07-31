------------------------------------------------------------------
-- ��ɫ���߹�����
------------------------------------------------------------------

eItemOpSoundType_Pickup         = 0
eItemOpSoundType_Putdown        = 1

-------------------------------------------------------------

RoleItemManager ={}
RoleItemManager.__index = RoleItemManager

local _instance

function RoleItemManager.getInstance()
    if not _instance then
        _instance = RoleItemManager:new()
    end
    return _instance
end

function RoleItemManager.destroyInstance()
    if _instance then
        for first, second in pairs(_instance.m_BagInfo) do
            local list = second
            for _, pItem in pairs(list) do
                if pItem then
                    pItem:OnRemove()
                    pItem = nil
                end
            end
        end
        _instance = nil
    end
end

function RoleItemManager:new()
    local self = {}
    setmetatable(self, RoleItemManager)

    self.m_iPackMoney                = 0        -- �����ֽ�
	self.m_iDeportMoney              = 0        -- �ֿ��ֽ�
	self.m_iReserveMoney             = 0        -- ������
    self.m_iGold                     = 0        -- ���
	self.m_bUseFlyFlagToFly          = true
	self.m_bShowMoneyFlyEffect       = true
	self.m_equipEffectShow           = false
	self.m_pEquipEffect              = nil
	self.m_EquipQuality              = 0
	self.m_superTreasureKey          = 0
    self.m_BagInfo                   = {}
    self.m_vCanStallItemBaseIds      = {}
    self.m_MapMoney                  = {}
    self.m_BagCapacity               = {}
    self.m_depotNames				 = {}
	self.m_rideItemId				 = 0
	self.m_rideId					 = 0

    self.m_BagInfo[fire.pb.item.BagTypes.BAG] = {}

    self.m_fUpdateFuMoCd = 1.0
    self.m_fUpdateFuMoCdDt = 0.0

    return self
end

function RoleItemManager:setDepotNames(names)
    for k,v in pairs(names) do
        self.m_depotNames[k] = v
    end
end

function RoleItemManager:setDepotNameByIndex(index, name)
    self.m_depotNames[index] = name
end

function RoleItemManager:getDepotNamesByIndex( index )
    if self.m_depotNames[index] then
        return self.m_depotNames[index]
    end
    return nil
end

function RoleItemManager:ItemNumChange(keyinpack, packid, curnum)
	local item = self:FindItemByBagAndThisID(keyinpack, packid)
	if item then
		local baseid = item:GetObjectID()
		item:ChangeNum(curnum)

		-- ĳ��baseID�ĵ��������ı�
		gGetRoleItemManager():FireItemNumChange(ItemIDParameter(keyinpack, baseid, fire.pb.item.BagTypes.BAG))

		if item:GetItemTypeID() == ZHENFA_BOOK and packid == fire.pb.item.BagTypes.BAG then -- �⻷��
			YangChengListDlg.notifyZhenFaAdd(baseid)
		end
	end
	CharacterPropertyAddPtrDlg.getInstanceExistAndShow()
	AddPointManager.getInstanceAndUpdate()
	require("logic.item.depot"):getInstanceRefresh()
end

function RoleItemManager:SetPackMoney(money)
	self.m_iPackMoney = math.floor(money)
	self:CheckMoneyOverLimit()
	gGetRoleItemManager().m_EventPackMoneyChange:Bingo()
end

function RoleItemManager:GetPackMoney()
	return self.m_iPackMoney
end

function RoleItemManager:SetDeportMoney(money)
	self.m_iDeportMoney = math.floor(money)
	self:CheckMoneyOverLimit()
	gGetRoleItemManager().m_EventDeportMoneyChange:Bingo()
end

function RoleItemManager:GetDeportMoney()
	return self.m_iDeportMoney
end

function RoleItemManager:SetReserveMoney(money)
	self.m_iReserveMoney = money
	gGetRoleItemManager().m_EventReserveMoneyChange:Bingo()
end
function RoleItemManager:IsMainPackEmpty()
    if not self.m_BagInfo[fire.pb.item.BagTypes.BAG] then
        return true
    end

    if TableUtil.tablelength(self.m_BagInfo[fire.pb.item.BagTypes.BAG]) == 0 then
        return true
    end

    return false
end
function RoleItemManager:GetReserveMoney()
	return self.m_iReserveMoney
end

function RoleItemManager:SetMoneyByMoneyType(moneyType, count)
	self.m_MapMoney[moneyType] = count
    if gGetRoleItemManager() then
	    gGetRoleItemManager().m_EventTypeMoneyChange:call(moneyType)
    end
end

function RoleItemManager:GetMoneyByMoneyType(moneyType)
	if self.m_MapMoney[moneyType] then
		return self.m_MapMoney[moneyType]
	end
	return 0
end

function RoleItemManager:CheckMoneyOverLimit()
	if not gGetDataManager() then
		return 0
    end

	local level = gGetDataManager():GetMainCharacterLevel()
	local moneyConfig = BeanConfigManager.getInstance():GetTableByName("role.cresmoneyconfig"):getRecorder(level)
    if moneyConfig then
        return moneyConfig.resmoney
    end

	return 0
end

function RoleItemManager:SetGold(gold)
	self.m_iGold = math.floor(gold)
	gGetRoleItemManager().m_EventPackGoldChange:Bingo()
end

function RoleItemManager:GetGold()
	return self.m_iGold
end

function RoleItemManager:AddBagItem(bagid, baginfo)
    for first, second in pairs(baginfo.currency) do
		if first == fire.pb.game.MoneyType.MoneyType_SilverCoin then
			if bagid == fire.pb.item.BagTypes.BAG then
				self:SetPackMoney(second)
			elseif bagid == fire.pb.item.BagTypes.DEPOT then
				self:SetDeportMoney(second)
			end
		elseif first == fire.pb.game.MoneyType.MoneyType_GoldCoin then
			self:SetGold(second)
		else
			self:SetMoneyByMoneyType(first, second)
		end
	end
	
	self.m_BagCapacity[bagid] = baginfo.capacity

    for _, data in pairs(baginfo.items) do
		self:AddItem(bagid, data)
	end

	-- ycl ���������󣬴ӷ�����ˢ�±����������п��ʹ�ô��ڼ���Ƿ�Ӧ�ùر�
	if bagid == fire.pb.item.BagTypes.BAG then
		require("logic.reminduseitemdlg").CheckCloseAllDialogs()
	end

	return true
end

function RoleItemManager:SetItemTreasure(item)
    local itemType = item:GetFirstType()
    if itemType == eItemType_PETITEM then
		local petitem = BeanConfigManager.getInstance():GetTableByName("item.cpetitemeffect"):getRecorder(item:GetObjectID())
		if petitem and petitem.treasure == 1 then
			item:setTreasure(true)
		end
	elseif itemType == eItemType_FOOD then
		local food = BeanConfigManager.getInstance():GetTableByName("item.cfoodanddrugeffect"):getRecorder(item:GetObjectID())
		if food and food.treasure == 1 then
			item:setTreasure(true)
		end
	elseif itemType == eItemType_DRUG then

	elseif itemType == eItemType_DIMARM then

	elseif itemType == eItemType_GEM then -- ��ʯ
		local gem = BeanConfigManager.getInstance():GetTableByName("item.cgemeffect"):getRecorder(item:GetObjectID())
		if gem and gem.treasure == 1 then
			item:setTreasure(true)
		end
	elseif itemType == eItemType_GROCERY then
		local grocery = BeanConfigManager.getInstance():GetTableByName("item.cgroceryeffect"):getRecorder(item:GetObjectID())
		if grocery and grocery.treasure == 1 then
			item:setTreasure(true)
		end
	elseif itemType == eItemType_EQUIP_RELATIVE then

	elseif itemType == eItemType_EQUIP then -- װ��
		local pObject = item:GetObject()
		local equipConfig = BeanConfigManager.getInstance():GetTableByName("item.cequipitemattr"):getRecorder(item:GetObjectID())
		if equipConfig and equipConfig.treasureScore < pObject.equipscore then
			item:setTreasure(true)
		end
	elseif itemType == eItemType_TASKITEM then -- ������Ʒ
		local taskObject = BeanConfigManager.getInstance():GetTableByName("item.ctaskrelative"):getRecorder(item:GetObjectID())
		if taskObject and taskObject.treasure == 1 then
			item:setTreasure(true)
		end
	end
end

function RoleItemManager:AddItem(bagid, data)
	local item = RoleItem:new()

	if item:SetItemData(bagid, data) then
		self:SetItemTreasure(item)

        if not self.m_BagInfo[bagid] then
            self.m_BagInfo[bagid] = {}
        end
        self.m_BagInfo[bagid][data.key] = item

		local nParam1 = bagid
		local nParam2 = item:GetThisID()
		local nParam3 = 0
		local nParam4 = 0
		local nResult = isNeedRequestItemData(nParam1, nParam2, nParam3, nParam4)
		if nResult == 1 then
	        require "protodef.fire.pb.item.cgetitemtips"
	        local itemTipOne = CGetItemTips.Create()
	        itemTipOne.packid = bagid
	        itemTipOne.keyinpack = item:GetThisID()
	        LuaProtocolManager.getInstance():send(itemTipOne)
		end
		
		-- ������ߵ�����Ϊ166��ֱ�Ӹ���lua
		if item:GetItemTypeID() == 166 then
			LoginRewardManager.SetLevelUpItemID(data.id)
			-- ��ȡ��ֱ�ӹر�
			LevelUpRewardDlg.DestroyDialog()
		end
        if item:GetItemTypeID() == 278 then  -- �⻷
            local guideId = GetNumberValueForStrKey("NEW_GUIDE_ZHENFA")
            if not NewRoleGuideManager.getInstance():isGuideFinish(guideId) then
                NewRoleGuideManager.getInstance():AddToWaitingList(guideId)
            end
        end

		if item:GetItemTypeID() == ZHENFA_BOOK and (not gGetGameApplication():isReconnecting()) then
			if bagid == fire.pb.item.BagTypes.BAG then
				YangChengListDlg.notifyZhenFaAdd(data.id)
			end
		end

		-- ����������������Ʒ,��Ҫ�������������������Ӿ���
		if bagid == fire.pb.item.BagTypes.BAG or bagid == fire.pb.item.BagTypes.QUEST then
			if bagid == fire.pb.item.BagTypes.BAG then
				gGetRoleItemManager().m_EventAddPackItem:call(data.key)

				if data.id == Treasure_Map or data.id == Advanced_Treasure_Map then
	                require "protodef.fire.pb.item.cgetitemtips"
	                local itemTip = CGetItemTips.Create()
	                itemTip.packid = fire.pb.item.BagTypes.BAG
	                itemTip.keyinpack = item:GetThisID()
	                LuaProtocolManager.getInstance():send(itemTip)
				end

				-- ������Ʒʱ�������ʱ�������ָ�����Ʒ�ĸ��ӣ�������tips
				if item and item:isAntique() and (not item:isWordPuzzleAntique()) then
	                require "protodef.fire.pb.item.cgetitemtips"
	                local itemTip = CGetItemTips.Create()
	                itemTip.packid = fire.pb.item.BagTypes.BAG
	                itemTip.keyinpack = item:GetThisID()
	                LuaProtocolManager.getInstance():send(itemTip)
				end
			else -- �������ֻ�ڸ�������ս���������о���
				
				gGetRoleItemManager().m_EventAddQuestItem:call(data.key)
			end

			gGetRoleItemManager():FireItemNumChange(ItemIDParameter(data.key, data.id, bagid))

			-- ������������additem�������Ч��
            if data.isnew then
				local bAddFloodLigh = true

                -- 30�����ϣ�ֻ���¼ӵ�װ����ʾ����Ч��
				if gGetDataManager():GetMainCharacterLevel() > 30 and item:GetFirstType() ~= eItemType_EQUIP then
					bAddFloodLigh = false;
				end

				if bAddFloodLigh then
					local pCell = self:GetItemCellByItem(item)
					if pCell then
						gGetGameUIManager():AddUIEffect(pCell, MHSD_UTILS.get_effectpath(10256), true, 0, 0, true)
						pCell:SetFloodLight(true)
					end
				end
			end
		end
		
		-- װ�����ľ�����
		if bagid == fire.pb.item.BagTypes.EQUIP then
			gGetRoleItemManager().m_EventAddEquipItem:call(data.key)
		end
		
	else -- ��������ʧ��
		item = nil
	end
end

-- ͨ��ThisID��ȡItem
function RoleItemManager:getItem(thisID, packid)
    return self:FindItemByBagAndThisID(thisID, packid);
end

function RoleItemManager:GetItemNumByBaseIDWithNoBind(itembaseID, bagid)
    if not bagid then
        bagid = fire.pb.item.BagTypes.BAG
    end

	local num = 0
	
	if self.m_BagInfo[bagid] then
        for first, second in pairs(self.m_BagInfo[bagid]) do
			local pItem = second
			if pItem and pItem:GetObjectID() == itembaseID and not pItem:isBind() then
				num = num + pItem:GetNum()
            end
		end
	end

	return num
end

function RoleItemManager:GetItemNumByBaseID(itembaseID, bagid)
    -- Ĭ��ֵ
    if not bagid then
        bagid = fire.pb.item.BagTypes.BAG
    end

	local num = 0
	
	if self.m_BagInfo[bagid] then
        for first, second in pairs(self.m_BagInfo[bagid]) do
			local pItem = second
			if pItem and pItem:GetObjectID() == itembaseID then
				num = num + pItem:GetNum()
            end
		end
	end

	return num;
end
function RoleItemManager:GetItemNumByBaseIDNotBind(itembaseID, bagid)
    -- Ĭ��ֵ
    if not bagid then
        bagid = fire.pb.item.BagTypes.BAG
    end

	local num = 0
	
	if self.m_BagInfo[bagid] then
        for first, second in pairs(self.m_BagInfo[bagid]) do
			local pItem = second
			if pItem and pItem:GetObjectID() == itembaseID and not pItem:isBind() then
				num = num + pItem:GetNum()
            end
		end
	end

	return num;
end
function RoleItemManager:GetItemTotalNumByBaseID(itembaseID, bagid)
    -- Ĭ��ֵ
    if not bagid then
        bagid = fire.pb.item.BagTypes.BAG
    end

	return self:GetItemNumByBaseID(itembaseID, bagid)
end

function RoleItemManager:GetAllItemKeyByBaseID(baseid, bagid)
    -- Ĭ��ֵ
    if not bagid then
        bagid = fire.pb.item.BagTypes.BAG
    end

    local itemkeys = {}

    if self.m_BagInfo[bagid] then
        for first, second in pairs(self.m_BagInfo[bagid]) do
            local pItem = second
            if pItem and pItem:GetObjectID() == baseid then
                itemkey = pItem:GetThisID()
                table.insert(itemkeys, itemkey)
            end
        end
    end

    return itemkeys
end

function RoleItemManager:GetItemKeyByBaseID(baseid, bBindPrior, bagid)
    -- Ĭ��ֵ
    if (not bBindPrior) and (not bagid) then
        bBindPrior = true
        bagid = fire.pb.item.BagTypes.BAG
    end

	local itemkey = 0

	if self.m_BagInfo[bagid] then
        for first, second in pairs(self.m_BagInfo[bagid]) do
			local pItem = second
			if pItem and pItem:GetObjectID() == baseid then
			    itemkey = pItem:GetThisID()

			    -- ����������ѡ������Ʒ
			    if not bBindPrior then
				    return itemkey
                end

			    if pItem:isBind() then
				    return itemkey
                end
            end
		end
	end

	return itemkey
end

function RoleItemManager:GetItemByBaseID(baseid, bBindPrior, bagid)
    -- Ĭ��ֵ
    if (not bBindPrior) and (not bagid) then
        bBindPrior = true
        bagid = fire.pb.item.BagTypes.BAG
    end

    local pItemFind = nil

	if self.m_BagInfo[bagid] then
        for first, second in pairs(self.m_BagInfo[bagid]) do
			local pItem = second

			if pItem and pItem:GetObjectID() == baseid then
                pItemFind = pItem

			    -- ����������ѡ������Ʒ
			    if not bBindPrior then
				    return pItemFind
                end

			    if pItem:isBind() then
				    return pItemFind
                end
            end
		end
	end

	return pItemFind
end

-- �õ�ĳ�����͵ĵ�������
function RoleItemManager:GetItemTotalNumByTypeID(itemtypeID, bagid)
    -- Ĭ��ֵ
    if not bagid then
        bagid = fire.pb.item.BagTypes.BAG
    end

	local num = 0

	if self.m_BagInfo[bagid] then
        for first, second in pairs(self.m_BagInfo[bagid]) do
			local pItem = second
			if pItem and pItem:GetItemTypeID() == itemtypeID then
				num = num + pItem:GetNum()
            end
		end
	end

	return num
end


-- �õ�ĳ����������Ʒ(baseID)���������и�bind������ʾ�ǲ��ǰ󶨵�
function RoleItemManager:GetNotLockItemTotalNumByBaseID(itembaseID, bind)
    if not bind then
        bind = false
    end
	local num = 0

	if self.m_BagInfo[fire.pb.item.BagTypes.BAG] then
        for first, second in pairs(self.m_BagInfo[fire.pb.item.BagTypes.BAG]) do
			local pItem = second
			if pItem and pItem:GetObjectID() == itembaseID and not pItem:isLock() and pItem:isBind() == bind then
				num = num + pItem:GetNum()
            end
		end
	end

	return num
end

-- �жϰ������Ƿ�����
function RoleItemManager:IsBagFull(bagid)
    -- Ĭ��ֵ
    if not bagid then
        bagid = fire.pb.item.BagTypes.BAG
    end

	if self.m_BagInfo[bagid] then
		local bagcapacity = self:GetBagCapacity(bagid)
		return bagcapacity == TableUtil.tablelength(self.m_BagInfo[bagid])
	elseif bagid == fire.pb.item.BagTypes.BAG then
		return false
	end
	return true
end

-- �жϰ����Ƿ���cellnum���ո�
function RoleItemManager:IsBagHaveEnoughCell(cellnum, bagid)
    -- Ĭ��ֵ
    if not bagid then
        bagid = fire.pb.item.BagTypes.BAG
    end

	if self.m_BagInfo[bagid] then
		local bagcapacity = self:GetBagCapacity(bagid)
		return bagcapacity >= TableUtil.tablelength(self.m_BagInfo[bagid]) + cellnum
	end
	return false
end

-- ��ʱ�������Ƿ�Ϊ��
function RoleItemManager:IsTemporyPackEmpty()
	if not self.m_BagInfo[fire.pb.item.BagTypes.TEMP] then
		return true
    end

	if TableUtil.tablelength(self.m_BagInfo[fire.pb.item.BagTypes.TEMP]) == 0 then
		return true
    end

	return false
end

function RoleItemManager:GetItemKeyListByType(itemvec, typeid, bagid)
    -- Ĭ��ֵ
    if not bagid then
        bagid = fire.pb.item.BagTypes.BAG
    end

	local typemask = 15
	for i = 0, 7 do
		if typemask < typeid then
			typemask = bit.blshift(typemask + 1, 4) - 1
		end
	end

    if not itemvec._size then
        itemvec = {}
        itemvec._size = 0
	    function itemvec:size()
		    return self._size
	    end
    end

	if self.m_BagInfo[bagid] then
		for first, second in pairs(self.m_BagInfo[bagid]) do
			local pItorItem = second
			if pItorItem then
			    if bit.band(pItorItem:GetItemTypeID(), typemask) == typeid then
                    itemvec[itemvec._size] = pItorItem:GetThisID()
                    itemvec._size = itemvec._size + 1
                    --table.insert(itemvec, pItorItem:GetThisID())
                end
            end
		end
	end

    return itemvec
end


function RoleItemManager:GetItemKeyListByType1(itemvec, typeid, bagid)
    if not bagid then
        bagid = fire.pb.item.BagTypes.BAG
    end

	local typemask = 15
	for i = 0, 7 do
		if typemask < typeid then
			typemask = bit.blshift(typemask + 1, 4) - 1
		end
	end
    if not itemvec._size then
        itemvec = {}
        itemvec._size = 0
	    function itemvec:size()
		    return self._size
	    end
	end
	if self.m_BagInfo[bagid] then
		itemvec.data = {}
		for first, second in pairs(self.m_BagInfo[bagid]) do
			local pItorItem = second
			if pItorItem then
			    if bit.band(pItorItem:GetItemTypeID(), typemask) == typeid then
                    itemvec[itemvec._size] = pItorItem:GetThisID()
					itemvec._size = itemvec._size + 1
					print("637******************",pItorItem:GetThisID())
					table.insert(itemvec.data, pItorItem:GetThisID())
                end
            end
		end
	end

    return itemvec
end

----------用于读取坐骑进阶ID所用
function RoleItemManager:GetItemKeyListByType2(itemvec, typeid, bagid)
    if not bagid then
        bagid = fire.pb.item.BagTypes.BAG
    end
    typeid = 680
    local typemask = 15
    for i = 0, 7 do
        if typemask < typeid then
            typemask = bit.blshift(typemask + 1, 4) - 1
        end
    end
    if not itemvec._size then
        itemvec = {}
        itemvec._size = 0
        function itemvec:size()
            return self._size
        end
    end
    if self.m_BagInfo[bagid] then
        itemvec.data = {}
        for first, second in pairs(self.m_BagInfo[bagid]) do
            local pItorItem = second
            if pItorItem then
                if bit.band(pItorItem:GetItemTypeID(), typemask) == typeid then
                    itemvec[itemvec._size] = pItorItem:GetThisID()
                    itemvec._size = itemvec._size + 1
                    print("637******************",pItorItem:GetThisID())
                    table.insert(itemvec.data, pItorItem:GetThisID())
                end
            end
        end
    end

    return itemvec
end

----------用于读取坐骑进阶ID所用
function RoleItemManager:GetItemKeyListByType3(itemvec, typeid, bagid)
    if not bagid then
        bagid = fire.pb.item.BagTypes.BAG
    end
    typeid = 376
    local typemask = 15
    for i = 0, 7 do
        if typemask < typeid then
            typemask = bit.blshift(typemask + 1, 4) - 1
        end
    end
    if not itemvec._size then
        itemvec = {}
        itemvec._size = 0
        function itemvec:size()
            return self._size
        end
    end
    if self.m_BagInfo[bagid] then
        itemvec.data = {}
        for first, second in pairs(self.m_BagInfo[bagid]) do
            local pItorItem = second
            if pItorItem then
                if bit.band(pItorItem:GetItemTypeID(), typemask) == typeid then
                    itemvec[itemvec._size] = pItorItem:GetThisID()
                    itemvec._size = itemvec._size + 1
                    print("637******************",pItorItem:GetThisID())
                    table.insert(itemvec.data, pItorItem:GetThisID())
                end
            end
        end
    end

    return itemvec
end

-- ������ƷbaseID�Ͱ���ID��ý�ɫ��ӵ������������Ʒ�б�
function RoleItemManager:GetItemListByType(typeid, bagid)
    -- Ĭ��ֵ
    if not bagid then
        bagid = fire.pb.item.BagTypes.BAG
    end

	local itemvec = {}
    itemvec._size = 0
	function itemvec:size()
		return self._size
	end

	if self.m_BagInfo[bagid] then
		for first, second in pairs(self.m_BagInfo[bagid]) do
			local pItorItem = second
			if pItorItem then
			    if pItorItem:GetItemTypeID() == typeid then
                    itemvec[itemvec._size] = pItorItem
                    itemvec._size = itemvec._size + 1
                    --table.insert(itemvec, pItorItem)
                end
            end
		end
	end

    return itemvec
end

-- ������ƷbaseID�Ͱ���ID��ý�ɫ��ӵ������������Ʒ�б���δ������
function RoleItemManager:GetItemListNoLockByType(typeid, bagid)
    -- Ĭ��ֵ
    if not bagid then
        bagid = fire.pb.item.BagTypes.BAG
    end

	local itemvec = {}
    itemvec._size = 0
	function itemvec:size()
		return self._size
	end

	if self.m_BagInfo[bagid] then
		for first, second in pairs(self.m_BagInfo[bagid]) do
			local pItorItem = second
			if pItorItem then
			    if pItorItem:GetItemTypeID() == typeid and (not pItorItem:isLock()) then
                    itemvec[itemvec._size] = pItorItem
                    itemvec._size = itemvec._size + 1
                    --table.insert(itemvec, pItorItem)
                end
            end
		end
	end

    return itemvec
end

-- �õ�������û�������tips��װ��
function RoleItemManager:GetNotRequestTipsEquips(itemvec)
	local itemvec = {}
    itemvec._size = 0
	function itemvec:size()
		return self._size
	end

	if self.m_BagInfo[fire.pb.item.BagTypes.BAG] then
		for first, second in pairs(self.m_BagInfo[fire.pb.item.BagTypes.BAG]) do
			local pItem = second
			if pItem then
			    if pItem:GetFirstType() == eItemType_EQUIP then
				    if pItem:GetObject().bNeedRequireData then
                        itemvec[itemvec._size] = pItem:GetThisID()
                        itemvec._size = itemvec._size + 1
                        --table.insert(itemvec, pItem:GetThisID())
					end
                end
            end
		end
	end

    return itemvec
end

-- ��ð��������е���Ʒ
function RoleItemManager:GetItemListByBag(bagid)
    -- Ĭ��ֵ
    if not bagid then
        bagid = fire.pb.item.BagTypes.BAG
    end

	local itemvec = {}
    itemvec._size = 0
	function itemvec:size()
		return self._size
	end

	if self.m_BagInfo[bagid] then
		for first, second in pairs(self.m_BagInfo[bagid]) do
			if second then
                itemvec[itemvec._size] = second
                itemvec._size = itemvec._size + 1
                --table.insert(itemvec, second)
			end
		end
	end

    return itemvec
end

function RoleItemManager:GetItemKeyListByBag(bagid)
    -- Ĭ��ֵ
    if not bagid then
        bagid = fire.pb.item.BagTypes.BAG
    end

	local itemvec = {}
    itemvec._size = 0
	function itemvec:size()
		return self._size
	end

	if self.m_BagInfo[bagid] then
		for first, second in pairs(self.m_BagInfo[bagid]) do
			if second then
                itemvec[itemvec._size] = first
                itemvec._size = itemvec._size + 1
                --table.insert(itemvec, first)
			end
		end
	end

    return itemvec
end

function RoleItemManager:SetBagCapacity(bagid, capacity)
	if self.m_BagCapacity[bagid] ~= capacity then
		self.m_BagCapacity[bagid] = capacity
		if bagid == fire.pb.item.BagTypes.BAG then
			require "logic.item.mainpackdlg"
			if CMainPackDlg:getInstanceOrNot() then
				CMainPackDlg:getInstanceOrNot():ExpendPackCapacity()
			end
		elseif bagid == fire.pb.item.BagTypes.DEPOT then
			GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(162143).msg);
		end
	end
end

-- �õ���������
function RoleItemManager:GetBagCapacity(bagid)
	if not self.m_BagCapacity[bagid] then
		return 0
    end

	return self.m_BagCapacity[bagid]
end

function RoleItemManager:GetBagShowNum(bagid)
	if bagid == fire.pb.item.BagTypes.BAG then
		local bagCap = self:GetBagCapacity(fire.pb.item.BagTypes.BAG)
		local bagNum = bagCap + 10;

		local maxBagNum = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(142).value);

		local vipLevel = gGetDataManager():GetVipLevel()
		local record = BeanConfigManager.getInstance():GetTableByName("fushi.cvipinfo"):getRecorder(vipLevel)
		maxBagNum = maxBagNum + record.bagextracount
		
		if bagNum > maxBagNum then
			bagNum = maxBagNum
		end
		return bagNum		
	else
		return 25
	end
end

function RoleItemManager:GetBagEmptyNum(bagid)
	local capacity = self:GetBagCapacity(bagid)
	if self.m_BagInfo[bagid] then
		return capacity - TableUtil.tablelength(self.m_BagInfo[bagid])
	end
	return capacity
end

function RoleItemManager:GetBagIsEmpty(bagid)
	if self.m_BagInfo[bagid] then
        return TableUtil.tablelength(self.m_BagInfo[bagid]) == 0
    end
	return true
end

function RoleItemManager:GetFirstEmptyCellIndex(bagid)
	local nSize = self:GetBagCapacity(bagid)
	local findpos = -1

	local tempMap = {}
	for npos = 0, nSize -1 do
		local baginfo = self:GetBagInfo()

		tempMap[npos] = 0
        for first, second in pairs(baginfo[bagid]) do
			local loc = second:GetLocation()
			local pos = loc.position

			if npos == pos then
				tempMap[pos] = 1
				break
			end
		end
	end

    for first, second in pairs(tempMap) do
		if second == 0 then
			return first
		end
	end

	return -1
end

function RoleItemManager:InitTabCellLockState(pTable, totalNum, locknum)
	for index = 0, totalNum -1 do
		pTable:GetCell(index):SetLockState(false)
	end

	if locknum == 0 then
		return
    end

	for index = 0, locknum -1 do
		pTable:GetCell((totalNum - 1) - index):SetLockState(true)
	end
end

-- ͨ������ID��pos�ҵ���Ʒ
function RoleItemManager:FindItemByBagIDAndPos(bagid, pos)
    local baginfo = self:GetBagInfo()

	if not baginfo[bagid] then -- û���ҵ���Ӧ�İ���
		return nil
	end

    for first, second in pairs(baginfo[bagid]) do
		local pItem = second
		if pItem then
		    if pItem:GetLocation().position == pos then
			    return pItem
		    end
        end
	end

	return nil
end

function RoleItemManager:GetBagInfo()
	return self.m_BagInfo
end

function RoleItemManager:FindItemByBagAndThisID(thisid, bagid)
    -- Ĭ��ֵ
    if not bagid then
        bagid = fire.pb.item.BagTypes.BAG
    end

    local baginfo = self:GetBagInfo()

	if not baginfo[bagid] then -- û���ҵ���Ӧ�İ���
		return nil
	end

	local list = baginfo[bagid]
	if list[thisid] then
		return list[thisid]
	end

	return nil
end

-- ���������
function RoleItemManager:ClearBag(bagid)
    local baginfo = self:GetBagInfo()

	if not baginfo[bagid] then -- û���ҵ���Ӧ�İ���
		return
	end

    for first, second in pairs(baginfo[bagid]) do
		local pItem = second
		if pItem then
		    pItem:OnRemove()
		    pItem = nil
        end
	end

    baginfo[bagid] = {}
end

-- ��հ�������Ʒ��ѡ��״̬
function RoleItemManager:ClearBagItemSelectState()
    local baginfo = self:GetBagInfo()

	if not baginfo[fire.pb.item.BagTypes.BAG] then -- û���ҵ���Ӧ�İ���
		return
	end

    for first, second in pairs(baginfo[fire.pb.item.BagTypes.BAG]) do
		local pItem = second
		if pItem and pItem:IsSelected() then
			pItem:SetSelected(false)
			break
		end
	end
end

-- ����ɾ����Ʒ
function RoleItemManager:RemoveItemList(bagid, list)
    local baginfo = self:GetBagInfo()
	local itemList = baginfo[bagid]

	if itemList then -- �ҵ���Ӧ�İ���
        for _, thisid in pairs(list) do
		    local pItem = itemList[thisid] -- ����thisid�ҵ���ɾ���ĵ���
		    if pItem then
			    local itembaseid = pItem:GetObjectID()
			    pItem:OnRemove()
			    itemList[thisid] = nil
		    end
	    end
	end

	gGetRoleItemManager().m_EventRemoveItemList:Bingo()
end

-- ɾ��ĳ����Ʒ
function RoleItemManager:RemoveItem(bagid, thisid)
    local baginfo = self:GetBagInfo()
	local list = baginfo[bagid]

	if not list then -- û���ҵ���Ӧ�İ���
		return false
	end

	local pItem = list[thisid] -- ����thisid�ҵ���ɾ���ĵ���
	if pItem then
		if bagid == fire.pb.item.BagTypes.BAG then
			gGetRoleItemManager().m_EventDelBagItem:call(thisid)
		elseif bagid == fire.pb.item.BagTypes.QUEST then
			gGetRoleItemManager().m_EventDelQuestItem:call(thisid)
		elseif bagid == fire.pb.item.BagTypes.EQUIP then
			gGetRoleItemManager().m_EventDelEquipItem:call(thisid)
		end

		local itemBaseID = pItem:GetObjectID()
        local itemType = pItem:GetItemTypeID()
		pItem:OnRemove()
		list[thisid] = nil

		if bagid == fire.pb.item.BagTypes.EQUIP then
			self:CheckEquipEffect();
		end

		if itemBaseID == 334009 then -- ��������������Ϣ������type
			LevelUpRewardDlg.DestroyDialog()
		end

		-- ɾ����Ʒ�¼�
		local IDParameter = ItemIDParameter(thisid, itemBaseID, bagid)
		if bagid == fire.pb.item.BagTypes.BAG then
			gGetRoleItemManager():FireItemNumChange(IDParameter)
			require("logic.reminduseitemdlg").CheckCloseDialog(itemBaseID)
		elseif bagid == fire.pb.item.BagTypes.QUEST then
			gGetRoleItemManager():FireItemNumChange(IDParameter)
		elseif bagid == fire.pb.item.BagTypes.EQUIP then
		end

		if itemType == ZHENFA_BOOK and bagid == fire.pb.item.BagTypes.BAG then
		    YangChengListDlg.dealwithZhenfaUse()
		end

		return true
	end

	return false
end

function RoleItemManager:GetItemCellByLoc(loc)
	if loc.tableType == fire.pb.item.BagTypes.BAG               -- ����
	    or loc.tableType == fire.pb.item.BagTypes.QUEST then    -- ���������
		return MainPackDlg_GetItemCellByPos(loc.position, loc.tableType)
	elseif loc.tableType == fire.pb.item.BagTypes.EQUIP then    -- װ��
		return MainPackDlg_GetEquipItemCellByPos(loc.position)
	elseif loc.tableType == fire.pb.item.BagTypes.TEMP then     -- ��ʱ����
		if 1 == CTemporaryPack_GetSingleton() then
            return CTemporaryPack_GetItemCellByPos(loc.position)
		end
	end

	return nil
end

function RoleItemManager:GetItemCellByItem(pItem)
	return self:GetItemCellByLoc(pItem:GetLocation())
end

function RoleItemManager:GetItemCellAtBag(baseID)
	local bagItems = self.m_BagInfo[fire.pb.item.BagTypes.BAG] -- Ѱ�Ҷ�Ӧ�������͵���Ʒ

	if not bagItems then
		return nil
	end

    for first, second in pairs(bagItems) do
		local roleItem = second
		if roleItem and roleItem:GetBaseObject().id == baseID then
			return self:GetItemCellByItem(roleItem)
		end
	end

	return nil
end

function RoleItemManager:GetItemCellAtQuestBag(baseID)
	local bagItems = self.m_BagInfo[fire.pb.item.BagTypes.QUEST] -- Ѱ�Ҷ�Ӧ�������͵���Ʒ

	if not bagItems then
		return nil
	end

    for first, second in pairs(bagItems) do
		local roleItem = second
		if roleItem and roleItem:GetBaseObject().id == baseID then
			return self:GetItemCellByItem(roleItem)
		end
	end

	return nil
end

function RoleItemManager:InitBagItem(bagid)
	local bagItems = self.m_BagInfo[bagid] -- Ѱ�Ҷ�Ӧ�������͵���Ʒ

	if not bagItems then
		return
	end

    for first, second in pairs(bagItems) do
		local roleItem = second
		if roleItem then
			roleItem:OnUpdate(roleItem:GetLocation(), -1)
        end
	end
end

function RoleItemManager:DestroyItem(bDestroy, item)
	print(debug.traceback())
	local pItem = item
	if not pItem then
		return false
	end

    -- Ĭ��ֵ
    if bDestroy == nil then
        bDestroy = true
    end

	pItem:SetAshy(false)

	if not bDestroy then
		return true
    end

	if not pItem:GetBaseObject().bManuleDesrtrol then
		-- ����Ʒ���ܴݻ�
		GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(141127).msg)
		return true
	end
	if pItem:isLock() then
		GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(141078).msg)
		return true
	end

	-- �ݻٵ����������
	if pItem:GetLocation().tableType == fire.pb.item.BagTypes.QUEST then
		self:DestroyTaskItem(pItem)
		return true
	end

	-- �ݻ�װ��
	if pItem:GetFirstType() == eItemType_EQUIP
        and pItem:GetSecondType() <= eEquipType_BOOT
        and (pItem:GetLocation().tableType == fire.pb.item.BagTypes.BAG or pItem:GetLocation().tableType == fire.pb.item.BagTypes.TEMP) then

		-- ��ȷ����[colour='ffffff00']"+ pItem->GetName() + L"[colour='ffffffff']������
		local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(142355)
        local sb = StringBuilder.new()
		sb:Set("parameter1", pItem:GetName())
		local id = bit.blshift_64(pItem:GetThisID(), 32)

		gGetMessageManager():AddConfirmBox(
            eConfirmDropItem,
            sb:GetString(tip.msg),
            RoleItemManager.HandleMessageBoxDestroyItem, self,
            MessageManager.HandleDefaultCancelEvent, MessageManager,
			id + pItem:GetLocation().tableType)
		
        sb:delete()
        return true
	end

	if pItem:GetLocation().tableType == fire.pb.item.BagTypes.BAG or pItem:GetLocation().tableType == fire.pb.item.BagTypes.TEMP then
		-- ��ȷ����[colour='ffffff00']"+ pItem->GetName() + L"[colour='ffffffff']������
		local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(140402)
		if pItem:GetFirstType()== eItemType_PETEQUIPITEM then
			tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(192823)
		end
        local sb = StringBuilder.new()
		sb:Set("parameter1", pItem:GetName())
        local nItemKey = pItem:GetThisID()
		local id = bit.blshift_64(nItemKey, 32)

		gGetMessageManager():AddConfirmBox(
            eConfirmDropItem,
            sb:GetString(tip.msg),
			RoleItemManager.HandleMessageBoxDestroyItem, self,
			MessageManager.HandleDefaultCancelEvent, MessageManager,
            id + pItem:GetLocation().tableType)

        sb:delete()
		return true
	end

	if pItem:GetLocation().tableType == fire.pb.item.BagTypes.EQUIP then
		-- װ�����ĵ����޷�ֱ�Ӵݻ٣����ȷŻذ�����
		GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(142375).msg)
		return true
	end

	if pItem:GetLocation().tableType == fire.pb.item.BagTypes.DEPOT then
		GetCTipsManager():AddMessageTip(MHSD_UTILS.get_resstring(1182))
		return true
	end

	return false
end

function RoleItemManager:HandleMessageBoxDestroyItem(e)
	local windowargs = CEGUI.toWindowEventArgs(e)
    local pConfirmBoxInfo = tostConfirmBoxInfo(windowargs.window:getUserData());
	if pConfirmBoxInfo then
        local nAllNum = pConfirmBoxInfo.userID
        local nBagId = bit.band(nAllNum,0xFFFFFFFF)
		local nItemKey = bit.brshift(nAllNum, 32)
        --local nItemKeyNum = bit.blshift2(nItemKey, 32)
        --local nBagId = nAllNum - nItemKeyNum
		local pItem = self:FindItemByBagAndThisID(nItemKey, nBagId)
		if not pItem then
			pItem = self:FindItemByBagAndThisID(nItemKey, fire.pb.item.BagTypes.QUEST)
		end

		if pItem then
		    require "protodef.fire.pb.item.cdropitem"
		    local dropItem = CDropItem.Create()
			dropItem.packid = pItem:GetLocation().tableType
			dropItem.keyinpack = pItem:GetThisID()
			dropItem.npcid = 0
			LuaProtocolManager.getInstance():send(dropItem)
		end

		gGetMessageManager():RemoveConfirmBox(pConfirmBoxInfo)

		return true
	end

	return true
end

function RoleItemManager:DestroyTaskItem(pItem)
	-- 142291 $parameter1$��������Ʒ���ݻٺ�����޷�����������������ݻ١�
	local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(142291)
    local sb = StringBuilder.new()
	sb:Set("parameter1", pItem:GetName())
	gGetMessageManager():AddConfirmBox(
        eConfirmDropItem,
        sb:GetString(tip.msg),
		RoleItemManager.HandleMessageBoxDestroyTaskItem, self,
		MessageManager.HandleDefaultCancelEvent, MessageManager,
        pItem:GetThisID())

    sb:delete()
end

function RoleItemManager:HandleMessageBoxDestroyTaskItem(e)
	local windowargs = CEGUI.toWindowEventArgs(e)

	local pConfirmBoxInfo = windowargs.window:getUserData()
	if pConfirmBoxInfo then
		local itemid = pConfirmBoxInfo.userID
		gGetMessageManager():RemoveConfirmBox(pConfirmBoxInfo)

		local pItem = self:FindItemByBagAndThisID(itemid, fire.pb.item.BagTypes.QUEST)
		if not pItem then
			-- �õ����Ѿ��������ˣ�
			GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(140869).msg)
		else
			-- 142292 ��ȷ��Ҫ�ݻ�$parameter1$��
			local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(142292)
            local sb = StringBuilder.new()
			sb:Set("parameter1", pItem:GetName())
			local id = bit.bit_lshift2(pItem:GetThisID(), 32)

			gGetMessageManager():AddConfirmBox(
                eConfirmDropItem,
                sb:GetString(tip.msg),
				RoleItemManager.HandleMessageBoxDestroyItem, self,
				MessageManager.HandleDefaultCancelEvent, MessageManager,
                id + pItem:GetLocation().tableType)
            sb:delete()
		end
	end

	return true
end

function RoleItemManager:EquipItem(pItem, bRightClick)
    -- Ĭ��ֵ
    if not bRightClick then
        bRightClick = true
    end

	local pObject = pItem:GetObject()

	-- �ж��Ա��Ƿ���������
	if gGetDataManager():GetMainCharacterData().sex ~= pObject.sexNeed and pObject.sexNeed ~= 0 then
		if not bRightClick then
			pItem:SetAshy(false)
		end
		-- �Ա𲻷�������ʹ��װ��
		GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(100066).msg)
	elseif not pItem:IsEquipRoleNeed() then
		-- ��ɫ����������ʹ��װ��
		GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(100068).msg)
	elseif bit.band(pObject.data.flags, fire.pb.Item.TIMEOUT) ~= 0 and pObject.data.loseeffecttime == -1 then
        -- ʱЧ�Ե��ߵ��ڲ��ܴ���
		GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(143934).msg)
	else
		local thisId = pItem:GetThisID()
		local dstPos = pItem:GetSecondType()

		require "protodef.fire.pb.item.cputonequip"
		local equipement = CPutOnEquip.Create()
        equipement.packkey = thisId
        equipement.dstpos = dstPos
		LuaProtocolManager.getInstance():send(equipement)
	end

	return true
end

function RoleItemManager:UnEquipItem(thisId, dstpos)
	if GetBattleManager():IsInBattle() then
		GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(131451))
	else
		require "protodef.fire.pb.item.ctakeoffequip"
		local equipement = CTakeOffEquip.Create()
        equipement.equipkey = thisId
        equipement.posinpack = dstpos
		LuaProtocolManager.getInstance():send(equipement)
	end
	return true
end

-- ȷ��ʹ������ҩ
function RoleItemManager:HandleConfirmUseItem(e)
	local windowargs = CEGUI.toWindowEventArgs(e)

	local pConfirmBoxInfo = windowargs.window:getUserData()
	if pConfirmBoxInfo then
		local itemkey = pConfirmBoxInfo.userID
		local pItem = self:FindItemByBagAndThisID(itemkey)
		if pItem then
			self:UseItem(pItem)
	    end
		gGetMessageManager():RemoveConfirmBox(pConfirmBoxInfo)
	end
	return true
end

function RoleItemManager:setShowMoneyFlyEffect(b)
	self.m_bShowMoneyFlyEffect = b
end

function RoleItemManager:isShowMoneyFlyEffect()
	return self.m_bShowMoneyFlyEffect
end

function RoleItemManager:DownEquip(nItemKey)
	local pItem = self:FindItemByBagAndThisID(nItemKey, fire.pb.item.BagTypes.EQUIP)
	if not pItem then
		return false
    end

	local desPos = MainPackDlg_GetFirstEmptyCell()

	if desPos == -1 then
		if GetTipsManager() then
			GetTipsManager():AddMsgTips(120059)
        end
	else
		if pItem:GetObject() then
			self:UnEquipItem(pItem:GetThisID(), desPos)
        end
	end

	return true
end

function RoleItemManager:RightClickItem(pItem)
	local itemtype = pItem:GetBaseObject().itemtypeid

	-- ս�����޷��Ҽ����ʹ����Ʒ
    --[[
	if GetBattleManager():IsInBattle() then
		GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(131451).msg)
		return false
	end
    ]]--

	local itemattr = pItem:GetBaseObject()

	-- new add, 166 ��������ֱ�ӵ����ȼ�����
	if pItem:GetItemTypeID() == 166 then
		require("logic.qiandaosongli.leveluprewarddlg").getInstanceAndShow()
		return true
	end

	-- װ��
	if pItem:GetFirstType() == eItemType_EQUIP then
		return self:EquipItem(pItem)
	end

    -- ս����ʹ�õĵ��߲����Ҽ�ʹ��
	if pItem:isUseInBattle() then
		GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(141174).msg)
		return true
	end

	local baseid = pItem:GetObjectID()

	local itemtypeid = pItem:GetItemTypeID()

	if itemtypeid == AUTO_RECOVERY_ITEM and pItem:IsNeedSecondConfirmUse() then
		-- ��ǰ���и�ҩЧ���ٴ�ʹ�ý��Ḳ�Ǹ�ҩЧ��ȷ��Ҫʹ����
		local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(141896)
		gGetMessageManager():AddConfirmBox(
            eConfirmLevel3Drug,
            tip.msg,
			RoleItemManager.HandleConfirmUseItem, self,
            MessageManager.HandleDefaultCancelEvent, MessageManager,
            pItem:GetThisID())
		return true
	end

	-- ��������齱ȯ����
	if pItem:GetObjectID() >= 36639 and pItem:GetObjectID() <= 36644 then
		return true
	end

	if pItem:CanAddHp() and pItem:CanAddMp() then
		return self:UseAddHpMpItem(pItem)
	end

	if pItem:CanResumeInjury() and pItem:CanAddHp() then
		return self:UseResumeHpInjuryItem(pItem)
	end

	if pItem:CanAddHp() then
		return self:UseAddHpItem(pItem)
	end

	if pItem:CanAddMp() then
		return self:UseAddMpItem(pItem)
	end

	-- ʹ�ûָ�����
	if pItem:CanResumeInjury() then
		return self:UseResumeInjuryItem(pItem)
	end

	-- �������
	if itemtypeid == PET_FOOD then
		return self:UsePetFood(pItem)
	end

	-- ���＼����
	if itemtypeid == PET_SKILL_BOOK then
		if MainPetDataManager.getInstance():isMyPetListEmpty() then
			-- �㻹û�г���
			GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(150078).msg)
			return true
		end
		return self:UsePetSkillBook(pItem)
    end
	
	if itemtypeid == PET_EQUIP_ITEM then
	    if MainPetDataManager.getInstance():isMyPetListEmpty() then
            -- ????????
            GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(150078).msg)
            return true
        end
        return self:UsePetEquipItem(pItem)
	end

	-- ���ﻹͯ
	if itemtypeid == PET_RETURN then
		if MainPetDataManager.getInstance():isMyPetListEmpty() then
			-- �㻹û�г���
			GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(150078).msg)
			return true
		end

		require "logic.item.mainpackdlg"
        if CMainPackDlg:getInstanceOrNot() then
            CMainPackDlg:getInstanceOrNot():DestroyDialog()
        end

		PetLabel.ShowXiLianView()
		return true
	end

	-- pet feed item
	local feedItemList = BeanConfigManager.getInstance():GetTableByName("pet.cpetfeeditemlist"):getAllID()
	for i = 1, #feedItemList do
		local feedItem = BeanConfigManager.getInstance():GetTableByName("pet.cpetfeeditemlist"):getRecorder(feedItemList[i])
		if feedItem.itemid == pItem:GetObjectID() then
			if MainPetDataManager.getInstance():isMyPetListEmpty() then
				-- �㻹û�г���
				GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(150078).msg)
				return true
			end
			require "logic.item.mainpackdlg"
            if CMainPackDlg:getInstanceOrNot() then
                CMainPackDlg:getInstanceOrNot():DestroyDialog()
            end
			PetLabel.ShowFeedView(feedItem.itemid)
			return true
		end
	end

	if itemtypeid == ZHENFA_BOOK then
		ZhenFaDlg.useZhenfaBookItemFromBag(baseid)
		return true
	end

	if baseid == XUEMAI_GEM_ELITE then
		-- ����ǳ���������ж��Ƿ��в�ս�裬û�в�ս�裬���ò��ɹ���������ʾ�����򣬸���ս��ʹ�ÿ���
		if gGetDataManager():GetBattlePetID() > 0 then
	        require "protodef.fire.pb.item.cappenditem"
			local useItem = CAppendItem.Create()
            useItem.keyinpack = pItem:GetThisID()
            useItem.idtype = fire.pb.item.IDType.PET
            useItem.id = gGetDataManager():GetBattlePetID()
			LuaProtocolManager.getInstance():send(useItem)
		else
			-- �㵱ǰû���趨��ս��������뵽������Ʒҳ��ʹ�����ʾ���
			GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(143586).msg)
		end
		return true
	end

	-- ʹ���������
	if pItem:GetFirstType() == eItemType_TASKITEM then
		if itemattr.needLevel > gGetDataManager():GetMainCharacterLevel() then
			-- <T t="�ȼ�δ�ﵽ"></T><T t="$parameter1$" c="ffffff33"></T><T t="�����޷�ʹ�ô˵��ߡ�"></T>
            local sb = StringBuilder.new()
			sb:SetNum("parameter1", itemattr.needLevel)
			GetCTipsManager():AddMessageTip(sb:GetString(GameTable.message.GetCMessageTipTableInstance():getRecorder(143731).msg))
            sb:delete()
			return true
		end
		return self:UseTaskItem(pItem)
	end

	if itemtypeid == FOOD_LEVEL1_TYPE then
		return true
	end

	if baseid == FOODSTUFF_LEVEL1 then
		return true
	end

	if baseid == COALBIND_BASEID or baseid == COAL_BASEID then
		return true
	end

	if baseid == MENGHUOYOU_BASEID or baseid == MENGHUOYOUBIND_BASEID or baseid == CAOYAOJINGHUA_BASEID then
		return true
	end

	if baseid >= QG_EFFECT_ITEM1 and baseid <= QG_EFFECT_ITEM4 then
		-- ȷ��Ҫ����Ծ(��Խ)��βĬ��Ч���滻Ϊ�µ�ô��
        gGetMessageManager():AddConfirmBox(
            eConfirmQGEffectItem,
            GameTable.message.GetCMessageTipTableInstance():getRecorder(143940).msg,
            RoleItemManager.HandleConfirmUseItem, self,
            MessageManager.HandleDefaultCancelEvent, MessageManager,
            pItem:GetThisID())
		return true
	end

	-- ����齱��ȯ
	if baseid >= LOTTERY_ITEM1 and baseid <= LOTTERY_ITEM3 then
		gGetMessageManager():AddConfirmBox(
            eConfirmLottery,
            GameTable.message.GetCMessageTipTableInstance():getRecorder(144257).msg,
            RoleItemManager.HandleConfirmUseItem, self,
            MessageManager.HandleDefaultCancelEvent, MessageManager,
            pItem:GetThisID())
		return true
	end

	if (baseid == AirSeaLevel1 and gGetDataManager():GetCittaAirSeaMaxlimit() >= 30)
		or (baseid == AirSeaLevel2 and gGetDataManager():GetCittaAirSeaMaxlimit() >= 40)
		or (baseid == AirSeaLevel3 and gGetDataManager():GetCittaAirSeaMaxlimit() >= 50) then
		GetCTipsManager():AddMessageTip(MHSD_UTILS.get_resstring(1184))
		return true
	end

	if baseid == FlyFlag_ID then
		WorldMapDialog.GetSingletonDialogAndShowIt()
		self:EnableUseFlyFlagToFly(true)
	end

	if baseid == PetSinkerID then
		GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(143703).msg)
		return true
	end

	if itemtypeid == WEAPON_MANUAL then
		-- �Ҽ����������װ��������ͱ���������
		local dlg = require("logic.item.mainpackdlg"):GetSingletonDialogAndShowIt()
		if dlg then
		    dlg:SetDialogType(eEquipManual)
		end
		return true
	end

	-- �������⴦��
	if itemtypeid == PEARL_TYPE then
		-- �Ҽ����������װ��������ͱ���������
		local dlg = require("logic.item.mainpackdlg"):GetSingletonDialogAndShowIt()
		if dlg then
			dlg:SetDialogType(ePearlrepair)
		end
		gGetGameOperateState():ChangeGameCursorWithUserDate(eGameCursorType_Repair, pItem)
		return true
	end

	if baseid == BIG_FLYFLAG_CLOTH or baseid == SMALL_FLYFLAG_CLOTH then
		-- �Ҽ����������װ��������ͱ���������
		local dlg = require("logic.item.mainpackdlg"):GetSingletonDialogAndShowIt()
		if dlg then
			dlg:SetDialogType(eFlyFlagSupply)
		end
		return true
	end

	if itemtypeid == FLOWER_ITEM and (not pItem:isLock()) then
		local sex = gGetDataManager():GetMainCharacterData().sex;
		if baseid == BaiHeID and sex == eSexMale then
            local sb = StringBuilder.new()
			sb:Set("parameter1", MHSD_UTILS.get_resstring(1187))
			GetCTipsManager():AddMessageTip(sb:GetString(GameTable.message.GetCMessageTipTableInstance():getRecorder(140986).msg))
            sb:delete()
			return true
		elseif baseid == NvErHongID and sex == eSexFemale then
            local sb = StringBuilder.new()
			sb:Set("parameter1", MHSD_UTILS.get_resstring(1188))
			GetCTipsManager():AddMessageTip(sb:GetString(GameTable.message.GetCMessageTipTableInstance():getRecorder(140986).msg))
            sb:delete()
			return true
		end

		if gGetGameOperateState():GetOperateState() ~= eCursorState_GiveFlower then
			gGetGameOperateState():ChangeGameCursorWithUserDate(eGameCursorType_Forbid, pItem)
			gGetGameOperateState():SetOperateState(eCursorState_GiveFlower)
		end
		return true
	end

	if baseid == ROSE_ITEM_ID and (not pItem:isLock()) then
		if gGetGameOperateState():GetOperateState() ~= eCursorState_GiveRose then
			gGetGameOperateState():ChangeGameCursorWithUserDate(eGameCursorType_Forbid, pItem)
			gGetGameOperateState():SetOperateState(eCursorState_GiveRose)
		end
		return true
	end

	if baseid == MaBuXingNangID then
		local capacity = self:GetBagCapacity(fire.pb.item.BagTypes.BAG)
		if capacity >= 50 then
			-- �����ֻ����4��������
			GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(142217).msg)
			return true
		end

		return self:UseItem(pItem)
	end

	if baseid == QingBuXingNangID then
		local capacity = self:GetBagCapacity(fire.pb.item.BagTypes.BAG)
		if capacity < 50 then
			-- �����ֻ����4��������
			GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(144499).msg)
			return true
		end
		if capacity >= 75 then
			GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(142217).msg)
			return true
		end

		return self:UseItem(pItem)
	end

	if baseid == JinBuXingNangID then
		local capacity = self:GetBagCapacity(fire.pb.item.BagTypes.BAG)
		if capacity < 75 then
			-- �����ֻ����4��������
			GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(144499).msg)
			return true
		end
		if capacity >= 100 then
			GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(142217).msg)
			return true
		end

		return self:UseItem(pItem)
	end

	if baseid == WuLingCangID or baseid == WuLingCangID3 or baseid == WuLingCangID4 or (baseid >= WuLingCangID5 and baseid <= WuLingCangID8) then
		return self:UseExtentDeportCapacityItem(pItem, baseid)
	end


	-- ʹ�ó����������������
	if baseid == ChongWuLanID4 or (baseid >= ChongWuLanID5 and baseid <= ChongWuLanID5 + 3) then
		return self:UseExtentPetCapacityItem(pItem, baseid)
	end

	if baseid == Qian_Li_Xun_Die then
		if pItem:isLock() then
			GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(141078).msg)
		end
		return true
	end

	if baseid == Pet_Guide_ID then
		return true
	end

	if baseid == Family_Guide_ID then
		return true
	end

	if baseid == Family_Manager_Book then
		return true
	end

	if baseid == Faction_Manager_Book then
		return true
	end

	local ret = LuaUseItem(baseid, itemtypeid, pItem:GetLocation().tableType, pItem:GetThisID(), baseid)
	if ret == 1 then
		return true
	end

	return self:UseItem(pItem)
end

function RoleItemManager:UseAddHpMpItem(pItem)
	local curHp = gGetDataManager():GetMainCharacterAttribute(fire.pb.attr.AttrType.HP)
	local maxHp = gGetDataManager():GetMainCharacterAttribute(fire.pb.attr.AttrType.UP_LIMITED_HP)
	local curMp = gGetDataManager():GetMainCharacterAttribute(fire.pb.attr.AttrType.MP)
	local maxMp = gGetDataManager():GetMainCharacterAttribute(fire.pb.attr.AttrType.MAX_MP)
	if curHp == maxHp and curMp == maxMp then
		GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(142081).msg)
		return true
	elseif pItem:IsNeedSecondConfirmUse() then
        local sb = StringBuilder.new()
		sb:Set("parameter1", pItem:GetName())
		-- ��ȷ��Ҫʹ��[colour='ffffff00']"+ pItem->GetName() + L"[colour='ffffffff']��
		local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(141564)
		gGetMessageManager():AddConfirmBox(
            eConfirmLevel3Drug,
            sb:GetString(tip.msg),
			RoleItemManager.HandleConfirmUseItem, self,
            MessageManager.HandleDefaultCancelEvent, MessageManager,
            pItem:GetThisID())
        sb:delete()
		return true
	else
		return self:UseItem(pItem)
	end
end


function RoleItemManager:UseTaskItem(pItem)
   
	if not pItem then
		return true
	end
	local baseid = pItem:GetObjectID()
    local nBagId = pItem:GetLocation().tableType
    local nItemKey = pItem:GetThisID()
	local taskObject = BeanConfigManager.getInstance():GetTableByName("item.ctaskrelative"):getRecorder(pItem:GetObjectID())
	if not taskObject then
		return true
	end
    local readTimeType = require "protodef.rpcgen.fire.pb.mission.readtimetype":new()

	local destmapid = taskObject.usemap
    local bInRect = require("logic.task.taskhelper").isInTaskArea(baseid)
	if destmapid > 0  then -- ��ʹ����������
		if destmapid == gGetScene():GetMapID() and bInRect then
			if pItem:GetProgressBarTime() > 0 then
				if 1 == GetMainPackDlg() then
					MainPackDlg_EndUseTaskItemOrSetType(eMainPackState_UseTaskItem)
					pItem:SetAshy(true)
				end
				local nReadType = readTimeType.USE_TASK_ITEM 
                local nBagId = pItem:GetLocation().tableType
				ReadTimeProgressDlg.Start(pItem:GetProgressBarText(), nReadType, pItem:GetProgressBarTime() * 1000, pItem:GetThisID(), nBagId)
			else
	            require "protodef.fire.pb.item.cappenditem"
			    local useItem = CAppendItem.Create()
                useItem.keyinpack = pItem:GetThisID()
                useItem.idtype = fire.pb.item.IDType.ROLE
                useItem.id = gGetDataManager():GetMainCharacterID()
			    LuaProtocolManager.getInstance():send(useItem)
                self:showUseItemEffect(nBagId,nItemKey)
			end
		else
			GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(141584).msg)
		end
	elseif pItem:GetProgressBarTime() > 0 then
		if 1 == GetMainPackDlg() then
			MainPackDlg_EndUseTaskItemOrSetType(eMainPackState_UseTaskItem)
		end
		pItem:SetAshy(true)
        local nBagId = pItem:GetLocation().tableType
        local nUseType = readTimeType.USE_TASK_ITEM 
		ReadTimeProgressDlg.Start(pItem:GetProgressBarText(), nUseType, pItem:GetProgressBarTime() * 1000, pItem:GetThisID(), nBagId)
	else
	    require "protodef.fire.pb.item.cappenditem"
		local useItem = CAppendItem.Create()
        useItem.keyinpack = pItem:GetThisID()
        useItem.idtype = fire.pb.item.IDType.ROLE
        useItem.id = gGetDataManager():GetMainCharacterID()
		LuaProtocolManager.getInstance():send(useItem)

        self:showUseItemEffect(nBagId,nItemKey)
	end
    readTimeType = nil

	return true
end


function RoleItemManager:showUseItemEffect(nBagId,nItemKey)
    
    local pItem = self:FindItemByBagAndThisID(nItemKey, nBagId)
	if not pItem then
        return
    end
    local nItemId = pItem:GetObjectID()
    --//use item 
	local taskItemCfg = BeanConfigManager.getInstance():GetTableByName("item.ctaskrelative"):getRecorder(nItemId)
	if taskItemCfg then
		local nEffectId = taskItemCfg.neffectid
		--local nRoleEffectId = taskItemCfg.
		--nEffectId = 10300 
		if nEffectId > 0 then
			local nPosX =  taskItemCfg.neffectposx
			local nPosY =  taskItemCfg.neffectposy
			local rootWin = gGetGameUIManager():GetMainRootWnd() 
			local strEffectPath = require ("utils.mhsdutils").get_effectpath(nEffectId)
			gGetGameUIManager():AddUIEffect(rootWin, strEffectPath, false,nPosX,nPosY,false)
		end
		local nRoleEffectId = taskItemCfg.nroleeffectid
		--nRoleEffectId = 10300 
		if nRoleEffectId > 0 then 
			local strEffectPath = require ("utils.mhsdutils").get_effectpath(nRoleEffectId)
			GetMainCharacter():PlayEffect(strEffectPath)
		end
	end
end

function RoleItemManager:UseAddHpItem(pItem)
	local curHp = gGetDataManager():GetMainCharacterAttribute(fire.pb.attr.AttrType.HP)
	local maxHp = gGetDataManager():GetMainCharacterAttribute(fire.pb.attr.AttrType.UP_LIMITED_HP)
	if curHp == maxHp then
		GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(141995).msg)
		return true
	elseif pItem:IsNeedSecondConfirmUse() then
		-- ���������ҩ���򵯳�3��ҩʹ�õĶ���ȷ�Ͽ�
        local sb = StringBuilder.new()
		sb:Set("parameter1", pItem:GetName())
		-- ��ȷ��Ҫʹ��[colour='ffffff00']"+ pItem->GetName() + L"[colour='ffffffff']��
		local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(141564)
		gGetMessageManager():AddConfirmBox(
            eConfirmLevel3Drug,
            sb:GetString(tip.msg),
			RoleItemManager.HandleConfirmUseItem, self,
            MessageManager.HandleDefaultCancelEvent, MessageManager,
            pItem:GetThisID())
        sb:delete()
		return true
	else
		return self:UseItem(pItem)
	end
end

function RoleItemManager:UseResumeHpInjuryItem(pItem)
	local curHp = gGetDataManager():GetMainCharacterAttribute(fire.pb.attr.AttrType.HP)
	local maxHp = gGetDataManager():GetMainCharacterAttribute(fire.pb.attr.AttrType.MAX_HP)
	local ulHp = gGetDataManager():GetMainCharacterAttribute(fire.pb.attr.AttrType.UP_LIMITED_HP)

	if curHp == ulHp and ulHp == maxHp then
		-- ��û�����ư�������Ҫʹ�ûָ����Ƶ�ҩ��
		GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(142094).msg)
		return true
	elseif pItem:IsNeedSecondConfirmUse() then
		-- ���������ҩ���򵯳�3��ҩʹ�õĶ���ȷ�Ͽ�
        local sb = StringBuilder.new()
		sb:Set(L"parameter1", pItem:GetName())
		-- ��ȷ��Ҫʹ��[colour='ffffff00']"+ pItem->GetName() + L"[colour='ffffffff']��
		local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(141564)
		gGetMessageManager():AddConfirmBox(
            eConfirmLevel3Drug,
            sb:GetString(tip.msg),
			RoleItemManager.HandleConfirmUseItem, self,
            MessageManager.HandleDefaultCancelEvent, MessageManager,
            pItem:GetThisID())
        sb:delete()
		return true
	else
		return self:UseItem(pItem)
	end
end

function RoleItemManager:UseAddMpItem(pItem)
	local curMp = gGetDataManager():GetMainCharacterAttribute(fire.pb.attr.AttrType.MP)
	local maxMp = gGetDataManager():GetMainCharacterAttribute(fire.pb.attr.AttrType.MAX_MP)

	if curMp == maxMp then
		GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(141996).msg)
		return true
	elseif pItem:IsNeedSecondConfirmUse() then
		-- ���������ҩ���򵯳�3��ҩʹ�õĶ���ȷ�Ͽ�
        local sb = StringBuilder.new()
		sb:Set("parameter1", pItem:GetName())
		-- ��ȷ��Ҫʹ��[colour='ffffff00']"+ pItem->GetName() + L"[colour='ffffffff']��
		local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(141564)
		gGetMessageManager():AddConfirmBox(
            eConfirmLevel3Drug,
            sb:GetString(tip.msg),
			RoleItemManager.HandleConfirmUseItem, self,
            MessageManager.HandleDefaultCancelEvent, MessageManager,
            pItem:GetThisID())
        sb:delete()
		return true
	else
		return self:UseItem(pItem)
	end
end

-- ʹ���������Ƶ�ҩƷ��ʳƷ
function RoleItemManager:UseResumeInjuryItem(pItem)
	local ulHp = gGetDataManager():GetMainCharacterAttribute(fire.pb.attr.AttrType.UP_LIMITED_HP)
	local maxHp = gGetDataManager():GetMainCharacterAttribute(fire.pb.attr.AttrType.MAX_HP)

	if ulHp == maxHp then
		-- ��û�����ư�������Ҫʹ�ûָ����Ƶ�ҩ�ˡ�
		GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(142094).msg)
		return true;
	elseif pItem:IsNeedSecondConfirmUse() then
		-- ���������ҩ���򵯳�3��ҩʹ�õĶ���ȷ�Ͽ�
        local sb = StringBuilder.new()
		sb:Set("parameter1", pItem:GetName())
		-- ��ȷ��Ҫʹ��[colour='ffffff00']"+ pItem->GetName() + L"[colour='ffffffff']��
		local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(141564)
		gGetMessageManager():AddConfirmBox(
            eConfirmLevel3Drug,
            sb:GetString(tip.msg),
			RoleItemManager.HandleConfirmUseItem, self,
            MessageManager.HandleDefaultCancelEvent, MessageManager,
            pItem:GetThisID())
        sb:delete()
		return true
	else
		return self:UseItem(pItem)
	end
end

function RoleItemManager:UsePetFood(pItem)
	-- ����ǳ���������ж��Ƿ��в�ս�裬û�в�ս�裬���ò��ɹ���������ʾ�����򣬸���ս��ʹ�ÿ���
	if gGetDataManager():GetBattlePetID() > 0 then
	    require "protodef.fire.pb.item.cappenditem"
		local useItem = CAppendItem.Create()
        useItem.keyinpack = pItem:GetThisID()
        useItem.idtype = fire.pb.item.IDType.PET
        useItem.id = gGetDataManager():GetBattlePetID()
		LuaProtocolManager.getInstance():send(useItem)

		self:PlayUseItemEffect(pItem, true)
	else
		-- �㵱ǰû�����ò�ս���ﰡ�����ʳƷ��˭���أ��������ò�ս���
		GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(142483).msg)
	end

	return true
end

-- ʹ�ó�������
function RoleItemManager:UseExtentPetCapacityItem(pItem, baseid)
	local parameter = 0

	if baseid == ChongWuLanID4 then -- ���������ģ�
		if MainPetDataManager.getInstance():GetMaxPetNum() ~= 3 then
			parameter = 4
		end
	elseif baseid == ChongWuLanID5 then -- ���������壩
		if MainPetDataManager.getInstance():GetMaxPetNum() ~= 4 then
			parameter = 5
		end
	elseif baseid == ChongWuLanID5 + 1 then -- ������������
		if MainPetDataManager.getInstance():GetMaxPetNum() ~= 5 then
			parameter = 6
		end
	elseif baseid == ChongWuLanID5 + 2 then -- ���������ߣ�
		if MainPetDataManager.getInstance():GetMaxPetNum() ~= 6 then
			parameter = 7
		end
	elseif baseid == ChongWuLanID5 + 3 then -- ���������ˣ�
		if MainPetDataManager.getInstance():GetMaxPetNum() ~= 7 then
			parameter = 8
		end
	end

	if parameter ~= 0 then
        local sb = StringBuilder.new()
		sb:SetNum("parameter1", parameter)
		-- <T t="�������ֻ�������"></T><T t="$parameter1$" c="ff33ff33"></T><T t="����������"></T>
		GetCTipsManager():AddMessageTip(sb:GetString(GameTable.message.GetCMessageTipTableInstance():getRecorder(141630).msg))
        sb:delete()
	else
		return self:UseItem(pItem)
	end

	return true
end

-- ʹ�ó��＼����,��ѧϰ���ܽ���
function RoleItemManager:UsePetSkillBook(pItem)
	if 1 == IsMainPackDlgVisible() then
		require "logic.item.mainpackdlg"
        if CMainPackDlg:getInstanceOrNot() then
            CMainPackDlg:getInstanceOrNot():DestroyDialog()
        end
	end

	PetLabel.ShowLearnSkillView()
	return true
end
function RoleItemManager:UsePetEquipItem(pItem)
    if 1 == IsMainPackDlgVisible() then
        require "logic.item.mainpackdlg"
        if CMainPackDlg:getInstanceOrNot() then
            CMainPackDlg:getInstanceOrNot():DestroyDialog()
        end
    end
    require "logic.pet.petlabel".Show()
    if CChatOutputDialog:getInstance() then
        CChatOutputDialog:getInstance():OnClose()
    end
    return true
end
function RoleItemManager:UseExtentDeportCapacityItem(pItem, baseid)
	local capacity = self:GetBagCapacity(fire.pb.item.BagTypes.DEPOT)
	local minicapacity = 0
	local maxcapacity = 0

	if baseid == WuLingCangID then
		minicapacity = 25
		maxcapacity = 50
	elseif baseid == WuLingCangID3 then
		minicapacity = 50
		maxcapacity = 75
	elseif baseid == WuLingCangID4 then
		minicapacity = 75
		maxcapacity = 100
	elseif baseid == WuLingCangID5 then
		minicapacity = 100
		maxcapacity = 125
	elseif baseid == WuLingCangID6 then
		minicapacity = 125
		maxcapacity = 150
	elseif baseid == WuLingCangID7 then
		minicapacity = 150
		maxcapacity = 175
	elseif baseid == WuLingCangID8 then
		minicapacity = 175
		maxcapacity = 200
	end

	if capacity < minicapacity then
		-- �����ֻ����4��������
		GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(142509).msg)
		return true
	end

	if capacity >= maxcapacity then
		GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(142374).msg)
		return true
	end

	return self:UseItem(pItem)
end

-- �����������ʹ����Ʒ��Ϣ��userType����ʹ�ö������ͣ�1Ϊ��ɫ��2Ϊ����
function RoleItemManager:UseItem(pItem, idtype, objid)
	if not pItem then
		return false
	end

    -- Ĭ��ֵ
    if (not idtype) and (not objid) then
        idtype = 0
        objid = 0
    end
    local useobjid = objid
	if useobjid == 0 then
		useobjid = gGetDataManager():GetMainCharacterID()
	end


	if pItem:GetNeedLevel() > gGetDataManager():GetMainCharacterLevel() then
        local sb = StringBuilder.new()
		sb:SetNum("parameter1", pItem:GetNeedLevel())
		-- <T t="����Ҫ�ﵽ"></T><T t="$parameter1$" c="FFFF3333"></T><T t="�����ܴ򿪴������" ></T>
		GetCTipsManager():AddMessageTip(sb:GetString(GameTable.message.GetCMessageTipTableInstance():getRecorder(142535).msg))
        sb:delete()
		return true
	end

	-- new add, 166 ��������ֱ�ӵ����ȼ�����
	if pItem:GetItemTypeID() == 166 then
		require("logic.qiandaosongli.leveluprewarddlg").getInstanceAndShow()
		return true
	end

    if pItem:GetObjectID() == Money_Tree then
        local strMsg =  require "utils.mhsdutils".get_msgtipstring(180029)
        local function ClickYes(args)
	        require "protodef.fire.pb.item.cappenditem"
	        local useItem = CAppendItem.Create()
            useItem.keyinpack = pItem:GetThisID()
            useItem.idtype = idtype
            useItem.id = useobjid
	        LuaProtocolManager.getInstance():send(useItem)
            gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
        end
        gGetMessageManager():AddConfirmBox(eConfirmNormal, strMsg, ClickYes, 0, MessageManager.HandleDefaultCancelEvent, MessageManager)
        return true
    end

	if pItem:GetObjectID() == QI_LI_WAN then
		if GetTipsManager() then
			GetTipsManager():AddMsgTips(143741)
        end
		return true
	end

	if pItem:GetBaseObject().id == Treasure_Map or pItem:GetBaseObject().id == Advanced_Treasure_Map then
        if (pItem:GetObjectID() == Treasure_Map or pItem:GetObjectID() == Advanced_Treasure_Map) and pItem:GetObject().x == 0 and pItem:GetObject().y == 0 then
            require "protodef.fire.pb.item.cgetitemtips"
	        local itemTip = CGetItemTips.Create()
	        itemTip.packid = fire.pb.item.BagTypes.BAG
	        itemTip.keyinpack = pItem:GetThisID()
	        LuaProtocolManager.getInstance():send(itemTip)
            return true
        end
		if (not GetTeamManager():IsOnTeam()) or  GetTeamManager():IsMyselfLeader() or GetTeamManager():isMyselfAbsent() then
			require "logic.item.mainpackdlg"
            if CMainPackDlg:getInstanceOrNot() then
                CMainPackDlg:getInstanceOrNot():DestroyDialog()
            end
		end

    	local pObject = pItem:GetObject()
		local mapConfig = BeanConfigManager.getInstance():GetTableByName("map.cmapconfig"):getRecorder(pObject.mapID)
		if pObject then
			GetMainCharacter():RemoveAutoWalkingEffect()
			local itemkey = pItem:GetObject().data.key
			GetMainCharacter():SetCurItemkey(itemkey)
            local mpId = gGetScene():GetMapID()
			if pObject.mapID == gGetScene():GetMapID() then
                supertreasuremap.DestroyDialog()
				local graX = GetMainCharacter():GetGridLocation().x
				local graY = GetMainCharacter():GetGridLocation().y
				if math.abs(graX - pObject.x) < 10 and math.abs(graY - pObject.y) < 10 then
					local mapType = 0 -- �ͼ��ر�ͼΪ0 �߼��ر�ͼΪ1
					if pItem:GetBaseObject().id == Advanced_Treasure_Map then
						mapType = 1
					end
					gGetGameUIManager():setCurrentItemId(-1)
					gGetGameUIManager():setTreasureMapId(-1)
                    local p = require("protodef.fire.pb.mission.cusetreasuremap"):new()
                    p.itemkey = itemkey
                    p.maptype = mapType
	                LuaProtocolManager:send(p)
					-- �ر����½ǵ���ͼ��
					if Taskuseitemdialog.isTreasure() == 1 then
						Taskuseitemdialog.DestroyDialog()
					end
				else
					if pItem:GetBaseObject().id == Treasure_Map then
						GetMainCharacter():WalkToPos(pObject.x, pObject.y)
					else
						if GetTeamManager():IsOnTeam() and (not GetTeamManager():IsMyselfLeader()) and (not GetTeamManager():isMyselfAbsent()) then
							GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(170020).msg)
						else
							GetMainCharacter():RemoveAutoWalkingEffect()
							GetMainCharacter():StopMove()
							GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(170001).msg)
							-- ���õ�ͼ��ʾ
							supertreasuremap.DestroyDialog()
							supertreasuremap.getInstanceAndShow(pObject.x, pObject.y)
						end
					end
				end
				gGetGameUIManager():setCurrentItemId(pItem:GetBaseObject().id)
			else
				if pItem:GetBaseObject().id == Treasure_Map then
					gGetGameUIManager():setCurrentItemId(pItem:GetBaseObject().id)
					GetMainCharacter():FlyToPos(pObject.mapID, mapConfig.flyPosX, mapConfig.flyPosY, 0, 0, false, pObject.x, pObject.y)
				else
					if GetTeamManager():IsOnTeam() and (not GetTeamManager():IsMyselfLeader()) and (not GetTeamManager():isMyselfAbsent()) then
						GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(170020).msg)
					else
                        supertreasuremap.DestroyDialog()
						gGetGameUIManager():setTreasureMapId(pObject.mapID)
						gGetGameUIManager():setSuperTreasureMapEnable(true)
                        local pt = Nuclear.NuclearPoint((pObject.x), (pObject.y))
						GetMainCharacter():SetSuperMapTargetPos(pt)
						local Goto = fire.pb.mission.CReqGoto(pObject.mapID, mapConfig.flyPosX, mapConfig.flyPosY)
						gGetNetConnection():send(Goto)
					end
				end
 			end
 		end
	end

	require "protodef.fire.pb.item.cappenditem"
	local useItem = CAppendItem.Create()
    useItem.keyinpack = pItem:GetThisID()
    useItem.idtype = idtype
    useItem.id = useobjid
	LuaProtocolManager.getInstance():send(useItem)

	if pItem:isLock() then
		return true
	end

	local baseid = pItem:GetObjectID()
	if baseid >= 36006 and baseid <= 36010 then
		return true
	end

	if pItem:CanUseToCharacter() then
		self:PlayUseItemEffect(pItem, true)
	end

	return true
end

function RoleItemManager:PlayUseItemEffect(pItem, bFromMousePos)
	local beginpoint
	if bFromMousePos then
		local mousepoint = CEGUI.MouseCursor:getSingleton():getPosition()
		beginpoint = Nuclear.NuclearFPoint(mousepoint.x, mousepoint.y)
	else
		local pCell = self:GetItemCellByItem(pItem)
		beginpoint = Nuclear.NuclearFPoint(pCell:GetScreenPos().x, pCell:GetScreenPos().y)
	end
    local config = GameTable.effect.GetCUseItemEffectTableInstance():getRecorder(pItem:GetObjectID())
	if config.id ~= -1 then
	    RoleSkillManager.getInstance():AddUseItemEffect(config.destWindow, beginpoint)
    end
end

function RoleItemManager:getEquipEffectId()
	local bagInfo = self:GetBagInfo()
	local list = bagInfo[fire.pb.item.BagTypes.EQUIP]
	if not list then -- û���ҵ���Ӧ�İ���
		return 0
	end

	local quality = 0
	for first, second in pairs(list) do
		local pItem = second
		local equipId = pItem:GetObjectID()
		local record = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(equipId)
		if record and(quality == 0 or record.nquality < quality) then
			quality = record.nquality
		end
	end

	if quality ~= 0 then
		local conf = BeanConfigManager.getInstance():GetTableByName("role.cequipeffectconfig"):getRecorder(quality)
		if TableUtil.tablelength(list) >= conf.equipNum and conf.effectId ~= 0 then
			return conf.effectId
		end
	end

	return 0
end

function RoleItemManager:CheckEquipEffect()
	local bagInfo = self:GetBagInfo()
	local list = bagInfo[fire.pb.item.BagTypes.EQUIP]
	if not list then -- û���ҵ���Ӧ�İ���
		return
	end

	local quality = 0
	for first, second in pairs(list) do
		local pItem = second
		local equipId = pItem:GetObjectID()
		local record = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(equipId)
		if record and(quality == 0 or record.nquality < quality) then
			quality = record.nquality
		end
	end

	if quality ~= 0 then
		local conf = BeanConfigManager.getInstance():GetTableByName("role.cequipeffectconfig"):getRecorder(quality)
		if TableUtil.tablelength(list) >= conf.equipNum and conf.effectId ~= 0 then
			if (not self.m_equipEffectShow) or self.m_EquipQuality ~= quality then
				-- ��֮ǰ����װ��Ч��ɾ��
				if self.m_pEquipEffect then
					GetMainCharacter():RemoveDurativeEffect(self.m_pEquipEffect)
					require "logic.item.mainpackdlg"
					if CMainPackDlg:getInstanceOrNot() then
						CMainPackDlg:getInstanceOrNot():removeEquipEffect()
					end
				end
				MainPackDlg_addEquipEffect(conf.effectId)
				self.m_pEquipEffect = GetMainCharacter():SetDurativeEffect(MHSD_UTILS.get_effectpath(conf.effectId), 0, 0, 0, false, true, false, true, false)
				self.m_equipEffectShow = true
				self.m_EquipQuality = quality
			end
		else
			if self.m_equipEffectShow then
				if self.m_pEquipEffect then
					GetMainCharacter():RemoveDurativeEffect(self.m_pEquipEffect)
				end
				require "logic.item.mainpackdlg"
				if CMainPackDlg:getInstanceOrNot() then
					CMainPackDlg:getInstanceOrNot():removeEquipEffect()
				end
				self.m_equipEffectShow = false
				self.m_EquipQuality = 0
			end
		end
	end
end

function RoleItemManager:isHaveEquip()
	local list = self.m_BagInfo[fire.pb.item.BagTypes.BAG]
	if list then
        for first, second in pairs(list) do
			local pItem = second
			if pItem and pItem:GetObject() then
				if pItem:GetFirstType() == eItemType_EQUIP then
					return true;
				end
			end
		end
		return false
	end
end
function RoleItemManager:isHaveGem()
	local list = self.m_BagInfo[fire.pb.item.BagTypes.BAG]
	if list then
        for first, second in pairs(list) do
			local pItem = second
			if pItem and pItem:GetObject() then
				if pItem:GetFirstType() == eItemType_GEM then
					return true;
				end
			end
		end
		return false
	end
end

function RoleItemManager:GetCurrentEquip(bagid, secondType)
    local bagInfo = self:GetBagInfo()
    local list = bagInfo[bagid]
	if not list then -- û���ҵ���Ӧ�İ���
		return nil
	end

    for first, second in pairs(list) do
		local pItem = second;
		if pItem then
		    if pItem:GetSecondType() == secondType then
			    return pItem
		    end
        end
	end

	return nil
end

function RoleItemManager:GetCurrentEquipId(bagid, secondType)
    local bagInfo = self:GetBagInfo()
    local list = bagInfo[bagid]
	if not list then -- û���ҵ���Ӧ�İ���
		return 0
	end

    for first, second in pairs(list) do
		local pItem = second;
		if pItem then
		    if pItem:GetSecondType() == secondType then
			    return pItem:GetThisID()
            end
		end
	end

	return 0
end

function RoleItemManager:EventPackItemLocationChangeFire()
	gGetRoleItemManager().m_EventPackItemLocationChange:Bingo();
end

function RoleItemManager:isUseFlyFlagToFly()
	return self.m_bUseFlyFlagToFly
end

function RoleItemManager:EnableUseFlyFlagToFly(bUse)
	self.m_bUseFlyFlagToFly = bUse
	self:UpdateUseFlyFlagDlgState()
end

-- ˢ�������ͼ��С��ͼ�Զ�����ѡ����״̬
function RoleItemManager:UpdateUseFlyFlagDlgState()
	if WorldMapdlg.GetSingleton() then
		WorldMapdlg.SigleUpdateUseFlyFlagState()
	end
end

function RoleItemManager:FilterBagItem(t, sort)
    local items = {}
    items._size = 0
	function items:size()
		return self._size
	end

    local list = self.m_BagInfo[fire.pb.item.BagTypes.BAG]
	if list then
        for first, second in pairs(list) do
			local pItem = second
			
			if pItem and pItem:GetObject() then
				if t == eItemFilterType_CanSale then -- �Ƿ������
					if pItem:GetBaseObject().bCanSaleToNpc > 0 then
                        items[items._size] = pItem
                        items._size = items._size +1
                        --table.insert(items, pItem)
					end
				elseif t == eItemFilterType_CanStall then -- �Ƿ�ɰ�̯
                    if ShopManager:getGoodsConfByItemID(pItem:GetBaseObject().id) then
                        items[items._size] = pItem
                        items._size = items._size +1
                        --table.insert(items, pItem)
                    end
				end
			end
		end
	end

    if sort then
        for i=0, items:size()-2 do
            for j=i+1, items:size()-1 do
                local itemi = items[i]
                local itemj = items[j]
                if itemi:GetLocation().position > itemj:GetLocation().position then
                    items[i], items[j] = items[j], items[i]
                end
            end
        end
    end

    return items
end

function RoleItemManager:GetBagItem(itemkey)
    local list = self.m_BagInfo[fire.pb.item.BagTypes.BAG]
	if list then
        for first, second in pairs(list) do
			local pItem = second
			if pItem and pItem:GetObject() and pItem:GetThisID() == itemkey then
				return pItem
            end
		end
	end
	return nil
end

function RoleItemManager:setLastAddeditemkey(key)
	self.m_superTreasureKey = key
end

function RoleItemManager:getLastAddeditemkey()
	return self.m_superTreasureKey
end


function RoleItemManager:updateFumoItemData(pItem)
    if not pItem then
        return
    end
    
    local pEquipData = pItem:GetObject()
    if not pEquipData then
         return
    end
    local nFumoCount = pEquipData:getFumoCount()
    if nFumoCount <= 0 then
        return
    end
   
    for nIndexCount=0,nFumoCount-1 do
        local fumoData = pEquipData:getFumoDataWidthIndex(nIndexCount)
        local nFomoEndTime = 0 
        if fumoData then
             nFomoEndTime = fumoData.nFomoEndTime
        end

        if nFomoEndTime > 0 then 
            local nServerTime = gGetServerTime() /1000
            local nLeftSecond = nFomoEndTime / 1000 - nServerTime
            if nLeftSecond <= 0 then  
                require "protodef.fire.pb.item.cgetitemtips"
	            local p = CGetItemTips.Create()
	            p.packid = fire.pb.item.BagTypes.EQUIP
	            p.keyinpack = pItem:GetThisID()
	            LuaProtocolManager.getInstance():send(p)

                fumoData.nFomoEndTime = 0
                return
            end
        end
    end
           

end

function RoleItemManager:updateFumoData()
    
    local bagid = fire.pb.item.BagTypes.EQUIP
    if self.m_BagInfo[bagid] then
		for first, second in pairs(self.m_BagInfo[bagid]) do
			local pItorItem = second
            self:updateFumoItemData(pItorItem)
		end
	end

end

function RoleItemManager:updateBind(delta)
    for i,v in pairs(self.m_BagInfo) do
        for m,n in pairs (v)do
            n:Update(delta)
        end
    end
end

function RoleItemManager:update(delta)
    local dt = delta /1000
    self.m_fUpdateFuMoCdDt = self.m_fUpdateFuMoCdDt + dt
    if self.m_fUpdateFuMoCdDt >= self.m_fUpdateFuMoCd then
        self:updateFumoData()
        self:updateBind(self.m_fUpdateFuMoCdDt*1000)
        self.m_fUpdateFuMoCdDt =0
    end
    
end

function RoleItemManager:getUnlockBagNeedMoney()
	local ids = BeanConfigManager.getInstance():GetTableByName("item.cbagtable"):getAllID();

	local npackcnt = self:GetBagCapacity(fire.pb.item.BagTypes.BAG);

	-- npackcnt ��Ҫ��ȥ VIP ���͵ĸ�����
	local vipGiftBagNum = 0;
	local vipLevel = gGetDataManager():GetVipLevel();
	local vipIds = BeanConfigManager.getInstance():GetTableByName("fushi.cvipinfo"):getAllID();
	for _, id in pairs(vipIds) do
		if vipLevel >= id then
			local vipRecord = BeanConfigManager.getInstance():GetTableByName("fushi.cvipinfo"):getRecorder(id);
			vipGiftBagNum = vipGiftBagNum + vipRecord.giftBagNum;
		end
	end

	npackcnt = npackcnt - vipGiftBagNum;

	local needMoney = 0;
	for _, id in pairs(ids) do
		local bagMoney = BeanConfigManager.getInstance():GetTableByName("item.cbagtable"):getRecorder(id);
		needMoney = bagMoney.needyinbi;
		if (bagMoney.haveCount == npackcnt) then
			break;
		end
	end

	return needMoney;
end


function RoleItemManager:refreshToXiuliFlag(pItem)
   
    local CMainPackLabelDlg = require("logic.item.MainPackLabelDlg")
    if not CMainPackLabelDlg:getInstanceOrNot() then
		return
	end

    local nItemKey = pItem:GetThisID()
    local nBagId = pItem.m_pObject.loc.tableType
    local nPos = pItem.m_pObject.loc.position 

    local mainPackDlg = require("logic.item.mainpackdlg"):getInstanceOrNot()
    if mainPackDlg and mainPackDlg.m_pFirstTable and
        nBagId == fire.pb.item.BagTypes.BAG 
    then
        --pItem.m_pObject.loc.tableType = bagid
	    --pItem.m_pObject.loc.position 

        
		local itemCell =  mainPackDlg.m_pFirstTable:GetCell(nPos);
        if not itemCell then
            return
        end
        g_refreshItemCellEquipEndureFlag(itemCell,nBagId,nItemKey)
	end


    local depotDlg = require("logic.item.depot"):getInstanceOrNot()
    if depotDlg  then
        local nIndex = nPos + 1 --nIndex 123...
        local vCells = depotDlg.m_pCells[nBagId]
        if not vCells then
            return
        end
        nIndex = nIndex%25 
        if nIndex==0 then
            nIndex = 25
        end
        local itemCell =  vCells[nIndex] 
        if not itemCell then
            return 
        end
        g_refreshItemCellEquipEndureFlag(itemCell,nBagId,nItemKey)
    end


end

function RoleItemManager:setRideData(itemid, rideid)
	self.m_rideItemId = itemid
	self.m_rideId = rideid
end

function RoleItemManager:getRideItemId()
	return self.m_rideItemId
end

function RoleItemManager:getRideId()
	return self.m_rideId
end

return RoleItemManager
