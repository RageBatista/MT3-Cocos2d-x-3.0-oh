require "utils.mhsdutils"
require "logic.dialog"
require "logic.workshop.Workshopitemcell4"
require "logic.workshop.workshophelper"

require "utils.commonutil"

ZuoqipinzhiDlg = {}
setmetatable(ZuoqipinzhiDlg, Dialog)
ZuoqipinzhiDlg.__index = ZuoqipinzhiDlg
local _instance;


function ZuoqipinzhiDlg.OnDzResult()
	LogInfo("ZuoqipinzhiDlg.OnDzResult()")
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


function ZuoqipinzhiDlg:RefreshItemTips(item)
	LogInfo("ZuoqipinzhiDlg.RefreshItemTips")
	local bUseLocal = true  
	self:RefreshRichBox(bUseLocal)
end



function ZuoqipinzhiDlg.OnFailTimesResult(protocol)
	
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

function ZuoqipinzhiDlg.OnRefreshAllResult(protocol)
	LogInfo(" ZuoqipinzhiDlg.OnRefreshAllResult(protocol)")
	if not _instance then
		return
	end
	_instance:RefreshEquip()
	_instance:RefreshEquipListState()
end



function ZuoqipinzhiDlg.OnXlResult()
	if not _instance then
		return
	end

	_instance:RefreshRichBox(false)
	--_instance:RefreshEquipList()
	_instance:RefreshEquipListState()

	_instance:RefreshEquip()
		local s = _instance.BtnXl:getPixelSize()---坐骑品质洗炼特效
   gGetGameUIManager():AddUIEffect(_instance.BtnXl, MHSD_UTILS.get_effectpath(11103), false, s.width*0.5, s.height*0.5)

end


function ZuoqipinzhiDlg.OnRefreshOneItemInfoResult(protocol)
	LogInfo("ZuoqipinzhiDlg.OnRefreshOneItemInfoResult")
	if not _instance then
		return
	end
	_instance:RefreshEquip()
end



function ZuoqipinzhiDlg:OnCreate()
    Dialog.OnCreate(self)
	SetPositionOfWindowWithLabel1(self:GetWindow())
	self.m_hItemNumChangeNotify = gGetRoleItemManager():InsertLuaItemNumChangeNotify(ZuoqipinzhiDlg.OnItemNumChange)
	self.m_hPackMoneyChange = gGetRoleItemManager().m_EventPackMoneyChange:InsertScriptFunctor(ZuoqipinzhiDlg.OnMoneyChange)
	self:InitUI()
	self.bLoadUI = true
	self:RefreshEquipList()
	self:RefreshEquipCellSel()
	self:RefreshEquip()
	self:SendRequestAllEndure()
	--self:RefreshTwoBtnSel()
    self:ResetEquip()
end


function ZuoqipinzhiDlg.AddItemInBag(nItemKey)
	if not _instance then
		return
	end
	
end

function ZuoqipinzhiDlg.DelItemInBag(nItemKey)
	if not _instance then
		return
	end
end

function ZuoqipinzhiDlg.AddItemInEquipBag(nItemKey)
	if not _instance then
		return
	end
end

function ZuoqipinzhiDlg.DelItemInEquipBag(nItemKey)
	if not _instance then
		return
	end
end


function ZuoqipinzhiDlg.OnMoneyChange()
	if not _instance then
		return
	end
	_instance:RefreshNeedMoneyLabel()
end

function ZuoqipinzhiDlg:AddCell(eBagType,nItemKey)
	
end

function ZuoqipinzhiDlg:DeleteCell(eBagType,nItemKey)
	
end

function ZuoqipinzhiDlg:RefreshAllCellSortData()
end


function ZuoqipinzhiDlg:SortAllCell()
end

function ZuoqipinzhiDlg:RefreshAllCellPos()
end


function ZuoqipinzhiDlg.OnItemNumChange(eBagType, nItemKey, nItemId)
	if _instance == nil then
		return
	end
	_instance:RefreshEquip()
end


function ZuoqipinzhiDlg:RefreshUI(nBagId,nItemKey)
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

