require "utils.mhsdutils"
require "logic.dialog"
require "logic.workshop.workshopitemcell"
require "logic.workshop.workshophelper"

require "utils.commonutil"

Workshopxlnew = {}
setmetatable(Workshopxlnew, Dialog)
Workshopxlnew.__index = Workshopxlnew
local _instance;


function Workshopxlnew.OnDzResult()
	LogInfo("Workshopxlnew.OnDzResult()")
	if not _instance then
		return
	end
	--[[
	--IsVisible
	if _instance.bLoadUI then
		_instance:RefreshEquipList()
		_instance:RefreshEquipCellSel()
		_instance:RefreshEquip()
		_instance:SendRequestAllEndure()
	end
	-]]
end


function Workshopxlnew:RefreshItemTips(item)
	LogInfo("Workshopxlnew.RefreshItemTips")
	local bUseLocal = true  
	self:RefreshRichBox(bUseLocal)
end



function Workshopxlnew.OnFailTimesResult(protocol)
	
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

function Workshopxlnew.OnRefreshAllResult(protocol)
	LogInfo(" Workshopxlnew.OnRefreshAllResult(protocol)")
	if not _instance then
		return
	end
	_instance:RefreshEquipListState()
	_instance:RefreshEquip()
end

function Workshopxlnew.OnXlResult()
	
	
	if not _instance then
		return
	end
	_instance:RefreshEquipListState()
	_instance:RefreshEquip()
	local bUseLocal = true  
	_instance:RefreshRichBox(bUseLocal)
end

--[[ 
	<variable name="bagid" type="int" validator="value=[1,)" />
    <variable name="itemkey" type="int" validator="value=[1,)" />
    <variable name="tips" type="octets" />
--]]
function Workshopxlnew.OnRefreshOneItemInfoResult(protocol)
	LogInfo("Workshopxlnew.OnRefreshOneItemInfoResult")
	if not _instance then
		return
	end
	_instance:RefreshEquip()
end

--[[
function Workshopxlnew:GetOnePropertyData(nPropertyId,nValue,mapOnePeoperty)
    local propertyCfg =  BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(nPropertyId)
	if propertyCfg ~= nil then
		mapOnePeoperty.strTitleName = propertyCfg.name
		mapOnePeoperty.strValue = "+"..tostring(nValue)
	end
end
--]]


function Workshopxlnew:OnCreate()
    Dialog.OnCreate(self)
	SetPositionOfWindowWithLabel1(self:GetWindow())
	self.m_hItemNumChangeNotify = gGetRoleItemManager():InsertLuaItemNumChangeNotify(Workshopxlnew.OnItemNumChange)
	self.m_hPackMoneyChange = gGetRoleItemManager().m_EventPackMoneyChange:InsertScriptFunctor(Workshopxlnew.OnMoneyChange)
	--[[
	self.m_AddItemInBag = gGetRoleItemManager().m_EventAddPackItem:InsertScriptFunctor(Workshopxlnew.AddItemInBag)
	self.m_DelItemInBag = gGetRoleItemManager().EventDelPackItem:InsertScriptFunctor(Workshopxlnew.DelItemInBag)
	self.m_AddItemInEquipBag = gGetRoleItemManager().m_EventAddEquipItem:InsertScriptFunctor(Workshopxlnew.AddItemInEquipBag)
	self.m_DelItemInEquipBag = gGetRoleItemManager().m_EventDelEquipItem:InsertScriptFunctor(Workshopxlnew.DelItemInEquipBag)
	--]]
	
	self:InitUI()
	self.bLoadUI = true
	--[[
	self:RefreshEquipList()
	self:RefreshEquipCellSel()
	self:RefreshEquip()
	self:SendRequestAllEndure()
	self.eXlType = 0
	self:RefreshTwoBtnSel()
	--]]
    self:ResetEquip()
end


function Workshopxlnew.AddItemInBag(nItemKey)
	if not _instance then
		return
	end
	
end

function Workshopxlnew.DelItemInBag(nItemKey)
	if not _instance then
		return
	end
