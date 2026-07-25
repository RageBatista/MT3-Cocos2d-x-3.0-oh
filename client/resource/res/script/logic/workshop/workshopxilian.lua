require "utils.mhsdutils"
require "logic.dialog"
require "logic.workshop.workshopitemcell4"
require "logic.workshop.workshophelper"

require "utils.commonutil"

----坐骑洗炼

XiLianDlg = {}
setmetatable(XiLianDlg, Dialog)
XiLianDlg.__index = XiLianDlg
local _instance;


function XiLianDlg.OnDzResult()
	LogInfo("XiLianDlg.OnDzResult()")
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


function XiLianDlg:RefreshItemTips(item)
	LogInfo("XiLianDlg.RefreshItemTips")
	local bUseLocal = true  
	self:RefreshRichBox(bUseLocal)
end



function XiLianDlg.OnFailTimesResult(protocol)
	
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

function XiLianDlg.OnRefreshAllResult(protocol)
	LogInfo(" XiLianDlg.OnRefreshAllResult(protocol)")
	if not _instance then
		return
	end
	_instance:RefreshEquip()
	_instance:RefreshEquipListState()
end



function XiLianDlg.OnXlResult()
	if not _instance then
		return
	end

	_instance:RefreshRichBox(false)
	--_instance:RefreshEquipList()
	_instance:RefreshEquipListState()

	_instance:RefreshEquip()

end



--[[ 
	<variable name="bagid" type="int" validator="value=[1,)" />
    <variable name="itemkey" type="int" validator="value=[1,)" />
    <variable name="tips" type="octets" />
--]]
function XiLianDlg.OnRefreshOneItemInfoResult(protocol)
	LogInfo("XiLianDlg.OnRefreshOneItemInfoResult")
	if not _instance then
		return
	end
	_instance:RefreshEquip()
end

--[[
function XiLianDlg:GetOnePropertyData(nPropertyId,nValue,mapOnePeoperty)
    local propertyCfg =  BeanConfigManager.getInstance():GetTableByName("item.cattributedesconfig"):getRecorder(nPropertyId)
	if propertyCfg ~= nil then
		mapOnePeoperty.strTitleName = propertyCfg.name
		mapOnePeoperty.strValue = "+"..tostring(nValue)
	end
end
--]]


function XiLianDlg:OnCreate()
    Dialog.OnCreate(self)
	SetPositionOfWindowWithLabel1(self:GetWindow())
	self.m_hItemNumChangeNotify = gGetRoleItemManager():InsertLuaItemNumChangeNotify(XiLianDlg.OnItemNumChange)
	self.m_hPackMoneyChange = gGetRoleItemManager().m_EventPackMoneyChange:InsertScriptFunctor(XiLianDlg.OnMoneyChange)
	--[[
	self.m_AddItemInBag = gGetRoleItemManager().m_EventAddPackItem:InsertScriptFunctor(XiLianDlg.AddItemInBag)
	self.m_DelItemInBag = gGetRoleItemManager().EventDelPackItem:InsertScriptFunctor(XiLianDlg.DelItemInBag)
	self.m_AddItemInEquipBag = gGetRoleItemManager().m_EventAddEquipItem:InsertScriptFunctor(XiLianDlg.AddItemInEquipBag)
	self.m_DelItemInEquipBag = gGetRoleItemManager().m_EventDelEquipItem:InsertScriptFunctor(XiLianDlg.DelItemInEquipBag)
	--]]
	
	self:InitUI()
	self.bLoadUI = true
	
	self:RefreshEquipList()
	self:RefreshEquipCellSel()
	self:RefreshEquip()
	self:SendRequestAllEndure()
	self.eXlType = 3
	self:RefreshTwoBtnSel()

    self:ResetEquip()
end


function XiLianDlg.AddItemInBag(nItemKey)
	if not _instance then
		return
	end
	
end

function XiLianDlg.DelItemInBag(nItemKey)
	if not _instance then
		return
	end
end

function XiLianDlg.AddItemInEquipBag(nItemKey)
	if not _instance then
		return
	end
end

function XiLianDlg.DelItemInEquipBag(nItemKey)
	if not _instance then
		return
	end
end


