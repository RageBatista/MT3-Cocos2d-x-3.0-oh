
require "utils.mhsdutils"

Mainpackhelper = { }

function Mainpackhelper.clickConfirmBoxCancel_fenjiegem()
	local bSendCancelEvent = false
	gGetMessageManager():CloseConfirmBox(eConfirmNormal, bSendCancelEvent)
end

function Mainpackhelper.clickConfirmBoxOk_fenjiegem()
	local bSendCancelEvent = false
	gGetMessageManager():CloseConfirmBox(eConfirmNormal, bSendCancelEvent)


	local p = require "protodef.fire.pb.product.cresolvegem":new()
	p.itemkey = Mainpackhelper.nItemKey_fenjiegem
	require "manager.luaprotocolmanager":send(p)
end

function Mainpackhelper.showFenjieGem(pRoleItem)


	if not pRoleItem then
		return
	end

	local itemAttrTable = pRoleItem:GetBaseObject()
	local nItemId = itemAttrTable.id
	local nItemKey = pRoleItem:GetThisID()

	local gemTable = BeanConfigManager.getInstance():GetTableByName("item.cgemeffect"):getRecorder(nItemId)
	if not gemTable then
		return
	end

	local nFenjieItemId = gemTable.nfenjieid
	local nFenjieItemNum = gemTable.nfenjienum

	local fenjieItemTable = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nFenjieItemId)
	local strFenjieItemName = ""
	if fenjieItemTable then
		strFenjieItemName = fenjieItemTable.name
	end

	local strMsg = require "utils.mhsdutils".get_msgtipstring(160384)

	local sb = StringBuilder.new()
	sb:Set("Parameter1", tostring(nFenjieItemNum))
	sb:Set("Parameter2", strFenjieItemName)
	strMsg = sb:GetString(strMsg)
	sb:delete()


	local msgManager = gGetMessageManager()


	Mainpackhelper.nItemKey_fenjiegem = nItemKey

	gGetMessageManager():AddConfirmBox(eConfirmNormal,
	strMsg,
	Mainpackhelper.clickConfirmBoxOk_fenjiegem,
	Mainpackhelper,
	Mainpackhelper.clickConfirmBoxCancel_fenjiegem,
	Mainpackhelper)

	require("logic.tips.commontipdlg").DestroyDialog()

end

function Mainpackhelper.replaceGemResult(bReplace)

	local nReplace = 0
	if bReplace == true then
		nReplace = 1
	end
	local msgManager = gGetMessageManager()
	local nSrcKey = msgManager.nSrcKey
	local nDesKey = msgManager.nDesKey

	nSrcKey = Mainpackhelper.nSrcKey
	nDesKey = Mainpackhelper.nDesKey

	local bSendCancelEvent = false
	gGetMessageManager():CloseConfirmBox(eConfirmNormal, bSendCancelEvent)

	if nSrcKey == nil or nDesKey == nil
	then
		return
	end



	local p = require "protodef.fire.pb.item.creplacegem":new()
	p.ret = nReplace
	p.srckey = nSrcKey
	p.deskey = nDesKey
	require "manager.luaprotocolmanager":send(p)
end

function Mainpackhelper.clickConfirmBoxCancel_sreplacegem()
	Mainpackhelper.replaceGemResult(false)
end

function Mainpackhelper.clickConfirmBoxOk_sreplacegem()


	local msgManager = gGetMessageManager()
	local nSrcKey = msgManager.nSrcKey
	local nDesKey = msgManager.nDesKey

	Mainpackhelper.replaceGemResult(true)

end

function Mainpackhelper.sreplacegem_process(protocol)
	local nSrcKey = protocol.srckey
	local nDesKey = protocol.deskey


	local strMsg = require "utils.mhsdutils".get_msgtipstring(160066)
	local msgManager = gGetMessageManager()
	msgManager.nSrcKey = nSrcKey
	msgManager.nDesKey = nDesKey

	Mainpackhelper.nSrcKey = nSrcKey
	Mainpackhelper.nDesKey = nDesKey

	gGetMessageManager():AddConfirmBox(eConfirmNormal,
	strMsg,
	Mainpackhelper.clickConfirmBoxOk_sreplacegem,
	Mainpackhelper,
	Mainpackhelper.clickConfirmBoxCancel_sreplacegem,
	Mainpackhelper)

	require("logic.tips.commontipdlg").DestroyDialog()

end

