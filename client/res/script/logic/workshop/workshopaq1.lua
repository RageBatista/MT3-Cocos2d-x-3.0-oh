require "utils.mhsdutils"
require "logic.dialog"
require "logic.workshop.Workshopitemcell4"
require "logic.workshop.workshophelper"

require "utils.commonutil"

AdvancedEquip1Dlg = {}
setmetatable(AdvancedEquip1Dlg, Dialog)
AdvancedEquip1Dlg.__index = AdvancedEquip1Dlg
local _instance;


function AdvancedEquip1Dlg.OnDzResult()
	if not _instance then
		return
	end
	--[[
	--IsVisible 	-]]
	if _instance.bLoadUI then
		_instance:RefreshEquipList()
		_instance:RefreshEquipCellSel()
		_instance:RefreshEquip()
		_instance:SendRequestAllEndure()
	end

end


function AdvancedEquip1Dlg:RefreshItemTips(item)
	local bUseLocal = true  
	self:RefreshRichBox(bUseLocal)
end



function AdvancedEquip1Dlg.OnFailTimesResult(protocol)
	
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

function AdvancedEquip1Dlg.OnRefreshAllResult(protocol)
	LogInfo(" AdvancedEquip1Dlg.OnRefreshAllResult(protocol)")
	if not _instance then
		return
	end
	_instance:RefreshEquip()
	_instance:RefreshEquipListState()
end



function AdvancedEquip1Dlg.OnXlResult()
	if not _instance then
		return
	end

	_instance:RefreshRichBox(false)
	_instance:RefreshEquipList()
	_instance:RefreshEquipListState()

	_instance:RefreshEquip()

end



--[[ 
	<variable name="bagid" type="int" validator="value=[1,)" />
    <variable name="itemkey" type="int" validator="value=[1,)" />
    <variable name="tips" type="octets" />
--]]
function AdvancedEquip1Dlg.OnRefreshOneItemInfoResult(protocol)
	LogInfo("AdvancedEquip1Dlg.OnRefreshOneItemInfoResult")
	if not _instance then
		return
	end
	_instance:RefreshEquip()
end

--[[
function AdvancedEquip1Dlg:GetOnePropertyData(nPropertyId,nValue,mapOnePeoperty)
    local propertyCfg =  BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(nPropertyId)
	if propertyCfg ~= nil then
		mapOnePeoperty.strTitleName = propertyCfg.name
		mapOnePeoperty.strValue = "+"..tostring(nValue)
	end
end
--]]


function AdvancedEquip1Dlg:OnCreate()
    Dialog.OnCreate(self)
	SetPositionOfWindowWithLabel1(self:GetWindow())
	self.m_hItemNumChangeNotify = gGetRoleItemManager():InsertLuaItemNumChangeNotify(AdvancedEquip1Dlg.OnItemNumChange)
	self.m_hPackMoneyChange = gGetRoleItemManager().m_EventPackMoneyChange:InsertScriptFunctor(AdvancedEquip1Dlg.OnMoneyChange)
	--[[
	self.m_AddItemInBag = gGetRoleItemManager().m_EventAddPackItem:InsertScriptFunctor(AdvancedEquip1Dlg.AddItemInBag)
	self.m_DelItemInBag = gGetRoleItemManager().EventDelPackItem:InsertScriptFunctor(AdvancedEquip1Dlg.DelItemInBag)
	self.m_AddItemInEquipBag = gGetRoleItemManager().m_EventAddEquipItem:InsertScriptFunctor(AdvancedEquip1Dlg.AddItemInEquipBag)
	self.m_DelItemInEquipBag = gGetRoleItemManager().m_EventDelEquipItem:InsertScriptFunctor(AdvancedEquip1Dlg.DelItemInEquipBag)
	--]]
	
	self:InitUI()
	self.bLoadUI = true
	
	self:RefreshEquipList()
	self:RefreshEquipCellSel()
	self:RefreshEquip()
	self:SendRequestAllEndure()
	self.eXlType = 2
	self:RefreshTwoBtnSel()

    self:ResetEquip()