function XiLianDlg.OnMoneyChange()
	if not _instance then
		return
	end
	_instance:RefreshNeedMoneyLabel()
end

function XiLianDlg:AddCell(eBagType,nItemKey)
	
end

function XiLianDlg:DeleteCell(eBagType,nItemKey)
	
end

function XiLianDlg:RefreshAllCellSortData()
end


function XiLianDlg:SortAllCell()
end

function XiLianDlg:RefreshAllCellPos()
end

function XiLianDlg:GetCell(eBagType,nEquipKey)
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


function XiLianDlg.OnItemNumChange(eBagType, nItemKey, nItemId)
	if _instance == nil then
		return
	end
	_instance:RefreshEquip()
	--LogInsane(string.format("XiLianDlg.OnItemNumChange(%d, %d, %d)", bagid, itemkey, itembaseid))
end


function XiLianDlg:RefreshUI(nBagId,nItemKey)
    if not nBagId then
        nBagId = -1
        nItemKey = -1
    end
	self:RefreshEquipList(nBagId,nItemKey)
	self:RefreshEquipCellSel()
	self:RefreshEquip()
	self:SendRequestAllEndure()
	self.eXlType = 3
	self:RefreshTwoBtnSel()
	--self.BtnMakeQh:SetPushState(false)
	--self.BtnMakeQh:setVisible(false)
end

function XiLianDlg:InitUI()
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.ScrollEquip = CEGUI.toScrollablePane(winMgr:getWindow("l/left"))
	self.ScrollEquip:setMousePassThroughEnabled(true)
	self.ScrollEquip:subscribeEvent("NextPage", XiLianDlg.OnNextPage, self)
	self.ItemCellTarget = CEGUI.toItemCell(winMgr:getWindow("l/right/part2/item2"))
	self.ImageTargetCanMake = winMgr:getWindow("l/right/part2/item2/yizhuangbei") 
	self.LabTargetName = winMgr:getWindow("l/right/part2/name2") 
	self.LabTargetNamec = winMgr:getWindow("l/right/part2/name21") 
	--self.LabTypeNameTarget = winMgr:getWindow("l/bg/mingcheng")
	self.richBoxEquip = CEGUI.toRichEditbox(winMgr:getWindow("l/right/shuxinglist/box"))
	self.richBoxEquip:subscribeEvent("MouseButtonUp", XiLianDlg.HandlBtnClickInfoClose) 

	self.richBoxEquip:setReadOnly(true)
	
	
	self.btnInfo = CEGUI.toPushButton(winMgr:getWindow("l/right/shuxinglist/tipsxiangqing"))
	self.btnInfo:subscribeEvent("MouseButtonDown", XiLianDlg.PreHandlBtnClickInfo, self) 
    self.btnInfo:subscribeEvent("MouseButtonUp", XiLianDlg.HandlBtnClickInfo, self) 
    --self.btnInfo:setVisible(false)
	
	
	self.xx = CEGUI.toPushButton(winMgr:getWindow("l"))
	self.xx:subscribeEvent("MouseButtonUp", XiLianDlg.HandlBtnClickInfoClose) 
	self.xx2 = CEGUI.toPushButton(winMgr:getWindow("l/right"))
	self.xx2:subscribeEvent("MouseButtonUp", XiLianDlg.HandlBtnClickInfoClose) 
	self.xx3 = CEGUI.toPushButton(winMgr:getWindow("l/right/part2/line1"))
	self.xx3:subscribeEvent("MouseButtonUp", XiLianDlg.HandlBtnClickInfoClose) 
	self.xx5 = CEGUI.toPushButton(winMgr:getWindow("l/left"))
	self.xx5:subscribeEvent("MouseButtonUp", XiLianDlg.HandlBtnClickInfoClose) 
	
	
	
	--self.richBoxEquip:setWordWrapping(false) --
	--self.BtnMake = CEGUI.toPushButton(winMgr:getWindow("l/right/putongbutton"))
	--GroupButton toGroupButton
	self.BtnMake = CEGUI.toGroupButton(winMgr:getWindow("l/right/putongbutton"))