function ZuoqipinzhiDlg:InitUI()
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.ScrollEquip = CEGUI.toScrollablePane(winMgr:getWindow("zuoqipinzhi/left"))
	self.ScrollEquip:setMousePassThroughEnabled(true)
	self.ScrollEquip:subscribeEvent("NextPage", ZuoqipinzhiDlg.OnNextPage, self)
	self.ItemCellTarget = CEGUI.toItemCell(winMgr:getWindow("zuoqipinzhi/right/part2/item2"))
	self.ImageTargetCanMake = winMgr:getWindow("zuoqipinzhi/right/part2/item2/yizhuangbei") 
	self.LabTargetName = winMgr:getWindow("zuoqipinzhi/right/part2/name2") 
	self.LabTargetName1 = winMgr:getWindow("zuoqipinzhi/rightc/partc2/namecc") 
	self.LabTargetNamec = winMgr:getWindow("zuoqipinzhi/right/part2/name22") 
	self.richBoxEquip = CEGUI.toRichEditbox(winMgr:getWindow("zuoqipinzhi/right/shuxinglist/box"))
	self.richBoxEquip:subscribeEvent("MouseButtonUp", ZuoqipinzhiDlg.HandlBtnClickInfoClose) 

	self.richBoxEquip:setReadOnly(true)
	
	
	self.btnInfo = CEGUI.toPushButton(winMgr:getWindow("zuoqipinzhi/right/shuxinglist/tipsxiangqing"))
	self.btnInfo:subscribeEvent("MouseButtonDown", ZuoqipinzhiDlg.PreHandlBtnClickInfo, self) 
    self.btnInfo:subscribeEvent("MouseButtonUp", ZuoqipinzhiDlg.HandlBtnClickInfo, self) 
	
	
	self.xx = CEGUI.toPushButton(winMgr:getWindow("zuoqipinzhi"))
	self.xx:subscribeEvent("MouseButtonUp", ZuoqipinzhiDlg.HandlBtnClickInfoClose) 
	self.xx2 = CEGUI.toPushButton(winMgr:getWindow("zuoqipinzhi/right"))
	self.xx2:subscribeEvent("MouseButtonUp", ZuoqipinzhiDlg.HandlBtnClickInfoClose) 
	self.xx3 = CEGUI.toPushButton(winMgr:getWindow("zuoqipinzhi/right/part2/line1"))
	self.xx3:subscribeEvent("MouseButtonUp", ZuoqipinzhiDlg.HandlBtnClickInfoClose) 
	self.xx5 = CEGUI.toPushButton(winMgr:getWindow("zuoqipinzhi/left"))
	self.xx5:subscribeEvent("MouseButtonUp", ZuoqipinzhiDlg.HandlBtnClickInfoClose) 
	
	
	
	self.BtnMake = CEGUI.toGroupButton(winMgr:getWindow("zuoqipinzhi/right/putongbutton"))

	self.BtnMakeQh = CEGUI.toPushButton(winMgr:getWindow("zuoqipinzhi/right/teshubutton"))
    self.checkbox = CEGUI.toCheckbox(winMgr:getWindow("zuoqipinzhi/right/part2/line1/gou"))
    self.checkbox:subscribeEvent("MouseButtonUp", ZuoqipinzhiDlg.CheckBoxStateChanged, self)
	
	self.tipsButton = CEGUI.toPushButton(winMgr:getWindow("zuoqipinzhi/right/tipsxiangqing1"))       --tips 法宝进阶tips
    self.tipsButton:subscribeEvent("Clicked", ZuoqipinzhiDlg.handleClickTipButtonc2, self)
	
	self.zuoqishengji = CEGUI.toPushButton(winMgr:getWindow("zuoqipinzhi/ccshengji"))       --打开坐骑升级
	self.zuoqishengji:subscribeEvent("Clicked", ZuoqipinzhiDlg.zuoqishengjic, self)
	
	self.zuoqixilian = CEGUI.toPushButton(winMgr:getWindow("zuoqipinzhi/ccpinzhi"))       --打开坐骑洗炼
	self.zuoqixilian:subscribeEvent("Clicked", ZuoqipinzhiDlg.zuoqixilianc, self)
	
	
	self.smokeBg = winMgr:getWindow("zuoqipinzhi/Back/flagbg/smoke")-----动画
	local s = self.smokeBg:getPixelSize()
	local flagSmoke = gGetGameUIManager():AddUIEffect(self.smokeBg, "geffect/ui/mt_shengqishi/mt_shengqishi9", true, s.width*0.5, s.height)

	self.ItemCellNeedItem1 = CEGUI.toItemCell(winMgr:getWindow("zuoqipinzhi/right/cailiaolist/item1"))
	self.LabNameNeedItem1 = winMgr:getWindow("zuoqipinzhi/right/cailiaolist/name1")
	self.ItemCellNeedItem2 = CEGUI.toItemCell(winMgr:getWindow("zuoqipinzhi/right/cailiaolist/item2"))
	self.LabNameNeedItem2 = winMgr:getWindow("zuoqipinzhi/right/cailiaolist/name2")
	self.needMoneyLabel = winMgr:getWindow("zuoqipinzhi/right/bg1/one") --zhuangbeichongzhu/right/bg1/one
	self.ownMoneyLabel = winMgr:getWindow("zuoqipinzhi/right/bg11/2") --zhuangbeichongzhu/right/bg11/2
	self.ImageNeedMoneyIcon = winMgr:getWindow("zuoqipinzhi/right/yinbi")
	self.ImageOwnMoneyIcon = winMgr:getWindow("zuoqipinzhi/right/yinbi2")
	self.BtnXl = CEGUI.toPushButton(winMgr:getWindow("zuoqipinzhi/right/button"))
	self.BtnXl:subscribeEvent("Clicked", ZuoqipinzhiDlg.HandlBtnClickedXl, self)
	

	
	--self.labelNormalDesc = winMgr:getWindow("zuoqipinzhi/right/part2/line1/text")
	self.labelSpecialDesc = winMgr:getWindow("zuoqipinzhi/right/part2/line1/textteshu1")
	self.ItemCellNeedItem1:setVisible(true)
	self.ItemCellNeedItem1:subscribeEvent("TableClick", Workshopmanager.HandleClickItemCell, Workshopmanager)

    self.BtnExchange = CEGUI.toPushButton(winMgr:getWindow("zuoqipinzhi/right/jiahao")) --zhuangbeichongzhu/right/jiahao
	self.BtnExchange:subscribeEvent("Clicked", ZuoqipinzhiDlg.HandleExchangeBtnClicked, self)
