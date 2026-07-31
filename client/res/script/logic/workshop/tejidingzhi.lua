require "utils.mhsdutils"
require "logic.dialog"
require "logic.workshop.workshopitemcell"
require "logic.workshop.workshophelper"
require "logic.workshop.tejidingzhicell"
require "utils.commonutil"

tejidingzhi = {}
setmetatable(tejidingzhi, Dialog)
tejidingzhi.__index = tejidingzhi
local _instance;


function tejidingzhi.OnDzResult()
	LogInfo("tejidingzhi.OnDzResult()")
	if not _instance then
		return
	end
	if _instance.bLoadUI then
		_instance:RefreshEquipList()
		_instance:RefreshEquipCellSel()
		_instance:RefreshEquip()
	end

end

function tejidingzhi:RefreshItemTips(item)
	LogInfo("tejidingzhi.RefreshItemTips")
	local bUseLocal = true  
	self:RefreshRichBox(bUseLocal)
end


function tejidingzhi.OnFailTimesResult(protocol)
	
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

function tejidingzhi.OnRefreshAllResult(protocol)
	LogInfo(" tejidingzhi.OnRefreshAllResult(protocol)")
	if not _instance then
		return
	end
	_instance:RefreshEquip()
	_instance:RefreshEquipListState()
end


function tejidingzhi.OnXlResult()
	if not _instance then
		return
	end

	_instance:RefreshRichBox(false)
	--_instance:RefreshEquipList()
	_instance:RefreshEquipListState()
	_instance:RefreshEquip()
	_instance:FuMoItemNeed()

end

function tejidingzhi.closeForBeside()
	if not _instance then
		return
	end
	_instance:closeForBeside()
end

function tejidingzhi:closeForBeside()
	self.bLevelTipOpen = false
	self:RefreshEffectBtn()
end


function tejidingzhi.OnRefreshOneItemInfoResult(protocol)
	LogInfo("tejidingzhi.OnRefreshOneItemInfoResult")
	if not _instance then
		return
	end
	_instance:RefreshEquip()
end



function tejidingzhi:OnCreate()
    Dialog.OnCreate(self)
	SetPositionOfWindowWithLabel1(self:GetWindow())
	self.m_hItemNumChangeNotify = gGetRoleItemManager():InsertLuaItemNumChangeNotify(tejidingzhi.OnItemNumChange)
	self.m_hPackMoneyChange = gGetRoleItemManager().m_EventPackMoneyChange:InsertScriptFunctor(tejidingzhi.OnMoneyChange)
	self:InitUI()
	self.bLoadUI = true
	self:RefreshEquipList()
	self:RefreshEquipCellSel()
	self:RefreshEquip()
    self:ResetEquip()
end


function tejidingzhi.AddItemInBag(nItemKey)
	if not _instance then
		return
	end
	
end

function tejidingzhi.DelItemInBag(nItemKey)
	if not _instance then
		return
	end
end

function tejidingzhi.AddItemInEquipBag(nItemKey)
	if not _instance then
		return
	end
end

function tejidingzhi.DelItemInEquipBag(nItemKey)
	if not _instance then
		return
	end
end


function tejidingzhi.OnMoneyChange()
	if not _instance then
		return
	end
	_instance:RefreshNeedMoneyLabel()
end

function tejidingzhi:AddCell(eBagType,nItemKey)
	
end

function tejidingzhi:DeleteCell(eBagType,nItemKey)
	
end

function tejidingzhi:RefreshAllCellSortData()
end


function tejidingzhi:SortAllCell()
end

function tejidingzhi:RefreshAllCellPos()
end


function tejidingzhi.OnItemNumChange(eBagType, nItemKey, nItemId)
	if _instance == nil then
		return
	end
	_instance:RefreshEquip()
end


function tejidingzhi:RefreshUI(nBagId,nItemKey)
    if not nBagId then
        nBagId = -1
        nItemKey = -1
    end
	self:RefreshEquipList(nBagId,nItemKey)
	self:RefreshEquipCellSel()
	self:RefreshEquip()
end

