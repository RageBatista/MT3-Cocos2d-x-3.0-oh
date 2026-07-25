require "utils.mhsdutils"
require "logic.dialog"
require "logic.workshop.workshopitemcell5"
require "logic.workshop.workshophelper"
require "logic.item.Addfabaoshuoming"
require "logic.qiandaosongli.fuliplane"

require "utils.commonutil"

AdvancedEquipDlg = {}
setmetatable(AdvancedEquipDlg, Dialog)
AdvancedEquipDlg.__index = AdvancedEquipDlg
local _instance;


function AdvancedEquipDlg.OnDzResult()
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


function AdvancedEquipDlg:RefreshItemTips(item)
	local bUseLocal = true  
	self:RefreshRichBox(bUseLocal)
end



function AdvancedEquipDlg.OnFailTimesResult(protocol)
	
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

function AdvancedEquipDlg.OnRefreshAllResult(protocol)
	LogInfo(" AdvancedEquipDlg.OnRefreshAllResult(protocol)")
	if not _instance then
		return
	end
	_instance:RefreshEquip()
	_instance:RefreshEquipListState()
end



function AdvancedEquipDlg.OnXlResult()
	if not _instance then
		return
	end
	_instance:RefreshRichBox(false)
	_instance:RefreshEquipList()
	_instance:RefreshEquipListState()
	_instance:RefreshEquip()
	local s = _instance.BtnXl:getPixelSize()---法宝进阶特效
   gGetGameUIManager():AddUIEffect(_instance.BtnXl, MHSD_UTILS.get_effectpath(11102), false, s.width*0.5, s.height*0.5)
end




function AdvancedEquipDlg.OnRefreshOneItemInfoResult(protocol)
	LogInfo("AdvancedEquipDlg.OnRefreshOneItemInfoResult")
	if not _instance then
		return
	end
	_instance:RefreshEquip()
end




function AdvancedEquipDlg:OnCreate()
    Dialog.OnCreate(self)
	--SetPositionOfWindowWithLabel1(self:GetWindow())
	self.m_hItemNumChangeNotify = gGetRoleItemManager():InsertLuaItemNumChangeNotify(AdvancedEquipDlg.OnItemNumChange)
	self.m_hPackMoneyChange = gGetRoleItemManager().m_EventPackMoneyChange:InsertScriptFunctor(AdvancedEquipDlg.OnMoneyChange)
	
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


function AdvancedEquipDlg.AddItemInBag(nItemKey)
	if not _instance then
		return
	end
	
end

function AdvancedEquipDlg.DelItemInBag(nItemKey)
	if not _instance then
		return
	end
end

function AdvancedEquipDlg.AddItemInEquipBag(nItemKey)
	if not _instance then
		return
	end
end

function AdvancedEquipDlg.DelItemInEquipBag(nItemKey)
	if not _instance then
		return
	end
end


function AdvancedEquipDlg.OnMoneyChange()
	if not _instance then
		return
	end
	_instance:RefreshNeedMoneyLabel()
end

function AdvancedEquipDlg:AddCell(eBagType,nItemKey)
	
end

function AdvancedEquipDlg:DeleteCell(eBagType,nItemKey)
	
end

function AdvancedEquipDlg:RefreshAllCellSortData()
end


function AdvancedEquipDlg:SortAllCell()
end

function AdvancedEquipDlg:RefreshAllCellPos()
end

function AdvancedEquipDlg:GetCell(eBagType,nEquipKey)

	
end


function AdvancedEquipDlg.OnItemNumChange(eBagType, nItemKey, nItemId)
	if _instance == nil then
		return
	end
	_instance:RefreshEquip()

end


function AdvancedEquipDlg:RefreshUI(nBagId,nItemKey)
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

end

function AdvancedEquipDlg:addButtonAnimation(button, animationName)
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation(animationName)
    if animationDef then
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        animation:setTargetWindow(button)
        animation:setSpeed(0.6)
        button.animation = animation
        button:subscribeEvent("MouseButtonDown", function()
            animation:start()
        end, self)
    end
end