end

function ZuoqipinzhiDlg:HandleExchangeBtnClicked(e)
	local dlg = require "logic.currency.stonegoldexchangesilverdlg".getInstanceAndShow()
	dlg:GetWindow():setAlwaysOnTop(true)

	return true
	
end

function ZuoqipinzhiDlg:zuoqishengjic(args)-----坐骑升级
   require "logic.workshop.workshopaq1".getInstanceAndShow()
    ZuoqipinzhiDlg.DestroyDialog()
end

function ZuoqipinzhiDlg:zuoqixilianc(args)-----坐骑洗炼
   require "logic.workshop.workshopxilian".getInstanceAndShow()
    ZuoqipinzhiDlg.DestroyDialog()
end


function ZuoqipinzhiDlg:DestroyDialogc()---动画
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


function ZuoqipinzhiDlg:handleClickTipButtonc2(args)
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


 function ZuoqipinzhiDlg:PreHandlBtnClickInfo(e)
 	--防止点击物品关闭表情界面--by yangbin
	local insetdlg = require("logic.chat.insertdlg").getInstanceNotCreate()
	if insetdlg then
		insetdlg.willCheckTipsWnd = true
	end
 end
 
 function ZuoqipinzhiDlg:HandlBtnClickInfoClose()
	local equipDlg = require("logic.tips.equipinfotips").getInstanceAndShow()
	equipDlg:DestroyDialog()
 end

 function ZuoqipinzhiDlg:HandlBtnClickInfo(e)
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

function ZuoqipinzhiDlg:GetCurServerKey()
	local cellEquipItem = self:GetCellWithIndex(self.nItemCellSelId)
	if not cellEquipItem then
		return 0
	end
	return cellEquipItem.nServerKey
end

