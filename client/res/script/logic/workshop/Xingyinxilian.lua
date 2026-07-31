require "utils.mhsdutils"
require "logic.dialog"
require "logic.workshop.Workshopitemcell4"
require "logic.workshop.workshophelper"

require "utils.commonutil"

XingyinxilianDlg = {}
setmetatable(XingyinxilianDlg, Dialog)
XingyinxilianDlg.__index = XingyinxilianDlg
local _instance;


function XingyinxilianDlg.OnDzResult()
	LogInfo("XingyinxilianDlg.OnDzResult()")
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


function XingyinxilianDlg:RefreshItemTips(item)
	LogInfo("XingyinxilianDlg.RefreshItemTips")
	local bUseLocal = true  
	self:RefreshRichBox(bUseLocal)
end



function XingyinxilianDlg.OnFailTimesResult(protocol)
	
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

function XingyinxilianDlg.OnRefreshAllResult(protocol)
	LogInfo(" XingyinxilianDlg.OnRefreshAllResult(protocol)")
	if not _instance then
		return
	end
	_instance:RefreshEquip()
	_instance:RefreshEquipListState()
end



function XingyinxilianDlg.OnXlResult()
	if not _instance then
		return
	end

	_instance:RefreshRichBox(false)
	--_instance:RefreshEquipList()
	_instance:RefreshEquipListState()

	_instance:RefreshEquip()

end


function XingyinxilianDlg.OnRefreshOneItemInfoResult(protocol)
	LogInfo("XingyinxilianDlg.OnRefreshOneItemInfoResult")
	if not _instance then
		return
	end
	_instance:RefreshEquip()
end



function XingyinxilianDlg:OnCreate()
    Dialog.OnCreate(self)
	SetPositionOfWindowWithLabel1(self:GetWindow())
	self.m_hItemNumChangeNotify = gGetRoleItemManager():InsertLuaItemNumChangeNotify(XingyinxilianDlg.OnItemNumChange)
	self.m_hPackMoneyChange = gGetRoleItemManager().m_EventPackMoneyChange:InsertScriptFunctor(XingyinxilianDlg.OnMoneyChange)
	self:InitUI()
	self.bLoadUI = true
	self:RefreshEquipList()
	self:RefreshEquipCellSel()
	self:RefreshEquip()
	self:SendRequestAllEndure()
	--self:RefreshTwoBtnSel()
    self:ResetEquip()
end


function XingyinxilianDlg.AddItemInBag(nItemKey)
	if not _instance then
		return
	end
	
end

function XingyinxilianDlg.DelItemInBag(nItemKey)
	if not _instance then
		return
	end
end

function XingyinxilianDlg.AddItemInEquipBag(nItemKey)
	if not _instance then
		return
	end
end

function XingyinxilianDlg.DelItemInEquipBag(nItemKey)
	if not _instance then
		return
	end
end


function XingyinxilianDlg.OnMoneyChange()
	if not _instance then
		return
	end
	_instance:RefreshNeedMoneyLabel()
end

function XingyinxilianDlg:AddCell(eBagType,nItemKey)
	
end

function XingyinxilianDlg:DeleteCell(eBagType,nItemKey)
	
end

function XingyinxilianDlg:RefreshAllCellSortData()
end


function XingyinxilianDlg:SortAllCell()
end

function XingyinxilianDlg:RefreshAllCellPos()
end


function XingyinxilianDlg.OnItemNumChange(eBagType, nItemKey, nItemId)
	if _instance == nil then
		return
	end
	_instance:RefreshEquip()
end


function XingyinxilianDlg:RefreshUI(nBagId,nItemKey)
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