end


function AdvancedEquip1Dlg.AddItemInBag(nItemKey)
	if not _instance then
		return
	end
	
end

function AdvancedEquip1Dlg.DelItemInBag(nItemKey)
	if not _instance then
		return
	end
end

function AdvancedEquip1Dlg.AddItemInEquipBag(nItemKey)
	if not _instance then
		return
	end
end

function AdvancedEquip1Dlg.DelItemInEquipBag(nItemKey)
	if not _instance then
		return
	end
end


function AdvancedEquip1Dlg.OnMoneyChange()
	if not _instance then
		return
	end
	_instance:RefreshNeedMoneyLabel()
end

function AdvancedEquip1Dlg:AddCell(eBagType,nItemKey)
	
end

function AdvancedEquip1Dlg:DeleteCell(eBagType,nItemKey)
	
end

function AdvancedEquip1Dlg:RefreshAllCellSortData()
end


function AdvancedEquip1Dlg:SortAllCell()
end

function AdvancedEquip1Dlg:RefreshAllCellPos()
end

function AdvancedEquip1Dlg:GetCell(eBagType,nEquipKey)
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


function AdvancedEquip1Dlg.OnItemNumChange(eBagType, nItemKey, nItemId)
	if _instance == nil then
		return
	end
	_instance:RefreshEquip()
	--LogInsane(string.format("AdvancedEquip1Dlg.OnItemNumChange(%d, %d, %d)", bagid, itemkey, itembaseid))
end


function AdvancedEquip1Dlg:RefreshUI(nBagId,nItemKey)
    if not nBagId then
        nBagId = -1
        nItemKey = -1
    end
	self:RefreshEquipList(nBagId,nItemKey)
	self:RefreshEquipCellSel()
	self:RefreshEquip()
	self:SendRequestAllEndure()
	self.eXlType = 2
	self:RefreshTwoBtnSel()
	--self.BtnMakeQh:SetPushState(false)
	--self.BtnMakeQh:setVisible(false)
end