--坐骑品质重铸
function ZuoqipinzhiDlg:HandlBtnClickedXl(e)

	if GetBattleManager() and GetBattleManager():IsInBattle() then
		local strShowTip = MHSD_UTILS.get_resstring(11693) 
		GetCTipsManager():AddMessageTip(strShowTip)
        return 
    end
	if self.nItemCellSelId == 0 then
        -- 没有选中物品，弹出提示
        GetCTipsManager():AddMessageTipById(193529) 
        return  -- 直接返回，不执行后续逻辑
    end
	
	local bCanXiuli, strResult = self:IsCanXiuli() --  调用 IsCanXiuli 函数检查物品是否足够
    if not bCanXiuli then
        GetCTipsManager():AddMessageTipById(193530)  -- 物品不足提示
        return
    end
	
	local nEquipKey = self:GetCurServerKey()
	local eBagType = self:GetCurItemBagType()
	
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local equipData = roleItemManager:FindItemByBagAndThisID(nEquipKey,eBagType)
	if equipData then
		local equipObj = equipData:GetObject() --GetEndureUpperLimit
		local itemAttrCfg = equipData:GetBaseObject()
	    local nEquipId = itemAttrCfg.id
		local equipPropertyCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipitemattr"):getRecorder(nEquipId)
	if not equipPropertyCfg then
		return false
	end
	local nNeedMoney = equipPropertyCfg.chongzhumoney
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local nUserMoney = roleItemManager:GetGold()
	
	if nUserMoney < nNeedMoney then
		GetCTipsManager():AddMessageTipById(160118)
		return 
	end
	end

	local p = require "protodef.fire.pb.item.cchongzhuequipitem":new()
	p.repairtype = 1 --normal
	p.keyinpack = nEquipKey
	local nBagType = eBagType
	p.packid = nBagType --fire.pb.item.BagTypes.BAG
	require "manager.luaprotocolmanager":send(p)
end	

function ZuoqipinzhiDlg:checkShowItemOverNeed()
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

function ZuoqipinzhiDlg:clickConfirmBoxOk_xl()
    gGetMessageManager():CloseConfirmBox(eConfirmNormal,false)
    local nEquipKey = self:GetCurServerKey()
	local eBagType = self:GetCurItemBagType()

    local p = require "protodef.fire.pb.item.cchongzhuequipitem":new()
	p.repairtype = 1 --normal
	p.keyinpack = nEquipKey
	local nBagType = eBagType
	p.packid = nBagType --fire.pb.item.BagTypes.BAG
	require "manager.luaprotocolmanager":send(p)

end

function ZuoqipinzhiDlg:clickConfirmBoxCancel_xl()
gGetMessageManager():CloseConfirmBox(eConfirmNormal,false)

end

function ZuoqipinzhiDlg:SendRequestAllEndure()
	local p1 = require "protodef.fire.pb.item.creqallnaijiu":new()
	p1.packid = fire.pb.item.BagTypes.BAG
	require "manager.luaprotocolmanager":send(p1)
	local p2 = require "protodef.fire.pb.item.creqallnaijiu":new()
	p2.packid = fire.pb.item.BagTypes.EQUIP
	require "manager.luaprotocolmanager":send(p2)
end



function ZuoqipinzhiDlg:RefreshEquipCellSel()
	for i = 1, #self.vItemCellEquip do 
		local equipCell = self.vItemCellEquip[i]
		if equipCell.nClientKey ~= self.nItemCellSelId then
			equipCell.btnBg:setSelected(false)
		else
			equipCell.btnBg:setSelected(true)
		end	
	end
end

function ZuoqipinzhiDlg:RefreshEquipListState()
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

function ZuoqipinzhiDlg:OnNextPage(args)
	local wsManager = Workshopmanager.getInstance()
	wsManager.nXilianPage = wsManager.nXilianPage + 1
	local vEquipKeyOrderIndex = {}
    wsManager:getchongzhuzq(vEquipKeyOrderIndex,wsManager.nXilianPage)--坐骑重铸品质读取
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

function ZuoqipinzhiDlg:CreateEquipCell(equipCellData)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local nIndexEquip = #self.vItemCellEquip + 1
	local nEquipKey = equipCellData.nEquipKey
		local eBagType = equipCellData.eBagType
		local equipData = roleItemManager:FindItemByBagAndThisID(nEquipKey,eBagType)
		if equipData then
			local itemAttrCfg = equipData:GetBaseObject()

			local prefix = "ZuoqipinzhiDlg_equip"..nIndexEquip
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
			local nDurence = equipData:GetEquipScore()
			cellEquipItem.labDurance:setText(tostring(nDurence))
			if eBagType==fire.pb.item.BagTypes.EQUIP then
				cellEquipItem.imageHaveEquiped:setVisible(true)
			end
			cellEquipItem.btnBg:subscribeEvent("MouseClick", ZuoqipinzhiDlg.HandleClickedItem,self)
		end
		
