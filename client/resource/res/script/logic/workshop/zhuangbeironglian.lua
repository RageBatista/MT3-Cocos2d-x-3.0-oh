require "utils.mhsdutils"
require "logic.dialog"
require "logic.workshop.workshopitemcell"
require "logic.workshop.workshophelper"

require "utils.commonutil"

RongLianDlg = {}
setmetatable(RongLianDlg, Dialog)
RongLianDlg.__index = RongLianDlg
local _instance;


function RongLianDlg.OnDzResult()
	LogInfo("RongLianDlg.OnDzResult()")
	if not _instance then
		return
	end
	if _instance.bLoadUI then
		_instance:RefreshEquipList()
		_instance:RefreshEquipCellSel()
		_instance:RefreshEquip()
		_instance:SendRequestAllEndure()
	end

end


function RongLianDlg:RefreshItemTips(item)
	LogInfo("RongLianDlg.RefreshItemTips")
	local bUseLocal = true  
	self:RefreshRichBox(bUseLocal)
end



function RongLianDlg.OnFailTimesResult(protocol)
	
	if not _instance then
		return
	end
	local nServerKey = protocol.keyinpack
	local nBagId = protocol.packid
	
	local nFailTime =  protocol.failtimes
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local equipData = roleItemManager:FindItemByBagAndThisID(nServerKey,nBagId)
	if equipData then
		 equipData:SetRepairFailCount(nFailTime)
	end
	_instance:RefreshEquip()
	local bUseLocal = true  
	_instance:RefreshRichBox(bUseLocal)
	
	_instance:RefreshEquipListState()
	
	
	
end

function RongLianDlg.OnRefreshAllResult(protocol)
	LogInfo(" RongLianDlg.OnRefreshAllResult(protocol)")
	if not _instance then
		return
	end
	_instance:RefreshEquip()
	_instance:RefreshEquipListState()
end



function RongLianDlg.OnXlResult()
	if not _instance then
		return
	end

	_instance:RefreshRichBox(false)
	--_instance:RefreshEquipList()
	_instance:RefreshEquipListState()

	_instance:RefreshEquip()

end


function RongLianDlg.OnRefreshOneItemInfoResult(protocol)
	LogInfo("RongLianDlg.OnRefreshOneItemInfoResult")
	if not _instance then
		return
	end
	_instance:RefreshEquip()
end



function RongLianDlg:OnCreate()
    Dialog.OnCreate(self)
	SetPositionOfWindowWithLabel(self:GetWindow())
	self.m_hItemNumChangeNotify = gGetRoleItemManager():InsertLuaItemNumChangeNotify(RongLianDlg.OnItemNumChange)
	self.m_hPackMoneyChange = gGetRoleItemManager().m_EventPackMoneyChange:InsertScriptFunctor(RongLianDlg.OnMoneyChange)
	self:InitUI()
	self.bLoadUI = true
	self:RefreshEquipList()
	self:RefreshEquipCellSel()
	self:RefreshEquip()

	--self:RefreshTwoBtnSel()
    self:ResetEquip()
end


function RongLianDlg.AddItemInBag(nItemKey)
	if not _instance then
		return
	end
	
end

function RongLianDlg.DelItemInBag(nItemKey)
	if not _instance then
		return
	end
end

function RongLianDlg.AddItemInEquipBag(nItemKey)
	if not _instance then
		return
	end
end

function RongLianDlg.DelItemInEquipBag(nItemKey)
	if not _instance then
		return
	end
end


function RongLianDlg.OnMoneyChange()
	if not _instance then
		return
	end
	_instance:RefreshNeedMoneyLabel()
end

function RongLianDlg:AddCell(eBagType,nItemKey)
	
end

function RongLianDlg:DeleteCell(eBagType,nItemKey)
	
end

function RongLianDlg:RefreshAllCellSortData()
end


function RongLianDlg:SortAllCell()
end

function RongLianDlg:RefreshAllCellPos()
end


function RongLianDlg.OnItemNumChange(eBagType, nItemKey, nItemId)
	if _instance == nil then
		return
	end
	_instance:RefreshEquip()
end


function RongLianDlg:RefreshUI(nBagId,nItemKey)
    if not nBagId then
        nBagId = -1
        nItemKey = -1
    end
	self:RefreshEquipList(nBagId,nItemKey)
	self:RefreshEquipCellSel()
	self:RefreshEquip()
	self:SendRequestAllEndure()
	--self:RefreshTwoBtnSel()
