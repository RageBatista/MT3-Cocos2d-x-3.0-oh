require "utils.mhsdutils"
require "logic.dialog"
require "logic.workshop.workshopitemcell"
require "logic.workshop.workshophelper"
require "logic.workshop.zhuangbeifumocell"
require "utils.commonutil"

ZhuangBeiFuMoDlg = {}
setmetatable(ZhuangBeiFuMoDlg, Dialog)
ZhuangBeiFuMoDlg.__index = ZhuangBeiFuMoDlg
local _instance;


function ZhuangBeiFuMoDlg.OnDzResult()
	LogInfo("ZhuangBeiFuMoDlg.OnDzResult()")
	if not _instance then
		return
	end
	if _instance.bLoadUI then
		_instance:RefreshEquipList()
		_instance:RefreshEquipCellSel()
		_instance:RefreshEquip()
	end

end

function ZhuangBeiFuMoDlg:RefreshItemTips(item)
	LogInfo("ZhuangBeiFuMoDlg.RefreshItemTips")
	local bUseLocal = true  
	self:RefreshRichBox(bUseLocal)
end


function ZhuangBeiFuMoDlg.OnFailTimesResult(protocol)
	
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

function ZhuangBeiFuMoDlg.OnRefreshAllResult(protocol)
	LogInfo(" ZhuangBeiFuMoDlg.OnRefreshAllResult(protocol)")
	if not _instance then
		return
	end
	_instance:RefreshEquip()
	_instance:RefreshEquipListState()
end


function ZhuangBeiFuMoDlg.OnXlResult()
	if not _instance then
		return
	end

	_instance:RefreshRichBox(false)
	--_instance:RefreshEquipList()
	_instance:RefreshEquipListState()
	_instance:RefreshEquip()
	_instance:FuMoItemNeed()

end

function ZhuangBeiFuMoDlg.closeForBeside()
	if not _instance then
		return
	end
	_instance:closeForBeside()
end

function ZhuangBeiFuMoDlg:closeForBeside()
	self.bLevelTipOpen = false
	self:RefreshEffectBtn()
end


function ZhuangBeiFuMoDlg.OnRefreshOneItemInfoResult(protocol)
	LogInfo("ZhuangBeiFuMoDlg.OnRefreshOneItemInfoResult")
	if not _instance then
		return
	end
	_instance:RefreshEquip()
end



function ZhuangBeiFuMoDlg:OnCreate()
    Dialog.OnCreate(self)
	SetPositionOfWindowWithLabel1(self:GetWindow())
	self.m_hItemNumChangeNotify = gGetRoleItemManager():InsertLuaItemNumChangeNotify(ZhuangBeiFuMoDlg.OnItemNumChange)
	self.m_hPackMoneyChange = gGetRoleItemManager().m_EventPackMoneyChange:InsertScriptFunctor(ZhuangBeiFuMoDlg.OnMoneyChange)
	self:InitUI()
	self.bLoadUI = true
	self:RefreshEquipList()
	self:RefreshEquipCellSel()
	self:RefreshEquip()
    self:ResetEquip()
end


function ZhuangBeiFuMoDlg.AddItemInBag(nItemKey)
	if not _instance then
		return
	end
	
end

function ZhuangBeiFuMoDlg.DelItemInBag(nItemKey)
	if not _instance then
		return
	end
end

function ZhuangBeiFuMoDlg.AddItemInEquipBag(nItemKey)
	if not _instance then
		return
	end
end

function ZhuangBeiFuMoDlg.DelItemInEquipBag(nItemKey)
	if not _instance then
		return
	end
end


function ZhuangBeiFuMoDlg.OnMoneyChange()
	if not _instance then
		return
	end
	_instance:RefreshNeedMoneyLabel()
end

function ZhuangBeiFuMoDlg:AddCell(eBagType,nItemKey)
	
end

function ZhuangBeiFuMoDlg:DeleteCell(eBagType,nItemKey)
	
end

function ZhuangBeiFuMoDlg:RefreshAllCellSortData()
end


function ZhuangBeiFuMoDlg:SortAllCell()
end

function ZhuangBeiFuMoDlg:RefreshAllCellPos()
end