end

function ZuoqipinzhiDlg:RefreshEquipList(nBagId,nItemKey)
	local wsManager = Workshopmanager.getInstance()
	wsManager:RefreshEquipArray(nBagId,nItemKey)
	wsManager.nXilianPage = 1
	
	self:ClearCellAll()
	
	self.ScrollEquip:cleanupNonAutoChildren()
	self.vItemCellEquip = {}


	local vEquipKeyOrderIndex = {}
    wsManager:getchongzhuzq(vEquipKeyOrderIndex,wsManager.nXilianPage)--控制点化等级

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

function ZuoqipinzhiDlg:GetCellWithIndex(nIndex)
	if nIndex > #self.vItemCellEquip then
		return nil
	end
	return self.vItemCellEquip[nIndex]
end

function ZuoqipinzhiDlg:GetCurItemBagType()
	local cellEquipItem = self:GetCellWithIndex(self.nItemCellSelId)
	if not cellEquipItem then
		return 0
	end
	return cellEquipItem.eBagType
end

function ZuoqipinzhiDlg:HandleClickedItem(e)
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

function ZuoqipinzhiDlg:ResetEquip()
	self.ItemCellTarget:SetImage(nil)
    SetItemCellBoundColorByQulityItemWithIdtm(self.ItemCellTarget,0)

    self.ImageTargetCanMake:setVisible(false)
	self.LabTargetName:setText("")
	self.ItemCellNeedItem1:SetTextUnit("")
	self.LabNameNeedItem1:setText("")
	self.ItemCellNeedItem2:SetTextUnit("")
	self.LabNameNeedItem2:setText("")
	self.needMoneyLabel:setText("")
	self.LabTargetNamec:setText("")
end

function ZuoqipinzhiDlg:getXlItemIdAndNeedNum(nEquipId)
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

function ZuoqipinzhiDlg:RefreshEquip()
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
	
	local nNeedItemId2 = equipPropertyCfg.tsxlcailiaoid
	local nNeedItemNum2 = equipPropertyCfg.tsxlcailiaonum
	local needItemCfg1 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(equipPropertyCfg.chongzhuitemid)
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
    SetItemCellBoundColorByQulityItemWithIdtm(self.ItemCellTarget,itemAttrCfg.id)

    if itemAttrCfg.nquality > 0 then
        SetItemCellBoundColorByQulityItemtm(self.ItemCellTarget,itemAttrCfg.nquality)
    end
    refreshItemCellBind(self.ItemCellTarget,eBagType,nEquipKey)

	self.LabTargetName:setText(itemAttrCfg.namecc1)
	self.LabTargetName1:setText(itemAttrCfg.name)
	self.LabTargetNamec:setText(itemAttrCfg.namecc1)
	local nEquipType = itemAttrCfg.itemtypeid
	local strTypeName = ""
	local itemTypeCfg = BeanConfigManager.getInstance():GetTableByName("item.citemtype"):getRecorder(nEquipType)
	if itemTypeCfg then
		strTypeName = itemTypeCfg.weapon
	end
	self.ItemCellNeedItem1:SetImage(gGetIconManager():GetItemIconByID(needItemCfg1.icon))
    SetItemCellBoundColorByQulityItemWithIdtm(self.ItemCellNeedItem1,needItemCfg1.id)

	self.ItemCellNeedItem1:setID(needItemCfg1.id)
	local nOwnItemNum1 = roleItemManager:GetItemNumByBaseID(needItemCfg1.id)
	local nNeedItemNum1 = equipPropertyCfg.chongzhuitemnum
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

function ZuoqipinzhiDlg:GetCurEquipData()
	local nServerKey = self:GetCurServerKey()
	local eBagType = self:GetCurItemBagType()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local equipData = roleItemManager:FindItemByBagAndThisID(nServerKey,eBagType)
	if not equipData then
		return nil
	end
	return equipData
end