end

function RongLianDlg:InitUI()
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.ScrollEquip = CEGUI.toScrollablePane(winMgr:getWindow("l/left"))
	self.ScrollEquip:setMousePassThroughEnabled(true)
	self.ScrollEquip:subscribeEvent("NextPage", RongLianDlg.OnNextPage, self)
	self.ItemCellTarget = CEGUI.toItemCell(winMgr:getWindow("l/right/part2/item2"))
	self.ImageTargetCanMake = winMgr:getWindow("l/right/part2/item2/yizhuangbei") 
	self.LabTargetName = winMgr:getWindow("l/right/part2/name2") 
	self.richBoxEquip = CEGUI.toRichEditbox(winMgr:getWindow("l/right/shuxinglist/box"))
	self.richBoxEquip:subscribeEvent("MouseButtonUp", RongLianDlg.HandlBtnClickInfoClose) 

	self.richBoxEquip:setReadOnly(true)
	
	
	self.btnInfo = CEGUI.toPushButton(winMgr:getWindow("l/right/shuxinglist/tipsxiangqing"))
	self.btnInfo:subscribeEvent("MouseButtonDown", RongLianDlg.PreHandlBtnClickInfo, self) 
    self.btnInfo:subscribeEvent("MouseButtonUp", RongLianDlg.HandlBtnClickInfo, self) 
	
	
	self.xx = CEGUI.toPushButton(winMgr:getWindow("l"))
	self.xx:subscribeEvent("MouseButtonUp", RongLianDlg.HandlBtnClickInfoClose) 
	self.xx2 = CEGUI.toPushButton(winMgr:getWindow("l/right"))
	self.xx2:subscribeEvent("MouseButtonUp", RongLianDlg.HandlBtnClickInfoClose) 
	self.xx3 = CEGUI.toPushButton(winMgr:getWindow("l/right/part2/line1"))
	self.xx3:subscribeEvent("MouseButtonUp", RongLianDlg.HandlBtnClickInfoClose) 
	self.xx5 = CEGUI.toPushButton(winMgr:getWindow("l/left"))
	self.xx5:subscribeEvent("MouseButtonUp", RongLianDlg.HandlBtnClickInfoClose) 
	
	
	
	self.BtnMake = CEGUI.toGroupButton(winMgr:getWindow("l/right/putongbutton"))

	self.BtnMakeQh = CEGUI.toPushButton(winMgr:getWindow("l/right/teshubutton"))
    self.checkbox = CEGUI.toCheckbox(winMgr:getWindow("l/right/part2/line1/gou"))
    self.checkbox:subscribeEvent("MouseButtonUp", RongLianDlg.CheckBoxStateChanged, self)

	self.ItemCellNeedItem1 = CEGUI.toItemCell(winMgr:getWindow("l/right/cailiaolist/item1"))
	self.LabNameNeedItem1 = winMgr:getWindow("l/right/cailiaolist/name1")
	self.ItemCellNeedItem2 = CEGUI.toItemCell(winMgr:getWindow("l/right/cailiaolist/item2"))
	self.LabNameNeedItem2 = winMgr:getWindow("l/right/cailiaolist/name2")
	self.needMoneyLabel = winMgr:getWindow("l/right/bg1/one") --l/right/bg1/one
	self.ownMoneyLabel = winMgr:getWindow("l/right/bg11/2") --l/right/bg11/2
	self.ImageNeedMoneyIcon = winMgr:getWindow("l/right/yinbi")
	self.ImageOwnMoneyIcon = winMgr:getWindow("l/right/yinbi2")
	self.BtnXl = CEGUI.toPushButton(winMgr:getWindow("l/right/button"))
	self.BtnXl:subscribeEvent("Clicked", RongLianDlg.HandlBtnClickedXl, self)
	self.labelNormalDesc = winMgr:getWindow("l/right/part2/line1/text")
	self.labelNormalDesc:setText(require "utils.mhsdutils".get_resstring(11696))
	self.labelSpecialDesc = winMgr:getWindow("l/right/part2/line1/textteshu1")
	
	self.ItemCellNeedItem1:subscribeEvent("TableClick", Workshopmanager.HandleClickItemCell, Workshopmanager)

    self.BtnExchange = CEGUI.toPushButton(winMgr:getWindow("l/right/jiahao")) --l/right/jiahao
	self.BtnExchange:subscribeEvent("Clicked", RongLianDlg.HandleExchangeBtnClicked, self)
