local EQUIPNUM = 23;
local EQUIP_PREVIEW_CONFIG = {
    model = true,
    components = true,
    horse = true,
    effects = false,
    equip_weapon_first = false
}

if _G and _G.FASHION_WEAPON_EQUIP_FIRST == nil then
    _G.FASHION_WEAPON_EQUIP_FIRST = EQUIP_PREVIEW_CONFIG.equip_weapon_first
end

local function toBoolean(value, defaultValue)
    if value == nil then
        return defaultValue
    end
    if type(value) == "boolean" then
        return value
    end
    if type(value) == "number" then
        return value ~= 0
    end
    if type(value) == "string" then
        local lower = string.lower(value)
        if lower == "1" or lower == "true" or lower == "on" or lower == "yes" then
            return true
        end
        if lower == "0" or lower == "false" or lower == "off" or lower == "no" then
            return false
        end
    end
    return defaultValue
end

local function isPreviewEnabled(key, defaultValue)
    if key == "equip_weapon_first" and _G and _G.FASHION_WEAPON_EQUIP_FIRST ~= nil then
        return toBoolean(_G.FASHION_WEAPON_EQUIP_FIRST, defaultValue)
    end
    local value = EQUIP_PREVIEW_CONFIG[key]
    if value == nil then
        return defaultValue
    end
    return toBoolean(value, defaultValue)
end

local function isRideModelInTable(tableName, ridemodel)
    local tableRef = BeanConfigManager.getInstance():GetTableByName(tableName)
    if not tableRef then
        return false
    end

    local ids = tableRef:getAllID()
    for _, id in pairs(ids) do
        local conf = tableRef:getRecorder(id)
        if conf and conf.id ~= -1 and tonumber(conf.ridemodel) == ridemodel then
            return true
        end
    end

    return false
end

local function isValidRideModelId(modelId)
    local ridemodel = tonumber(modelId) or 0
    if ridemodel <= 0 then
        return false
    end

    if isRideModelInTable("npc.cride", ridemodel) then
        return true
    end
    if isRideModelInTable("npc.cridea", ridemodel) then
        return true
    end

    return false
end

local function getRideModelByRideItemId(rideItemId)
    local itemId = tonumber(rideItemId) or 0
    if itemId <= 0 then
        return 0
    end

    local rideItemTable = BeanConfigManager.getInstance():GetTableByName("npc.crideitem")
    local rideTable = BeanConfigManager.getInstance():GetTableByName("npc.cride")
    if not rideItemTable or not rideTable then
        return 0
    end

    local rideItemCfg = rideItemTable:getRecorder(itemId)
    if not rideItemCfg or rideItemCfg.id == -1 then
        return 0
    end

    local rideCfg = rideTable:getRecorder(rideItemCfg.rideid)
    if not rideCfg or rideCfg.id == -1 then
        return 0
    end

    return tonumber(rideCfg.ridemodel) or 0
end

local function getRideModelFromEquipPosition(roleItemManager, equipPosition)
    if not roleItemManager or not roleItemManager.GetBagInfo then
        return 0
    end

    local bagInfo = roleItemManager:GetBagInfo()
    if not bagInfo then
        return 0
    end

    local equipBag = bagInfo[fire.pb.item.BagTypes.EQUIP]
    if not equipBag then
        return 0
    end

    for _, pItem in pairs(equipBag) do
        if pItem and pItem.GetLocation and pItem.GetObjectID then
            local loc = pItem:GetLocation()
            if loc and tonumber(loc.position) == equipPosition then
                return getRideModelByRideItemId(pItem:GetObjectID())
            end
        end
    end

    return 0
end

local function isValidItemId(itemId)
    local id = tonumber(itemId) or 0
    if id <= 0 then
        return false
    end
    local itemTable = BeanConfigManager.getInstance():GetTableByName("item.citemattr")
    if not itemTable then
        return false
    end
    local itemCfg = itemTable:getRecorder(id)
    return itemCfg and itemCfg.id ~= -1
end

local function getWeaponComponentIdFromEquipItemId(equipItemId)
    local itemId = tonumber(equipItemId) or 0
    if itemId <= 0 then
        return 0, "invalid_item_id"
    end

    -- 大ID（如 9250101）在当前项目里可直接作为武器组件使用，优先直接返回。
    local directWeaponId = 0
    if itemId >= 1000000 then
        directWeaponId = itemId
    end

    local isPointCardServer = (type(IsPointCardServer) == "function" and IsPointCardServer()) or false
    local mappedWeaponId = 0

    if isPointCardServer then
        local equipEffectTable = BeanConfigManager.getInstance():GetTableByName("item.cequipeffect")
        if equipEffectTable then
            local equipEffectCfg = equipEffectTable:getRecorder(itemId)
            if equipEffectCfg and equipEffectCfg.id ~= -1 then
                mappedWeaponId = tonumber(equipEffectCfg.weaponid) or 0
            end
        end
    else
        if GameTable and GameTable.item and GameTable.item.GetCEquipEffectTableInstance then
            local equipEffectTable = GameTable.item.GetCEquipEffectTableInstance()
            if equipEffectTable then
                local equipEffectCfg = equipEffectTable:getRecorder(itemId)
                if equipEffectCfg and equipEffectCfg.id ~= -1 then
                    mappedWeaponId = tonumber(equipEffectCfg.weaponid) or 0
                end
            end
        end
    end

    if directWeaponId > 0 then
        if mappedWeaponId > 0 and mappedWeaponId ~= directWeaponId then
            LogInfo(string.format("EquipDialog.weapon resolve prefer direct itemId=%s over mapped=%s",
                tostring(itemId), tostring(mappedWeaponId)))
        end
        return directWeaponId, "direct_item_id"
    end

    if mappedWeaponId > 0 then
        return mappedWeaponId, "equip_effect_map"
    end

    return itemId, "direct_item_id_fallback"