function ZhuangBeiFuMoDlg.OnItemNumChange(eBagType, nItemKey, nItemId)
	if _instance == nil then
		return
	end
	_instance:RefreshEquip()
end


function ZhuangBeiFuMoDlg:RefreshUI(nBagId,nItemKey)
    if not nBagId then
        nBagId = -1
        nItemKey = -1
    end
	self:RefreshEquipList(nBagId,nItemKey)
	self:RefreshEquipCellSel()
	self:RefreshEquip()
end

function ZhuangBeiFuMoDlg:InitUI()
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
	self.ScrollEquip:subscribeEvent("NextPage", ZhuangBeiFuMoDlg.OnNextPage, self)
	self.ItemCellTarget = CEGUI.toItemCell(winMgr:getWindow("zhuangbeifumo/right/part2/item2"))
	self.ImageTargetCanMake = winMgr:getWindow("zhuangbeifumo/right/part2/item2/yizhuangbei") 
	self.LabTargetName = winMgr:getWindow("zhuangbeifumo/right/part2/name2") 
	self.richBoxEquip = CEGUI.toRichEditbox(winMgr:getWindow("zhuangbeifumo/right/shuxinglist/box"))
	self.richBoxEquip:subscribeEvent("MouseButtonUp", ZhuangBeiFuMoDlg.HandlBtnClickInfoClose) 
	self.richBoxEquip:setReadOnly(true)
	
	
	self.smokeBg = winMgr:getWindow("zhuangbeifumo/Back/flagbg/smoke")
	local s = self.smokeBg:getPixelSize()
	local flagSmoke = gGetGameUIManager():AddUIEffect(self.smokeBg, "geffect/ui/mt_shengqishi/mt_shengqishi3", true, s.width*0.5, s.height)


	local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(191232)
	self.m_ShuoMing = CEGUI.toRichEditbox(winMgr:getWindow("zhuangbeifumo/right/shuxinglist/box1"))
	self.m_ShuoMing:AppendParseText(CEGUI.String(tip.msg))
	self.m_ShuoMing:Refresh()
	self.m_ShuoMing:getVertScrollbar():setScrollPosition(0)
	self.m_ShuoMing:setShowVertScrollbar(true)
	self.btnInfo = CEGUI.toPushButton(winMgr:getWindow("zhuangbeifumo/right/shuxinglist/tipsxiangqing"))
	self.btnInfo:subscribeEvent("MouseButtonDown", ZhuangBeiFuMoDlg.PreHandlBtnClickInfo, self) 
    self.btnInfo:subscribeEvent("MouseButtonUp", ZhuangBeiFuMoDlg.HandlBtnClickInfo, self) 
	self.xx = CEGUI.toPushButton(winMgr:getWindow("zhuangbeifumo"))
	self.xx:subscribeEvent("MouseButtonUp", ZhuangBeiFuMoDlg.HandlBtnClickInfoClose) 
	self.xx2 = CEGUI.toPushButton(winMgr:getWindow("zhuangbeifumo/right"))
	self.xx2:subscribeEvent("MouseButtonUp", ZhuangBeiFuMoDlg.HandlBtnClickInfoClose) 
	self.xx3 = CEGUI.toPushButton(winMgr:getWindow("zhuangbeifumo/right/part2/line1"))
	self.xx3:subscribeEvent("MouseButtonUp", ZhuangBeiFuMoDlg.HandlBtnClickInfoClose) 
	self.xx5 = CEGUI.toPushButton(winMgr:getWindow("zhuangbeifumo/left"))
	self.xx5:subscribeEvent("MouseButtonUp", ZhuangBeiFuMoDlg.HandlBtnClickInfoClose) 
	self.ItemCellNeedItem1 = CEGUI.toItemCell(winMgr:getWindow("zhuangbeifumo/right/cailiaolist/item1"))
	self.LabNameNeedItem1 = winMgr:getWindow("zhuangbeifumo/right/cailiaolist/name1")
	self.LabNameNeed1Itemc1 = winMgr:getWindow("zhuangbeifumo/right/cailiaolist/namec1")
	self.LabNameNeed1Itemc2 = winMgr:getWindow("zhuangbeifumo/right/cailiaolist/namec2")
	self.LabNameNeed1Itemc3 = winMgr:getWindow("zhuangbeifumo/right/cailiaolist/namec3")
	self.BtnXl = CEGUI.toPushButton(winMgr:getWindow("zhuangbeifumo/right/button"))
	self.BtnXl:subscribeEvent("Clicked", ZhuangBeiFuMoDlg.HandlBtnClickedXl, self)
	
	self.Btncca1 = CEGUI.toPushButton(winMgr:getWindow("zhuangbeifumo/dianhuacc"))---点化
	self.Btncca1:subscribeEvent("Clicked", ZhuangBeiFuMoDlg.HandlBtncca1, self)
	
	self.Btnccb1 = CEGUI.toPushButton(winMgr:getWindow("zhuangbeifumo/kaikongc147"))---开孔
	self.Btnccb1:subscribeEvent("Clicked", ZhuangBeiFuMoDlg.HandlBtnccb1, self)
	
	self.ItemCellNeedItem1:subscribeEvent("TableClick", Workshopmanager.HandleClickItemCell, Workshopmanager)
	self.BtnSelEffect = CEGUI.toPushButton(winMgr:getWindow("zhuangbeifumo/liebiao/effect"))
	self.BtnSelEffect:subscribeEvent("Clicked", ZhuangBeiFuMoDlg.HandleSelEffectBtnClicked, self) 
	self.BtnSelEffect1 = CEGUI.toPushButton(winMgr:getWindow("zhuangbeifumo/liebiao/effect1"))
	self.BtnSelEffect1:subscribeEvent("Clicked", ZhuangBeiFuMoDlg.HandleSelEffectBtnClicked1, self) 
	self.BtnSelEffect2 = CEGUI.toPushButton(winMgr:getWindow("zhuangbeifumo/liebiao/effect11"))
	self.BtnSelEffect2:subscribeEvent("Clicked", ZhuangBeiFuMoDlg.HandleSelEffectBtnClicked2, self) 
	self.BtnSelEffect3 = CEGUI.toPushButton(winMgr:getWindow("zhuangbeifumo/liebiao/effect111"))
	self.BtnSelEffect3:subscribeEvent("Clicked", ZhuangBeiFuMoDlg.HandleSelEffectBtnClicked3, self) 
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

 function ZhuangBeiFuMoDlg:PreHandlBtnClickInfo(e)
 	--防止点击物品关闭表情界面--by yangbin
	local insetdlg = require("logic.chat.insertdlg").getInstanceNotCreate()
	if insetdlg then
		insetdlg.willCheckTipsWnd = true
	end
 end