end

function Workshopxlnew.AddItemInEquipBag(nItemKey)
	if not _instance then
		return
	end
end

function Workshopxlnew.DelItemInEquipBag(nItemKey)
	if not _instance then
		return
	end
end


function Workshopxlnew.OnMoneyChange()
	if not _instance then
		return
	end
	_instance:RefreshNeedMoneyLabel()
end

function Workshopxlnew:AddCell(eBagType,nItemKey)
	
end

function Workshopxlnew:DeleteCell(eBagType,nItemKey)
	
end

function Workshopxlnew:RefreshAllCellSortData()
end


function Workshopxlnew:SortAllCell()
end

function Workshopxlnew:RefreshAllCellPos()
end

function Workshopxlnew:GetCell(eBagType,nEquipKey)
	--cellEquipItem.eBagType = eBagType
	--cellEquipItem.nServerKey = nEquipKey
	--for k,v
	--end
	--[[
	for i = 1, #self.vItemCellEquip do 
		local equipCell = self.vItemCellEquip[i]
		nEquipKey = equipCell.itemCell:getID() 
		eBagType = equipCell.eBagType
		local roleItem = require("logic.item.roleitemmanager").getInstance():FindItemByBagAndThisID(nEquipKey,eBagType)
		local nEndure = 0
		if roleItem then
			 nEndure = roleItem:GetEndure()
		end
		equipCell.labDurance:setText(tostring(nEndure))
	end
	--]]
	
end


function Workshopxlnew.OnItemNumChange(eBagType, nItemKey, nItemId)
	if _instance == nil then
		return
	end
	_instance:RefreshEquip()
	--LogInsane(string.format("Workshopxlnew.OnItemNumChange(%d, %d, %d)", bagid, itemkey, itembaseid))
end


function Workshopxlnew:RefreshUI(nBagId,nItemKey)
    if not nBagId then
        nBagId = -1
        nItemKey = -1
    end
	self:RefreshEquipList(nBagId,nItemKey)
	self:RefreshEquipCellSel()
	self:RefreshEquip()
	self:SendRequestAllEndure()
	self.eXlType = 0
	self:RefreshTwoBtnSel()
	--self.BtnMakeQh:SetPushState(false)
	--self.BtnMakeQh:setVisible(false)
end

function Workshopxlnew:InitUI()
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.ScrollEquip = CEGUI.toScrollablePane(winMgr:getWindow("workshopxlnew/left"))
	self.ScrollEquip:setMousePassThroughEnabled(true)
	self.ScrollEquip:subscribeEvent("NextPage", Workshopxlnew.OnNextPage, self)
	self.ItemCellTarget = CEGUI.toItemCell(winMgr:getWindow("workshopxlnew/right/part2/item2"))
	self.ImageTargetCanMake = winMgr:getWindow("workshopxlnew/right/part2/item2/yizhuangbei") 
	self.LabTargetName = winMgr:getWindow("workshopxlnew/right/part2/name2") 
	--self.LabTypeNameTarget = winMgr:getWindow("workshopxlnew/bg/mingcheng")
	self.richBoxEquip = CEGUI.toRichEditbox(winMgr:getWindow("workshopxlnew/right/shuxinglist/box"))
	self.richBoxEquip:setReadOnly(true)
	
	
	self.smokeBg = winMgr:getWindow("workshopxlnew/Back/flagbg/smoke")
	local s = self.smokeBg:getPixelSize()
	local flagSmoke = gGetGameUIManager():AddUIEffect(self.smokeBg, "geffect/ui/mt_shengqishi/mt_shengqishi1", true, s.width*0.5, s.height)
	
	--self.richBoxEquip:setWordWrapping(false) --
	--self.BtnMake = CEGUI.toPushButton(winMgr:getWindow("workshopxlnew/right/putongbutton"))
	--GroupButton toGroupButton
	self.BtnMake = CEGUI.toGroupButton(winMgr:getWindow("workshopxlnew/right/putongbutton"))