function AdvancedEquipDlg:InitUI()
	local winMgr = CEGUI.WindowManager:getSingleton()
    self.cc_fabaojinjie = winMgr:getWindow("advancedequip")
	self.cc_fabaojiemian = winMgr:getWindow("advancedequip/ccfbjiemianc1")
   
    local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen = aniMan:getAnimation("pane0Expand") 
    self.animationInstance = aniMan:instantiateAnimation(animationOpen) 
    self.animationInstance:setTargetWindow(self.cc_fabaojiemian)
    self.animationInstance:start()
	
	self.ScrollEquip = CEGUI.toScrollablePane(winMgr:getWindow("advancedequip/left"))
	self.ScrollEquip:setMousePassThroughEnabled(true)
	self.ScrollEquip:EnableHorzScrollBar(true)
	self.ScrollEquip:subscribeEvent("NextPage", AdvancedEquipDlg.OnNextPage, self)
	self.ItemCellTarget = CEGUI.toItemCell(winMgr:getWindow("advancedequip/right/part2/item2"))
	self.ImageTargetCanMake = winMgr:getWindow("advancedequip/right/part2/item2/yizhuangbei") 
	self.LabTargetName = winMgr:getWindow("advancedequip/right/part2/name2") 
	self.richBoxEquip = CEGUI.toRichEditbox(winMgr:getWindow("advancedequip/right/shuxinglist/box"))
	self.richBoxEquip:subscribeEvent("MouseButtonUp", AdvancedEquipDlg.HandlBtnClickInfoClose) 
	self.richBoxEquip:setReadOnly(true)
	
	self.btnInfo = CEGUI.toPushButton(winMgr:getWindow("advancedequip/right/shuxinglist/tipsxiangqing"))
	self.btnInfo:subscribeEvent("MouseButtonDown", AdvancedEquipDlg.PreHandlBtnClickInfo, self) 
    self.btnInfo:subscribeEvent("MouseButtonUp", AdvancedEquipDlg.HandlBtnClickInfo, self) 

	
	
	self.xx = CEGUI.toPushButton(winMgr:getWindow("advancedequip"))
	self.xx:subscribeEvent("MouseButtonUp", AdvancedEquipDlg.HandlBtnClickInfoClose) 
	self.xx2 = CEGUI.toPushButton(winMgr:getWindow("advancedequip/right"))
	self.xx2:subscribeEvent("MouseButtonUp", AdvancedEquipDlg.HandlBtnClickInfoClose) 
	self.xx3 = CEGUI.toPushButton(winMgr:getWindow("advancedequip/right/part2/line1"))
	self.xx3:subscribeEvent("MouseButtonUp", AdvancedEquipDlg.HandlBtnClickInfoClose) 
	self.xx5 = CEGUI.toPushButton(winMgr:getWindow("advancedequip/left"))
	self.xx5:subscribeEvent("MouseButtonUp", AdvancedEquipDlg.HandlBtnClickInfoClose) 
	

	self.BtnMake = CEGUI.toGroupButton(winMgr:getWindow("advancedequip/right/putongbutton"))
    self.cc_icon1 = CEGUI.toItemCell(winMgr:getWindow("advancedequip/right/yinbi1"))
    self.cc_shuliang = winMgr:getWindow("advancedequip/right/bg1/one1")

	
	
	self.smokeBg = winMgr:getWindow("advancedequip/Back/flagbg/smoke")-----动画
	local s = self.smokeBg:getPixelSize()
	local flagSmoke = gGetGameUIManager():AddUIEffect(self.smokeBg, "geffect/ui/mt_shengqishi/cc_xingxingc1", true, s.width*0.5, s.height)
	
	
	
	self.ItemCellSrc = CEGUI.toItemCell(winMgr:getWindow("advancedequip/right/part2/line1/tb/item"))
	self.ItemCellSrc:setMousePassThroughEnabled(true)
	

	self.ItemCellNeedItem1 = CEGUI.toItemCell(winMgr:getWindow("advancedequip/right/cailiaolist/item1"))

	self.LabNameNeedItem1 = winMgr:getWindow("advancedequip/right/cailiaolist/name1")
	self.ItemCellNeedItem2 = CEGUI.toItemCell(winMgr:getWindow("advancedequip/right/cailiaolist/item2"))
	self.LabNameNeedItem2 = winMgr:getWindow("advancedequip/right/cailiaolist/name2")
	self.needMoneyLabel = winMgr:getWindow("advancedequip/right/bg1/one") 
	
	
	
	
	self.ownMoneyLabel = winMgr:getWindow("advancedequip/right/bg11/2")
	self.ImageNeedMoneyIcon = winMgr:getWindow("advancedequip/right/yinbi")
	self.ImageOwnMoneyIcon = winMgr:getWindow("advancedequip/right/yinbi2")
	self.BtnXl = CEGUI.toPushButton(winMgr:getWindow("advancedequip/right/button"))
	self.BtnXl:subscribeEvent("Clicked", AdvancedEquipDlg.HandlBtnClickedXl, self)
	
	
	self.cc_btnClose = CEGUI.toPushButton(winMgr:getWindow("advancedequip/ccbtnClose")) -- 关闭
	self:addButtonAnimation(self.cc_btnClose, "xstudyBtnPress")
    self.cc_btnClose:subscribeEvent("Clicked", AdvancedEquipDlg.btnCloseCallBack, self)
    
	self.cc_qhnzbtn = CEGUI.toPushButton(winMgr:getWindow("advancedequip/ccfbjiemianc1/ccqhbtn")) -- 逆转
	self:addButtonAnimation(self.cc_qhnzbtn, "xstudyBtnPress")
    self.cc_qhnzbtn:subscribeEvent("Clicked", AdvancedEquipDlg.fbnzbtnCallBack, self)
	
	self.cc_tipsbtn = CEGUI.toPushButton(winMgr:getWindow("advancedequip/shuxinglist/tipsxiangqing1"))       --tips 法宝进阶tips
	self:addButtonAnimation(self.cc_tipsbtn, "xstudyBtnPress")
	self.cc_tipsbtn:subscribeEvent("Clicked", AdvancedEquipDlg.handleClickTipButton, self)
	
	self.cc_duihuan = CEGUI.toPushButton(winMgr:getWindow("advancedequip/right/bg12/jia1"))---法宝兑换
	self.cc_duihuan:subscribeEvent("Clicked", AdvancedEquipDlg.HandleduihuanbtnClicck, self)--法宝兑换
	

	
	self.ItemCellNeedItem1:subscribeEvent("TableClick", Workshopmanager.HandleClickItemCell, Workshopmanager)
	self.ItemCellNeedItem2:subscribeEvent("TableClick", Workshopmanager.HandleClickItemCell, Workshopmanager)

    self.BtnExchange = CEGUI.toPushButton(winMgr:getWindow("advancedequip/right/jiahao")) --l/right/jiahao
	self.BtnExchange:subscribeEvent("Clicked", AdvancedEquipDlg.HandleExchangeBtnClicked, self)