function ZhuangBeiFuMoDlg:HandlBtncca1(e)---器灵套装
   require "logic.workshop.Attunement".getInstanceAndShow()
    ZhuangBeiFuMoDlg.DestroyDialog()
end

function ZhuangBeiFuMoDlg:HandlBtnccb1(e)---器灵开孔
   require "logic.workshop.superronglian".getInstanceAndShow()
    ZhuangBeiFuMoDlg.DestroyDialog()
end 

 function ZhuangBeiFuMoDlg:RefreshEffectBtn()
	local bUp = self.bLevelTipOpen
	if bUp == true then
		self.ImageDown:setVisible(false)
		self.ImageUp:setVisible(true)
	else
		self.ImageDown:setVisible(true)
		self.ImageUp:setVisible(false)
	end
end

 function ZhuangBeiFuMoDlg:DestroyDialogc()
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

 function ZhuangBeiFuMoDlg:cleanInfo()
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
	self.labelNewEffectArea:setText("器灵列表")
	self:FuMoItemNeed()
end

 function ZhuangBeiFuMoDlg:HandlBtnClickInfoClose()
	local equipDlg = require("logic.tips.equipinfotips").getInstanceAndShow()
	equipDlg:DestroyDialog()
 end

 function ZhuangBeiFuMoDlg:HandlBtnClickInfo(e)
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

function ZhuangBeiFuMoDlg:GetCurServerKey()
	local cellEquipItem = self:GetCellWithIndex(self.nItemCellSelId)
	if not cellEquipItem then
		return 0
	end
	return cellEquipItem.nServerKey