--	self.BtnMake:subscribeEvent("MouseClick", Workshopxlnew.HandlBtnClickedXlnormal, self)

	self.BtnMakeQh = CEGUI.toPushButton(winMgr:getWindow("workshopxlnew/right/teshubutton"))
--	self.BtnMakeQh = CEGUI.toGroupButton(winMgr:getWindow("workshopxlnew/right/teshubutton"))
--	self.BtnMakeQh:subscribeEvent("MouseClick", Workshopxlnew.HandlBtnClickedXlQh, self)
    self.checkbox = CEGUI.toCheckbox(winMgr:getWindow("workshopxlnew/right/part2/line1/gou"))
    self.checkbox:subscribeEvent("MouseButtonUp", Workshopxlnew.CheckBoxStateChanged, self)

	self.ItemCellNeedItem1 = CEGUI.toItemCell(winMgr:getWindow("workshopxlnew/right/cailiaolist/item1"))
	self.LabNameNeedItem1 = winMgr:getWindow("workshopxlnew/right/cailiaolist/name1")
	self.ItemCellNeedItem2 = CEGUI.toItemCell(winMgr:getWindow("workshopxlnew/right/cailiaolist/item2"))
	self.LabNameNeedItem2 = winMgr:getWindow("workshopxlnew/right/cailiaolist/name2")
	--self.LabFailTimes = winMgr:getWindow("workshopxlnew/right/shuxinglist/9")
	self.needMoneyLabel = winMgr:getWindow("workshopxlnew/right/bg1/one") --workshopxlnew/right/bg1/one
	self.ownMoneyLabel = winMgr:getWindow("workshopxlnew/right/bg11/2") --workshopxlnew/right/bg11/2
	self.ImageNeedMoneyIcon = winMgr:getWindow("workshopxlnew/right/yinbi")
	self.ImageOwnMoneyIcon = winMgr:getWindow("workshopxlnew/right/yinbi2")
	self.BtnXl = CEGUI.toPushButton(winMgr:getWindow("workshopxlnew/right/button"))
	self.BtnXl:subscribeEvent("Clicked", Workshopxlnew.HandlBtnClickedXl, self)
	self.labelNormalDesc = winMgr:getWindow("workshopxlnew/right/part2/line1/text")
	self.labelSpecialDesc = winMgr:getWindow("workshopxlnew/right/part2/line1/textteshu1")
	
	self.ItemCellNeedItem1:subscribeEvent("TableClick", Workshopmanager.HandleClickItemCell, Workshopmanager)
	self.ItemCellNeedItem2:subscribeEvent("TableClick", Workshopmanager.HandleClickItemCell, Workshopmanager)

    self.BtnExchange = CEGUI.toPushButton(winMgr:getWindow("workshopxlnew/right/jiahao")) --workshopxlnew/right/jiahao
	self.BtnExchange:subscribeEvent("Clicked", Workshopxlnew.HandleExchangeBtnClicked, self)
end

function Workshopxlnew:HandleExchangeBtnClicked(e)
	local dlg = require "logic.currency.stonegoldexchangesilverdlg".getInstanceAndShow()
	dlg:GetWindow():setAlwaysOnTop(true)

	return true
	
end

function Workshopxlnew:GetCurServerKey()
	local cellEquipItem = self:GetCellWithIndex(self.nItemCellSelId)
	if not cellEquipItem then
		return 0
	end
	return cellEquipItem.nServerKey
end

function Workshopxlnew:DestroyDialog()
	if self._instance then
        if self.sprite then
            self.sprite:delete()
            self.sprite = nil
        end
		if self.smokeBg then
		    gGetGameUIManager():RemoveUIEffect(self.smokeBg)
		end
		if self.roleEffectBg then
		    gGetGameUIManager():RemoveUIEffect(self.roleEffectBg)
		end
		self:OnClose()
		getmetatable(self)._instance = nil
        _instance = nil
	end
end