end

local function getEquippedWeaponItemIdFromRoleItemManager(roleItemManager)
    if not roleItemManager then
        return 0, "no_role_item_manager"
    end

    if roleItemManager.GetCurrentEquip then
        local weaponEquip = roleItemManager:GetCurrentEquip(fire.pb.item.BagTypes.EQUIP, eEquipType_ARMS)
        if weaponEquip and weaponEquip.GetObjectID then
            local itemId = tonumber(weaponEquip:GetObjectID()) or 0
            if itemId > 0 then
                return itemId, "GetCurrentEquip"
            end
        end
    end

    if roleItemManager.GetBagInfo then
        local bagInfo = roleItemManager:GetBagInfo()
        local function scanList(list, source)
            if not list then
                return 0, source
            end
            for _, pItem in pairs(list) do
                if pItem and pItem.GetSecondType and pItem.GetObjectID then
                    local secondType = tonumber(pItem:GetSecondType()) or -1
                    if secondType == eEquipType_ARMS then
                        local loc = pItem.GetLocation and pItem:GetLocation() or nil
                        if (not loc) or loc.tableType == fire.pb.item.BagTypes.EQUIP then
                            local itemId = tonumber(pItem:GetObjectID()) or 0
                            if itemId > 0 then
                                return itemId, source
                            end
                        end
                    end
                end
            end
            return 0, source
        end

        if bagInfo then
            local itemId, source = scanList(bagInfo[fire.pb.item.BagTypes.EQUIP], "GetBagInfo[EQUIP]")
            if itemId > 0 then
                return itemId, source
            end
            for bagId, list in pairs(bagInfo) do
                itemId, source = scanList(list, "GetBagInfoScan:" .. tostring(bagId))
                if itemId > 0 then
                    return itemId, source
                end
            end
        end
    end

    return 0, "not_found"
end

local function getValidatedMainShapeId()
    local rawShapeId = tonumber(gGetDataManager():GetMainCharacterShape()) or 0
    local shapeTable = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape")
    local function isShapeValid(shapeId)
        if not shapeTable or shapeId <= 0 then
            return false
        end
        local shapeCfg = shapeTable:getRecorder(shapeId)
        return shapeCfg and shapeCfg.id ~= -1
    end

    if isShapeValid(rawShapeId) then
        return rawShapeId, rawShapeId
    end

    local convertedShapeId = rawShapeId
    if rawShapeId < 100 then
        convertedShapeId = rawShapeId + 1010100 + 1000
        if isShapeValid(convertedShapeId) then
            return convertedShapeId, rawShapeId
        end
    end

    convertedShapeId = rawShapeId % 100 + 1010100
    if isShapeValid(convertedShapeId) then
        return convertedShapeId, rawShapeId
    end

    return 0, rawShapeId
end

local function clearPreviewCaches(dialog)
    dialog.m_lastPreviewWeapon = nil
    dialog.m_lastPreviewHorse = nil
    dialog.m_lastPreviewDyeA = nil
    dialog.m_lastPreviewDyeB = nil
end

local function destroyPreviewSprite(dialog)
    if not dialog or not dialog.m_pEquipUISprite then
        return
    end

    -- 销毁阶段禁止再访问引擎精灵方法，避免窗口回收顺序导致 hardref 失效断言。
    dialog.m_pPackEquipEffect = nil

    -- AddWindowSprite 由引擎窗口生命周期托管，手动 delete 可能触发硬引用断言。
    -- 这里仅清空 Lua 侧引用，避免在切换“外观”时重复释放导致崩溃。
    dialog.m_pEquipUISprite = nil
    dialog.m_previewSpriteKind = nil
    dialog.m_previewShapeId = nil
end

local function createPreviewSprite(dialog, shapeid)
    if not dialog or not dialog.m_pSpriteBack then
        return nil
    end

    local spriteBackSize = dialog.m_pSpriteBack:getPixelSize()
    local sprite = gGetGameUIManager():AddWindowSprite(
        dialog.m_pSpriteBack,
        shapeid,
        Nuclear.XPDIR_BOTTOMRIGHT,
        spriteBackSize.width * 0.5,
        spriteBackSize.height * 0.5 + 48,
        true
    )
    dialog.m_pEquipUISprite = sprite
    dialog.m_previewSpriteKind = "window_sprite"
    dialog.m_previewShapeId = shapeid
    return sprite
end

CEquipDialog =
{
	m_pEquipCell = { }
};
CEquipDialog.__index = CEquipDialog;

function CEquipDialog:GetWindow()
	return self.m_pParentWindow;
end

function CEquipDialog:SetSelectID(nID)
	self.m_nSelectCellID = nID;
end

function CEquipDialog:GetSelectID()
	return self.m_nSelectCellID;
end

function CEquipDialog:removeEventMapChangeFunctor()
	if (gGetScene() and self.mEventMapChangeFunctor) then
		gGetScene().EventMapChange:RemoveScriptFunctor(self.mEventMapChangeFunctor);
		self.mEventMapChangeFunctor = nil;
	end
end

function CEquipDialog:GetItemTableByPos(pos)
	return nil;
end