end

--重铸
function ZhuangBeiFuMoDlg:HandlBtnClickedXl(e)
	if GetBattleManager() and GetBattleManager():IsInBattle() then
		local strShowTip = MHSD_UTILS.get_resstring(11705) 
		GetCTipsManager():AddMessageTip(strShowTip)
        return 
    end
	if self.itemid==0 then
		GetCTipsManager():AddMessageTip(MHSD_UTILS.get_resstring(11706))
		return 
	end
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local nOwnItemNum1 = roleItemManager:GetItemNumByBaseID(self.itemid)
	if self.itemnum > nOwnItemNum1 then
		GetCTipsManager():AddMessageTip(MHSD_UTILS.get_resstring(11707))
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



function ZhuangBeiFuMoDlg:RefreshEquipCellSel()
	for i = 1, #self.vItemCellEquip do 
		local equipCell = self.vItemCellEquip[i]
		if equipCell.nClientKey ~= self.nItemCellSelId then
			equipCell.btnBg:setSelected(false)
		else
			equipCell.btnBg:setSelected(true)
		end	
	end
end

function ZhuangBeiFuMoDlg:RefreshEquipListState()
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

function ZhuangBeiFuMoDlg:OnNextPage(args)
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

function ZhuangBeiFuMoDlg:RefreshSkillArea(name,id,itemid,itemnum)
	self.labelSkillArea:setText(name)
	self.skillid=id
	self.itemid=itemid
	self.itemnum=itemnum
	self.cout=itemnum+self.itemnum1+self.itemnum2+self.itemnum3
	self:FuMoItemNeed()
end

function ZhuangBeiFuMoDlg:RefreshEffectArea(name,id,itemid,itemnum)
	self.labelEffectArea:setText(name)
	self.effectid=id
	self.itemid=itemid
	self.itemnum1=itemnum
	self.cout=self.itemnum+itemnum+self.itemnum2+self.itemnum3
	self:FuMoItemNeed()
end

function ZhuangBeiFuMoDlg:RefreshNewSkillArea(name,id,itemid,itemnum)
	self.labelNewSkillArea:setText(name)
	self.newskillid=id
	self.itemid=itemid
	self.itemnum2=itemnum
	self.cout=self.itemnum+self.itemnum1+itemnum+self.itemnum3
	self:FuMoItemNeed()
end

function ZhuangBeiFuMoDlg:RefreshNewEffectArea(name,id,itemid,itemnum)
	self.labelNewEffectArea:setText(name)
	self.neweffectid=id
	self.itemid=itemid
	self.itemnum3=itemnum
	self.cout=self.itemnum+self.itemnum1+self.itemnum2+itemnum
	self:FuMoItemNeed()
end

function ZhuangBeiFuMoDlg:FuMoItemNeed()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local needItemCfg1 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.itemid)
	if not needItemCfg1 then
		return
	end
	self.ItemCellNeedItem1:SetImage(gGetIconManager():GetItemIconByID(needItemCfg1.icon))
    SetItemCellBoundColorByQulityItemWithIdtm(self.ItemCellNeedItem1,needItemCfg1.id)
	self.ItemCellNeedItem1:setID(needItemCfg1.id)
	self.LabNameNeedItem1:setText(needItemCfg1.name)
	self.LabNameNeed1Itemc1:setText(needItemCfg1.namecc1)
	self.LabNameNeed1Itemc2:setText(needItemCfg1.namecc2)
	self.LabNameNeed1Itemc3:setText(needItemCfg1.namecc3)
	local nOwnItemNum1 = roleItemManager:GetItemNumByBaseID(needItemCfg1.id)
	local strNumNeed_own1 = nOwnItemNum1.."/"..self.cout
	self.ItemCellNeedItem1:SetTextUnit(strNumNeed_own1)
	if nOwnItemNum1 >= self.cout then
		self.ItemCellNeedItem1:SetTextUnitColor(MHSD_UTILS.get_greencolor())
	else
		self.ItemCellNeedItem1:SetTextUnitColor(MHSD_UTILS.get_redcolor())
	end
end