function AdvancedEquip1Dlg:InitUI()
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.ScrollEquip = CEGUI.toScrollablePane(winMgr:getWindow("advancedequip/left"))
	self.ScrollEquip:setMousePassThroughEnabled(true)
	self.ScrollEquip:subscribeEvent("NextPage", AdvancedEquip1Dlg.OnNextPage, self)
	self.ItemCellTarget = CEGUI.toItemCell(winMgr:getWindow("advancedequip/right/part2/item2"))
	self.ImageTargetCanMake = winMgr:getWindow("advancedequip/right/part2/item2/yizhuangbei") 
	self.LabTargetName = winMgr:getWindow("advancedequip/right/part2/name2")
	self.LabTargetName1 = winMgr:getWindow("advancedequip/right/part2/dengji2") 
	self.LabTargetNamec = winMgr:getWindow("advancedequip/right/part2/name3")
	self.LabTargetNamecc = winMgr:getWindow("advancedequip/right/part2/dengji1")
	
	--self.LabTypeNameTarget = winMgr:getWindow("advancedequip/bg/mingcheng")
	self.richBoxEquip = CEGUI.toRichEditbox(winMgr:getWindow("advancedequip/right/shuxinglist/box"))
	self.richBoxEquip:subscribeEvent("MouseButtonUp", AdvancedEquip1Dlg.HandlBtnClickInfoClose) 

	self.richBoxEquip:setReadOnly(true)
	
	
	self.btnInfo = CEGUI.toPushButton(winMgr:getWindow("advancedequip/right/shuxinglist/tipsxiangqing"))
	self.btnInfo:subscribeEvent("MouseButtonDown", AdvancedEquip1Dlg.PreHandlBtnClickInfo, self) 
    self.btnInfo:subscribeEvent("MouseButtonUp", AdvancedEquip1Dlg.HandlBtnClickInfo, self) 
    --self.btnInfo:setVisible(false)
	
	
	self.xx = CEGUI.toPushButton(winMgr:getWindow("advancedequip"))
	self.xx:subscribeEvent("MouseButtonUp", AdvancedEquip1Dlg.HandlBtnClickInfoClose) 
	self.xx2 = CEGUI.toPushButton(winMgr:getWindow("advancedequip/right"))
	self.xx2:subscribeEvent("MouseButtonUp", AdvancedEquip1Dlg.HandlBtnClickInfoClose) 
	self.xx3 = CEGUI.toPushButton(winMgr:getWindow("advancedequip/right/part2/line1"))
	self.xx3:subscribeEvent("MouseButtonUp", AdvancedEquip1Dlg.HandlBtnClickInfoClose) 
	self.xx5 = CEGUI.toPushButton(winMgr:getWindow("advancedequip/left"))
	self.xx5:subscribeEvent("MouseButtonUp", AdvancedEquip1Dlg.HandlBtnClickInfoClose) 
	
    self.tipsButton = CEGUI.toPushButton(winMgr:getWindow("advancedequip/shuxinglist/tipsxiangqing1"))       --tips 升级tips
    self.tipsButton:subscribeEvent("Clicked", AdvancedEquip1Dlg.handleClickTipButtonc1, self)
	
	self.zuoqixl = CEGUI.toPushButton(winMgr:getWindow("advancedequip/right/button1"))       --打开坐骑洗炼界面
	self.zuoqixl:subscribeEvent("Clicked", AdvancedEquip1Dlg.zuoqixilian, self)
		
	self.zuoqijl = CEGUI.toPushButton(winMgr:getWindow("advancedequip/right/button11"))       --打开坐骑品质界面
	self.zuoqijl:subscribeEvent("Clicked", AdvancedEquip1Dlg.zuoqijinglian, self)
	

	self.BtnMake = CEGUI.toGroupButton(winMgr:getWindow("advancedequip/right/putongbutton"))

	self.BtnMakeQh = CEGUI.toPushButton(winMgr:getWindow("advancedequip/right/teshubutton"))
    self.checkbox = CEGUI.toCheckbox(winMgr:getWindow("advancedequip/right/part2/line1/gou"))
    self.checkbox:subscribeEvent("MouseButtonUp", AdvancedEquip1Dlg.CheckBoxStateChanged, self)
	
	
	--[[self.smokeBg = winMgr:getWindow("advancedequip/Back/flagbg/smoke")-----动画
	local s = self.smokeBg:getPixelSize()
	local flagSmoke = gGetGameUIManager():AddUIEffect(self.smokeBg, "geffect/ui/mt_shengqishi/mt_shengqishi6", true, s.width*0.5, s.height)
	--]]
	
	
	self.ItemCellSrc = CEGUI.toItemCell(winMgr:getWindow("advancedequip/right/part2/line1/tb/item")) 
	self.ItemCellSrc:setMousePassThroughEnabled(false)
	

	self.ItemCellNeedItem1 = CEGUI.toItemCell(winMgr:getWindow("advancedequip/right/cailiaolist/item1"))
	self.LabNameNeedItem1 = winMgr:getWindow("advancedequip/right/cailiaolist/name1")
	self.ItemCellNeedItem2 = CEGUI.toItemCell(winMgr:getWindow("advancedequip/right/cailiaolist/item2"))
	self.LabNameNeedItem2 = winMgr:getWindow("advancedequip/right/cailiaolist/name2")
	self.needMoneyLabel = winMgr:getWindow("advancedequip/right/bg1/one") 
	self.ownMoneyLabel = winMgr:getWindow("advancedequip/right/bg11/2")
	self.ImageNeedMoneyIcon = winMgr:getWindow("advancedequip/right/yinbi")
	self.ImageOwnMoneyIcon = winMgr:getWindow("advancedequip/right/yinbi2")
	self.BtnXl = CEGUI.toPushButton(winMgr:getWindow("advancedequip/right/button"))
	self.BtnXl:subscribeEvent("Clicked", AdvancedEquip1Dlg.HandlBtnClickedXl, self)
	
	

	
	self.labelNormalDesc = winMgr:getWindow("advancedequip/right/part2/line1/text")
	self.labelSpecialDesc = winMgr:getWindow("advancedequip/right/part2/line1/textteshu1")
	
	self.ItemCellNeedItem1:subscribeEvent("TableClick", Workshopmanager.HandleClickItemCell, Workshopmanager)
	self.ItemCellNeedItem2:subscribeEvent("TableClick", Workshopmanager.HandleClickItemCell, Workshopmanager)

    self.BtnExchange = CEGUI.toPushButton(winMgr:getWindow("advancedequip/right/jiahao")) --l/right/jiahao
	self.BtnExchange:subscribeEvent("Clicked", AdvancedEquip1Dlg.HandleExchangeBtnClicked, self)