end

function RongLianDlg:HandleExchangeBtnClicked(e)
	local dlg = require "logic.currency.stonegoldexchangesilverdlg".getInstanceAndShow()
	dlg:GetWindow():setAlwaysOnTop(true)

	return true
	
end


 function RongLianDlg:PreHandlBtnClickInfo(e)
 	--防止点击物品关闭表情界面--by yangbin
	local insetdlg = require("logic.chat.insertdlg").getInstanceNotCreate()
	if insetdlg then
		insetdlg.willCheckTipsWnd = true
	end
 end
 
 function RongLianDlg:HandlBtnClickInfoClose()
	local equipDlg = require("logic.tips.equipinfotips").getInstanceAndShow()
	equipDlg:DestroyDialog()
 end

 function RongLianDlg:HandlBtnClickInfo(e)
	self.willCheckTipsWnd = false

	--防止点击物品详情关闭表情界面--by yangbin
	local insetdlg = require("logic.chat.insertdlg").getInstanceNotCreate()
	if insetdlg then
		insetdlg.willCheckTipsWnd = true
	end

    require("logic.tips.equipcomparetipdlg").DestroyDialog()
    
    local equipDlg = require("logic.tips.equipinfotips").getInstanceAndShow()
    equipDlg:RefreshWithItem(self:GetCurEquipData())
    equipDlg:RefreshSize()
 end

function RongLianDlg:GetCurServerKey()
	local cellEquipItem = self:GetCellWithIndex(self.nItemCellSelId)
	if not cellEquipItem then
		return 0
	end
	return cellEquipItem.nServerKey
end


--点化
function RongLianDlg:HandlBtnClickedXl(e)
    -- local bCanXiuli,strResult = self:IsCanXiuli()
	-- if bCanXiuli==false then
	-- 	GetCTipsManager():AddMessageTip(strResult)
	-- 	return 
	-- end
	if GetBattleManager() and GetBattleManager():IsInBattle() then
		local strShowTip = MHSD_UTILS.get_resstring(11693) 
		GetCTipsManager():AddMessageTip(strShowTip)
        return 
    end
	
	--//=======================================

	--//=======================================
	local nEquipKey = self:GetCurServerKey()
	local eBagType = self:GetCurItemBagType()
	
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local equipData = roleItemManager:FindItemByBagAndThisID(nEquipKey,eBagType)
	if equipData then
		local itemAttrCfg = equipData:GetBaseObject()
	    local nEquipId = itemAttrCfg.id
		local equipPropertyCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipitemattr"):getRecorder(nEquipId)
	     if not equipPropertyCfg then
		  return false
	    end
		local nNeedMoney = equipPropertyCfg.equipmoney
		local roleItemManager = require("logic.item.roleitemmanager").getInstance()
		local nUserMoney = roleItemManager:GetGold()
		
		if nUserMoney < nNeedMoney then
			local nMoneyType = fire.pb.game.MoneyType.MoneyType_SilverCoin
			local nShowNeed = nNeedMoney - nUserMoney
		
			CurrencyManager.handleCurrencyNotEnough(nMoneyType, nShowNeed)
			return 
		end
	
	local needItemid =  equipPropertyCfg.equipitemid
	local nNeedItemNum= equipPropertyCfg.equipnum
	local nItemNum = roleItemManager:GetItemNumByBaseID(needItemid)
	if nItemNum < nNeedItemNum then
		GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(191224))
		return
	end

	local p = require "protodef.fire.pb.item.cronglianequipitem":new()
	p.repairtype = 1 --normal
	p.keyinpack = nEquipKey
	local nBagType = eBagType
	p.packid = nBagType --fire.pb.item.BagTypes.BAG
	require "manager.luaprotocolmanager":send(p)
  end
end	