end

function AdvancedEquipDlg:HandleExchangeBtnClicked(e)
	local dlg = require "logic.currency.stonegoldexchangesilverdlg".getInstanceAndShow()
	dlg:GetWindow():setAlwaysOnTop(true)

	return true
	
end

--[[function AdvancedEquipDlg:HandleBtnRedPackClicck(args)
	require "logic.qiandaosongli.fuliplane".getInstanceAndShow()
    AdvancedEquipDlg.DestroyDialog()
end

function AdvancedEquipDlg:HandleduihuanbtnClicck( args )
	--local dlg = 
	require "logic.qiandaosongli.fuliplane".getInstanceAndShow()
--	dlg:GetWindow():setAlwaysOnTop(true)
	--dlg:GetWindow():setAlwaysOnTop(true)
end	]]

function AdvancedEquipDlg:HandleduihuanbtnClicck( args )
	if fuliplane.getInstanceNotCreate() then
		fuliplane.DestroyDialog()
		return
	end
	local dlg = fuliplane.getInstanceAndShow(self.cc_fabaojinjie);
end	

function AdvancedEquipDlg:handleClickTipButton( args )
	if addfabaoshuoming.getInstanceNotCreate() then
		addfabaoshuoming.DestroyDialog()
		return
	end
	local dlg = addfabaoshuoming.getInstanceAndShow(self.cc_fabaojinjie);