end

function AdvancedEquip1Dlg:HandleExchangeBtnClicked(e)
	local dlg = require "logic.currency.stonegoldexchangesilverdlg".getInstanceAndShow()
	dlg:GetWindow():setAlwaysOnTop(true)

	return true
	
end



--[[function AdvancedEquip1Dlg:DestroyDialogc()----动画屏蔽
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
--]]


function AdvancedEquip1Dlg:handleClickTipButtonc1(args)
    local tipsStr = ""
    if IsPointCardServer() then
        tipsStr = require("utils.mhsdutils").get_resstring(11813)
    else
        tipsStr = require("utils.mhsdutils").get_resstring(7306)----第一条
    end
    local title = require("utils.mhsdutils").get_resstring(7305)----标题名称
    local tipdlg = require "logic.workshop.tips1".getInstanceAndShow(tipsStr, title)
    SetPositionScreenCenter(tipdlg:GetWindow())
end

 function AdvancedEquip1Dlg:PreHandlBtnClickInfo(e)
	local insetdlg = require("logic.chat.insertdlg").getInstanceNotCreate()
	if insetdlg then
		insetdlg.willCheckTipsWnd = true
	end
 end
 
 function AdvancedEquip1Dlg:HandlBtnClickInfoClose()
	local equipDlg = require("logic.tips.equipinfotips").getInstanceAndShow()
	equipDlg:DestroyDialog()
 end

 function AdvancedEquip1Dlg:HandlBtnClickInfo(e)
	self.willCheckTipsWnd = false
	local insetdlg = require("logic.chat.insertdlg").getInstanceNotCreate()
	if insetdlg then
		insetdlg.willCheckTipsWnd = true
	end

    require("logic.tips.equipcomparetipdlg").DestroyDialog()
    
    local equipDlg = require("logic.tips.equipinfotips").getInstanceAndShow()
    equipDlg:RefreshWithItem(self:GetCurEquipData())
    equipDlg:RefreshSize()
 end

function AdvancedEquip1Dlg:GetCurServerKey()
	local cellEquipItem = self:GetCellWithIndex(self.nItemCellSelId)
	if not cellEquipItem then
		return 0
	end
	return cellEquipItem.nServerKey
end

function AdvancedEquip1Dlg:HandlBtnClickedXl(e)
	if GetBattleManager() and GetBattleManager():IsInBattle() then
        return 
    end
	
	--//=======================================
	local nNeedMoney = self:GetCurNeedMoney()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local nUserMoney = roleItemManager:GetPackMoney()
	
	if nUserMoney < nNeedMoney then
		local nMoneyType = fire.pb.game.MoneyType.MoneyType_SilverCoin
		local nShowNeed = nNeedMoney - nUserMoney
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
	end

    ----------------------------------
    local bCheckShow = self:checkShowItemOverNeed()
    if bCheckShow == true then
        return
    end
    -----------------------------------
	local p = require "protodef.fire.pb.item.cxiuliequipitem":new()
	p.repairtype = self.eXlType --normals
	p.keyinpack = nEquipKey
	local nBagType = eBagType
	p.packid = nBagType --fire.pb.item.BagTypes.BAG
	require "manager.luaprotocolmanager":send(p)