function Workshopxlnew:HandlBtnClickedXl(e)
	if GetBattleManager() and GetBattleManager():IsInBattle() then
		local strShowTip = MHSD_UTILS.get_resstring(11018) 
		GetCTipsManager():AddMessageTip(strShowTip)
        return 
    end
	
	--//=======================================
	local nNeedMoney = self:GetCurNeedMoney()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local nUserMoney = roleItemManager:GetPackMoney()
	
	if nUserMoney < nNeedMoney then
		local nMoneyType = fire.pb.game.MoneyType.MoneyType_SilverCoin
		local nShowNeed = nNeedMoney - nUserMoney
		LogInfo("nMoneyType="..nMoneyType)
		CurrencyManager.handleCurrencyNotEnough(nMoneyType, nShowNeed)
		return 
	end




	--//=======================================
	local nEquipKey = self:GetCurServerKey()
	local eBagType = self:GetCurItemBagType()
	
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local equipData = roleItemManager:FindItemByBagAndThisID(nEquipKey,eBagType)
	if equipData then
		local equipObj = equipData:GetObject() --GetEndureUpperLimit
	    local nEndureMax = equipObj.endureuplimit
		local nCurEndure = equipObj.endure
        local nFailTimes = equipObj.repairTimes
        local nFialTimesMax = 3

        if self.eXlType == 0 then 
            if nFailTimes >= nFialTimesMax then
                local strDadaozuidazishuzi = MHSD_UTILS.get_resstring(11291) --
			    GetCTipsManager():AddMessageTip(strDadaozuidazishuzi)
                return
            end
        end

		if nCurEndure>=nEndureMax then
			local strShowTip = MHSD_UTILS.get_resstring(11012) --ÄÍ¾ÃÒÑÂú
			GetCTipsManager():AddMessageTip(strShowTip)
			return
		end
	end
	--//=======================================
	
	
	
	local bCanXiuli,strResult = self:IsCanXiuli()
	if bCanXiuli==false then
		GetCTipsManager():AddMessageTip(strResult)
		return 
	end

    ----------------------------------
    local bCheckShow = self:checkShowItemOverNeed()
    if bCheckShow == true then
        return
    end
    -----------------------------------
	--self.eXlType = 1 --0=normal 1=special
	local p = require "protodef.fire.pb.item.cxiuliequipitem":new()
	p.repairtype = self.eXlType --normal
	p.keyinpack = nEquipKey
	local nBagType = eBagType
	p.packid = nBagType --fire.pb.item.BagTypes.BAG
	require "manager.luaprotocolmanager":send(p)
end	

function Workshopxlnew:checkShowItemOverNeed()
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

function Workshopxlnew:clickConfirmBoxOk_xl()
    gGetMessageManager():CloseConfirmBox(eConfirmNormal,false)
    local nEquipKey = self:GetCurServerKey()
	local eBagType = self:GetCurItemBagType()

    local p = require "protodef.fire.pb.item.cxiuliequipitem":new()
	p.repairtype = self.eXlType --normal
	p.keyinpack = nEquipKey
	local nBagType = eBagType
	p.packid = nBagType --fire.pb.item.BagTypes.BAG
	require "manager.luaprotocolmanager":send(p)

end

function Workshopxlnew:clickConfirmBoxCancel_xl()
gGetMessageManager():CloseConfirmBox(eConfirmNormal,false)

end

function Workshopxlnew:SendRequestAllEndure()
	
	local p1 = require "protodef.fire.pb.item.creqallnaijiu":new()
	p1.packid = fire.pb.item.BagTypes.BAG
	require "manager.luaprotocolmanager":send(p1)
	local p2 = require "protodef.fire.pb.item.creqallnaijiu":new()
	p2.packid = fire.pb.item.BagTypes.EQUIP
	require "manager.luaprotocolmanager":send(p2)
end



function Workshopxlnew:RefreshEquipCellSel()
	for i = 1, #self.vItemCellEquip do 
		local equipCell = self.vItemCellEquip[i]
		if equipCell.nClientKey ~= self.nItemCellSelId then
			--equipCell.btnBg:SetPushState(false)
			--equipCell.imageBg:setProperty("Image","" ) 
			equipCell.btnBg:setSelected(false)
		else
			equipCell.btnBg:setSelected(true)
			--equipCell.btnBg:SetPushState(true)
			--equipCell.imageBg:setProperty("Image",Workshopitemcell.strImageSelName ) 
		end	
	end