function RongLianDlg:checkShowItemOverNeed()
   local nEquipKey = self:GetCurServerKey()
	local eBagType = self:GetCurItemBagType()

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local pItem = roleItemManager:FindItemByBagAndThisID(nEquipKey,eBagType)
    if not pItem then
        return false
    end
	local itemAttrCfg = pItem:GetBaseObject()
	local nEquipId = itemAttrCfg.id
    local nEquipLevel = itemAttrCfg.level

	local nNeedItemId1,nNeedItemNum1  = self:getXlItemIdAndNeedNum(nEquipId)
    local needItemCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nNeedItemId1)
    if not needItemCfg then
        return false
    end

    if needItemCfg.level <= nEquipLevel then
        return false
    end
    
    local strNeedName = needItemCfg.name

    local strMsg =  require "utils.mhsdutils".get_msgtipstring(160177) 
     local sb = StringBuilder:new()
	sb:Set("parameter1",strNeedName )
    --sb:Set("parameter2", tostring(nStep))
	strMsg = sb:GetString(strMsg)
	sb:delete()

    local msgManager = gGetMessageManager()
		
	gGetMessageManager():AddConfirmBox(eConfirmNormal,
		strMsg,
		self.clickConfirmBoxOk_xl,
	  	self,
	  	self.clickConfirmBoxCancel_xl,
	  	self)
     return true

end

function RongLianDlg:clickConfirmBoxOk_xl()
    gGetMessageManager():CloseConfirmBox(eConfirmNormal,false)
    local nEquipKey = self:GetCurServerKey()
	local eBagType = self:GetCurItemBagType()

    local p = require "protodef.fire.pb.item.cronglianequipitem":new()
	p.repairtype = 1 --normal
	p.keyinpack = nEquipKey
	local nBagType = eBagType
	p.packid = nBagType --fire.pb.item.BagTypes.BAG
	require "manager.luaprotocolmanager":send(p)

end

function RongLianDlg:clickConfirmBoxCancel_xl()
gGetMessageManager():CloseConfirmBox(eConfirmNormal,false)

end

function RongLianDlg:SendRequestAllEndure()
	local p1 = require "protodef.fire.pb.item.creqallnaijiu":new()
	p1.packid = fire.pb.item.BagTypes.BAG
	require "manager.luaprotocolmanager":send(p1)
	local p2 = require "protodef.fire.pb.item.creqallnaijiu":new()
	p2.packid = fire.pb.item.BagTypes.EQUIP
	require "manager.luaprotocolmanager":send(p2)
end



function RongLianDlg:RefreshEquipCellSel()
	for i = 1, #self.vItemCellEquip do 
		local equipCell = self.vItemCellEquip[i]
		if equipCell.nClientKey ~= self.nItemCellSelId then
			equipCell.btnBg:setSelected(false)
		else
			equipCell.btnBg:setSelected(true)
		end	
	end
end

function RongLianDlg:RefreshEquipListState()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	for i = 1, #self.vItemCellEquip do 
		local equipCell = self.vItemCellEquip[i]
		nEquipKey = equipCell.itemCell:getID() 
		eBagType = equipCell.eBagType
		local roleItem = roleItemManager:FindItemByBagAndThisID(nEquipKey,eBagType)
		local nEndure = 0
		if roleItem then
			 nEndure = roleItem:GetEquipScore()
		end
		equipCell.labDurance:setText(tostring(nEndure))
	end
end

function RongLianDlg:OnNextPage(args)
	local wsManager = Workshopmanager.getInstance()
	wsManager.nXilianPage = wsManager.nXilianPage + 1
	local vEquipKeyOrderIndex = {}
    wsManager:ronglianlv(vEquipKeyOrderIndex,wsManager.nXilianPage)--控制点化等级
	local nNewNum = #vEquipKeyOrderIndex
	if nNewNum==0 then
		return
	end
	for nIndex=1,nNewNum do 
		local nEquipOrderIndex = vEquipKeyOrderIndex[nIndex]
		local equipCellData = wsManager:GetEquipCellDataWithIndex(nEquipOrderIndex)
		if equipCellData~= nil then
			self:CreateEquipCell(equipCellData)
		end
	end
	
	self:RefreshEquipListState()
end