end	

function AdvancedEquip1Dlg:checkShowItemOverNeed()
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

	local nNeedItemId1,nNeedItemNum1  = self:getAQItemIdAndNeedNum(nEquipId)
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

function AdvancedEquip1Dlg:clickConfirmBoxOk_xl()
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

function AdvancedEquip1Dlg:clickConfirmBoxCancel_xl()
gGetMessageManager():CloseConfirmBox(eConfirmNormal,false)

end

function AdvancedEquip1Dlg:zuoqixilian(e)---打开坐骑洗炼界面
   require "logic.workshop.workshopxilian".getInstanceAndShow()
    AdvancedEquip1Dlg.DestroyDialog()
end

function AdvancedEquip1Dlg:zuoqijinglian(args)-----打开坐骑品质界面
   require "logic.workshop.zuoqipinzhi".getInstanceAndShow()
    AdvancedEquip1Dlg.DestroyDialog()
end

function AdvancedEquip1Dlg:SendRequestAllEndure()
	local p1 = require "protodef.fire.pb.item.creqallnaijiu":new()
	p1.packid = fire.pb.item.BagTypes.BAG
	require "manager.luaprotocolmanager":send(p1)
	local p2 = require "protodef.fire.pb.item.creqallnaijiu":new()
	p2.packid = fire.pb.item.BagTypes.EQUIP
	require "manager.luaprotocolmanager":send(p2)
end



function AdvancedEquip1Dlg:RefreshEquipCellSel()
	for i = 1, #self.vItemCellEquip do 
		local equipCell = self.vItemCellEquip[i]
		if equipCell.nClientKey ~= self.nItemCellSelId then
			--equipCell.btnBg:SetPushState(false)
			--equipCell.imageBg:setProperty("Image","" ) 
			equipCell.btnBg:setSelected(false)
		else
			equipCell.btnBg:setSelected(true)
			--equipCell.btnBg:SetPushState(true)
			--equipCell.imageBg:setProperty("Image",Workshopitemcell4.strImageSelName ) 
		end	
	end
end

function AdvancedEquip1Dlg:RefreshEquipListState()
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

function AdvancedEquip1Dlg:OnNextPage(args)
	local wsManager = Workshopmanager.getInstance()
	wsManager.nXilianPage = wsManager.nXilianPage + 1
	local vEquipKeyOrderIndex = {}
    wsManager:GetAqEquipWithPage2(vEquipKeyOrderIndex,wsManager.nXilianPage)
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
		if self.nItemCellSelId ==0 then 
			self.nItemCellSelId = nEquipOrderIndex
		end
	end
	
	self:RefreshEquipListState()
end

function AdvancedEquip1Dlg:CreateEquipCell(equipCellData)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local nIndexEquip = #self.vItemCellEquip + 1
	local nEquipKey = equipCellData.nEquipKey
		local eBagType = equipCellData.eBagType
		local equipData = roleItemManager:FindItemByBagAndThisID(nEquipKey,eBagType)
		if equipData then
			local itemAttrCfg = equipData:GetBaseObject()

			local prefix = "AdvancedEquip1Dlg_equip"..nIndexEquip
			local cellEquipItem = Workshopitemcell4.new(self.ScrollEquip, nIndexEquip - 1,prefix)
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
			local nDurence = 0
			cellEquipItem.labDurance:setText(tostring(nDurence))
			if eBagType==fire.pb.item.BagTypes.EQUIP then
				cellEquipItem.imageHaveEquiped:setVisible(true)
			end
			cellEquipItem.btnBg:subscribeEvent("MouseClick", AdvancedEquip1Dlg.HandleClickedItem,self)
		end
	return true
end