end

function Workshopxlnew:RefreshEquipListState()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	for i = 1, #self.vItemCellEquip do 
		local equipCell = self.vItemCellEquip[i]
		nEquipKey = equipCell.itemCell:getID() 
		eBagType = equipCell.eBagType
		local roleItem = roleItemManager:FindItemByBagAndThisID(nEquipKey,eBagType)
		local nEndure = 0
		if roleItem then
			 nEndure = roleItem:GetEndure()
		end
		equipCell.labDurance:setText(tostring(nEndure))
	end
end

function Workshopxlnew:OnNextPage(args)
	local wsManager = Workshopmanager.getInstance()
	wsManager.nXlPage = wsManager.nXlPage + 1
	local vEquipKeyOrderIndex = {}
    wsManager:GetXqEquipWithPage(vEquipKeyOrderIndex,wsManager.nXlPage)
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

function Workshopxlnew:CreateEquipCell(equipCellData)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local nIndexEquip = #self.vItemCellEquip + 1
	local nEquipKey = equipCellData.nEquipKey
		local eBagType = equipCellData.eBagType
		local equipData = roleItemManager:FindItemByBagAndThisID(nEquipKey,eBagType)
		if equipData then
			
			local prefix = "Workshopxlnew_equip"..nIndexEquip
			local cellEquipItem = Workshopitemcell.new(self.ScrollEquip, nIndexEquip - 1,prefix)
			cellEquipItem:RefreshVisibleWithType(4) --//1=dz 2xq 3hc 4xl
			self.vItemCellEquip[nIndexEquip] = cellEquipItem
			local itemAttrCfg = equipData:GetBaseObject()
			cellEquipItem.labItemName:setText(equipData:GetName())
			cellEquipItem.itemCell:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg.icon))
            SetItemCellBoundColorByQulityItemWithIdtm(cellEquipItem.itemCell,itemAttrCfg.id)

            if  itemAttrCfg.nquality > 0 then
                SetItemCellBoundColorByQulityItem(cellEquipItem.itemCell, itemAttrCfg.nquality )
            end
            refreshItemCellBind(cellEquipItem.itemCell, eBagType,nEquipKey)

			cellEquipItem.itemCell:setID(nEquipKey) --key
			cellEquipItem.nClientKey = nIndexEquip
			cellEquipItem.eBagType = eBagType
			cellEquipItem.nServerKey = nEquipKey
			local strNaijiuduzi = MHSD_UTILS.get_resstring(11000)
			cellEquipItem.labBottom1:setText(strNaijiuduzi)
			local nDurence = 0 
			cellEquipItem.labDurance:setText(tostring(nDurence))
			if eBagType==fire.pb.item.BagTypes.EQUIP then
				cellEquipItem.imageHaveEquiped:setVisible(true)
			end
			cellEquipItem.btnBg:subscribeEvent("MouseClick", Workshopxlnew.HandleClickedItem,self)
		end
end

function Workshopxlnew:RefreshEquipList(nBagId,nItemKey)
	local wsManager = Workshopmanager.getInstance()
	wsManager:RefreshEquipArray(nBagId,nItemKey)
	wsManager.nXlPage = 1
	
	self:ClearCellAll()
	
	self.ScrollEquip:cleanupNonAutoChildren()
	self.vItemCellEquip = {}
	--//=============================
	--local vEquipKeyOrder= {}
	--WorkshopHelper.GetEquipArray(vEquipKeyOrder)

	local vEquipKeyOrderIndex = {}
    wsManager:GetXqEquipWithPage(vEquipKeyOrderIndex,wsManager.nXlPage)
	--//=============================
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
	
	--self:RefreshEquipListState()
end

function Workshopxlnew:GetCellWithIndex(nIndex)
	if nIndex > #self.vItemCellEquip then
		return nil
	end
	return self.vItemCellEquip[nIndex]