end	


	
function AdvancedEquipDlg:btnCloseCallBack(args)
    AdvancedEquipDlg.DestroyDialog()
end

function AdvancedEquipDlg:DestroyDialogc()
	if self._instance then
	
	_instance.cc_tipsbtn.animation:stop()
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

function AdvancedEquipDlg:fbnzbtnCallBack(e)----逆转
	require "logic.workshop.zhuangbeichongzhu".getInstanceAndShow()
    AdvancedEquipDlg.DestroyDialog()
end



--[[function AdvancedEquipDlg:handleClickTipButton(args)-- 进阶tips
    local tipsStr = ""
    if IsPointCardServer() then
        tipsStr = require("utils.mhsdutils").get_resstring(11806)
    else
        tipsStr = require("utils.mhsdutils").get_resstring(11816)----第一条
    end
    local title = require("utils.mhsdutils").get_resstring(11815)----标题名称
    local tipdlg = require "logic.workshop.tips1".getInstanceAndShow(tipsStr, title)
    SetPositionScreenCenter(tipdlg:GetWindow())
end]]

 function AdvancedEquipDlg:PreHandlBtnClickInfo(e)
	local insetdlg = require("logic.chat.insertdlg").getInstanceNotCreate()
	if insetdlg then
		insetdlg.willCheckTipsWnd = true
	end
 end
 
 function AdvancedEquipDlg:HandlBtnClickInfoClose()
	local equipDlg = require("logic.tips.equipinfotips").getInstanceAndShow()
	equipDlg:DestroyDialog()
 end

 function AdvancedEquipDlg:HandlBtnClickInfo(e)
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

function AdvancedEquipDlg:GetCurServerKey()
	local cellEquipItem = self:GetCellWithIndex(self.nItemCellSelId)
	if not cellEquipItem then
		return 0
	end
	return cellEquipItem.nServerKey
end



function AdvancedEquipDlg:HandlBtnClickedXl(e)
    if GetBattleManager() and GetBattleManager():IsInBattle() then
        return 
    end
    -- 检查货币是否足够
    local nNeedMoney = self:GetCurNeedMoney()
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local nUserMoney = roleItemManager:GetGold()
	
	if self.nItemCellSelId == 0 then
        -- 没有选中物品，弹出提示
        GetCTipsManager():AddMessageTipById(193515) 
        return  -- 直接返回，不执行后续逻辑
    end

    if nUserMoney < nNeedMoney then
        GetCTipsManager():AddMessageTipById(193514) -- 货币不足提示
        return 
    end
    -- 检查物品是否足够
    local bCanXiuli, strResult = self:IsCanXiuli() --  调用 IsCanXiuli 函数检查物品是否足够
    if not bCanXiuli then
        GetCTipsManager():AddMessageTipById(193513)  -- 物品不足提示
        return
    end
	
    -- 发送请求
    local nEquipKey = self:GetCurServerKey()
    local eBagType = self:GetCurItemBagType()
    local p = require "protodef.fire.pb.item.cxiuliequipitem":new()
    p.repairtype = self.eXlType
    p.keyinpack = nEquipKey
    p.packid = eBagType 
    require "manager.luaprotocolmanager":send(p)
    
  --  GetCTipsManager():AddMessageTipById(193516)  --  成功提示
end	

function AdvancedEquipDlg:checkShowItemOverNeed()
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

function AdvancedEquipDlg:clickConfirmBoxOk_xl()
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

function AdvancedEquipDlg:clickConfirmBoxCancel_xl()
gGetMessageManager():CloseConfirmBox(eConfirmNormal,false)

end

function AdvancedEquipDlg:SendRequestAllEndure()
	local p1 = require "protodef.fire.pb.item.creqallnaijiu":new()
	p1.packid = fire.pb.item.BagTypes.BAG
	require "manager.luaprotocolmanager":send(p1)
	local p2 = require "protodef.fire.pb.item.creqallnaijiu":new()
	p2.packid = fire.pb.item.BagTypes.EQUIP
	require "manager.luaprotocolmanager":send(p2)