function tejidingzhi:InitUI()
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.effectid = 0
	self.skillid = 0
	self.neweffectid = 0
	self.newskillid = 0
	self.itemid = 0
	self.itemnum = 0
	self.itemnum1 = 0
	self.itemnum2 = 0
	self.itemnum3 = 0
	self.cout = 0
	self.ScrollEquip = CEGUI.toScrollablePane(winMgr:getWindow("zhuangbeifumo/left"))
	self.ScrollEquip:setMousePassThroughEnabled(true)
	self.ScrollEquip:subscribeEvent("NextPage", tejidingzhi.OnNextPage, self)
	self.ItemCellTarget = CEGUI.toItemCell(winMgr:getWindow("zhuangbeifumo/right/part2/item2"))
	self.ImageTargetCanMake = winMgr:getWindow("zhuangbeifumo/right/part2/item2/yizhuangbei") 
	self.LabTargetName = winMgr:getWindow("zhuangbeifumo/right/part2/name2") 
	self.richBoxEquip = CEGUI.toRichEditbox(winMgr:getWindow("zhuangbeifumo/right/shuxinglist/box"))
	self.richBoxEquip:subscribeEvent("MouseButtonUp", tejidingzhi.HandlBtnClickInfoClose) 
	self.richBoxEquip:setReadOnly(true)
	
	
	self.smokeBg = winMgr:getWindow("zhuangbeifumo/Back/flagbg/smoke")
	local s = self.smokeBg:getPixelSize()
	local flagSmoke = gGetGameUIManager():AddUIEffect(self.smokeBg, "geffect/ui/mt_shengqishi/mt_shengqishi8", true, s.width*0.5, s.height)


	local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(191232)
	self.m_ShuoMing = CEGUI.toRichEditbox(winMgr:getWindow("zhuangbeifumo/right/shuxinglist/box1"))
	self.m_ShuoMing:AppendParseText(CEGUI.String(tip.msg))
	self.m_ShuoMing:Refresh()
	self.m_ShuoMing:getVertScrollbar():setScrollPosition(0)
	self.m_ShuoMing:setShowVertScrollbar(true)
	self.btnInfo = CEGUI.toPushButton(winMgr:getWindow("zhuangbeifumo/right/shuxinglist/tipsxiangqing"))
	self.btnInfo:subscribeEvent("MouseButtonDown", tejidingzhi.PreHandlBtnClickInfo, self) 
    self.btnInfo:subscribeEvent("MouseButtonUp", tejidingzhi.HandlBtnClickInfo, self) 
	self.xx = CEGUI.toPushButton(winMgr:getWindow("zhuangbeifumo"))
	self.xx:subscribeEvent("MouseButtonUp", tejidingzhi.HandlBtnClickInfoClose) 
	self.xx2 = CEGUI.toPushButton(winMgr:getWindow("zhuangbeifumo/right"))
	self.xx2:subscribeEvent("MouseButtonUp", tejidingzhi.HandlBtnClickInfoClose) 
	self.xx3 = CEGUI.toPushButton(winMgr:getWindow("zhuangbeifumo/right/part2/line1"))
	self.xx3:subscribeEvent("MouseButtonUp", tejidingzhi.HandlBtnClickInfoClose) 
	self.xx5 = CEGUI.toPushButton(winMgr:getWindow("zhuangbeifumo/left"))
	self.xx5:subscribeEvent("MouseButtonUp", tejidingzhi.HandlBtnClickInfoClose) 
	self.ItemCellNeedItem1 = CEGUI.toItemCell(winMgr:getWindow("zhuangbeifumo/right/cailiaolist/item1"))
	self.LabNameNeedItem1 = winMgr:getWindow("zhuangbeifumo/right/cailiaolist/name1")
	self.LabNameNeed1Item1 = winMgr:getWindow("zhuangbeifumo/right/cailiaolist/shuomingc")
	self.LabNameNeed1Item2 = winMgr:getWindow("zhuangbeifumo/right/cailiaolist/item1/shuomingc1")
	self.BtnXl = CEGUI.toPushButton(winMgr:getWindow("zhuangbeifumo/right/button"))
	self.BtnXl:subscribeEvent("Clicked", tejidingzhi.HandlBtnClickedXl, self)
	

	
	self.ItemCellNeedItem1:subscribeEvent("TableClick", Workshopmanager.HandleClickItemCell, Workshopmanager)
	self.BtnSelEffect = CEGUI.toPushButton(winMgr:getWindow("zhuangbeifumo/liebiao/effect"))
	self.BtnSelEffect:subscribeEvent("Clicked", tejidingzhi.HandleSelEffectBtnClicked, self) 
	self.BtnSelEffect1 = CEGUI.toPushButton(winMgr:getWindow("zhuangbeifumo/liebiao/effect1"))
	self.BtnSelEffect1:subscribeEvent("Clicked", tejidingzhi.HandleSelEffectBtnClicked1, self) 
	self.BtnSelEffect2 = CEGUI.toPushButton(winMgr:getWindow("zhuangbeifumo/liebiao/effect11"))
	self.BtnSelEffect2:subscribeEvent("Clicked", tejidingzhi.HandleSelEffectBtnClicked2, self) 
	self.BtnSelEffect3 = CEGUI.toPushButton(winMgr:getWindow("zhuangbeifumo/liebiao/effect111"))
	self.BtnSelEffect3:subscribeEvent("Clicked", tejidingzhi.HandleSelEffectBtnClicked3, self) 
	self.labelSkillArea = winMgr:getWindow("zhuangbeifumo/liebiao/effect/text")
    self.labelSkillArea:setMousePassThroughEnabled(true)
	self.labelEffectArea = winMgr:getWindow("zhuangbeifumo/liebiao/effect/text1")
    self.labelEffectArea:setMousePassThroughEnabled(true)
	self.labelNewSkillArea = winMgr:getWindow("zhuangbeifumo/liebiao/effect/text11")
    self.labelNewSkillArea:setMousePassThroughEnabled(true)
	self.labelNewEffectArea = winMgr:getWindow("zhuangbeifumo/liebiao/effect/text111")
    self.labelNewEffectArea:setMousePassThroughEnabled(true)
	self.ImageDown = winMgr:getWindow("zhuangbeifumo/liebiao/xuanze")
	self.ImageUp = winMgr:getWindow("zhuangbeifumo/liebiao/xuanze2")