end

function Workshopxlnew:GetCurItemBagType()
	local cellEquipItem = self:GetCellWithIndex(self.nItemCellSelId)
	if not cellEquipItem then
		return 0
	end
	return cellEquipItem.eBagType
end

function Workshopxlnew:HandleClickedItem(e)
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
	--self:SendReqOneItemInfo()
	return true
end

function Workshopxlnew:ResetEquip()
	self.ItemCellTarget:SetImage(nil)
    SetItemCellBoundColorByQulityItemWithIdtm(self.ItemCellTarget,0)

    self.ImageTargetCanMake:setVisible(false)
	self.LabTargetName:setText("")
	self.ItemCellNeedItem1:SetTextUnit("")
	self.LabNameNeedItem1:setText("")
	self.ItemCellNeedItem2:SetTextUnit("")
	self.LabNameNeedItem2:setText("")
	self.needMoneyLabel:setText("")
	--self.ownMoneyLabel:setText(tostring(nUserMoney))
end

function Workshopxlnew:getXlItemIdAndNeedNum(nEquipId)
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

function Workshopxlnew:RefreshEquip()
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
	--baseAttrId 
	--local nNeedItemId1 = equipPropertyCfg.ptxlcailiaoid
	--local nNeedItemNum1 = equipPropertyCfg.ptxlcailiaonum
	
	local nNeedItemId1,nNeedItemNum1  = self:getXlItemIdAndNeedNum(nEquipId)
	
	local nNeedItemId2 = equipPropertyCfg.tsxlcailiaoid
	local nNeedItemNum2 = equipPropertyCfg.tsxlcailiaonum
	local needItemCfg1 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nNeedItemId1)
	if not needItemCfg1 then
		return
	end
	local needItemCfg2 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nNeedItemId2)
	if not needItemCfg2 then
		return
	end
	--//===============================
	if eBagType==fire.pb.item.BagTypes.EQUIP then 
		self.ImageTargetCanMake:setVisible(true)
	else
		self.ImageTargetCanMake:setVisible(false)
	end
	self.ItemCellTarget:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg.icon))
    SetItemCellBoundColorByQulityItemWithIdtm(self.ItemCellTarget,itemAttrCfg.id)

    if itemAttrCfg.nquality > 0 then
        SetItemCellBoundColorByQulityItemtm(self.ItemCellTarget,itemAttrCfg.nquality)
    end
    refreshItemCellBind(self.ItemCellTarget,eBagType,nEquipKey)

	self.LabTargetName:setText(itemAttrCfg.name)
	local nEquipType = itemAttrCfg.itemtypeid
	local strTypeName = ""
	local itemTypeCfg = BeanConfigManager.getInstance():GetTableByName("item.citemtype"):getRecorder(nEquipType)
	if itemTypeCfg then
		strTypeName = itemTypeCfg.weapon
	end
	--//===============================
	self.ItemCellNeedItem1:SetImage(gGetIconManager():GetItemIconByID(needItemCfg1.icon))
    SetItemCellBoundColorByQulityItemWithIdtm(self.ItemCellNeedItem1,needItemCfg1.id)

	self.ItemCellNeedItem1:setID(needItemCfg1.id)
	local nOwnItemNum1 = roleItemManager:GetItemNumByBaseID(needItemCfg1.id)
	local strNumNeed_own1 = nOwnItemNum1.."/"..nNeedItemNum1
	self.ItemCellNeedItem1:SetTextUnit(strNumNeed_own1)
	self.LabNameNeedItem1:setText(needItemCfg1.name)
	if nOwnItemNum1 >= nNeedItemNum1 then
		self.ItemCellNeedItem1:SetTextUnitColor(MHSD_UTILS.get_greencolor())
	else
		self.ItemCellNeedItem1:SetTextUnitColor(MHSD_UTILS.get_redcolor())
	end
	--//===============================
	self.ItemCellNeedItem2:SetImage(gGetIconManager():GetItemIconByID(needItemCfg2.icon))
    SetItemCellBoundColorByQulityItemWithIdtm(self.ItemCellNeedItem2,needItemCfg2.id)

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