function XingyinxilianDlg:InitUI()
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.ScrollEquip = CEGUI.toScrollablePane(winMgr:getWindow("Xingyinxilianyyy/left"))
	self.ScrollEquip:setMousePassThroughEnabled(true)
	self.ScrollEquip:subscribeEvent("NextPage", XingyinxilianDlg.OnNextPage, self)
	self.ItemCellTarget = CEGUI.toItemCell(winMgr:getWindow("Xingyinxilianyyy/right/part2/item2"))
	self.ImageTargetCanMake = winMgr:getWindow("Xingyinxilianyyy/right/part2/item2/yizhuangbei") 
	self.LabTargetName = winMgr:getWindow("Xingyinxilianyyy/right/part2/name2") 
	self.LabTargetName1 = winMgr:getWindow("Xingyinxilianyyy/rightc/partc2/namecc") 
	self.LabTargetNamec = winMgr:getWindow("Xingyinxilianyyy/right/part2/name22") 
	self.richBoxEquip = CEGUI.toRichEditbox(winMgr:getWindow("Xingyinxilianyyy/right/shuxinglist/box"))
	self.richBoxEquip:subscribeEvent("MouseButtonUp", XingyinxilianDlg.HandlBtnClickInfoClose) 

	self.richBoxEquip:setReadOnly(true)
	
	self.richBoxEquip1 = CEGUI.toRichEditbox(winMgr:getWindow("Xingyinxilianyyy/right/shuxinglist/box2"))
	self.richBoxEquip1:subscribeEvent("MouseButtonUp", XingyinxilianDlg.HandlBtnClickInfoClose) 

	self.richBoxEquip1:setReadOnly(true)
	
	
	self.btnInfo = CEGUI.toPushButton(winMgr:getWindow("Xingyinxilianyyy/right/shuxinglist/tipsxiangqing"))
	self.btnInfo:subscribeEvent("MouseButtonDown", XingyinxilianDlg.PreHandlBtnClickInfo, self) 
    self.btnInfo:subscribeEvent("MouseButtonUp", XingyinxilianDlg.HandlBtnClickInfo, self) 
	
	self.m_xingyinhc = CEGUI.Window.toPushButton(winMgr:getWindow("Xingyinxilianyyy/yyydz/hec111"))
	self.m_xingyinhc:subscribeEvent("Clicked", XingyinxilianDlg.xingyinhc, self)
	
	
	self.xx = CEGUI.toPushButton(winMgr:getWindow("Xingyinxilianyyy"))
	self.xx:subscribeEvent("MouseButtonUp", XingyinxilianDlg.HandlBtnClickInfoClose) 
	self.xx2 = CEGUI.toPushButton(winMgr:getWindow("Xingyinxilianyyy/right"))
	self.xx2:subscribeEvent("MouseButtonUp", XingyinxilianDlg.HandlBtnClickInfoClose) 
	self.xx3 = CEGUI.toPushButton(winMgr:getWindow("Xingyinxilianyyy/right/part2/line1"))
	self.xx3:subscribeEvent("MouseButtonUp", XingyinxilianDlg.HandlBtnClickInfoClose) 
	self.xx5 = CEGUI.toPushButton(winMgr:getWindow("Xingyinxilianyyy/left"))
	self.xx5:subscribeEvent("MouseButtonUp", XingyinxilianDlg.HandlBtnClickInfoClose) 
	
	
	
	self.BtnMake = CEGUI.toGroupButton(winMgr:getWindow("Xingyinxilianyyy/right/putongbutton"))

	self.BtnMakeQh = CEGUI.toPushButton(winMgr:getWindow("Xingyinxilianyyy/right/teshubutton"))
    self.checkbox = CEGUI.toCheckbox(winMgr:getWindow("Xingyinxilianyyy/right/part2/line1/gou"))
    self.checkbox:subscribeEvent("MouseButtonUp", XingyinxilianDlg.CheckBoxStateChanged, self)
	

	
	
	self.smokeBg = winMgr:getWindow("Xingyinxilianyyy/Back/flagbg/smoke")-----动画
	local s = self.smokeBg:getPixelSize()
	local flagSmoke = gGetGameUIManager():AddUIEffect(self.smokeBg, "geffect/ui/mt_shengqishi/mt_shengqishi9", true, s.width*0.5, s.height)
	
	self.smokeBg1 = winMgr:getWindow("Xingyinxilianyyy/yyydz/addccy")-----加号动画
	local s = self.smokeBg1:getPixelSize()
	local flagSmoke1 = gGetGameUIManager():AddUIEffect(self.smokeBg1, "geffect/ui/addjinse", true, s.width*0.5, s.height)
	
	self.smokeBg2 = winMgr:getWindow("Xingyinxilianyyy/yyydz/addccy1")----星印框动画
	local s = self.smokeBg2:getPixelSize()
	local flagSmoke2 = gGetGameUIManager():AddUIEffect(self.smokeBg2, "geffect/ui/mt_shengqishi/mt_shengqishi8", true, s.width*0.5, s.height)

	self.ItemCellNeedItem1 = CEGUI.toItemCell(winMgr:getWindow("Xingyinxilianyyy/right/cailiaolist/item1"))
	self.LabNameNeedItem1 = winMgr:getWindow("Xingyinxilianyyy/right/cailiaolist/name1")
	self.ItemCellNeedItem2 = CEGUI.toItemCell(winMgr:getWindow("Xingyinxilianyyy/right/cailiaolist/item2"))
	self.LabNameNeedItem2 = winMgr:getWindow("Xingyinxilianyyy/right/cailiaolist/name2")
	self.needMoneyLabel = winMgr:getWindow("Xingyinxilianyyy/right/bg1/one") --Xingyinxilianyyy/right/bg1/one
	self.ownMoneyLabel = winMgr:getWindow("Xingyinxilianyyy/right/bg11/2") --Xingyinxilianyyy/right/bg11/2
	self.ImageNeedMoneyIcon = winMgr:getWindow("Xingyinxilianyyy/right/yinbi")
	self.ImageOwnMoneyIcon = winMgr:getWindow("Xingyinxilianyyy/right/yinbi2")
	self.BtnXl = CEGUI.toPushButton(winMgr:getWindow("Xingyinxilianyyy/right/button"))
	self.BtnXl:subscribeEvent("Clicked", XingyinxilianDlg.HandlBtnClickedXl, self)
	

	
	self.labelNormalDesc = winMgr:getWindow("Xingyinxilianyyy/right/part2/line1/text")
	self.labelSpecialDesc = winMgr:getWindow("Xingyinxilianyyy/right/part2/line1/textteshu1")
	self.ItemCellNeedItem1:setVisible(true)
	self.ItemCellNeedItem1:subscribeEvent("TableClick", Workshopmanager.HandleClickItemCell, Workshopmanager)

    self.BtnExchange = CEGUI.toPushButton(winMgr:getWindow("Xingyinxilianyyy/right/jiahao")) --Xingyinxilianyyy/right/jiahao
	self.BtnExchange:subscribeEvent("Clicked", XingyinxilianDlg.HandleExchangeBtnClicked, self)