function ZhuangBeiFuMoDlg:CreateEquipCell(equipCellData)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local nIndexEquip = #self.vItemCellEquip + 1
	local nEquipKey = equipCellData.nEquipKey
		local eBagType = equipCellData.eBagType
		local equipData = roleItemManager:FindItemByBagAndThisID(nEquipKey,eBagType)
		if equipData then
			local itemAttrCfg = equipData:GetBaseObject()

			local prefix = "ZhuangBeiFuMoDlg_equip"..nIndexEquip
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
			cellEquipItem.btnBg:subscribeEvent("MouseClick", ZhuangBeiFuMoDlg.HandleClickedItem,self)
		end
		
end

function ZhuangBeiFuMoDlg:RefreshEquipList(nBagId,nItemKey)
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

function ZhuangBeiFuMoDlg:GetCellWithIndex(nIndex)
	if nIndex > #self.vItemCellEquip then
		return nil
	end
	return self.vItemCellEquip[nIndex]
end

function ZhuangBeiFuMoDlg:GetCurItemBagType()
	local cellEquipItem = self:GetCellWithIndex(self.nItemCellSelId)
	if not cellEquipItem then
		return 0
	end
	return cellEquipItem.eBagType
end

function ZhuangBeiFuMoDlg:HandleClickedItem(e)
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

function ZhuangBeiFuMoDlg:ResetEquip()
	self.ItemCellTarget:SetImage(nil)
    SetItemCellBoundColorByQulityItemWithIdtm(self.ItemCellTarget,0)

    self.ImageTargetCanMake:setVisible(false)
	self.LabTargetName:setText("")
	self.ItemCellNeedItem1:SetTextUnit("")
end

function ZhuangBeiFuMoDlg:getXlItemIdAndNeedNum(nEquipId)
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

function ZhuangBeiFuMoDlg:RefreshEquip()
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

function ZhuangBeiFuMoDlg:GetCurEquipData()
	local nServerKey = self:GetCurServerKey()
	local eBagType = self:GetCurItemBagType()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local equipData = roleItemManager:FindItemByBagAndThisID(nServerKey,eBagType)
	if not equipData then
		return nil
	end
	return equipData
end

function ZhuangBeiFuMoDlg:RefreshRichBox(bUseLocal)
	LogInfo(" ZhuangBeiFuMoDlg.RefreshRichBox(bUseLocal)")
	local equipData = self:GetCurEquipData()
	if not equipData then
		return 
	end
	local eBagType = self:GetCurItemBagType()
	local bHaveData,strParseText = WorkshopHelper.GetEquipsitccData(equipData,bUseLocal,eBagType, true)
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
		self.BtnSelEffect:setVisible(false)
	end
    if equipobject.skilleffect < 1 then
		self.BtnSelEffect1:setVisible(false)
	else
		self.BtnSelEffect1:setVisible(false)
	end
	if equipobject.newskilleffect < 1 then
		self.BtnSelEffect3:setVisible(true)
	else
		self.BtnSelEffect3:setVisible(true)
	end
	if equipobject.newskillid < 1 then
		self.BtnSelEffect2:setVisible(false)
	else
		self.BtnSelEffect2:setVisible(false)
	end


end

function ZhuangBeiFuMoDlg:GetCurNeedMoney()
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

function ZhuangBeiFuMoDlg:RefreshNeedMoneyLabel()
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

function ZhuangBeiFuMoDlg:RefreshEquipDetailInfo(vProperty)
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

function ZhuangBeiFuMoDlg:GetLabelWithIndex(nIndex)
	if nIndex > #self.vLabelTitleProperty then 
		return nil
	end
	return self.vLabelTitleProperty[nIndexLabel], self.vLabelProperty[nIndexLabel]
end


function ZhuangBeiFuMoDlg.getInstance()
    if not _instance then
        _instance = ZhuangBeiFuMoDlg:new()
        _instance:OnCreate()
    end
    return _instance
end

function ZhuangBeiFuMoDlg.getInstanceAndShow()
    if not _instance then
        _instance = ZhuangBeiFuMoDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    return _instance
end

function ZhuangBeiFuMoDlg.getInstanceNotCreate()
    return _instance