function CEquipDialog:showEffectOnEquipCell(nSecondType, nEffectId)
	if (nSecondType >= eEquipType_MAXTYPE) then
		return;
	end

	local pEquipCell = m_pEquipCell[nSecondType];
	if (not pEquipCell) then
		return;
	end
	local bCycle = false;

	local strEffectName = MHSD_UTILS.get_effectpath(nEffectId);
	gGetGameUIManager():AddUIEffect(pEquipCell, strEffectName, bCycle);

end

function CEquipDialog:HandleWindowPosChange(e)
	local pt = self.m_pSpriteBack:GetScreenPosOfCenter();
	local wndHeight = self.m_pSpriteBack:getPixelSize().height;
	local xPos =(pt.x);
	local yPos =(pt.y + wndHeight / 3.0);

	if (self.m_pEquipUISprite and self.m_pEquipUISprite.SetUILocation) then
		self.m_pEquipUISprite:SetUILocation(Nuclear.NuclearPoint(xPos, yPos));
	end
	return true;
end

function CEquipDialog:UpdataModel()
    if not isPreviewEnabled("model", true) then
        return
    end
	if (self.m_pEquipUISprite) then
     local mainCharacter = GetMainCharacter()
     if not mainCharacter then
         LogErr("EquipDialog.UpdataModel mainCharacter is nil")
         return
     end
     local pA = mainCharacter:GetSpriteComponent(eSprite_DyePartA)
     local pB = mainCharacter:GetSpriteComponent(eSprite_DyePartB)
     LogInfo(string.format("EquipDialog.UpdataModel dyeA=%s dyeB=%s", tostring(pA), tostring(pB)))
     if self.m_lastPreviewDyeA ~= pA then
         self.m_pEquipUISprite:SetDyePartIndex(0, pA)
         self.m_lastPreviewDyeA = pA
     end
     if self.m_lastPreviewDyeB ~= pB then
         self.m_pEquipUISprite:SetDyePartIndex(1, pB)
         self.m_lastPreviewDyeB = pB
     end

     if isPreviewEnabled("components", true) then
         local wuqi = 0
         local weaponSource = "none"
         local mainWeapon = tonumber(mainCharacter:GetSpriteComponent(eSprite_Weapon)) or 0
         local roleItemManager = require("logic.item.roleitemmanager").getInstance()

        local function tryUseMainCharacterWeapon()
            if mainWeapon > 0 then
                wuqi = mainWeapon
                weaponSource = "main_character_component"
            end
        end

        local function tryUseEquipBagWeapon()
            local equipItemId, equipItemSource = getEquippedWeaponItemIdFromRoleItemManager(roleItemManager)
            if equipItemId > 0 then
                local equipWeapon, equipWeaponSource = getWeaponComponentIdFromEquipItemId(equipItemId)
                if equipWeapon > 0 then
                    wuqi = equipWeapon
                    weaponSource = "equip_bag_weapon_model:" .. tostring(equipItemSource) .. "/" .. tostring(equipWeaponSource)
                else
                    LogInfo(string.format("EquipDialog.UpdataModel weapon mapping missing for equipItemId=%s source=%s",
                        tostring(equipItemId), tostring(equipItemSource)))
                end
            end
        end

         -- 统一规则：角色当前武器组件优先；装备栏仅作缺省兜底。
         local equipWeaponFirst = isPreviewEnabled("equip_weapon_first", false)
         if equipWeaponFirst then
             tryUseEquipBagWeapon()
             if wuqi <= 0 then
                 tryUseMainCharacterWeapon()
             end
         else
             tryUseMainCharacterWeapon()
             if wuqi <= 0 then
                 tryUseEquipBagWeapon()
             end
         end

         if wuqi > 0 then
             if self.m_lastPreviewWeapon ~= wuqi then
                 LogInfo(string.format("EquipDialog.UpdataModel set weapon=%s source=%s", tostring(wuqi), weaponSource))
                  self.m_pEquipUISprite:SetSpriteComponent(eSprite_Weapon, wuqi)
                  self.m_lastPreviewWeapon = wuqi
              else
                  LogInfo(string.format("EquipDialog.UpdataModel skip same weapon=%s", tostring(wuqi)))
              end
          else
              LogInfo(string.format("EquipDialog.UpdataModel skip weapon=%s source=%s", tostring(wuqi), weaponSource))
          end

          if isPreviewEnabled("horse", true) then
             -- 坐骑组件优先走坐骑链路，模型合法后再下发到引擎。
             local rideModelId = self:GetRideModelId()
             if rideModelId > 0 then
                  if self.m_lastPreviewHorse ~= rideModelId then
                      LogInfo(string.format("EquipDialog.UpdataModel set horse=%s", tostring(rideModelId)))
                      self.m_pEquipUISprite:SetSpriteComponent(eSprite_Horse, rideModelId)
                      self.m_lastPreviewHorse = rideModelId
                  else
                      LogInfo(string.format("EquipDialog.UpdataModel skip same horse=%s", tostring(rideModelId)))
                  end
              else
                  if (self.m_lastPreviewHorse or 0) > 0 then
                      LogInfo("EquipDialog.UpdataModel clear horse=0")
                      self.m_pEquipUISprite:SetSpriteComponent(eSprite_Horse, 0)
                      self.m_lastPreviewHorse = 0
                  else
                      LogInfo("EquipDialog.UpdataModel skip clear horse=0")
                  end
              end
          end
     end
    end
end