end

TaskHelper.m_xingyinhc = 254050


function XingyinxilianDlg.xingyinhc()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_xingyinhc
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end

function XingyinxilianDlg:HandleExchangeBtnClicked(e)
	local dlg = require "logic.currency.stonegoldexchangesilverdlg".getInstanceAndShow()
	dlg:GetWindow():setAlwaysOnTop(true)

	return true
	
end

function XingyinxilianDlg:zuoqishengjic(args)-----坐骑升级
   require "logic.workshop.workshopaq1".getInstanceAndShow()
    XingyinxilianDlg.DestroyDialog()
end

function XingyinxilianDlg:zuoqixilianc(args)-----坐骑洗炼
   require "logic.workshop.workshopxilian".getInstanceAndShow()
    XingyinxilianDlg.DestroyDialog()
end




function XingyinxilianDlg:DestroyDialogc()---动画
	if self._instance then
        if self.sprite then
            self.sprite:delete()
            self.sprite = nil
        end
		if self.smokeBg then
		    gGetGameUIManager():RemoveUIEffect(self.smokeBg)
		end
		if self.smokeBg1 then
		    gGetGameUIManager():RemoveUIEffect(self.smokeBg1)
		end
		if self.smokeBg2 then
		    gGetGameUIManager():RemoveUIEffect(self.smokeBg2)
		end
		if self.roleEffectBg then
		    gGetGameUIManager():RemoveUIEffect(self.roleEffectBg)
		end
		self:OnClose()
		getmetatable(self)._instance = nil
        _instance = nil
	end