end

 function tejidingzhi:PreHandlBtnClickInfo(e)

 	--防止点击物品关闭表情界面--by yangbin
	local insetdlg = require("logic.chat.insertdlg").getInstanceNotCreate()
	if insetdlg then
		insetdlg.willCheckTipsWnd = true
	end
 end



 function tejidingzhi:RefreshEffectBtn()
	local bUp = self.bLevelTipOpen
	if bUp == true then
		self.ImageDown:setVisible(false)
		self.ImageUp:setVisible(true)
	else
		self.ImageDown:setVisible(true)
		self.ImageUp:setVisible(false)
	end
end

 function tejidingzhi:DestroyDialogc()
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

 function tejidingzhi:cleanInfo()
	self.effectid = 0
	self.skillid = 0
	self.neweffectid = 0
	self.newskillid = 0
	self.itemid = 0
	self.itemnum = 0
	self.itemnum1 = 0
	self.itemnum2 = 0
	self.itemnum3 = 0
	self.cout = 0
	self.labelSkillArea:setText("")
	self.labelEffectArea:setText("")
	self.labelNewSkillArea:setText("")
	self.labelNewEffectArea:setText("")
	self:FuMoItemNeed()
end

 function tejidingzhi:HandlBtnClickInfoClose()
	local equipDlg = require("logic.tips.equipinfotips").getInstanceAndShow()
	equipDlg:DestroyDialog()
 end

function tejidingzhi:HandlBtnClickInfo(e)
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

function tejidingzhi:GetCurServerKey()
	local cellEquipItem = self:GetCellWithIndex(self.nItemCellSelId)
	if not cellEquipItem then
		return 0
	end
	return cellEquipItem.nServerKey
end

--重铸
function tejidingzhi:HandlBtnClickedXl(e)
	if GetBattleManager() and GetBattleManager():IsInBattle() then
		local strShowTip = MHSD_UTILS.get_resstring(7204) 
		GetCTipsManager():AddMessageTip(strShowTip)
        return 
    end
	if self.itemid==0 then
		GetCTipsManager():AddMessageTip(MHSD_UTILS.get_resstring(7205))
		return 
	end
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local nOwnItemNum1 = roleItemManager:GetItemNumByBaseID(self.itemid)
	if self.itemnum > nOwnItemNum1 then
		GetCTipsManager():AddMessageTip(MHSD_UTILS.get_resstring(7204))
		return 
	end
	--//=======================================
	local nEquipKey = self:GetCurServerKey()
	local eBagType = self:GetCurItemBagType()
	
	local p = require "protodef.fire.pb.item.cequipfumo":new()
	p.skillid = self.skillid
	p.effectid = self.effectid
	p.neweffectid = self.neweffectid
	p.newskillid = self.newskillid
	
	p.keyinpack = nEquipKey
	local nBagType = eBagType
	p.packid = nBagType 
	require "manager.luaprotocolmanager":send(p)