function CEquipDialog:GetRideModelId()
    local rideModelId = 0

    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    if roleItemManager then
        -- 规则B：优先读取装备槽位(FASHION5)中的坐骑道具。
        rideModelId = getRideModelFromEquipPosition(roleItemManager, eEquipType_FASHION5)

        -- 兜底1：服务端同步的当前骑乘道具。
        if rideModelId <= 0 and roleItemManager.getRideItemId then
            rideModelId = getRideModelByRideItemId(roleItemManager:getRideItemId())
        end

        -- 兜底2：服务端同步的 rideid。
        if rideModelId <= 0 and roleItemManager.getRideId then
            local rideId = tonumber(roleItemManager:getRideId()) or 0
            if rideId > 0 then
                local rideTable = BeanConfigManager.getInstance():GetTableByName("npc.cride")
                if rideTable then
                    local rideCfg = rideTable:getRecorder(rideId)
                    if rideCfg and rideCfg.id ~= -1 then
                        rideModelId = tonumber(rideCfg.ridemodel) or 0
                    end
                end
            end
        end
    end

    -- 兜底3：主角当前坐骑组件（放在最后，避免引擎侧特殊状态直接带入预览）。
    if rideModelId <= 0 and GetMainCharacter() then
        local mainRideModelId = tonumber(GetMainCharacter():GetSpriteComponent(eSprite_Horse)) or 0
        if isValidRideModelId(mainRideModelId) then
            rideModelId = mainRideModelId
        end
    end

    if not isValidRideModelId(rideModelId) then
        return 0
    end

    return rideModelId
end

function CEquipDialog:GetEquipTabBackImage(loc)
	if (loc == eEquipType_CUFF) then
		return "Cuff";
	elseif loc == eEquipType_ADORN then
		return "Accessories";
	elseif loc == eEquipType_LORICAE then
		return "Armour";
	elseif loc == eEquipType_ARMS then
		return "Weapon";
	elseif loc == eEquipType_TIRE then
		return "Head";
	elseif loc == eEquipType_BOOT then
		return "Shoe";
	elseif loc == eEquipType_WAISTBAND then
		return "Belt";
	elseif loc == eEquipType_EYEPATCH then
	elseif loc == eEquipType_RESPIRATOR then
	elseif loc == eEquipType_VEIL then
	elseif loc == eEquipType_CLOAK then
		return "Mask";
	elseif loc == eEquipType_FASHION then
		return "Fashion";
	else
	end
	return "";
end

--[[
function CEquipDialog:HandleShiftClickItem(pItem)
	if (GetChatManager() and pItem and pItem:GetObject()) then
		local ItemColor = CEGUI.colour(pItem:GetLinkTipsColor());
		local bind = pItem:GetObject().data.flags;
		local loseeffecttime = pItem:GetObject().data.loseeffecttime;
		GetChatManager():AddObjectTipsLinkToCurInputBox(pItem:GetName(), gGetDataManager():GetMainCharacterID(), fire.pb.talk.ShowInfo.SHOW_ITEM, pItem:GetThisID(), pItem:GetBaseObject().id, 0, fire.pb.item.BagTypes.EQUIP, true, bind, loseeffecttime, ItemColor);
	end
	return true;
end
--]]

function CEquipDialog:HandleDrawSprite()
    if not isPreviewEnabled("model", true) then
        return
    end
	if (self.m_pEquipUISprite and self.m_pEquipUISprite.RenderUISprite) then
		self.m_pEquipUISprite:RenderUISprite();
	end
end

function CEquipDialog:HandleTableDoubleClick(e)
	local MouseArgs = CEGUI.toMouseEventArgs(e);

	local pCell = CEGUI.toItemCell(MouseArgs.window);
	if (pCell == nil) then
		return false;
	end

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local pItem = roleItemManager:getItem(pCell:getID2(), fire.pb.item.BagTypes.EQUIP)
	if (pItem == nil) then
		return false;
	end

	self:Unequip(pItem);

	local dlg = require 'logic.tips.commontipdlg'.getInstanceNotCreate();
	if dlg then
		dlg:DestroyDialog();
	end

	return true;
end

function CEquipDialog:Unequip(item)
	local desPos = CMainPackDlg:GetSingleton():GetFirstEmptyCell();
	if (desPos == -1) then
		if (GetChatManager()) then
			GetChatManager():AddTipsMsg(120059);
		end
	else
		if (item:GetObject() ~= nil) then
			local roleItemManager = require("logic.item.roleitemmanager").getInstance()
            roleItemManager:UnEquipItem(item:GetThisID(), desPos);
		end
	end
end

function CEquipDialog:UpdateTotalScore()
	local roleScore = gGetDataManager():GetMainCharacterData().roleScore;
	local stream = "";
	local viplevel = gGetDataManager():GetVipLevel()
	stream =  MHSD_UTILS.get_resstring(1637) .. roleScore;
	self.m_TotalScore:setText(stream, 0xFF5E3F25);
	self.m_TotalVipScore:setText("SVIP-"..tostring(viplevel));
end