end





 function XingyinxilianDlg:PreHandlBtnClickInfo(e)
 	--防止点击物品关闭表情界面--by yangbin
	local insetdlg = require("logic.chat.insertdlg").getInstanceNotCreate()
	if insetdlg then
		insetdlg.willCheckTipsWnd = true
	end
 end
 
 function XingyinxilianDlg:HandlBtnClickInfoClose()
	local equipDlg = require("logic.tips.equipinfotips").getInstanceAndShow()
	equipDlg:DestroyDialog()
 end

 function XingyinxilianDlg:HandlBtnClickInfo(e)
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

function XingyinxilianDlg:GetCurServerKey()
	local cellEquipItem = self:GetCellWithIndex(self.nItemCellSelId)
	if not cellEquipItem then
		return 0
	end
	return cellEquipItem.nServerKey
end

--重铸
function XingyinxilianDlg:HandlBtnClickedXl(e)
    if GetBattleManager() and GetBattleManager():IsInBattle() then
        local strShowTip = MHSD_UTILS.get_resstring(11693)
        GetCTipsManager():AddMessageTip(strShowTip)
        return
    end

    local nEquipKey = self:GetCurServerKey()
    local eBagType = self:GetCurItemBagType()

    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local equipData = roleItemManager:FindItemByBagAndThisID(nEquipKey, eBagType)

    -- 检查是否选择了物品进行修复
    if not equipData then
        local strNoItemSelectedTip = MHSD_UTILS.get_resstring(160118) -- 假设这是未选择物品时的提示字符串ID
        GetCTipsManager():AddMessageTip(strNoItemSelectedTip)
        return
    end

    local equipObj = equipData:GetObject()
    local itemAttrCfg = equipData:GetBaseObject()
    local nEquipId = itemAttrCfg.id
    local equipPropertyCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipitemattr"):getRecorder(nEquipId)
    if not equipPropertyCfg then
        return false
    end
    local nNeedMoney = equipPropertyCfg.chongzhumoney
    local nUserMoney = roleItemManager:GetGold()

    if nUserMoney < nNeedMoney then
        GetCTipsManager():AddMessageTipById(160118)
        return
    end

    local p = require "protodef.fire.pb.item.cchongzhuequipitem":new()
    p.repairtype = 1
    p.keyinpack = nEquipKey
    local nBagType = eBagType
    p.packid = nBagType
    require "manager.luaprotocolmanager":send(p)
end

function XingyinxilianDlg:checkShowItemOverNeed()
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

function XingyinxilianDlg:clickConfirmBoxOk_xl()
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

function XingyinxilianDlg:clickConfirmBoxCancel_xl()
gGetMessageManager():CloseConfirmBox(eConfirmNormal,false)

end

function XingyinxilianDlg:SendRequestAllEndure()
	local p1 = require "protodef.fire.pb.item.creqallnaijiu":new()
	p1.packid = fire.pb.item.BagTypes.BAG
	require "manager.luaprotocolmanager":send(p1)
	local p2 = require "protodef.fire.pb.item.creqallnaijiu":new()
	p2.packid = fire.pb.item.BagTypes.EQUIP
	require "manager.luaprotocolmanager":send(p2)
end



function XingyinxilianDlg:RefreshEquipCellSel()
	for i = 1, #self.vItemCellEquip do 
		local equipCell = self.vItemCellEquip[i]
		if equipCell.nClientKey ~= self.nItemCellSelId then
			equipCell.btnBg:setSelected(false)
		else
			equipCell.btnBg:setSelected(true)
		end	
	end
end

function XingyinxilianDlg:RefreshEquipListState()
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