function Workshopxlnew:GetCurEquipData()
	local nServerKey = self:GetCurServerKey()
	local eBagType = self:GetCurItemBagType()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local equipData = roleItemManager:FindItemByBagAndThisID(nServerKey,eBagType)
	if not equipData then
		return nil
	end
	return equipData
end

function Workshopxlnew:RefreshRichBox(bUseLocal)
	local equipData = self:GetCurEquipData()
	if not equipData then
		return 
	end
	local eBagType = self:GetCurItemBagType()
	local bHaveData,strParseText = WorkshopHelper.GetMapPropertyWithEquipData(equipData,bUseLocal,eBagType)
	if bHaveData then
		self.richBoxEquip:Clear()
		self.richBoxEquip:show()
		self.richBoxEquip:AppendParseText(CEGUI.String(strParseText))
		self.richBoxEquip:Refresh()
	end
end

function Workshopxlnew:GetCurNeedMoney()
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
	--baseAttrId 
	local nNeedMoney1 = equipPropertyCfg.ptxlmoneynum
	local nNeedMoney2 = equipPropertyCfg.tsxlmoneynum
	--self.eXlType = 0 --normal --qh
	local nNeedMoney = 0
	if self.eXlType == 0 then
		nNeedMoney = nNeedMoney1
	else
		nNeedMoney = nNeedMoney2
	end
	return nNeedMoney
end

function Workshopxlnew:RefreshNeedMoneyLabel()
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
	--baseAttrId 
	local nNeedMoney1 = equipPropertyCfg.ptxlmoneynum
	local nNeedMoney2 = equipPropertyCfg.tsxlmoneynum
	--self.eXlType = 0 --normal --qh
	local nNeedMoney = 0
	if self.eXlType == 0 then
		nNeedMoney = nNeedMoney1
	else
		nNeedMoney = nNeedMoney2
	end
	local nUserMoney = roleItemManager:GetPackMoney()
	--//===========================
	if nUserMoney >= nNeedMoney then
		--("TextColours", money >= cfg.yinliang and "FFFFFFFF" or "FFFF0000")
		self.needMoneyLabel:setProperty("TextColours", "FFFFF2DF")
	else
		self.needMoneyLabel:setProperty("TextColours", "ffff0000")
	end
	
	local strNeedMoney = require("logic.workshop.workshopmanager").getNumStrWithThousand(nNeedMoney)
	
	self.needMoneyLabel:setText(strNeedMoney)
	local strUserMoney = require("logic.workshop.workshopmanager").getNumStrWithThousand(nUserMoney)
	self.ownMoneyLabel:setText(strUserMoney)
end

function Workshopxlnew:RefreshEquipDetailInfo(vProperty)
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

function Workshopxlnew:GetLabelWithIndex(nIndex)
	if nIndex > #self.vLabelTitleProperty then 
		return nil
	end
	return self.vLabelTitleProperty[nIndexLabel], self.vLabelProperty[nIndexLabel]
end

--function Workshopxlnew:HandlBtnClickedXlnormal(e)
--	self.eXlType = 0 --normal --qh
--	self:RefreshTwoBtnSel()
--	self:RefreshNeedMoneyLabel()
--end

function Workshopxlnew:IsCanXiuli()
	--self.eXlType = 0 --normal --qh
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
	--baseAttrId 
	--local nNeedItemId1 = equipPropertyCfg.ptxlcailiaoid
	--local nNeedItemNum1 = equipPropertyCfg.ptxlcailiaonum
	
	local nNeedItemId1,nNeedItemNum1  = self:getXlItemIdAndNeedNum(nEquipId)

	
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
		LogInfo("Workshopxlnew:IsCanXiuli()=nNeedItemId1="..nNeedItemId1)
		return false, strResult
	end
	if self.eXlType == 0 then 
		if nUserMoney < nNeedMoney1 then
			strResult = MHSD_UTILS.get_resstring(11006) 
			
			return false, strResult
		end
	else
		if nUserMoney < nNeedMoney2 then
			strResult = MHSD_UTILS.get_resstring(1792) 
			return false, strResult
		end
		if nOwnItemNum2 < nNeedItemNum2 then
			strResult = MHSD_UTILS.get_resstring(11006) 
			strResult = strResult..needItemCfg2.name
			LogInfo("Workshopxlnew:IsCanXiuli()=nNeedItemId2="..nNeedItemId2)
			return false, strResult
		end
	end
	return true, strResult