--	self.BtnMake:subscribeEvent("MouseClick", XiLianDlg.HandlBtnClickedXlnormal, self)

	self.BtnMakeQh = CEGUI.toPushButton(winMgr:getWindow("l/right/teshubutton"))
--	self.BtnMakeQh = CEGUI.toGroupButton(winMgr:getWindow("l/right/teshubutton"))
--	self.BtnMakeQh:subscribeEvent("MouseClick", XiLianDlg.HandlBtnClickedXlQh, self)
    self.checkbox = CEGUI.toCheckbox(winMgr:getWindow("l/right/part2/line1/gou"))
    self.checkbox:subscribeEvent("MouseButtonUp", XiLianDlg.CheckBoxStateChanged, self)

	self.ItemCellNeedItem1 = CEGUI.toItemCell(winMgr:getWindow("l/right/cailiaolist/item1"))
	self.LabNameNeedItem1 = winMgr:getWindow("l/right/cailiaolist/name1")
	self.ItemCellNeedItem2 = CEGUI.toItemCell(winMgr:getWindow("l/right/cailiaolist/item2"))
	self.LabNameNeedItem2 = winMgr:getWindow("l/right/cailiaolist/name2")
	--self.LabFailTimes = winMgr:getWindow("l/right/shuxinglist/9")
	self.needMoneyLabel = winMgr:getWindow("l/right/bg1/one") --l/right/bg1/one
	self.ownMoneyLabel = winMgr:getWindow("l/right/bg11/2") --l/right/bg11/2
	self.ImageNeedMoneyIcon = winMgr:getWindow("l/right/yinbi")
	self.ImageOwnMoneyIcon = winMgr:getWindow("l/right/yinbi2")
	self.BtnXl = CEGUI.toPushButton(winMgr:getWindow("l/right/button"))
	self.BtnXl:subscribeEvent("Clicked", XiLianDlg.HandlBtnClickedXl, self)
	self.labelNormalDesc = winMgr:getWindow("l/right/part2/line1/text")
	self.labelSpecialDesc = winMgr:getWindow("l/right/part2/line1/textteshu1")
	
	self.tipsButton = CEGUI.toPushButton(winMgr:getWindow("1/shuxinglist/tipsxiangqing1"))       --tips 升级tips
    self.tipsButton:subscribeEvent("Clicked", XiLianDlg.handleClickTipButtonc3, self)
	
	self.m_btnAddzuojinjie = CEGUI.toPushButton(winMgr:getWindow("l/xiliancc"))---坐骑升级	
	self.m_btnAddzuojinjie:subscribeEvent("Clicked", XiLianDlg.handleAddtBtnzuoqijj, self)---坐骑升级
	
	self.m_btnAddzuopinzhi = CEGUI.toPushButton(winMgr:getWindow("1/right/button11"))---坐骑品质	
	self.m_btnAddzuopinzhi:subscribeEvent("Clicked", XiLianDlg.handleAddtBtnzuoqipz, self)---坐骑品质
	
	self.ItemCellNeedItem1:subscribeEvent("TableClick", Workshopmanager.HandleClickItemCell, Workshopmanager)
	self.ItemCellNeedItem2:subscribeEvent("TableClick", Workshopmanager.HandleClickItemCell, Workshopmanager)

    self.BtnExchange = CEGUI.toPushButton(winMgr:getWindow("l/right/jiahao")) --l/right/jiahao
	self.BtnExchange:subscribeEvent("Clicked", XiLianDlg.HandleExchangeBtnClicked, self)
end

function XiLianDlg:HandleExchangeBtnClicked(e)
	local dlg = require "logic.currency.stonegoldexchangesilverdlg".getInstanceAndShow()
	dlg:GetWindow():setAlwaysOnTop(true)

	return true
	