function AdvancedEquip1Dlg:RefreshEquipList(nBagId,nItemKey)
	local wsManager = Workshopmanager.getInstance()
	wsManager:RefreshEquipArray(nBagId,nItemKey)
	wsManager.nXilianPage = 1
	
	self:ClearCellAll()
	
	self.ScrollEquip:cleanupNonAutoChildren()
	self.vItemCellEquip = {}
	--//=============================
	--local vEquipKeyOrder= {}
	--WorkshopHelper.GetEquipArray(vEquipKeyOrder)

	local vEquipKeyOrderIndex = {}
    wsManager:GetAqEquipWithPage2(vEquipKeyOrderIndex,wsManager.nXilianPage)
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

function AdvancedEquip1Dlg:GetCellWithIndex(nIndex)
	if nIndex > #self.vItemCellEquip then
		return nil
	end
	return self.vItemCellEquip[nIndex]
end

function AdvancedEquip1Dlg:GetCurItemBagType()
	local cellEquipItem = self:GetCellWithIndex(self.nItemCellSelId)
	if not cellEquipItem then
		return 0
	end
	return cellEquipItem.eBagType
end

function AdvancedEquip1Dlg:HandleClickedItem(e)
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

function AdvancedEquip1Dlg:ResetEquip()
	self.richBoxEquip:Clear()
	self.richBoxEquip:Refresh()
	self.ItemCellTarget:SetImage(nil)
	self.ItemCellSrc:SetImage(nil)
    SetItemCellBoundColorByQulityItemWithIdtm(self.ItemCellTarget,0)

    self.ImageTargetCanMake:setVisible(false)
	self.LabTargetName:setText("")
	self.LabTargetName1:setText("")
	self.LabTargetNamec:setText("")
	self.LabTargetNamecc:setText("")
	self.ItemCellNeedItem1:SetTextUnit("")
	self.LabNameNeedItem1:setText("")
	self.ItemCellNeedItem2:SetTextUnit("")
	self.LabNameNeedItem2:setText("")
	self.needMoneyLabel:setText("")
	--self.ownMoneyLabel:setText(tostring(nUserMoney))
end

function AdvancedEquip1Dlg:getAQItemIdAndNeedNum(nEquipId)
	local equipPropertyCfg1 = BeanConfigManager.getInstance():GetTableByName("item.cequipitemattr"):getRecorder(nEquipId)
	local nNeedItemId = equipPropertyCfg1.jinjieitemid
	local nNeedItemNum = 0
	local equipPropertyCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nEquipId)
	if not equipPropertyCfg then
		return nNeedItemId,nNeedItemNum
	end
	local needLv = equipPropertyCfg.needLevel
	if needLv >200 then
		nNeedItemNum = equipPropertyCfg1.jinjienum
	else
		nNeedItemNum = equipPropertyCfg1.jinjienum
	end
	return nNeedItemId,nNeedItemNum
end

function AdvancedEquip1Dlg:RefreshEquip()
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
	local jinjieid = equipPropertyCfg.jinjieid
	local jinjieidicon = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(jinjieid)
	if not equipPropertyCfg then
		return 
	end
	--baseAttrId 
	--local nNeedItemId1 = equipPropertyCfg.ptxlcailiaoid
	--local nNeedItemNum1 = equipPropertyCfg.ptxlcailiaonum
	
	local nNeedItemId1,nNeedItemNum1  = self:getAQItemIdAndNeedNum(nEquipId)
	
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
	self.ItemCellTarget:SetImage(gGetIconManager():GetItemIconByID(jinjieidicon.icon))
    SetItemCellBoundColorByQulityItemWithIdzq(self.ItemCellTarget,itemAttrCfg.id)

    if jinjieidicon.nquality > 0 then
        SetItemCellBoundColorByQulityItemzq(self.ItemCellTarget,itemAttrCfg.nquality+1)
    end
    refreshItemCellBind(self.ItemCellTarget,eBagType,nEquipKey)


	self.LabTargetName:setText(jinjieidicon.name)
	self.LabTargetName1:setText(jinjieidicon.namecc1)
	self.LabTargetNamec:setText(itemAttrCfg.name)
	self.LabTargetNamecc:setText(itemAttrCfg.namecc1)
	local nEquipType = jinjieidicon.itemtypeid
	local strTypeName = ""
	local itemTypeCfg = BeanConfigManager.getInstance():GetTableByName("item.citemtype"):getRecorder(nEquipType)
	if itemTypeCfg then
		strTypeName = itemTypeCfg.weapon
	end
	--//===============================
	self.ItemCellNeedItem1:SetImage(gGetIconManager():GetItemIconByID(needItemCfg1.icon))
    SetItemCellBoundColorByQulityItemWithIdzq(self.ItemCellNeedItem1,needItemCfg1.id)

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