end

function ZhuangBeiFuMoDlg.getInstanceOrNot()
	return _instance
end
	
function ZhuangBeiFuMoDlg.GetLayoutFileName()
    return "zhuangbeifumo.layout"
end

function ZhuangBeiFuMoDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ZhuangBeiFuMoDlg)
	self:ClearData()
    return self
end

function ZhuangBeiFuMoDlg.DestroyDialog()
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

function ZhuangBeiFuMoDlg:ClearData()
	self.vItemCellEquip = {}	
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
	self.bLevelTipOpen = false
end

function ZhuangBeiFuMoDlg:ClearDataInClose()
	self.vItemCellEquip = nil	
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
	self.bLevelTipOpen = false
end

function ZhuangBeiFuMoDlg:ClearCellAll()
	for k, v in pairs(self.vItemCellEquip) do
		LogInfo("ZhuangBeiFuMoDlg:ClearCellAll()=k="..k)
		v:DestroyDialog()
	end
	self.vItemCellEquip = {}
end


function ZhuangBeiFuMoDlg:OnClose()
	self:ClearCellAll()
	ZhuangBeiFuMoCell.DestroyDialog()
	Dialog.OnClose(self)
	
	self:HandlBtnClickInfoClose()

	self:ClearDataInClose()
	gGetRoleItemManager().m_EventPackMoneyChange:RemoveScriptFunctor(self.m_hPackMoneyChange)
    gGetRoleItemManager():RemoveLuaItemNumChangeNotify(self.m_hItemNumChangeNotify)
	_instance = nil
end

function ZhuangBeiFuMoDlg:HandleSelEffectBtnClicked(e) --show select level tip
	if self.bLevelTipOpen == true then
		ZhuangBeiFuMoCell.DestroyDialog()
		
		self.bLevelTipOpen = false
		self:RefreshEffectBtn()
	else
		local scrollLevel = ZhuangBeiFuMoCell.getInstanceAndShow(self.m_pMainFrame)
		scrollLevel.dzDlg = self
		self.bLevelTipOpen = true
		self:RefreshEffectBtn()
		ZhuangBeiFuMoCell.getInstanceNotCreate():setSkillList(2);
	end	
end
function ZhuangBeiFuMoDlg:HandleSelEffectBtnClicked1(e) --show select level tip
	if self.bLevelTipOpen == true then
		ZhuangBeiFuMoCell.DestroyDialog()
		
		self.bLevelTipOpen = false
		self:RefreshEffectBtn()
	else
		local scrollLevel = ZhuangBeiFuMoCell.getInstanceAndShow(self.m_pMainFrame)
		scrollLevel.dzDlg = self
		self.bLevelTipOpen = true
		self:RefreshEffectBtn()
		ZhuangBeiFuMoCell.getInstanceNotCreate():setSkillList(1);
	end	
end
function ZhuangBeiFuMoDlg:HandleSelEffectBtnClicked2(e) --show select level tip
	if self.bLevelTipOpen == true then
		ZhuangBeiFuMoCell.DestroyDialog()
		
		self.bLevelTipOpen = false
		self:RefreshEffectBtn()
	else
		local scrollLevel = ZhuangBeiFuMoCell.getInstanceAndShow(self.m_pMainFrame)
		scrollLevel.dzDlg = self
		self.bLevelTipOpen = true
		self:RefreshEffectBtn()
		ZhuangBeiFuMoCell.getInstanceNotCreate():setSkillList(3);
	end	
end
function ZhuangBeiFuMoDlg:HandleSelEffectBtnClicked3(e) --show select level tip
	if self.bLevelTipOpen == true then
		ZhuangBeiFuMoCell.DestroyDialog()
		
		self.bLevelTipOpen = false
		self:RefreshEffectBtn()
	else
		local scrollLevel = ZhuangBeiFuMoCell.getInstanceAndShow(self.m_pMainFrame)
		scrollLevel.dzDlg = self
		self.bLevelTipOpen = true
		self:RefreshEffectBtn()
		ZhuangBeiFuMoCell.getInstanceNotCreate():setSkillList(4);
	end	
end

return ZhuangBeiFuMoDlg