end

function Workshopxlnew:RefreshTwoBtnSel()
	--:setSelected(true)
	
	--self.BtnMake:SetPushState(false)
	--self.BtnMakeQh:SetPushState(false)
	
--	self.BtnMake:setSelected(false)
--	self.BtnMakeQh:setSelected(false)
	LogInfo("Workshopxlnew:RefreshTwoBtnSel()="..self.eXlType)
	
	local strTitleCur = ""
	if self.eXlType == 0 then
--		self.BtnMake:setSelected(true)
--		self.BtnMakeQh:setSelected(false)
		--self.ItemCellNeedItem2:setVisible(false)
		--self.LabNameNeedItem2:setVisible(false)
		strTitleCur = self.BtnMake:getText()
		self.labelNormalDesc:setVisible(true)
		self.labelSpecialDesc:setVisible(false)
	else
--		self.BtnMake:setSelected(false)
--		self.BtnMakeQh:setSelected(true)
		--self.ItemCellNeedItem2:setVisible(true)
		--self.LabNameNeedItem2:setVisible(true)
		strTitleCur = self.BtnMakeQh:getText()
		self.labelNormalDesc:setVisible(false)
		self.labelSpecialDesc:setVisible(true)
	end
	self.BtnXl:setText(strTitleCur)
end

--function Workshopxlnew:HandlBtnClickedXlQh(e)
--	self.eXlType = 1
--	self:RefreshTwoBtnSel()
--end

function Workshopxlnew:CheckBoxStateChanged(args)
    local state = self.checkbox:isSelected()
    if state then
        self.eXlType = 1
	    self:RefreshTwoBtnSel()
    else
        self.eXlType = 0 --normal --qh
	    self:RefreshTwoBtnSel()
	    self:RefreshNeedMoneyLabel()
    end
end 

--//=========================================
function Workshopxlnew.getInstance()
    if not _instance then
        _instance = Workshopxlnew:new()
        _instance:OnCreate()
    end
    return _instance
end

function Workshopxlnew.getInstanceAndShow()
    if not _instance then
        _instance = Workshopxlnew:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
	_instance:SendRequestAllEndure()
    return _instance
end

function Workshopxlnew.getInstanceNotCreate()
    return _instance
end

function Workshopxlnew.getInstanceOrNot()
	return _instance
end
	
function Workshopxlnew.GetLayoutFileName()
    return "workshopxlnew.layout"
end

function Workshopxlnew:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, Workshopxlnew)
	self:ClearData()
    return self
end

function Workshopxlnew.DestroyDialog()
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

function Workshopxlnew:ClearData()
	self.vItemCellEquip = {}	
	self.eXlType = 0 --0=normal 1=special
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
end

function Workshopxlnew:ClearDataInClose()
	self.vItemCellEquip = nil	
	self.eXlType = 0 --0=normal 1=special
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
end

function Workshopxlnew:ClearCellAll()
	for k, v in pairs(self.vItemCellEquip) do
		LogInfo("Workshopxlnew:ClearCellAll()=k="..k)
		v:DestroyDialog()
	end
	self.vItemCellEquip = {}
end


function Workshopxlnew:OnClose()
	self:ClearCellAll()
	
	Dialog.OnClose(self)
	
	self:ClearDataInClose()
	gGetRoleItemManager().m_EventPackMoneyChange:RemoveScriptFunctor(self.m_hPackMoneyChange)
    gGetRoleItemManager():RemoveLuaItemNumChangeNotify(self.m_hItemNumChangeNotify)
	_instance = nil
end

return Workshopxlnew