function Mainpackhelper.suseenhancementitem_process(protocol)
	local nSecondType = protocol.equippos

	local pEquipItem = require("logic.tips.commontiphelper").getEquipItemWithSecondType(nSecondType)
	if not pEquipItem then
		return
	end

	local bagDlg = CMainPackDlg:GetSingleton()
	if not bagDlg then
		return
	end

	local pEquipCell = bagDlg:GetEquipItemCellByPos(nSecondType)
	if not pEquipCell then
		return
	end

	local nPosX = 0
	local nPosY = 0

	local bCycle = false
	local bClicp = false
	local strEffectPath = require("utils.mhsdutils").get_effectpath(11040)

	local pWin = CEGUI.toItemCell(pEquipCell)


	gGetGameUIManager():AddUIEffect(pWin, strEffectPath, bCycle, nPosX, nPosY, bClicp)

	local nItemKey = pEquipItem:GetThisID()

	require "protodef.fire.pb.item.cgetitemtips"
	local p = CGetItemTips.Create()
	p.packid = fire.pb.item.BagTypes.EQUIP
	p.keyinpack = nItemKey
	LuaProtocolManager.getInstance():send(p)

end

function Mainpackhelper.addEffectOnCell(pRoleItem, nEffectId)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local itemcell = roleItemManager:GetItemCellByLoc(pRoleItem:GetLocation())
	if itemcell then

		local strEffectPath = require("utils.mhsdutils").get_effectpath(nEffectId)

		local bCycle = true
		local nPosX = 0
		local nPosY = 0
		local bClicp = true
		local bBounds = true
		gGetGameUIManager():AddParticalEffect(itemcell, strEffectPath, bCycle, nPosX, nPosY, bClicp, bBounds)
	end
end


function Mainpackhelper.isInArea(nEquipLevel)

	local nUserLevel = gGetDataManager():GetMainCharacterLevel()
	local nLevelIndex = nUserLevel

	local nArea = math.floor(nLevelIndex / 10)
	nArea = nArea * 10
	if nArea == 0 then
		nArea = 1
	end
	if nEquipLevel == nArea then
		return true
	end
	return false

end



function Mainpackhelper.isNeedShowEffectOnCell(nTableId)



	local equipAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipitemattr"):getRecorder(nTableId)
	local needItemCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nTableId)
	if not equipAttrCfg then
		return false
	end
	if not needItemCfg then
		return false
	end

	if equipAttrCfg.nautoeffect ~= 1 then
		return false
	end


	local nEquipLevel = needItemCfg.level
	local bInArea = Mainpackhelper.isInArea(nEquipLevel)

	if bInArea == true then
		return true
	end
	return false
end



function Mainpackhelper.refreshCellEffect(nItemKey, nIgnoreItemKeyInEquip)
	local nIgnoreItemKey = nItemKey

	gGetGameUIManager():RemoveAllBoundsEffect()

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()

	local vItemKeyAll = roleItemManager:GetItemKeyListByBag(fire.pb.item.BagTypes.BAG)
	for i = 0, vItemKeyAll:size() -1 do
		local nItemKey = vItemKeyAll[i]
		if nIgnoreItemKey ~= nItemKey then
			local pRoleItem = roleItemManager:FindItemByBagAndThisID(nItemKey, fire.pb.item.BagTypes.BAG)
			if pRoleItem then
				local nTableId = pRoleItem:GetObjectID()
				local bShow = Mainpackhelper.isNeedShowEffectOnCell(nTableId)

				if bShow == true then
					local bSameLevelInEquip = Mainpackhelper.isHaveEquipInBodyAndLevelSame(pRoleItem, nIgnoreItemKeyInEquip)
					if bSameLevelInEquip == false then
						local nEffectId = 10068
						Mainpackhelper.addEffectOnCell(pRoleItem, nEffectId)
					end

				end
			end
		end

	end

end

function Mainpackhelper.getFirstNeedShowEffectItem(nIgnoreItemKeyInBag)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local vItemKeyAll = roleItemManager:GetItemKeyListByBag(fire.pb.item.BagTypes.BAG)
	for i = 0, vItemKeyAll:size() -1 do
		local nItemKey = vItemKeyAll[i]
		if nIgnoreItemKeyInBag ~= nItemKey then
			local pRoleItem = roleItemManager:FindItemByBagAndThisID(nItemKey, fire.pb.item.BagTypes.BAG)
			if pRoleItem then
				local nTableId = pRoleItem:GetObjectID()
				local bShow = Mainpackhelper.isNeedShowEffectOnCell(nTableId)
				if bShow == true then
					local nIgnoreItemKeyInEquip = nil
					local bSameLevelInEquip = Mainpackhelper.isHaveEquipInBodyAndLevelSame(pRoleItem, nIgnoreItemKeyInEquip)
					if bSameLevelInEquip == false then
						return pRoleItem
					end

				end
			end
		end
	end
	return nil
end

function Mainpackhelper.eventDelBagItem(nDelItemKeyInBag)

	Mainpackhelper.refreshCellEffect(nDelItemKeyInBag)
	if Mainpackhelper.isInBagUI() == false then
		return
	end
	Mainpackhelper.showNextEquipToTip(nDelItemKeyInBag)
end