function RongLianDlg:CreateEquipCell(equipCellData)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local nIndexEquip = #self.vItemCellEquip + 1
	local nEquipKey = equipCellData.nEquipKey
		local eBagType = equipCellData.eBagType
		local equipData = roleItemManager:FindItemByBagAndThisID(nEquipKey,eBagType)
		if equipData then
			local itemAttrCfg = equipData:GetBaseObject()

			local prefix = "RongLianDlg_equip"..nIndexEquip
			local cellEquipItem = Workshopitemcell.new(self.ScrollEquip, nIndexEquip - 1,prefix)
			cellEquipItem:RefreshVisibleWithType(4) --//1=dz 2xq 3hc 4xl
			self.vItemCellEquip[nIndexEquip] = cellEquipItem
			cellEquipItem.labItemName:setText(equipData:GetName())
			cellEquipItem.itemCell:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg.icon))
            SetItemCellBoundColorByQulityItemWithId(cellEquipItem.itemCell,itemAttrCfg.id)

            if  itemAttrCfg.nquality > 0 then
                SetItemCellBoundColorByQulityItem(cellEquipItem.itemCell, itemAttrCfg.nquality )
            end
            refreshItemCellBind(cellEquipItem.itemCell, eBagType,nEquipKey)

			cellEquipItem.itemCell:setID(nEquipKey) --key
			cellEquipItem.nClientKey = nIndexEquip
			cellEquipItem.eBagType = eBagType
			cellEquipItem.nServerKey = nEquipKey
			local strNaijiuduzi = MHSD_UTILS.get_resstring(111)
			cellEquipItem.labBottom1:setText(strNaijiuduzi)
			local nDurence = equipData:GetEquipScore()
			cellEquipItem.labDurance:setText(tostring(nDurence))
			if eBagType==fire.pb.item.BagTypes.EQUIP then
				cellEquipItem.imageHaveEquiped:setVisible(true)
			end
			cellEquipItem.btnBg:subscribeEvent("MouseClick", RongLianDlg.HandleClickedItem,self)
		end
		
end

function RongLianDlg:RefreshEquipList(nBagId,nItemKey)
	local wsManager = Workshopmanager.getInstance()
	wsManager:RefreshEquipArray(nBagId,nItemKey)
	wsManager.nXilianPage = 1
	
	self:ClearCellAll()
	
	self.ScrollEquip:cleanupNonAutoChildren()
	self.vItemCellEquip = {}


	local vEquipKeyOrderIndex = {}
    wsManager:ronglianlv(vEquipKeyOrderIndex,wsManager.nXilianPage)--控制点化等级

	for nIndex=1,#vEquipKeyOrderIndex do 
		local nEquipOrderIndex = vEquipKeyOrderIndex[nIndex]
		local equipCellData = wsManager:GetEquipCellDataWithIndex(nEquipOrderIndex)
		if equipCellData~= nil then
			self:CreateEquipCell(equipCellData)
			if self.nItemCellSelId ==0 then 
				self.nItemCellSelId = nEquipOrderIndex
			end
		end
	end

end

function RongLianDlg:GetCellWithIndex(nIndex)
	if nIndex > #self.vItemCellEquip then
		return nil
	end
	return self.vItemCellEquip[nIndex]
end

function RongLianDlg:GetCurItemBagType()
	local cellEquipItem = self:GetCellWithIndex(self.nItemCellSelId)
	if not cellEquipItem then
		return 0
	end
	return cellEquipItem.eBagType
end

function RongLianDlg:HandleClickedItem(e)
	local mouseArgs = CEGUI.toMouseEventArgs(e)
	for i = 1, #self.vItemCellEquip do
		local cellEquip = self.vItemCellEquip[i]
		if cellEquip.btnBg == mouseArgs.window then
			self.nItemCellSelId =  cellEquip.nClientKey
			break
		end
	end
	self:RefreshEquipCellSel() --self:RefreshEquipCellSel()
	self:RefreshEquip()
	return true
end

function RongLianDlg:ResetEquip()
	self.ItemCellTarget:SetImage(nil)
    SetItemCellBoundColorByQulityItemWithId(self.ItemCellTarget,0)

    self.ImageTargetCanMake:setVisible(false)
	self.LabTargetName:setText("")
	self.ItemCellNeedItem1:SetTextUnit("")
	self.LabNameNeedItem1:setText("")
	self.ItemCellNeedItem2:SetTextUnit("")
	self.LabNameNeedItem2:setText("")
	self.needMoneyLabel:setText("")
end