end



function AdvancedEquipDlg:RefreshEquipCellSel()
	for i = 1, #self.vItemCellEquip do 
		local equipCell = self.vItemCellEquip[i]
		if equipCell.nClientKey ~= self.nItemCellSelId then
			equipCell.btnBg:setSelected(false)
		else
			equipCell.btnBg:setSelected(true)

		end	
	end
end

function AdvancedEquipDlg:RefreshEquipListState()
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

function AdvancedEquipDlg:OnNextPage(args)
	local wsManager = Workshopmanager.getInstance()
	wsManager.nXilianPage = wsManager.nXilianPage + 1
	local vEquipKeyOrderIndex = {}
    wsManager:GetAqEquipWithPage1(vEquipKeyOrderIndex,wsManager.nXilianPage)
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

function AdvancedEquipDlg:CreateEquipCell(equipCellData)
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local nIndexEquip = #self.vItemCellEquip + 1
    local nEquipKey = equipCellData.nEquipKey
    local eBagType = equipCellData.eBagType
    local equipData = roleItemManager:FindItemByBagAndThisID(nEquipKey, eBagType)
    if equipData then
        local itemAttrCfg = equipData:GetBaseObject()

        local prefix = "AdvancedEquipDlg_equip"..nIndexEquip
        local cellEquipItem = Workshopitemcell5.new(self.ScrollEquip, nIndexEquip - 1, prefix)
        local offsetX = 0
        for i = 1, nIndexEquip - 1 do 
            offsetX = offsetX + self.vItemCellEquip[i].m_pMainFrame:getWidth():asAbsolute(0) 
        end
        offsetX = offsetX + 5 * (nIndexEquip - 1)  
        cellEquipItem.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, offsetX), CEGUI.UDim(0, 0)))
		
			cellEquipItem:RefreshVisibleWithType(4) --//1=dz 2xq 3hc 4xl
			self.vItemCellEquip[nIndexEquip] = cellEquipItem
			cellEquipItem.labItemName:setText(equipData:GetName())
			cellEquipItem.itemCell:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg.icon))
            SetItemCellBoundColorByQulityItemWithIdtm(cellEquipItem.itemCell,itemAttrCfg.id)

            if  itemAttrCfg.nquality > 0 then
                SetItemCellBoundColorByQulityItemtm(cellEquipItem.itemCell, itemAttrCfg.nquality )
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
			cellEquipItem.btnBg:subscribeEvent("MouseClick", AdvancedEquipDlg.HandleClickedItem,self)
		end
	return true
end

function AdvancedEquipDlg:RefreshEquipList(nBagId,nItemKey)
	local wsManager = Workshopmanager.getInstance()
	wsManager:RefreshEquipArray(nBagId,nItemKey)
	wsManager.nXilianPage = 1
	
	self:ClearCellAll()
	
	self.ScrollEquip:cleanupNonAutoChildren()
	self.vItemCellEquip = {}


	local vEquipKeyOrderIndex = {}
    wsManager:GetAqEquipWithPage1(vEquipKeyOrderIndex,wsManager.nXilianPage)
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

function AdvancedEquipDlg:GetCellWithIndex(nIndex)
	if nIndex > #self.vItemCellEquip then
		return nil
	end
	return self.vItemCellEquip[nIndex]
end

function AdvancedEquipDlg:GetCurItemBagType()
	local cellEquipItem = self:GetCellWithIndex(self.nItemCellSelId)
	if not cellEquipItem then
		return 0
	end
	return cellEquipItem.eBagType
end

function AdvancedEquipDlg:HandleClickedItem(e)
	local mouseArgs = CEGUI.toMouseEventArgs(e)
	for i = 1, #self.vItemCellEquip do
		local cellEquip = self.vItemCellEquip[i]
		if cellEquip.btnBg == mouseArgs.window then
			self.nItemCellSelId =  cellEquip.nClientKey
			break
		end
	end
	self:RefreshEquipCellSel() 
	self:RefreshEquip()

	return true
end