end


 function XiLianDlg:PreHandlBtnClickInfo(e)
 	--��ֹ�����Ʒ�رձ������--by yangbin
	local insetdlg = require("logic.chat.insertdlg").getInstanceNotCreate()
	if insetdlg then
		insetdlg.willCheckTipsWnd = true
	end
 end
 
 function XiLianDlg:HandlBtnClickInfoClose()
	local equipDlg = require("logic.tips.equipinfotips").getInstanceAndShow()
	equipDlg:DestroyDialog()
 end

 function XiLianDlg:HandlBtnClickInfo(e)
	self.willCheckTipsWnd = false

	--��ֹ�����Ʒ����رձ������--by yangbin
	local insetdlg = require("logic.chat.insertdlg").getInstanceNotCreate()
	if insetdlg then
		insetdlg.willCheckTipsWnd = true
	end

    require("logic.tips.equipcomparetipdlg").DestroyDialog()
    
    local equipDlg = require("logic.tips.equipinfotips").getInstanceAndShow()
    equipDlg:RefreshWithItem(self:GetCurEquipData())
    equipDlg:RefreshSize()
 end

function XiLianDlg:GetCurServerKey()
	local cellEquipItem = self:GetCellWithIndex(self.nItemCellSelId)
	if not cellEquipItem then
		return 0
	end
	return cellEquipItem.nServerKey
end

function XiLianDlg:handleAddtBtnzuoqijj(args)-----坐骑洗炼
   require "logic.workshop.workshopaq1".getInstanceAndShow()
    XiLianDlg.DestroyDialog()
end

function XiLianDlg:handleAddtBtnzuoqipz(args)-----坐骑品质
   require "logic.workshop.zuoqipinzhi".getInstanceAndShow()
    XiLianDlg.DestroyDialog()
end

function XiLianDlg:handleClickTipButtonc3(args)
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

--ϴ��
function XiLianDlg:HandlBtnClickedXl(e)
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

        if self.eXlType == 3 then 
            if nFailTimes >= nFialTimesMax then
                local strDadaozuidazishuzi = MHSD_UTILS.get_resstring(11291) --
			    GetCTipsManager():AddMessageTip(strDadaozuidazishuzi)
                return
            end
        end
--[[
		if nCurEndure>=nEndureMax then
			local strShowTip = MHSD_UTILS.get_resstring(11012) --�;�����
			GetCTipsManager():AddMessageTip(strShowTip)
			return
		end]]
	end
	--//=======================================
	
	    --LogInfo("111111111:")
--[[
	local bCanXiuli,strResult = self:IsCanXiuli()
	if bCanXiuli==false then
		GetCTipsManager():AddMessageTip(strResult)
		return 
	end]]

    ----------------------------------
    local bCheckShow = self:checkShowItemOverNeed()
    if bCheckShow == true then
        return
    end
    -----------------------------------
	--self.eXlType = 1 --3=normal 4=special
	local p = require "protodef.fire.pb.item.cxiuliequipitem":new()
	p.repairtype = self.eXlType --normal
	p.keyinpack = nEquipKey
	local nBagType = eBagType
	p.packid = nBagType --fire.pb.item.BagTypes.BAG
	require "manager.luaprotocolmanager":send(p)
end	

function XiLianDlg:checkShowItemOverNeed()
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

function XiLianDlg:clickConfirmBoxOk_xl()
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

function XiLianDlg:clickConfirmBoxCancel_xl()
gGetMessageManager():CloseConfirmBox(eConfirmNormal,false)

end

function XiLianDlg:SendRequestAllEndure()
	local p1 = require "protodef.fire.pb.item.creqallnaijiu":new()
	p1.packid = fire.pb.item.BagTypes.BAG
	require "manager.luaprotocolmanager":send(p1)
	local p2 = require "protodef.fire.pb.item.creqallnaijiu":new()
	p2.packid = fire.pb.item.BagTypes.EQUIP
	require "manager.luaprotocolmanager":send(p2)
end



function XiLianDlg:RefreshEquipCellSel()
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

function XiLianDlg:RefreshEquipListState()
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

function XiLianDlg:OnNextPage(args)
	local wsManager = Workshopmanager.getInstance()
	wsManager.nXilianPage = wsManager.nXilianPage + 1
	local vEquipKeyOrderIndex = {}
    wsManager:GetXiLianEquipWithPage(vEquipKeyOrderIndex,wsManager.nXilianPage)
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