function RongLianDlg:getXlItemIdAndNeedNum(nEquipId)
	local nNeedItemId = 0
	local nNeedItemNum = 0
	local equipPropertyCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipitemattr"):getRecorder(nEquipId)
	if not equipPropertyCfg then
		return nNeedItemId,nNeedItemNum
	end
	
	local vcNeedItem = equipPropertyCfg.commonidlist
	local vcNeedItemNum = equipPropertyCfg.commonnumlist
	
	if vcNeedItem:size() >0 then
		nNeedItemId = vcNeedItem[0]
		nNeedItemNum = 0
        if vcNeedItemNum:size() > 0 then
            nNeedItemNum = vcNeedItemNum[0]
        end
        
	end
	
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	for nIndex=0,vcNeedItem:size()-1 do 
		local nItemId = vcNeedItem[nIndex]
		local nItemNeedNum = 0
        
        if nIndex < vcNeedItemNum:size() then
            nItemNeedNum = vcNeedItemNum[nIndex]
        end
		
		local nOwnItemNum = roleItemManager:GetItemNumByBaseID(nItemId)
		if nOwnItemNum >= nItemNeedNum then
			nNeedItemId = nItemId
			nNeedItemNum = nItemNeedNum
			break
		end
		
	end
	
	return nNeedItemId,nNeedItemNum 
end

function RongLianDlg:RefreshEquip()
	local cellEquipItem = self:GetCellWithIndex(self.nItemCellSelId)
	if not cellEquipItem then
		return
	end

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()

	local nEquipKey = cellEquipItem.itemCell:getID()
	local eBagType =  cellEquipItem.eBagType
	local equipData = roleItemManager:FindItemByBagAndThisID(nEquipKey,eBagType)
	if not equipData then
		return
	end
	local itemAttrCfg = equipData:GetBaseObject()
	local nEquipId = itemAttrCfg.id
	local equipPropertyCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipitemattr"):getRecorder(nEquipId)
	if not equipPropertyCfg then
		return 
	end
	
	local nNeedItemId1,nNeedItemNum1  = self:getXlItemIdAndNeedNum(nEquipId)
	local needItemid =  equipPropertyCfg.equipitemid
	local nNeedItemId2 = equipPropertyCfg.tsxlcailiaoid
	local nNeedItemNum2 = equipPropertyCfg.tsxlcailiaonum
	local needItemCfg1 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(needItemid)
	if not needItemCfg1 then
		return
	end
	local needItemCfg2 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nNeedItemId2)
	if not needItemCfg2 then
		return
	end
	if eBagType==fire.pb.item.BagTypes.EQUIP then 
		self.ImageTargetCanMake:setVisible(true)
	else
		self.ImageTargetCanMake:setVisible(false)
	end
	self.ItemCellTarget:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg.icon))
    SetItemCellBoundColorByQulityItemWithId(self.ItemCellTarget,itemAttrCfg.id)

    if itemAttrCfg.nquality > 0 then
        SetItemCellBoundColorByQulityItem(self.ItemCellTarget,itemAttrCfg.nquality)
    end
    refreshItemCellBind(self.ItemCellTarget,eBagType,nEquipKey)

	self.LabTargetName:setText(itemAttrCfg.name)
	local nEquipType = itemAttrCfg.itemtypeid
	local strTypeName = ""
	local itemTypeCfg = BeanConfigManager.getInstance():GetTableByName("item.citemtype"):getRecorder(nEquipType)
	if itemTypeCfg then
		strTypeName = itemTypeCfg.weapon
	end
	self.ItemCellNeedItem1:SetImage(gGetIconManager():GetItemIconByID(needItemCfg1.icon))
    SetItemCellBoundColorByQulityItemWithId(self.ItemCellNeedItem1,needItemCfg1.id)

	self.ItemCellNeedItem1:setID(needItemCfg1.id)
	local nOwnItemNum1 = roleItemManager:GetItemNumByBaseID(needItemCfg1.id)
	local nNeedItemNum1 = equipPropertyCfg.equipnum
	local strNumNeed_own1 = nOwnItemNum1.."/"..nNeedItemNum1
	self.ItemCellNeedItem1:SetTextUnit(strNumNeed_own1)
	self.LabNameNeedItem1:setText(needItemCfg1.name)
	if nOwnItemNum1 >= nNeedItemNum1 then
		self.ItemCellNeedItem1:SetTextUnitColor(MHSD_UTILS.get_greencolor())
	else
		self.ItemCellNeedItem1:SetTextUnitColor(MHSD_UTILS.get_redcolor())
	end
	self.ItemCellNeedItem2:SetImage(gGetIconManager():GetItemIconByID(needItemCfg2.icon))
    SetItemCellBoundColorByQulityItemWithId(self.ItemCellNeedItem2,needItemCfg2.id)

	self.ItemCellNeedItem2:setID(needItemCfg2.id)
	local nOwnItemNum2 = roleItemManager:GetItemNumByBaseID(needItemCfg2.id)
	local strNumNeed_own2 = nOwnItemNum2.."/"..nNeedItemNum2
	self.ItemCellNeedItem2:SetTextUnit(strNumNeed_own2)
	self.LabNameNeedItem2:setText(needItemCfg2.name)
	if nOwnItemNum2 >= nNeedItemNum2 then
		self.ItemCellNeedItem2:SetTextUnitColor(MHSD_UTILS.get_greencolor())
	else
		self.ItemCellNeedItem2:SetTextUnitColor(MHSD_UTILS.get_redcolor())
	end
	self:RefreshNeedMoneyLabel()
	self:RefreshRichBox(false)