end	



function tejidingzhi:RefreshEquipCellSel()
	for i = 1, #self.vItemCellEquip do 
		local equipCell = self.vItemCellEquip[i]
		if equipCell.nClientKey ~= self.nItemCellSelId then
			equipCell.btnBg:setSelected(false)
		else
			equipCell.btnBg:setSelected(true)
		end	
	end
end

function tejidingzhi:RefreshEquipListState()
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

function tejidingzhi:OnNextPage(args)
	local wsManager = Workshopmanager.getInstance()
	wsManager.nXilianPage = wsManager.nXilianPage + 1
	local vEquipKeyOrderIndex = {}
    wsManager:fumolv(vEquipKeyOrderIndex,wsManager.nXilianPage)--控制点化等级
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

function tejidingzhi:RefreshSkillArea(name,id,itemid,itemnum)
	self.labelSkillArea:setText(name)
	self.skillid=id
	self.itemid=itemid
	self.itemnum=itemnum
	self.cout=itemnum+self.itemnum1+self.itemnum2+self.itemnum3
	self:FuMoItemNeed()
end

function tejidingzhi:RefreshEffectArea(name,id,itemid,itemnum)
	self.labelEffectArea:setText(name)
	self.effectid=id
	self.itemid=itemid
	self.itemnum1=itemnum
	self.cout=self.itemnum+itemnum+self.itemnum2+self.itemnum3
	self:FuMoItemNeed()
end

function tejidingzhi:RefreshNewSkillArea(name,id,itemid,itemnum)
	self.labelNewSkillArea:setText(name)
	self.newskillid=id
	self.itemid=itemid
	self.itemnum2=itemnum
	self.cout=self.itemnum+self.itemnum1+itemnum+self.itemnum3
	self:FuMoItemNeed()
end

function tejidingzhi:RefreshNewEffectArea(name,id,itemid,itemnum)
	self.labelNewEffectArea:setText(name)
	self.neweffectid=id
	self.itemid=itemid
	self.itemnum3=itemnum
	self.cout=self.itemnum+self.itemnum1+self.itemnum2+itemnum
	self:FuMoItemNeed()
end

function tejidingzhi:FuMoItemNeed()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local needItemCfg1 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.itemid)
	if not needItemCfg1 then
		return
	end
	self.ItemCellNeedItem1:SetImage(gGetIconManager():GetItemIconByID(needItemCfg1.icon))
    SetItemCellBoundColorByQulityItemWithIdtm(self.ItemCellNeedItem1,needItemCfg1.id)
	self.ItemCellNeedItem1:setID(needItemCfg1.id)
	self.LabNameNeedItem1:setText(needItemCfg1.namecc1)
	self.LabNameNeed1Item1:setText(needItemCfg1.namecc2)
	self.LabNameNeed1Item2:setText(needItemCfg1.namecc3)
	local nOwnItemNum1 = roleItemManager:GetItemNumByBaseID(needItemCfg1.id)
	local strNumNeed_own1 = nOwnItemNum1.."/"..self.cout
	self.ItemCellNeedItem1:SetTextUnit(strNumNeed_own1)
	if nOwnItemNum1 >= self.cout then
		self.ItemCellNeedItem1:SetTextUnitColor(MHSD_UTILS.get_greencolor())
	else
		self.ItemCellNeedItem1:SetTextUnitColor(MHSD_UTILS.get_redcolor())
	end
end