function AdvancedEquipDlg:ResetEquip()
	self.richBoxEquip:Clear()
	self.richBoxEquip:Refresh()
	self.ItemCellTarget:SetImage(nil)
	self.ItemCellSrc:SetImage(nil)
    SetItemCellBoundColorByQulityItemWithIdtm(self.ItemCellTarget,0)

    self.ImageTargetCanMake:setVisible(false)
	self.LabTargetName:setText("")
	self.ItemCellNeedItem1:SetTextUnit("")
	self.LabNameNeedItem1:setText("")
	self.ItemCellNeedItem2:SetTextUnit("")
	self.LabNameNeedItem2:setText("")
	self.needMoneyLabel:setText("")

end

function AdvancedEquipDlg:getAQItemIdAndNeedNum(nEquipId)
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

function AdvancedEquipDlg:RefreshEquip()
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
    SetItemCellBoundColorByQulityItemWithIdtm(self.ItemCellTarget,itemAttrCfg.id)

    if jinjieidicon.nquality > 0 then
        SetItemCellBoundColorByQulityItemtm(self.ItemCellTarget,itemAttrCfg.nquality+1)
    end
    refreshItemCellBind(self.ItemCellTarget,eBagType,nEquipKey)

	self.LabTargetName:setText(jinjieidicon.name)
	local nEquipType = jinjieidicon.itemtypeid
	local strTypeName = ""
	local itemTypeCfg = BeanConfigManager.getInstance():GetTableByName("item.citemtype"):getRecorder(nEquipType)
	if itemTypeCfg then
		strTypeName = itemTypeCfg.weapon
	end
	--//===============================
	self.ItemCellNeedItem1:SetImage(gGetIconManager():GetItemIconByID(needItemCfg1.icon))
    SetItemCellBoundColorByQulityItemWithIdtm(self.ItemCellNeedItem1,needItemCfg1.id)
	self.ItemCellNeedItem1:setID(needItemCfg1.id)
	self.cc_icon1:SetImage(gGetIconManager():GetItemIconByID(needItemCfg1.icon))
	
	local nOwnItemNum1 = roleItemManager:GetItemNumByBaseID(needItemCfg1.id)
	local strNumNeed_own1 = nOwnItemNum1.."/"..nNeedItemNum1
	self.ItemCellNeedItem1:SetTextUnit(strNumNeed_own1)
	self.cc_shuliang:setText(strNumNeed_own1)
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

function AdvancedEquipDlg:GetCurEquipData()
	local nServerKey = self:GetCurServerKey()
	local eBagType = self:GetCurItemBagType()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local equipData = roleItemManager:FindItemByBagAndThisID(nServerKey,eBagType)
	if not equipData then
		return nil
	end
	return equipData
end

function AdvancedEquipDlg:RefreshRichBox(bUseLocal)
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
		self.ItemCellSrc:SetImage(gGetIconManager():GetItemIconByID(equipData:GetBaseObject().icon))
		SetItemCellBoundColorByQulityItemWithId(self.ItemCellSrc,equipData:GetBaseObject().id)
	end
end

function AdvancedEquipDlg:GetCurNeedMoney()
	local cellEquipItem = self:GetCellWithIndex(self.nItemCellSelId)
    if not cellEquipItem then
        return 0  -- 没有找到对应物品，返回 0
    end
    local nEquipKey = cellEquipItem.itemCell:getID()
    local eBagType =  cellEquipItem.eBagType
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local equipData = roleItemManager:FindItemByBagAndThisID(nEquipKey,eBagType)
    if not equipData then
        return 0  -- 没有找到对应物品，返回 0 
    end
    local itemAttrCfg = equipData:GetBaseObject()
    local nEquipId = itemAttrCfg.id
    local equipPropertyCfg = BeanConfigManager.getInstance():GetTableByName("item.cequipitemattr"):getRecorder(nEquipId)
    if not equipPropertyCfg then
        return 0  --  没有找到对应配置，返回 0
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