function XiLianDlg:CreateEquipCell(equipCellData)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local nIndexEquip = #self.vItemCellEquip + 1
	local nEquipKey = equipCellData.nEquipKey
		local eBagType = equipCellData.eBagType
		local equipData = roleItemManager:FindItemByBagAndThisID(nEquipKey,eBagType)
		if equipData then
			local itemAttrCfg = equipData:GetBaseObject()

			local prefix = "XiLianDlg_equip"..nIndexEquip
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
			cellEquipItem.btnBg:subscribeEvent("MouseClick", XiLianDlg.HandleClickedItem,self)
		end
end

function XiLianDlg:RefreshEquipList(nBagId,nItemKey)
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
    wsManager:GetXiLianEquipWithPage(vEquipKeyOrderIndex,wsManager.nXilianPage)
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

function XiLianDlg:GetCellWithIndex(nIndex)
	if nIndex > #self.vItemCellEquip then
		return nil
	end
	return self.vItemCellEquip[nIndex]
end

function XiLianDlg:GetCurItemBagType()
	local cellEquipItem = self:GetCellWithIndex(self.nItemCellSelId)
	if not cellEquipItem then
		return 0
	end
	return cellEquipItem.eBagType
end

function XiLianDlg:HandleClickedItem(e)
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

function XiLianDlg:ResetEquip()
	self.ItemCellTarget:SetImage(nil)
    SetItemCellBoundColorByQulityItemWithIdtm(self.ItemCellTarget,0)

    self.ImageTargetCanMake:setVisible(false)
	self.LabTargetName:setText("")
	self.LabTargetNamec:setText("")
	self.ItemCellNeedItem1:SetTextUnit("")
	self.LabNameNeedItem1:setText("")
	self.ItemCellNeedItem2:SetTextUnit("")
	self.LabNameNeedItem2:setText("")
	self.needMoneyLabel:setText("")
	--self.ownMoneyLabel:setText(tostring(nUserMoney))
end

function XiLianDlg:getXlItemIdAndNeedNum(nEquipId)
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

function XiLianDlg:RefreshEquip()
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
	print("nEquipId====>%d %d,%d",nEquipId,nNeedItemId1,nNeedItemNum1 )
	local nNeedItemId2 = equipPropertyCfg.tsxlcailiaoid
	local nNeedItemNum2 = equipPropertyCfg.tsxlcailiaonum
	local needItemCfg1 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(500120)
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
	self.LabTargetNamec:setText(itemAttrCfg.namecc1)
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

function XiLianDlg:GetCurEquipData()
	local nServerKey = self:GetCurServerKey()
	local eBagType = self:GetCurItemBagType()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local equipData = roleItemManager:FindItemByBagAndThisID(nServerKey,eBagType)
	if not equipData then
		return nil
	end
	return equipData
end

function XiLianDlg:RefreshRichBox(bUseLocal)
	LogInfo(" XiLianDlg.RefreshRichBox(bUseLocal)")
	local equipData = self:GetCurEquipData()
	if not equipData then
		return 
	end
	local eBagType = self:GetCurItemBagType()
	local bHaveData,strParseText = WorkshopHelper.GetMapPropertyWithEquipDatazqxl(equipData,bUseLocal,eBagType, true)
	if bHaveData then
		self.richBoxEquip:Clear()
		self.richBoxEquip:show()
		self.richBoxEquip:AppendParseText(CEGUI.String(strParseText))
		self.richBoxEquip:Refresh()
	end
end

function XiLianDlg:GetCurNeedMoney()
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
	--self.eXlType = 3 --normal --qh
	local nNeedMoney = 0
	if self.eXlType == 3 then
		nNeedMoney = nNeedMoney1
	else
		nNeedMoney = nNeedMoney2
	end
	return nNeedMoney
end

function XiLianDlg:RefreshNeedMoneyLabel()
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
	--self.eXlType = 3 --normal --qh
	local nNeedMoney = 0
	if self.eXlType == 3 then
		nNeedMoney = nNeedMoney1
	else
		nNeedMoney = nNeedMoney2
	end
	local nUserMoney = roleItemManager:GetPackMoney()
	--//===========================
	if nUserMoney >= nNeedMoney then
		--("TextColours", money >= cfg.yinliang and "FFFFFFFF" or "FFFF0000")
		self.needMoneyLabel:setProperty("TextColours", "ffffffff")
	else
		self.needMoneyLabel:setProperty("TextColours", "ffff0000")
	end
	
	local strNeedMoney = require("logic.workshop.workshopmanager").getNumStrWithThousand(nNeedMoney)
	
	self.needMoneyLabel:setText(strNeedMoney)
	local strUserMoney = require("logic.workshop.workshopmanager").getNumStrWithThousand(nUserMoney)
	self.ownMoneyLabel:setText(strUserMoney)