function XingyinxilianDlg:OnNextPage(args)
	local wsManager = Workshopmanager.getInstance()
	wsManager.nXilianPage = wsManager.nXilianPage + 1
	local vEquipKeyOrderIndex = {}
    wsManager:getchongzhuxingying(vEquipKeyOrderIndex,wsManager.nXilianPage)--控制点化等级
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

function XingyinxilianDlg:CreateEquipCell(equipCellData)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local nIndexEquip = #self.vItemCellEquip + 1
	local nEquipKey = equipCellData.nEquipKey
		local eBagType = equipCellData.eBagType
		local equipData = roleItemManager:FindItemByBagAndThisID(nEquipKey,eBagType)
		if equipData then
			local itemAttrCfg = equipData:GetBaseObject()

			local prefix = "XingyinxilianDlg_equip"..nIndexEquip
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
			cellEquipItem.btnBg:subscribeEvent("MouseClick", XingyinxilianDlg.HandleClickedItem,self)
		end
		
end

function XingyinxilianDlg:RefreshEquipList(nBagId,nItemKey)
	local wsManager = Workshopmanager.getInstance()
	wsManager:RefreshEquipArray(nBagId,nItemKey)
	wsManager.nXilianPage = 1
	
	self:ClearCellAll()
	
	self.ScrollEquip:cleanupNonAutoChildren()
	self.vItemCellEquip = {}


	local vEquipKeyOrderIndex = {}
    wsManager:getchongzhuxingying(vEquipKeyOrderIndex,wsManager.nXilianPage)--控制点化等级

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

function XingyinxilianDlg:GetCellWithIndex(nIndex)
	if nIndex > #self.vItemCellEquip then
		return nil
	end
	return self.vItemCellEquip[nIndex]
end

function XingyinxilianDlg:GetCurItemBagType()
	local cellEquipItem = self:GetCellWithIndex(self.nItemCellSelId)
	if not cellEquipItem then
		return 0
	end
	return cellEquipItem.eBagType
end

function XingyinxilianDlg:HandleClickedItem(e)
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

function XingyinxilianDlg:ResetEquip()
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

function XingyinxilianDlg:getXlItemIdAndNeedNum(nEquipId)
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

function XingyinxilianDlg:RefreshEquip()
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

function XingyinxilianDlg:GetCurEquipData()
	local nServerKey = self:GetCurServerKey()
	local eBagType = self:GetCurItemBagType()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local equipData = roleItemManager:FindItemByBagAndThisID(nServerKey,eBagType)
	if not equipData then
		return nil
	end
	return equipData
end

--[[function XingyinxilianDlg:RefreshRichBox(bUseLocal)
	LogInfo(" XingyinxilianDlg.RefreshRichBox(bUseLocal)")
	local equipData = self:GetCurEquipData()
	if not equipData then
		return 
	end
	local eBagType = self:GetCurItemBagType()
	local bHaveData,strParseText = WorkshopHelper.GetMapPropertyWithEquipxyData(equipData,bUseLocal,eBagType, true)
	if bHaveData then
		self.richBoxEquip:Clear()
		self.richBoxEquip:show()
		self.richBoxEquip:AppendParseText(CEGUI.String(strParseText))
		self.richBoxEquip:Refresh()
		self.richBoxEquip1:Clear()
		self.richBoxEquip1:show()
		self.richBoxEquip1:AppendParseText(CEGUI.String(strParseText))
		self.richBoxEquip1:Refresh()
	end
end--]]