function Mainpackhelper.eventAddBagItem(nItemKey)
	local nIgnoreItemKey = nil
	Mainpackhelper.refreshCellEffect(nIgnoreItemKey)
	if Mainpackhelper.isInBagUI() == false then
		return
	end

end

function Mainpackhelper.eventDelEquipItem(nItemKey)
	if Mainpackhelper.isInBagUI() == false then
		return
	end
	local nIgnoreItemKey = nil
	local nIgnoreItemKeyInEquip = nItemKey
	Mainpackhelper.refreshCellEffect(nIgnoreItemKey, nIgnoreItemKeyInEquip)
end

function Mainpackhelper.showNextEquipToTip(nDelItemKeyInBag)

	local bCurAuto = Mainpackhelper.isNeedShowAutoEffect(nDelItemKeyInBag)
	if bCurAuto == false then
		return
	end
	local nIgnoreItemKey = nDelItemKeyInBag

	local pItem = Mainpackhelper.getFirstNeedShowEffectItem(nIgnoreItemKey)
	if not pItem then
		return
	end
	local commontip = Commontipdlg.getInstanceAndShow()
	commontip.nBagId = fire.pb.item.BagTypes.BAG
	commontip.nItemKey = pItem:GetThisID()

	local nItemId = pItem:GetObjectID()
	local pObj = pItem:GetObject()
	local nCellPosX = 0
	local nCellPosY = 0
	commontip:refreshItemForBeibao(nItemId, pObj, nCellPosX, nCellPosY)
end

function Mainpackhelper.isNeedShowAutoEffect(nItemKeyInBag)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local pRoleItem = roleItemManager:FindItemByBagAndThisID(nItemKeyInBag, fire.pb.item.BagTypes.BAG)
	if pRoleItem then
		local nTableId = pRoleItem:GetObjectID()
		local bShow = Mainpackhelper.isNeedShowEffectOnCell(nTableId)
		return bShow
	end
	return false
end

function Mainpackhelper.isHaveEquipInBodyAndLevelSame(roleItemInBag, nIgnoreItemKeyInEquip)

	local nItemId = roleItemInBag:GetBaseObject().id

	local itemTable = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemTable then
		return false
	end

	local nItemLevel = itemTable.level
	local pItemInBody = require("logic.tips.commontiphelper").getEquipInBodySameComponent(nItemId)
	if pItemInBody then
		local nItemKeyInBody = pItemInBody:GetThisID()
		local nItemLevelInBody = pItemInBody:GetBaseObject().level
		if nIgnoreItemKeyInEquip then
			if nItemLevel == nItemLevelInBody and nItemKeyInBody ~= nIgnoreItemKeyInEquip then
				return true
			end
		else
			if nItemLevel == nItemLevelInBody then
				return true
			end
		end

	end
	return false
end

function Mainpackhelper.isInBagUI()
	local bagDlg = CMainPackDlg:GetSingleton()
	if not bagDlg then
		return false
	end

	local bShowDepot = require("logic.item.depot").isShowing()
	if bShowDepot == true then
		return false
	end
	return true

end

function Mainpackhelper.eventAddEquipItem(nItemKey)

	local nIgnoreItemKey = nil
	Mainpackhelper.refreshCellEffect(nIgnoreItemKey)
end

function Mainpackhelper.DestroyEnd()
	gGetRoleItemManager().m_EventAddPackItem:RemoveScriptFunctor(Mainpackhelper.handle_AddBagItem)
	gGetRoleItemManager().m_EventDelBagItem:RemoveScriptFunctor(Mainpackhelper.handle_DelBagItem)

	gGetRoleItemManager().m_EventAddEquipItem:RemoveScriptFunctor(Mainpackhelper.handle_AddEquipItem)
	gGetRoleItemManager().m_EventDelEquipItem:RemoveScriptFunctor(Mainpackhelper.handle_DelEquipItem)
end

function Mainpackhelper.OnCreateEnd()
	local nIgnoreItemKey = nil
	Mainpackhelper.refreshCellEffect(nIgnoreItemKey)

	Mainpackhelper.handle_AddBagItem = gGetRoleItemManager().m_EventAddPackItem:InsertScriptFunctor(Mainpackhelper.eventAddBagItem)
	Mainpackhelper.handle_DelBagItem = gGetRoleItemManager().m_EventDelBagItem:InsertScriptFunctor(Mainpackhelper.eventDelBagItem)


	Mainpackhelper.handle_AddEquipItem = gGetRoleItemManager().m_EventAddEquipItem:InsertScriptFunctor(Mainpackhelper.eventAddEquipItem)
	Mainpackhelper.handle_DelEquipItem = gGetRoleItemManager().m_EventDelEquipItem:InsertScriptFunctor(Mainpackhelper.eventDelEquipItem)

	local p = require "protodef.fire.pb.item.copenitembag":new()
	require "manager.luaprotocolmanager":send(p)
end



return Mainpackhelper