function ZuoqipinzhiDlg:RefreshRichBox(bUseLocal)
	LogInfo(" ZuoqipinzhiDlg.RefreshRichBox(bUseLocal)")
	local equipData = self:GetCurEquipData()
	if not equipData then
		return 
	end
	local eBagType = self:GetCurItemBagType()
	local bHaveData,strParseText = WorkshopHelper.GetMapPropertyWithEquipDatazqcz(equipData,bUseLocal,eBagType, true)
	if bHaveData then
		self.richBoxEquip:Clear()
		self.richBoxEquip:show()
		self.richBoxEquip:AppendParseText(CEGUI.String(strParseText))
		self.richBoxEquip:Refresh()
	end
end

function ZuoqipinzhiDlg:GetCurNeedMoney()
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

function ZuoqipinzhiDlg:RefreshNeedMoneyLabel()
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
	local nNeedMoney=equipPropertyCfg.chongzhumoney
	
	local nUserMoney = roleItemManager:GetGold()
	--//===========================
	if nUserMoney >= nNeedMoney then
		self.needMoneyLabel:setProperty("TextColours", "ffffffff")
	else
		self.needMoneyLabel:setProperty("TextColours", "ffff0000")
	end
	
	self.needMoneyLabel:setText(nNeedMoney)
	local roleGold = roleItemManager:GetGold()
    self.ownMoneyLabel:setText(tostring(roleGold))
end

function ZuoqipinzhiDlg:RefreshEquipDetailInfo(vProperty)
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

function ZuoqipinzhiDlg:GetLabelWithIndex(nIndex)
	if nIndex > #self.vLabelTitleProperty then 
		return nil
	end
	return self.vLabelTitleProperty[nIndexLabel], self.vLabelProperty[nIndexLabel]
end



function ZuoqipinzhiDlg:IsCanXiuli()
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
    nNeedItemId1=equipPropertyCfg.chongzhuitemid
	nNeedItemNum1=equipPropertyCfg.chongzhuitemnum
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
		LogInfo("ZuoqipinzhiDlg:IsCanXiuli()=nNeedItemId1="..nNeedItemId1)
		return false, strResult
	end
		if nUserMoney < nNeedMoney1 then
			strResult = MHSD_UTILS.get_resstring(11006) 
			
			return false, strResult
		end
	return true, strResult
end





function ZuoqipinzhiDlg:CheckBoxStateChanged(args)
    local state = self.checkbox:isSelected()
    if state then
	    --self:RefreshTwoBtnSel()
	    self:RefreshNeedMoneyLabel()
	end
end 

--//=========================================
function ZuoqipinzhiDlg.getInstance()
    if not _instance then
        _instance = ZuoqipinzhiDlg:new()
        _instance:OnCreate()
    end
    return _instance
end

function ZuoqipinzhiDlg.getInstanceAndShow()
    if not _instance then
        _instance = ZuoqipinzhiDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
	_instance:SendRequestAllEndure()
    return _instance
end

function ZuoqipinzhiDlg.getInstanceNotCreate()
    return _instance
end

function ZuoqipinzhiDlg.getInstanceOrNot()
	return _instance
end
	
function ZuoqipinzhiDlg.GetLayoutFileName()
    return "zuoqipinzhi.layout"
end

function ZuoqipinzhiDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ZuoqipinzhiDlg)
	self:ClearData()
    return self
end

function ZuoqipinzhiDlg.DestroyDialog()
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

function ZuoqipinzhiDlg:ClearData()
	self.vItemCellEquip = {}	
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
end

function ZuoqipinzhiDlg:ClearDataInClose()
	self.vItemCellEquip = nil	
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
end

function ZuoqipinzhiDlg:ClearCellAll()
	for k, v in pairs(self.vItemCellEquip) do
		LogInfo("ZuoqipinzhiDlg:ClearCellAll()=k="..k)
		v:DestroyDialog()
	end
	self.vItemCellEquip = {}
end


function ZuoqipinzhiDlg:OnClose()
	self:ClearCellAll()
	
	Dialog.OnClose(self)
	
	self:HandlBtnClickInfoClose()

	self:ClearDataInClose()
	gGetRoleItemManager().m_EventPackMoneyChange:RemoveScriptFunctor(self.m_hPackMoneyChange)
    gGetRoleItemManager():RemoveLuaItemNumChangeNotify(self.m_hItemNumChangeNotify)
	_instance = nil
end

return ZuoqipinzhiDlg