function CEquipDialog:UpdateEquipTotalScore()
	local score = 0;
	local jewelryScore = 0;
	for i = 0, EQUIPNUM - 1 do
		local pCell = self.m_pEquipCell[i];
		if (pCell ~= nil) then
	        local roleItemManager = require("logic.item.roleitemmanager").getInstance()
            local pItem = roleItemManager:getItem(pCell:getID2(), fire.pb.item.BagTypes.EQUIP)
			if (pItem) then
				if (pItem:GetObject() and pItem:GetObject().bNeedRequireData) then
		            require "protodef.fire.pb.item.cgetitemtips"
		            local send = CGetItemTips.Create()
					send.packid = fire.pb.item.BagTypes.EQUIP
					send.keyinpack = pItem:GetThisID()
					LuaProtocolManager.getInstance():send(send)
				end
				if (pItem:GetSecondType() == 6) then
					jewelryScore = jewelryScore + GetEquipScore(pItem:GetLocation().tableType, pItem:GetThisID()) -- pItem:GetEquipScore();
				else
					score = score + GetEquipScore(pItem:GetLocation().tableType, pItem:GetThisID()) -- pItem:GetEquipScore();
				end
			end
		end
	end
	local stream = "";
	stream = stream .. MHSD_UTILS.get_resstring(1637);
	stream = stream .. score;
	self.m_TotalScore:setText(stream);
	stream = "";
	stream = stream .. MHSD_UTILS.get_resstring(3000);
	stream = stream .. jewelryscore;
	self.m_TotalJewelryScore:setText(stream, 0xFF5E3F25);

	local total = jewelryScore + score;
	stream = "";
	stream = MHSD_UTILS.get_resstring(1637) .. total;
	self.m_TotalScore:setText(stream, 0xFF5E3F25);
end

function CEquipDialog:GetItemCellByPos(pos)
	--if (pos == eEquipType_VEIL) then
	--	return self.m_pEquipCell[eEquipType_EYEPATCH];
	--end

	return self.m_pEquipCell[pos];
end

function CEquipDialog:addEquipEffect(effectId)
    if not isPreviewEnabled("effects", false) then
        return
    end
    if (not self.m_pEquipUISprite) then
        return
    end
	self.m_pPackEquipEffect = self.m_pEquipUISprite:SetEngineSpriteDurativeEffect(MHSD_UTILS.get_effectpath(effectId), false);
    self.m_pPackEquipEffect:SetScale(2,2)
end

function CEquipDialog:removeEquipEffect()
	if (self.m_pEquipUISprite) then
		if (self.m_pPackEquipEffect) then
			self.m_pEquipUISprite:RemoveEngineSpriteDurativeEffect(self.m_pPackEquipEffect);
			self.m_pPackEquipEffect = nil;
		end
	end
end

function CEquipDialog:InitEquipEffect()
    if not isPreviewEnabled("effects", false) then
        return
    end
	if (self.m_pEquipUISprite) then
		local roleItemManager = require("logic.item.roleitemmanager").getInstance()
        local effectId = roleItemManager:getEquipEffectId();
		if (self.m_pPackEquipEffect == nil) then
			self.m_pPackEquipEffect = self.m_pEquipUISprite:SetEngineSpriteDurativeEffect(MHSD_UTILS.get_effectpath(effectId), false);
            if self.m_pPackEquipEffect then
                self.m_pPackEquipEffect:SetScale(2,2)
            end
		end
	end
end

function CEquipDialog:InitSpriteModel()
    if not isPreviewEnabled("model", true) then
        destroyPreviewSprite(self)
        clearPreviewCaches(self)
        return
    end

	local shapeid, rawShapeId = getValidatedMainShapeId();
    LogInfo(string.format("EquipDialog.InitSpriteModel rawShape=%s validShape=%s", tostring(rawShapeId), tostring(shapeid)))
    if shapeid <= 0 then
        LogErr("EquipDialog.InitSpriteModel invalid shape id, skip creating preview sprite")
        return
    end
    if (not self.m_pEquipUISprite) or (self.m_previewShapeId ~= shapeid) then
        destroyPreviewSprite(self)
        LogInfo(string.format("EquipDialog.InitSpriteModel AddWindowSprite shape=%s", tostring(shapeid)))
        local sprite = createPreviewSprite(self, shapeid)
        if not sprite then
            LogErr("EquipDialog.InitSpriteModel failed to create preview sprite")
            return
        end
        clearPreviewCaches(self)
    end

	self:UpdataModel();
end

function CEquipDialog:SetFootprint(id)
	if (id == self.m_footprint) then
		return;
	end
	self.m_footprint = id;
	if (self.m_pFootprintEffect) then
		gGetGameUIManager():RemoveUIEffect(self.m_pFootprintEffect);
		self.m_pFootprintEffect = nil;
	end
end
function CEquipDialog:GetMBagOffset()
	return GetBagOffset()
end
function CEquipDialog.GetSingleton()
	return CEquipDialog:getInstance();
end
function CEquipDialog:getInstance()
	if not self._instance then
		self._instance = CEquipDialog.new();
		self._instance:OnCreate();
	end
	return self._instance;
end

function CEquipDialog:getInstanceOrNot()
    return self._instance
end

function CEquipDialog.GetPreviewConfig()
    return {
        model = isPreviewEnabled("model", true),
        components = isPreviewEnabled("components", true),
        horse = isPreviewEnabled("horse", true),
        effects = isPreviewEnabled("effects", false),
        equip_weapon_first = isPreviewEnabled("equip_weapon_first", false)
    }
end

local function applyPreviewConfigValue(key, value, defaultValue)
    if value ~= nil then
        local flag = toBoolean(value, defaultValue)
        EQUIP_PREVIEW_CONFIG[key] = flag
        if key == "equip_weapon_first" and _G then
            _G.FASHION_WEAPON_EQUIP_FIRST = flag
        end
    end
end