function tejidingzhi:CreateEquipCell(equipCellData)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local nIndexEquip = #self.vItemCellEquip + 1
	local nEquipKey = equipCellData.nEquipKey
		local eBagType = equipCellData.eBagType
		local equipData = roleItemManager:FindItemByBagAndThisID(nEquipKey,eBagType)
		if equipData then
			local itemAttrCfg = equipData:GetBaseObject()

			local prefix = "tejidingzhi_equip"..nIndexEquip
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
			cellEquipItem.btnBg:subscribeEvent("MouseClick", tejidingzhi.HandleClickedItem,self)
		end
		
end

function tejidingzhi:RefreshEquipList(nBagId,nItemKey)
	local wsManager = Workshopmanager.getInstance()
	wsManager:RefreshEquipArray(nBagId,nItemKey)
	wsManager.nXilianPage = 1
	
	self:ClearCellAll()
	
	self.ScrollEquip:cleanupNonAutoChildren()
	self.vItemCellEquip = {}


	local vEquipKeyOrderIndex = {}
    wsManager:fumolv(vEquipKeyOrderIndex,wsManager.nXilianPage)--控制点化等级

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

function tejidingzhi:GetCellWithIndex(nIndex)
	if nIndex > #self.vItemCellEquip then
		return nil
	end
	return self.vItemCellEquip[nIndex]
end

function tejidingzhi:GetCurItemBagType()
	local cellEquipItem = self:GetCellWithIndex(self.nItemCellSelId)
	if not cellEquipItem then
		return 0
	end
	return cellEquipItem.eBagType
end

function tejidingzhi:HandleClickedItem(e)
	local mouseArgs = CEGUI.toMouseEventArgs(e)
	for i = 1, #self.vItemCellEquip do
		local cellEquip = self.vItemCellEquip[i]
		if cellEquip.btnBg == mouseArgs.window then
			self.nItemCellSelId =  cellEquip.nClientKey
			break
		end
	end
	self:cleanInfo()
	self:RefreshEquipCellSel() --self:RefreshEquipCellSel()
	self:RefreshEquip()
	return true
end

function tejidingzhi:ResetEquip()
	self.ItemCellTarget:SetImage(nil)
    SetItemCellBoundColorByQulityItemWithIdtm(self.ItemCellTarget,0)

    self.ImageTargetCanMake:setVisible(false)
	self.LabTargetName:setText("")
	self.ItemCellNeedItem1:SetTextUnit("")
end

function tejidingzhi:getXlItemIdAndNeedNum(nEquipId)
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

function tejidingzhi:RefreshEquip()
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
	
	self:RefreshNeedMoneyLabel()
	self:RefreshRichBox(false)
end

function tejidingzhi:GetCurEquipData()
	local nServerKey = self:GetCurServerKey()
	local eBagType = self:GetCurItemBagType()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local equipData = roleItemManager:FindItemByBagAndThisID(nServerKey,eBagType)
	if not equipData then
		return nil
	end
	return equipData
end

function tejidingzhi:RefreshRichBox(bUseLocal)
	LogInfo(" tejidingzhi.RefreshRichBox(bUseLocal)")
	local equipData = self:GetCurEquipData()
	if not equipData then
		return 
	end
	local eBagType = self:GetCurItemBagType()
	local bHaveData,strParseText = WorkshopHelper.tejidingzhidq(equipData,bUseLocal,eBagType, true)
	if bHaveData then
		self.richBoxEquip:Clear()
		self.richBoxEquip:show()
		self.richBoxEquip:AppendParseText(CEGUI.String(strParseText))
		self.richBoxEquip:Refresh()
	end
	local equipobject =equipData:GetObject()
	if equipobject.skillid < 1 then
		self.BtnSelEffect:setVisible(false)
	else
		self.BtnSelEffect:setVisible(true)
	end
    if equipobject.skilleffect < 1 then
		self.BtnSelEffect1:setVisible(false)
	else
		self.BtnSelEffect1:setVisible(true)
	end
	if equipobject.newskillid < 1 then
		self.BtnSelEffect2:setVisible(false)
	else
		self.BtnSelEffect2:setVisible(true)
	end
    if equipobject.newskilleffect < 1 then
		self.BtnSelEffect3:setVisible(false)
	else
		self.BtnSelEffect3:setVisible(true)
	end


end

function tejidingzhi:GetCurNeedMoney()
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

function tejidingzhi:RefreshNeedMoneyLabel()
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
end

function tejidingzhi:RefreshEquipDetailInfo(vProperty)
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