function AdvancedEquip1Dlg:GetCurEquipData()
	local nServerKey = self:GetCurServerKey()
	local eBagType = self:GetCurItemBagType()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local equipData = roleItemManager:FindItemByBagAndThisID(nServerKey,eBagType)
	if not equipData then
		return nil
	end
	return equipData
end

function AdvancedEquip1Dlg:RefreshRichBox(bUseLocal)
	local equipData = self:GetCurEquipData()
	if not equipData then
		return 
	end
	local eBagType = self:GetCurItemBagType()
	local bHaveData,strParseText = WorkshopHelper.GetMapPropertyEquipData(equipData,bUseLocal,eBagType, true)
	if bHaveData then
		self.richBoxEquip:Clear()
		self.richBoxEquip:show()
		self.richBoxEquip:AppendParseText(CEGUI.String(strParseText))
		self.richBoxEquip:Refresh()
		--:GetBaseObject()
		--self.ItemCellSrc:setText(gGetIconManager():GetItemNameByID(equipData:GetBaseObject().name))
		self.ItemCellSrc:SetImage(gGetIconManager():GetItemIconByID(equipData:GetBaseObject().icon))
		SetItemCellBoundColorByQulityItemWithIdzq(self.ItemCellSrc,equipData:GetBaseObject().id)
	end
end

function AdvancedEquip1Dlg:GetCurNeedMoney()
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
	local nNeedMoney1 = equipPropertyCfg.jinjiemoney
	local nNeedMoney2 = equipPropertyCfg.jinjiemoney
	--self.eXlType = 3 --normal --qh
	local nNeedMoney = 0
	if self.eXlType == 2 then
		nNeedMoney = nNeedMoney1
	else
		nNeedMoney = nNeedMoney2
	end
	return nNeedMoney
end

function AdvancedEquip1Dlg:RefreshNeedMoneyLabel()
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

	local itemCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nEquipId)
	--baseAttrId 
	local needLv = itemCfg.needLevel
	
	local nNeedMoney = equipPropertyCfg.jinjiemoney;
	if needLv >110 then
		nNeedMoney = equipPropertyCfg.jinjiemoney
	end
	local nUserMoney = CurrencyManager.getOwnCurrencyMount(3)--roleItemManager:GetPackMoney()
	--//===========================
	
	local strNeedMoney = require("logic.workshop.workshopmanager").getNumStrWithThousand(nNeedMoney)
	self.needMoneyLabel:setText(strNeedMoney)
	

	local strUserMoney = require("logic.workshop.workshopmanager").getNumStrWithThousand(nUserMoney)
    
	local roleGold = roleItemManager:GetGold()
    self.ownMoneyLabel:setText(tostring(roleGold))
end

function AdvancedEquip1Dlg:RefreshEquipDetailInfo(vProperty)
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

function AdvancedEquip1Dlg:GetLabelWithIndex(nIndex)
	if nIndex > #self.vLabelTitleProperty then 
		return nil
	end
	return self.vLabelTitleProperty[nIndexLabel], self.vLabelProperty[nIndexLabel]
end

--function AdvancedEquip1Dlg:HandlBtnClickedXlnormal(e)
--	self.eXlType = 2 --normal --qh
--	self:RefreshTwoBtnSel()
--	self:RefreshNeedMoneyLabel()
--end