end

function RongLianDlg:GetCurEquipData()
	local nServerKey = self:GetCurServerKey()
	local eBagType = self:GetCurItemBagType()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local equipData = roleItemManager:FindItemByBagAndThisID(nServerKey,eBagType)
	if not equipData then
		return nil
	end
	return equipData
end

function RongLianDlg:RefreshRichBox(bUseLocal)
	LogInfo(" RongLianDlg.RefreshRichBox(bUseLocal)")
	local equipData = self:GetCurEquipData()
	if not equipData then
		return 
	end
	local eBagType = self:GetCurItemBagType()
	local bHaveData,strParseText = WorkshopHelper.GetMapPropertyWithEquipData1(equipData,bUseLocal,eBagType, true)
	if bHaveData then
		self.richBoxEquip:Clear()
		self.richBoxEquip:show()
		self.richBoxEquip:AppendParseText(CEGUI.String(strParseText))
		self.richBoxEquip:Refresh()
	end
end

function RongLianDlg:GetCurNeedMoney()
	local cellEquipItem = self:GetCellWithIndex(self.nItemCellSelId)
	if not cellEquipItem then
		return
	end
	local nEquipKey = cellEquipItem.itemCell:getID()
	local eBagType =  cellEquipItem.eBagType
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local equipData = roleItemManager:FindItemByBagAndThisID(nEquipKey,eBagType)
	if not equipData then
		return
	end
	local itemAttrCfg = equipData:GetBaseObject()
	local nEquipId = itemAttrCfg.id
	local equipPropertyCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipitemattr"):getRecorder(nEquipId)
	if not equipPropertyCfg then
		return 
	end
	local nNeedMoney = equipPropertyCfg.ptxlmoneynum
	return nNeedMoney
end

function RongLianDlg:RefreshNeedMoneyLabel()
	local cellEquipItem = self:GetCellWithIndex(self.nItemCellSelId)
	if not cellEquipItem then
		return
	end

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()

	local nEquipKey = cellEquipItem.itemCell:getID()
	local eBagType =  cellEquipItem.eBagType
	local equipData = roleItemManager:FindItemByBagAndThisID(nEquipKey,eBagType)
	if not equipData then
		return
	end
	local itemAttrCfg = equipData:GetBaseObject()
	local nEquipId = itemAttrCfg.id
	local equipPropertyCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipitemattr"):getRecorder(nEquipId)
	if not equipPropertyCfg then
		return 
	end
	local nNeedMoney = equipPropertyCfg.equipmoney
	local nUserMoney = roleItemManager:GetGold()
	--//===========================
	if nUserMoney >= nNeedMoney then
		self.needMoneyLabel:setProperty("TextColours", "FFFFF2DF")
	else
		self.needMoneyLabel:setProperty("TextColours", "ffff0000")
	end
	
	self.needMoneyLabel:setText(nNeedMoney)
	local roleGold = roleItemManager:GetGold()
    self.ownMoneyLabel:setText(tostring(roleGold))
end

function RongLianDlg:RefreshEquipDetailInfo(vProperty)
	for nIndexLabel = 1, #self.vLabelProperty do
		self.vLabelProperty[nIndexLabel]:setVisible(false)
	end
	for nIndexLabel = 1, #self.vLabelTitleProperty do
		self.vLabelTitleProperty[nIndexLabel]:setVisible(false)
	end	
	for nIndex=1,#vstrProperty do 
		local mapOne = vstrProperty[nIndex]
		local labelTitle,labelValue = self:GetLabelWithIndex(nIndex)
		labelTitle:setText( mapOne.strTitleName)
		labelValue:setText( mapOne.strValue )
	end
end

function RongLianDlg:GetLabelWithIndex(nIndex)
	if nIndex > #self.vLabelTitleProperty then 
		return nil
	end
	return self.vLabelTitleProperty[nIndexLabel], self.vLabelProperty[nIndexLabel]