function CEquipDialog.DebugSetPreviewConfig(model, components, horse, effects, refreshNow, equipWeaponFirst)
    applyPreviewConfigValue("model", model, true)
    applyPreviewConfigValue("components", components, true)
    applyPreviewConfigValue("horse", horse, true)
    applyPreviewConfigValue("effects", effects, false)
    applyPreviewConfigValue("equip_weapon_first", equipWeaponFirst, false)

    local needRefresh = toBoolean(refreshNow, true)
    local instance = CEquipDialog:getInstanceOrNot()
    if instance and needRefresh then
        instance:InitSpriteModel()
        instance:UpdataModel()
        if isPreviewEnabled("effects", false) then
            instance:InitEquipEffect()
        else
            instance:removeEquipEffect()
        end
    end

    local cfg = CEquipDialog.GetPreviewConfig()
    LogInfo(string.format("EquipPreviewConfig model=%s components=%s horse=%s effects=%s equip_weapon_first=%s",
        tostring(cfg.model), tostring(cfg.components), tostring(cfg.horse), tostring(cfg.effects), tostring(cfg.equip_weapon_first)))
    return cfg
end

function EquipPreviewSet(model, components, horse, effects, refreshNow, equipWeaponFirst)
    return CEquipDialog.DebugSetPreviewConfig(model, components, horse, effects, refreshNow, equipWeaponFirst)
end

function EquipPreviewSetEquipWeaponFirst(enable, refreshNow)
    return CEquipDialog.DebugSetPreviewConfig(nil, nil, nil, nil, refreshNow, enable)
end

function EquipPreviewStatus()
    local cfg = CEquipDialog.GetPreviewConfig()
    LogInfo(string.format("EquipPreviewStatus model=%s components=%s horse=%s effects=%s equip_weapon_first=%s",
        tostring(cfg.model), tostring(cfg.components), tostring(cfg.horse), tostring(cfg.effects), tostring(cfg.equip_weapon_first)))
    return cfg
end