function AdvancedEquipDlg:RefreshNeedMoneyLabel()
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
	local nUserMoney = CurrencyManager.getOwnCurrencyMount(1)--roleItemManager:GetPackMoney()
	--//===========================
	
	local strNeedMoney = require("logic.workshop.workshopmanager").getNumStrWithThousand(nNeedMoney)
	
	self.needMoneyLabel:setText(strNeedMoney)
	local strUserMoney = require("logic.workshop.workshopmanager").getNumStrWithThousand(nUserMoney)
	
	local roleGold = roleItemManager:GetGold()
    self.ownMoneyLabel:setText(tostring(roleGold))

end



function AdvancedEquipDlg:RefreshEquipDetailInfo(vProperty)
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

function AdvancedEquipDlg:GetLabelWithIndex(nIndex)
	if nIndex > #self.vLabelTitleProperty then 
		return nil
	end
	return self.vLabelTitleProperty[nIndexLabel], self.vLabelProperty[nIndexLabel]
end



function AdvancedEquipDlg:IsCanXiuli()
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

	
	local nNeedItemId1,nNeedItemNum1  = self:getAQItemIdAndNeedNum(nEquipId)

	
	local nNeedItemId2 = equipPropertyCfg.tsxlcailiaoid
	local nNeedItemNum2 = equipPropertyCfg.tsxlcailiaonum
	local nOwnItemNum1 = roleItemManager:GetItemNumByBaseID(nNeedItemId1)
	local nOwnItemNum2 = roleItemManager:GetItemNumByBaseID(nNeedItemId2)
	local nUserMoney = roleItemManager:GetGold()
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
		if nOwnItemNum1 < nNeedItemNum1 then
			strResult = MHSD_UTILS.get_resstring(11006) 
			strResult = strResult..needItemCfg2.name
			return false, strResult
		end
	end
	return true, strResult
end

function AdvancedEquipDlg:RefreshTwoBtnSel()
	local strTitleCur = ""
	if self.eXlType == 2 then
		strTitleCur = self.BtnMake:getText()
	else
		strTitleCur = self.BtnMakeQh:getText()
	end
	self.BtnXl:setText(strTitleCur)
end


function AdvancedEquipDlg:CheckBoxStateChanged(args)
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
function AdvancedEquipDlg.getInstance()
    if not _instance then
        _instance = AdvancedEquipDlg:new()
        _instance:OnCreate()
    end
    return _instance
end

function AdvancedEquipDlg.getInstanceAndShow()
    if not _instance then
        _instance = AdvancedEquipDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
	_instance:SendRequestAllEndure()
    return _instance
end

function AdvancedEquipDlg.getInstanceNotCreate()
    return _instance
end

function AdvancedEquipDlg.getInstanceOrNot()
	return _instance
end
	
function AdvancedEquipDlg.GetLayoutFileName()
    return "advancedequipment.layout"
end

function AdvancedEquipDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, AdvancedEquipDlg)
	self:ClearData()
    return self
end

function AdvancedEquipDlg.DestroyDialog()
	if not _instance then
		return
	end
	if _instance.animationInstance then 
       _instance.animationInstance:stop()
       _instance.animationInstance = nil 
    end
   _instance.cc_btnClose.animation:stop()
   _instance.cc_qhnzbtn.animation:stop()
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

function AdvancedEquipDlg:ClearData()
	self.vItemCellEquip = {}	
	self.eXlType = 2 --3=normal 4=special
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
end

function AdvancedEquipDlg:ClearDataInClose()
	self.vItemCellEquip = nil	
	self.eXlType = 2 --3=normal 4=special
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
end

function AdvancedEquipDlg:ClearCellAll()
	for k, v in pairs(self.vItemCellEquip) do
		v:DestroyDialog()
	end
	self.vItemCellEquip = {}
end


function AdvancedEquipDlg:OnClose()
	self:ClearCellAll()
	Dialog.OnClose(self)
	self:HandlBtnClickInfoClose()
	self:ClearDataInClose()
	gGetRoleItemManager().m_EventPackMoneyChange:RemoveScriptFunctor(self.m_hPackMoneyChange)
    gGetRoleItemManager():RemoveLuaItemNumChangeNotify(self.m_hItemNumChangeNotify)
	
	CurrencyManager.unregisterTextWidget(self.ownMoneyLabel)
	_instance = nil
end

return AdvancedEquipDlg