end

function XiLianDlg:RefreshEquipDetailInfo(vProperty)
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

function XiLianDlg:GetLabelWithIndex(nIndex)
	if nIndex > #self.vLabelTitleProperty then 
		return nil
	end
	return self.vLabelTitleProperty[nIndexLabel], self.vLabelProperty[nIndexLabel]
end

--function XiLianDlg:HandlBtnClickedXlnormal(e)
--	self.eXlType = 3 --normal --qh
--	self:RefreshTwoBtnSel()
--	self:RefreshNeedMoneyLabel()
--end

function XiLianDlg:IsCanXiuli()
	--self.eXlType = 3 --normal --qh
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
		LogInfo("XiLianDlg:IsCanXiuli()=nNeedItemId1="..nNeedItemId1)
		return false, strResult
	end
	if self.eXlType == 3 then 
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
			LogInfo("XiLianDlg:IsCanXiuli()=nNeedItemId2="..nNeedItemId2)
			return false, strResult
		end
	end
	return true, strResult
end

function XiLianDlg:RefreshTwoBtnSel()
	--:setSelected(true)
	
	--self.BtnMake:SetPushState(false)
	--self.BtnMakeQh:SetPushState(false)
	
--	self.BtnMake:setSelected(false)
--	self.BtnMakeQh:setSelected(false)
	LogInfo("XiLianDlg:RefreshTwoBtnSel()="..self.eXlType)
	
	local strTitleCur = ""
	if self.eXlType == 3 then
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

--function XiLianDlg:HandlBtnClickedXlQh(e)
--	self.eXlType = 1
--	self:RefreshTwoBtnSel()
--end

function XiLianDlg:CheckBoxStateChanged(args)
    local state = self.checkbox:isSelected()
    if state then
        self.eXlType = 4
	    self:RefreshTwoBtnSel()
    else
        self.eXlType = 3 --normal --qh
	    self:RefreshTwoBtnSel()
	    self:RefreshNeedMoneyLabel()
    end
end 

--//=========================================
function XiLianDlg.getInstance()
    if not _instance then
        _instance = XiLianDlg:new()
        _instance:OnCreate()
    end
    return _instance
end

function XiLianDlg.getInstanceAndShow()
    if not _instance then
        _instance = XiLianDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
	_instance:SendRequestAllEndure()
    return _instance
end

function XiLianDlg.getInstanceNotCreate()
    return _instance
end

function XiLianDlg.getInstanceOrNot()
	return _instance
end
	
function XiLianDlg.GetLayoutFileName()
    return "zhuangbeixilian.layout"
end

function XiLianDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, XiLianDlg)
	self:ClearData()
    return self
end

function XiLianDlg.DestroyDialog()
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

function XiLianDlg:ClearData()
	self.vItemCellEquip = {}	
	self.eXlType = 3 --3=normal 4=special
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
end

function XiLianDlg:ClearDataInClose()
	self.vItemCellEquip = nil	
	self.eXlType = 3 --3=normal 4=special
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
end

function XiLianDlg:ClearCellAll()
	for k, v in pairs(self.vItemCellEquip) do
		LogInfo("XiLianDlg:ClearCellAll()=k="..k)
		v:DestroyDialog()
	end
	self.vItemCellEquip = {}
end


function XiLianDlg:OnClose()
	self:ClearCellAll()
	
	Dialog.OnClose(self)
	
	self:HandlBtnClickInfoClose()

	self:ClearDataInClose()
	gGetRoleItemManager().m_EventPackMoneyChange:RemoveScriptFunctor(self.m_hPackMoneyChange)
    gGetRoleItemManager():RemoveLuaItemNumChangeNotify(self.m_hItemNumChangeNotify)
	_instance = nil
end

return XiLianDlg