function CEquipDialog:OnCreate()
	self.mEventMapChangeFunctor = gGetScene().EventMapChange:InsertScriptFunctor( function()
		self:OnMapChange();
	end );

    local previewCfg = CEquipDialog.GetPreviewConfig()
    LogInfo(string.format("EquipDialog.OnCreate preview model=%s components=%s horse=%s effects=%s equip_weapon_first=%s",
        tostring(previewCfg.model), tostring(previewCfg.components), tostring(previewCfg.horse), tostring(previewCfg.effects), tostring(previewCfg.equip_weapon_first)))

	local winMgr = CEGUI.WindowManager:getSingleton();

	self.m_pSpriteBack = CEGUI.toWindow(winMgr:getWindow("EquipDialog/spriteBack"));
	self.m_pEquipWindowBack = CEGUI.toWindow(winMgr:getWindow("EquipDialog/Back/Pattern"));
	self.m_pEquipWindowBack:setMousePassThroughEnabled(true);

	self.m_pSpriteBack:setAlwaysOnTop(true);


	self.m_TotalScore = CEGUI.toWindow(winMgr:getWindow("EquipDialog/point"));
	self.m_TotalJewelryScore = CEGUI.toWindow(winMgr:getWindow("EquipDialog/ring"));
	
	self.clearequip = CEGUI.toPushButton(winMgr:getWindow("EquipDialog/Back/Pattern/clearequip"));
	self.clearequip:subscribeEvent(CEGUI.PushButton.EventClicked, CEquipDialog.HandleClearEquipBtnClick, self);
	
	self.xc_xingpan = CEGUI.toPushButton(winMgr:getWindow("EquipDialog/xcxingpan")); -- 星盘按钮
	self.xc_xingpan:subscribeEvent(CEGUI.PushButton.EventClicked, CEquipDialog.HandleXingPanClick, self); -- 星盘
	--self.xc_xingpan:setVisible(false) -- 暂时隐藏
	
    self.cc_jiemianc1 = winMgr:getWindow("EquipDialog/Back/Pattern/ccjiemian1")
    self.cc_jiemianc2 = winMgr:getWindow("EquipDialog/Back/Pattern/ccjiemian2")
    self.cc_jiemianc2:setVisible(false)  -- 隐藏
    local fashionPaneName = "EquipDialog/Back/Pattern/ccjiemian2"
    if winMgr:isWindowPresent("EquipDialog/Back/Pattern/fashion") then
        fashionPaneName = "EquipDialog/Back/Pattern/fashion"
    end
	self.fashionplane = CEGUI.toWindow(winMgr:getWindow(fashionPaneName));

    self.cc_zbbtn1 = CEGUI.toPushButton(winMgr:getWindow("MainPackDlg/ccbtn1"))
    self.cc_zbbtn2 = CEGUI.toPushButton(winMgr:getWindow("MainPackDlg/ccbtn2"))
    self.cc_zbbtn2:setVisible(false)   -- 隐藏

    -- 绑定
    self.cc_zbbtn1:subscribeEvent("Clicked", function() 
    self:switchInterface(self.cc_jiemianc2, "pane1Expand") --  法宝
    end, self) 

    self.cc_zbbtn2:subscribeEvent("Clicked", function() 
    self:switchInterface(self.cc_jiemianc1, "pane0Expand") --  装备
    end, self) 
	
    self.m_TotalVipScore = CEGUI.toWindow(winMgr:getWindow("EquipDialog/vippoint"));
	self.m_pEquipCell[eEquipType_CUFF] = nil -- 当前布局未提供袖箭格子
	self.m_pEquipCell[eEquipType_ADORN] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/adorn"));
	self.m_pEquipCell[eEquipType_LORICAE] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/loricae"));
	self.m_pEquipCell[eEquipType_ARMS] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/arms"));
	self.m_pEquipCell[eEquipType_TIRE] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/tire"));
	self.m_pEquipCell[eEquipType_CLOAK] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/cloak"));---星环 已弃用
	self.m_pEquipCell[eEquipType_BOOT] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/boot"));---不知道是啥
	self.m_pEquipCell[eEquipType_WAISTBAND] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/waistband"));
	self.m_pEquipCell[eEquipType_EYEPATCH] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/extern01"));---经脉1
	self.m_pEquipCell[eEquipType_RESPIRATOR] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/extern02"));---宠物法宝
	self.m_pEquipCell[eEquipType_VEIL] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/extern03"));
	self.m_pEquipCell[eEquipType_FASHION] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/extern04"));
	self.m_pEquipCell[eEquipType_FASHION1] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/fashion1"));---法宝2---金甲
	self.m_pEquipCell[eEquipType_FASHION2] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/fashion2"));---法宝4---风袋
	self.m_pEquipCell[eEquipType_FASHION3] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/fashion3"));---法宝3----斗篷
	self.m_pEquipCell[eEquipType_FASHION4] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/fashion4"));---法宝1---飞剑之类的
	self.m_pEquipCell[eEquipType_FASHION5] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/cloak1"));---坐骑
	self.m_pEquipCell[eEquipType_new1] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/new1"));
	self.m_pEquipCell[eEquipType_new2] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/new2"));
	self.m_pEquipCell[eEquipType_new3] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/new3"));
	self.m_pEquipCell[eEquipType_new4] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/new4"));
	

	self.m_ItemTable = GameItemTable:new(fire.pb.item.BagTypes.EQUIP);

	for index = 0, EQUIPNUM - 1 do
		if (self.m_pEquipCell[index]) then
			self.m_pEquipCell[index]:SetIndex(index);
			self.m_pEquipCell[index]:SetHaveSelectedState(true);
			self.m_pEquipCell[index]:SetCellTypeMask(1);
			self.m_pEquipCell[index]:subscribeEvent(CEGUI.ItemCell.EventCellClick, GameItemTable.HandleShowToolTips, self.m_ItemTable);
			self.m_pEquipCell[index]:subscribeEvent(CEGUI.ItemCell.EventCellClick, CMainPackDlg.HandleShowSelect, self);
			self.m_pEquipCell[index]:subscribeEvent(CEGUI.ItemCell.EventCellDoubleClick, CEquipDialog.HandleTableDoubleClick, self);
			self.m_pEquipCell[index]:subscribeEvent(CEGUI.ItemCell.EventCellDoubleClick, CMainPackDlg.HandleShowSelect, CMainPackDlg:getInstanceOrNot());
		end
	end
	--self.m_pEquipCell[eEquipType_CUFF]:SetBackGroundImage("common_pack", "kuang96");
	self.m_pEquipCell[eEquipType_ADORN]:SetBackGroundImage("ccui1", "kuang2");
	self.m_pEquipCell[eEquipType_ADORN]:SetImage("ccui1", "shipin");--项链
	self.m_pEquipCell[eEquipType_LORICAE]:SetBackGroundImage("ccui1", "kuang2");
	self.m_pEquipCell[eEquipType_LORICAE]:SetImage("ccui1", "yifu");--衣服
	self.m_pEquipCell[eEquipType_ARMS]:SetBackGroundImage("ccui1", "kuang2");
	self.m_pEquipCell[eEquipType_ARMS]:SetImage("ccui1", "wuqi");--武器
	self.m_pEquipCell[eEquipType_TIRE]:SetBackGroundImage("ccui1", "kuang2");
	self.m_pEquipCell[eEquipType_TIRE]:SetImage("ccui1", "toubu");--头盔
	self.m_pEquipCell[eEquipType_CLOAK]:SetBackGroundImage("ccui1", "xingying2");---师门法宝--改为星环
	self.m_pEquipCell[eEquipType_CLOAK]:SetImage("ccui1", "xingying2");
	self.m_pEquipCell[eEquipType_BOOT]:SetBackGroundImage("ccui1", "kuang2");
	self.m_pEquipCell[eEquipType_BOOT]:SetImage("ccui1", "jiao");--鞋子
	self.m_pEquipCell[eEquipType_WAISTBAND]:SetBackGroundImage("ccui1", "kuang2");
	self.m_pEquipCell[eEquipType_WAISTBAND]:SetImage("ccui1", "yaodai");--腰带
	self.m_pEquipCell[eEquipType_EYEPATCH]:SetBackGroundImage("ccui1", "jmkuang1");----经脉1
	self.m_pEquipCell[eEquipType_EYEPATCH]:SetImage("ccui1", "xinghuang");
	self.m_pEquipCell[eEquipType_RESPIRATOR]:SetBackGroundImage("ccui1", "jmkuang2");---经脉2
	self.m_pEquipCell[eEquipType_RESPIRATOR]:SetImage("ccui1", "xinghuang");
	self.m_pEquipCell[eEquipType_VEIL]:SetBackGroundImage("ccui1", "kuang2");
	self.m_pEquipCell[eEquipType_VEIL]:SetImage("ccui1", "fabao");
	self.m_pEquipCell[eEquipType_FASHION]:SetBackGroundImage("ccui1", "kuang2");
	self.m_pEquipCell[eEquipType_FASHION]:SetImage("ccui1", "fabao");
	self.m_pEquipCell[eEquipType_FASHION1]:SetBackGroundImage("ccui1", "fabaokuang");---法宝
	self.m_pEquipCell[eEquipType_FASHION1]:SetImage("ccui1", "fabao");
	self.m_pEquipCell[eEquipType_FASHION2]:SetBackGroundImage("ccui1", "fabaokuang");---法宝
	self.m_pEquipCell[eEquipType_FASHION2]:SetImage("ccui1", "fabao");
	self.m_pEquipCell[eEquipType_FASHION3]:SetBackGroundImage("ccui1", "fabaokuang");---法宝
	self.m_pEquipCell[eEquipType_FASHION3]:SetImage("ccui1", "fabao");
	self.m_pEquipCell[eEquipType_FASHION4]:SetBackGroundImage("ccui1", "fabaokuang");---法宝
	self.m_pEquipCell[eEquipType_FASHION4]:SetImage("ccui1", "fabao");
	self.m_pEquipCell[eEquipType_FASHION5]:SetBackGroundImage("ccui1", "kuang2");---坐骑
	self.m_pEquipCell[eEquipType_FASHION5]:SetImage("ccui1", "zuoqi");---坐骑
	self.m_pEquipCell[eEquipType_new1]:SetBackGroundImage("ccui1", "kuang2");
	self.m_pEquipCell[eEquipType_new1]:SetImage("renwuui", "shipin");
	self.m_pEquipCell[eEquipType_new2]:SetBackGroundImage("ccui1", "kuang2");
	self.m_pEquipCell[eEquipType_new2]:SetImage("renwuui", "shipin");
	self.m_pEquipCell[eEquipType_new3]:SetBackGroundImage("ccui1", "kuang2");
	self.m_pEquipCell[eEquipType_new3]:SetImage("renwuui", "shipin");
	self.m_pEquipCell[eEquipType_new4]:SetBackGroundImage("ccui1", "kuang2");
	self.m_pEquipCell[eEquipType_new4]:SetImage("renwuui", "shipin");

	self.m_pEquipStarEffect = CEGUI.toGUISheet(winMgr:getWindow("EquipDialog/Back/SpriteEffectTop"));
	self.m_pEquipStarEffect:setMousePassThroughEnabled(true);
	local pEffect = GameUImanager:createXPRenderEffect(0, function(id)
		local pMainPackDlg = CMainPackDlg:getInstanceOrNot();
		if (pMainPackDlg) then
			pMainPackDlg:HandleDrawSprite();
		end
	end );
	self.m_pSpriteBack:getGeometryBuffer():setRenderEffect(pEffect);
    if isPreviewEnabled("effects", false) then
	    gGetGameUIManager():AddUIEffect(CEGUI.toWindow(winMgr:getWindow("EquipDialog/point1")), MHSD_UTILS.get_effectpath(10242), true);
    end

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    roleItemManager:InitBagItem(fire.pb.item.BagTypes.EQUIP);

	self:InitSpriteModel();

	self:UpdateTotalScore();

	self:InitEquipEffect();

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local pItem = roleItemManager:getItem(self.m_pEquipCell[eEquipType_EYEPATCH]:getID2(), fire.pb.item.BagTypes.EQUIP)
	--if pItem then
	--	if (pItem:GetSecondType() == eEquipType_VEIL) then
	--		self.m_pEquipCell[eEquipType_RESPIRATOR]:SetBackGroundImage("ccui1", "kuang2");
	--	end
	--end