function AdvancedEquip1Dlg:IsCanXiuli()
	--self.eXlType =2--normal --qh
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
	
	local nNeedItemId1,nNeedItemNum1  = self:getAQItemIdAndNeedNum(nEquipId)

	
	local nNeedItemId2 = equipPropertyCfg.tsxlcailiaoid
	local nNeedItemNum2 = equipPropertyCfg.tsxlcailiaonum
	local nOwnItemNum1 = roleItemManager:GetItemNumByBaseID(nNeedItemId1)
	local nOwnItemNum2 = roleItemManager:GetItemNumByBaseID(nNeedItemId2)
	local nUserMoney = roleItemManager:GetPackMoney()
	local nNeedMoney1 = equipPropertyCfg.jinjiemoney
	local nNeedMoney2 = equipPropertyCfg.jinjiemoney
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
		return false, strResult
	end
	if self.eXlType == 2 then 
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
			return false, strResult
		end
	end
	return true, strResult
end

function AdvancedEquip1Dlg:RefreshTwoBtnSel()
	--:setSelected(true)
	
	--self.BtnMake:SetPushState(false)
	--self.BtnMakeQh:SetPushState(false)
	
--	self.BtnMake:setSelected(false)
--	self.BtnMakeQh:setSelected(false)
	
	local strTitleCur = ""
	if self.eXlType == 2 then
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

--function AdvancedEquip1Dlg:HandlBtnClickedXlQh(e)
--	self.eXlType = 1
--	self:RefreshTwoBtnSel()
--end

function AdvancedEquip1Dlg:CheckBoxStateChanged(args)
    local state = self.checkbox:isSelected()
    if state then
        self.eXlType = 2
	    self:RefreshTwoBtnSel()
    else
        self.eXlType = 2 --normal --qh
	    self:RefreshTwoBtnSel()
	    self:RefreshNeedMoneyLabel()
    end
end 

--//=========================================
function AdvancedEquip1Dlg.getInstance()
    if not _instance then
        _instance = AdvancedEquip1Dlg:new()
        _instance:OnCreate()
    end
    return _instance
end

function AdvancedEquip1Dlg.getInstanceAndShow()
    if not _instance then
        _instance = AdvancedEquip1Dlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
	_instance:SendRequestAllEndure()
    return _instance
end

function AdvancedEquip1Dlg.getInstanceNotCreate()
    return _instance
end

function AdvancedEquip1Dlg.getInstanceOrNot()
	return _instance
end
	
function AdvancedEquip1Dlg.GetLayoutFileName()
    return "zuoqijinjie.layout"
end

function AdvancedEquip1Dlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, AdvancedEquip1Dlg)
	self:ClearData()
    return self
end

function AdvancedEquip1Dlg.DestroyDialog()
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

function AdvancedEquip1Dlg:ClearData()
	self.vItemCellEquip = {}	
	self.eXlType = 2 --3=normal 4=special
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
end

function AdvancedEquip1Dlg:ClearDataInClose()
	self.vItemCellEquip = nil	
	self.eXlType = 2 --3=normal 4=special
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
end

function AdvancedEquip1Dlg:ClearCellAll()
	for k, v in pairs(self.vItemCellEquip) do
		v:DestroyDialog()
	end
	self.vItemCellEquip = {}
end


function AdvancedEquip1Dlg:OnClose()
	self:ClearCellAll()
	
	Dialog.OnClose(self)
	
	self:HandlBtnClickInfoClose()

	self:ClearDataInClose()
	gGetRoleItemManager().m_EventPackMoneyChange:RemoveScriptFunctor(self.m_hPackMoneyChange)
    gGetRoleItemManager():RemoveLuaItemNumChangeNotify(self.m_hItemNumChangeNotify)
	
	CurrencyManager.unregisterTextWidget(self.ownMoneyLabel)
	_instance = nil
end

return AdvancedEquip1Dlg