function tejidingzhi:GetLabelWithIndex(nIndex)
	if nIndex > #self.vLabelTitleProperty then 
		return nil
	end
	return self.vLabelTitleProperty[nIndexLabel], self.vLabelProperty[nIndexLabel]
end


function tejidingzhi.getInstance()
    if not _instance then
        _instance = tejidingzhi:new()
        _instance:OnCreate()
    end
    return _instance
end

function tejidingzhi.getInstanceAndShow()
    if not _instance then
        _instance = tejidingzhi:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    return _instance
end

function tejidingzhi.getInstanceNotCreate()
    return _instance
end

function tejidingzhi.getInstanceOrNot()
	return _instance
end
	
function tejidingzhi.GetLayoutFileName()
    return "tejidingzhi.layout"
end

function tejidingzhi:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, tejidingzhi)
	self:ClearData()
    return self
end

function tejidingzhi.DestroyDialog()
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

function tejidingzhi:ClearData()
	self.vItemCellEquip = {}	
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
	self.bLevelTipOpen = false
end

function tejidingzhi:ClearDataInClose()
	self.vItemCellEquip = nil	
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
	self.bLevelTipOpen = false
end

function tejidingzhi:ClearCellAll()
	for k, v in pairs(self.vItemCellEquip) do
		LogInfo("tejidingzhi:ClearCellAll()=k="..k)
		v:DestroyDialog()
	end
	self.vItemCellEquip = {}
end


function tejidingzhi:OnClose()
	self:ClearCellAll()
	tejidingzhicell.DestroyDialog()
	Dialog.OnClose(self)
	
	self:HandlBtnClickInfoClose()

	self:ClearDataInClose()
	gGetRoleItemManager().m_EventPackMoneyChange:RemoveScriptFunctor(self.m_hPackMoneyChange)
    gGetRoleItemManager():RemoveLuaItemNumChangeNotify(self.m_hItemNumChangeNotify)
	_instance = nil
end

function tejidingzhi:HandleSelEffectBtnClicked(e) --show select level tip
	if self.bLevelTipOpen == true then
		tejidingzhicell.DestroyDialog()
		
		self.bLevelTipOpen = false
		self:RefreshEffectBtn()
	else
		local scrollLevel = tejidingzhicell.getInstanceAndShow(self.m_pMainFrame)
		scrollLevel.dzDlg = self
		self.bLevelTipOpen = true
		self:RefreshEffectBtn()
		tejidingzhicell.getInstanceNotCreate():setSkillList(2);
	end	
end
function tejidingzhi:HandleSelEffectBtnClicked1(e) --show select level tip
	if self.bLevelTipOpen == true then
		tejidingzhicell.DestroyDialog()
		
		self.bLevelTipOpen = false
		self:RefreshEffectBtn()
	else
		local scrollLevel = tejidingzhicell.getInstanceAndShow(self.m_pMainFrame)
		scrollLevel.dzDlg = self
		self.bLevelTipOpen = true
		self:RefreshEffectBtn()
		tejidingzhicell.getInstanceNotCreate():setSkillList(1);
	end	
end
function tejidingzhi:HandleSelEffectBtnClicked2(e) --show select level tip
	if self.bLevelTipOpen == true then
		tejidingzhicell.DestroyDialog()
		
		self.bLevelTipOpen = false
		self:RefreshEffectBtn()
	else
		local scrollLevel = tejidingzhicell.getInstanceAndShow(self.m_pMainFrame)
		scrollLevel.dzDlg = self
		self.bLevelTipOpen = true
		self:RefreshEffectBtn()
		tejidingzhicell.getInstanceNotCreate():setSkillList(3);
	end	
end
function tejidingzhi:HandleSelEffectBtnClicked3(e) --show select level tip
	if self.bLevelTipOpen == true then
		tejidingzhicell.DestroyDialog()
		
		self.bLevelTipOpen = false
		self:RefreshEffectBtn()
	else
		local scrollLevel = tejidingzhicell.getInstanceAndShow(self.m_pMainFrame)
		scrollLevel.dzDlg = self
		self.bLevelTipOpen = true
		self:RefreshEffectBtn()
		tejidingzhicell.getInstanceNotCreate():setSkillList(4);
	end	
end

return tejidingzhi