end



function RongLianDlg:IsCanXiuli()
	local strResult = ""
	local cellEquipItem = self:GetCellWithIndex(self.nItemCellSelId)
	if not cellEquipItem then
		return false
	end

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()

	local nEquipKey = cellEquipItem.itemCell:getID()
	local eBagType =  cellEquipItem.eBagType
	local equipData = roleItemManager:FindItemByBagAndThisID(nEquipKey,eBagType)
	if not equipData then
	end
	local itemAttrCfg = equipData:GetBaseObject()
	local nEquipId = itemAttrCfg.id
	local equipPropertyCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipitemattr"):getRecorder(nEquipId)
	if not equipPropertyCfg then
		return false
	end
	
	--local nNeedItemId1,nNeedItemNum1  = self:getXlItemIdAndNeedNum(nEquipId)
    nNeedItemId1=equipPropertyCfg.equipitemid
	nNeedItemNum1=equipPropertyCfg.equipnum
	local nNeedItemId2 = equipPropertyCfg.tsxlcailiaoid
	local nNeedItemNum2 = equipPropertyCfg.tsxlcailiaonum
	local nOwnItemNum1 = roleItemManager:GetItemNumByBaseID(nNeedItemId1)
	local nOwnItemNum2 = roleItemManager:GetItemNumByBaseID(nNeedItemId2)
	local nUserMoney = roleItemManager:GetPackMoney()
	local nNeedMoney1 = equipPropertyCfg.ptxlmoneynum
	local nNeedMoney2 = equipPropertyCfg.tsxlmoneynum
	local needItemCfg1 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nNeedItemId1)
	if not needItemCfg1 then
		return false
	end
	local needItemCfg2 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nNeedItemId2)
	if not needItemCfg2 then
		return false
	end
	
	if nOwnItemNum1 < nNeedItemNum1 then
		strResult = MHSD_UTILS.get_resstring(11006) 
		strResult = strResult..needItemCfg1.name
		LogInfo("RongLianDlg:IsCanXiuli()=nNeedItemId1="..nNeedItemId1)
		return false, strResult
	end
		if nUserMoney < nNeedMoney1 then
			strResult = MHSD_UTILS.get_resstring(11006) 
			
			return false, strResult
		end
	return true, strResult
end

function RongLianDlg:CheckBoxStateChanged(args)
    local state = self.checkbox:isSelected()
    if state then
	    --self:RefreshTwoBtnSel()
	    self:RefreshNeedMoneyLabel()
	end
end 

--//=========================================
function RongLianDlg.getInstance()
    if not _instance then
        _instance = RongLianDlg:new()
        _instance:OnCreate()
    end
    return _instance
end

function RongLianDlg.getInstanceAndShow()
    if not _instance then
        _instance = RongLianDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
	_instance:SendRequestAllEndure()
    return _instance
end

function RongLianDlg.getInstanceNotCreate()
    return _instance
end

function RongLianDlg.getInstanceOrNot()
	return _instance
end
	
function RongLianDlg.GetLayoutFileName()
    return "zhuangbeironglian.layout"
end

function RongLianDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, RongLianDlg)
	self:ClearData()
    return self
end

function RongLianDlg.DestroyDialog()
	if not _instance then
		return
	end
	if _instance.m_LinkLabel then
		_instance.m_LinkLabel:OnClose()
	else
		--self:OnClose()

		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function RongLianDlg:ClearData()
	self.vItemCellEquip = {}	
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
end

function RongLianDlg:ClearDataInClose()
	self.vItemCellEquip = nil	
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
end

function RongLianDlg:ClearCellAll()
	for k, v in pairs(self.vItemCellEquip) do
		LogInfo("RongLianDlg:ClearCellAll()=k="..k)
		v:DestroyDialog()
	end
	self.vItemCellEquip = {}
end


function RongLianDlg:OnClose()
	self:ClearCellAll()
	
	Dialog.OnClose(self)
	
	self:HandlBtnClickInfoClose()

	self:ClearDataInClose()
	gGetRoleItemManager().m_EventPackMoneyChange:RemoveScriptFunctor(self.m_hPackMoneyChange)
    gGetRoleItemManager():RemoveLuaItemNumChangeNotify(self.m_hItemNumChangeNotify)
	_instance = nil
end

return RongLianDlg