end
function CEquipDialog:HandleXingPanClick()
	require "logic.xingpan.xingpandlg".getInstanceAndShow()
end
function CEquipDialog:OnMapChange()
end
function CEquipDialog:HandleJinmaiBtnClick()
	if self.m_pPackEquipEffect or self.m_pEquipUISprite or self.m_pFootprintEffect then
		self:DestroyDialog()
		self.botton:setText(tostring("主角"))
		if self.fashionplane then
			self.fashionplane:setVisible(true)
		end
	else
		self:InitSpriteModel()
		self:InitEquipEffect();
		self.botton:setText(tostring("时装"))
		if self.fashionplane then
			self.fashionplane:setVisible(false)
		end
	end
end

function CEquipDialog:switchInterface(targetPane, animationName)
    --  界面
    self.cc_jiemianc1:setVisible(false)
    self.cc_jiemianc2:setVisible(false)

    --  按钮
    self.cc_zbbtn1:setVisible(not self.cc_zbbtn1:isVisible())
    self.cc_zbbtn2:setVisible(not self.cc_zbbtn2:isVisible())

    targetPane:setVisible(true)
	
    local expandAnimation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationName)
    expandAnimation:setTargetWindow(targetPane)
    expandAnimation:start() 
end

function CEquipDialog:HandleClearEquipBtnClick()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local bagInfo = roleItemManager:GetBagInfo()
	local list = bagInfo[fire.pb.item.BagTypes.EQUIP]
	if not list then 
		return
	end
   local p =require "protodef.fire.pb.item.coffallequip":new()
   LuaProtocolManager.getInstance():send(p)
end

function CEquipDialog:DestroyDialog()
    destroyPreviewSprite(self)
    clearPreviewCaches(self)
	if (self.m_pFootprintEffect) then
		gGetGameUIManager():RemoveUIEffect(self.m_pFootprintEffect);
		self.m_pFootprintEffect = nil;
	end
	self:removeEventMapChangeFunctor();
end

function CEquipDialog:delete()
	self:removeEventMapChangeFunctor();
end

function CEquipDialog.new(parent)
	local obj = { };
	setmetatable(obj, CEquipDialog);

	obj.m_pEquipUISprite = nil;
	obj.m_footprint = 0;
	obj.m_pFootprintEffect = nil;
	obj.m_pPackEquipEffect = nil;
	obj.m_pParentWindow = parent;
	obj.mEventMapChangeFunctor = nil;
    obj.m_lastPreviewWeapon = nil
    obj.m_lastPreviewHorse = nil
	obj.m_lastPreviewDyeA = nil
    obj.m_lastPreviewDyeB = nil
    obj.m_previewSpriteKind = nil
    obj.m_previewShapeId = nil

	return obj;
end

return CEquipDialog;