function XingyinxilianDlg:RefreshRichBox(bUseLocal)
    LogInfo(" XingyinxilianDlg.RefreshRichBox(bUseLocal)")
    local equipData = self:GetCurEquipData()
    if not equipData then
        return
    end
    local eBagType = self:GetCurItemBagType()
    -- 调用GetMapPropertyWithEquipxyData函数获取richBoxEquip的数据
    local bHaveData1, strParseText1 = WorkshopHelper.GetMapPropertyWithEquipxyData(equipData, bUseLocal, eBagType, true)
    -- 调用GetMapPropertyWithEquipxy1Data函数获取richBoxEquip1的数据
    local bHaveData2, strParseText2 = WorkshopHelper.GetMapPropertyWithEquipxy1Data(equipData, bUseLocal, eBagType, true)
    
    if bHaveData1 then
        self.richBoxEquip:Clear()
        self.richBoxEquip:show()
        self.richBoxEquip:AppendParseText(CEGUI.String(strParseText1))
        self.richBoxEquip:Refresh()
    end
    
    if bHaveData2 then
        self.richBoxEquip1:Clear()
        self.richBoxEquip1:show()
        self.richBoxEquip1:AppendParseText(CEGUI.String(strParseText2))
        self.richBoxEquip1:Refresh()
    end
end

function XingyinxilianDlg:GetCurNeedMoney()
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

function XingyinxilianDlg:RefreshNeedMoneyLabel()
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

function XingyinxilianDlg:RefreshEquipDetailInfo(vProperty)
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

function XingyinxilianDlg:GetLabelWithIndex(nIndex)
	if nIndex > #self.vLabelTitleProperty then 
		return nil
	end
	return self.vLabelTitleProperty[nIndexLabel], self.vLabelProperty[nIndexLabel]
end



function XingyinxilianDlg:IsCanXiuli()
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
		LogInfo("XingyinxilianDlg:IsCanXiuli()=nNeedItemId1="..nNeedItemId1)
		return false, strResult
	end
		if nUserMoney < nNeedMoney1 then
			strResult = MHSD_UTILS.get_resstring(11006) 
			
			return false, strResult
		end
	return true, strResult
end

-- function XingyinxilianDlg:RefreshTwoBtnSel()
	
	
	-- local strTitleCur = ""
		-- strTitleCur = self.BtnMake:getText()
		-- self.labelNormalDesc:setVisible(true)
		-- self.labelSpecialDesc:setVisible(false)
	-- self.BtnXl:setText(strTitleCur)
-- end



function XingyinxilianDlg:CheckBoxStateChanged(args)
    local state = self.checkbox:isSelected()
    if state then
	    --self:RefreshTwoBtnSel()
	    self:RefreshNeedMoneyLabel()
	end
end 

--//=========================================
function XingyinxilianDlg.getInstance()
    if not _instance then
        _instance = XingyinxilianDlg:new()
        _instance:OnCreate()
    end
    return _instance
end

function XingyinxilianDlg.getInstanceAndShow()
    if not _instance then
        _instance = XingyinxilianDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
	_instance:SendRequestAllEndure()
    return _instance
end

function XingyinxilianDlg.getInstanceNotCreate()
    return _instance
end

function XingyinxilianDlg.getInstanceOrNot()
	return _instance
end
	
function XingyinxilianDlg.GetLayoutFileName()
    return "xingyinxilian.layout"
end

function XingyinxilianDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, XingyinxilianDlg)
	self:ClearData()
    return self
end

function XingyinxilianDlg.DestroyDialog()
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

function XingyinxilianDlg:ClearData()
	self.vItemCellEquip = {}	
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
end

function XingyinxilianDlg:ClearDataInClose()
	self.vItemCellEquip = nil	
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
end

function XingyinxilianDlg:ClearCellAll()
	for k, v in pairs(self.vItemCellEquip) do
		LogInfo("XingyinxilianDlg:ClearCellAll()=k="..k)
		v:DestroyDialog()
	end
	self.vItemCellEquip = {}
end


function XingyinxilianDlg:OnClose()
	self:ClearCellAll()
	
	Dialog.OnClose(self)
	
	self:HandlBtnClickInfoClose()

	self:ClearDataInClose()
	gGetRoleItemManager().m_EventPackMoneyChange:RemoveScriptFunctor(self.m_hPackMoneyChange)
    gGetRoleItemManager():RemoveLuaItemNumChangeNotify(self.m_hItemNumChangeNotify)
	_instance = nil
end

return XingyinxilianDlg


