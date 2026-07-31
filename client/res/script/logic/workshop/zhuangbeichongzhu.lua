require "utils.mhsdutils"
require "logic.dialog"
require "logic.workshop.workshopitemcell5"
require "logic.workshop.workshophelper"
require "logic.qiandaosongli.fuliplane"
require "utils.commonutil"

ZhuangBeiChongZhuDlg = {}
setmetatable(ZhuangBeiChongZhuDlg, Dialog)
ZhuangBeiChongZhuDlg.__index = ZhuangBeiChongZhuDlg
local _instance;


function ZhuangBeiChongZhuDlg.OnDzResult()
	LogInfo("ZhuangBeiChongZhuDlg.OnDzResult()")
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


function ZhuangBeiChongZhuDlg:RefreshItemTips(item)
	LogInfo("ZhuangBeiChongZhuDlg.RefreshItemTips")
	local bUseLocal = true  
	self:RefreshRichBox(bUseLocal)
end



function ZhuangBeiChongZhuDlg.OnFailTimesResult(protocol)
	
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

function ZhuangBeiChongZhuDlg.OnRefreshAllResult(protocol)
	LogInfo(" ZhuangBeiChongZhuDlg.OnRefreshAllResult(protocol)")
	if not _instance then
		return
	end
	_instance:RefreshEquip()
	_instance:RefreshEquipListState()
end



function ZhuangBeiChongZhuDlg.OnXlResult()
	if not _instance then
		return
	end

	_instance:RefreshRichBox(false)
	_instance:RefreshEquipListState()

	_instance:RefreshEquip()
	local s = _instance.BtnXl:getPixelSize()---法宝逆转特效
    gGetGameUIManager():AddUIEffect(_instance.BtnXl, MHSD_UTILS.get_effectpath(11101), false, s.width*0.5, s.height*0.5)
	
	local aniMan = CEGUI.AnimationManager:getSingleton()
    local animation = aniMan:getAnimation("ccfbnzani") 
    local animationInstance = aniMan:instantiateAnimation(animation)  
    animationInstance:setTargetWindow(_instance.cc_fbrichBox) 
    animationInstance:start() 
end


function ZhuangBeiChongZhuDlg.OnRefreshOneItemInfoResult(protocol)
	LogInfo("ZhuangBeiChongZhuDlg.OnRefreshOneItemInfoResult")
	if not _instance then
		return
	end
	_instance:RefreshEquip()
end



function ZhuangBeiChongZhuDlg:OnCreate()
    Dialog.OnCreate(self)
--	SetPositionOfWindowWithLabel1(self:GetWindow())
	self.m_hItemNumChangeNotify = gGetRoleItemManager():InsertLuaItemNumChangeNotify(ZhuangBeiChongZhuDlg.OnItemNumChange)
	self.m_hPackMoneyChange = gGetRoleItemManager().m_EventPackMoneyChange:InsertScriptFunctor(ZhuangBeiChongZhuDlg.OnMoneyChange)
	self:InitUI()
	self.bLoadUI = true
	self:RefreshEquipList()
	self:RefreshEquipCellSel()
	self:RefreshEquip()
	self:SendRequestAllEndure()
	--self:RefreshTwoBtnSel()
    self:ResetEquip()
end


function ZhuangBeiChongZhuDlg.AddItemInBag(nItemKey)
	if not _instance then
		return
	end
	
end

function ZhuangBeiChongZhuDlg.DelItemInBag(nItemKey)
	if not _instance then
		return
	end
end

function ZhuangBeiChongZhuDlg.AddItemInEquipBag(nItemKey)
	if not _instance then
		return
	end
end

function ZhuangBeiChongZhuDlg.DelItemInEquipBag(nItemKey)
	if not _instance then
		return
	end
end


function ZhuangBeiChongZhuDlg.OnMoneyChange()
	if not _instance then
		return
	end
	_instance:RefreshNeedMoneyLabel()
end

function ZhuangBeiChongZhuDlg:AddCell(eBagType,nItemKey)
	
end

function ZhuangBeiChongZhuDlg:DeleteCell(eBagType,nItemKey)
	
end

function ZhuangBeiChongZhuDlg:RefreshAllCellSortData()
end


function ZhuangBeiChongZhuDlg:SortAllCell()
end

function ZhuangBeiChongZhuDlg:RefreshAllCellPos()
end


function ZhuangBeiChongZhuDlg.OnItemNumChange(eBagType, nItemKey, nItemId)
	if _instance == nil then
		return
	end
	_instance:RefreshEquip()
end


function ZhuangBeiChongZhuDlg:RefreshUI(nBagId,nItemKey)
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

function ZhuangBeiChongZhuDlg:addButtonAnimation(button, animationName)
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

function ZhuangBeiChongZhuDlg:InitUI()
	local winMgr = CEGUI.WindowManager:getSingleton()
--	SetPositionOfWindowWithLabel(self.m_pMainFrame);
    self.cc_fabaonizhuan = winMgr:getWindow("zhuangbeichongzhu/mask")
	self.cc_fabaonzjiemian = winMgr:getWindow("fabaonz/ccfbjiemianc1")
   
    local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen = aniMan:getAnimation("pane0Expand") 
    self.animationInstance = aniMan:instantiateAnimation(animationOpen) 
    self.animationInstance:setTargetWindow(self.cc_fabaonzjiemian)
    self.animationInstance:start()
	
	self.ScrollEquip = CEGUI.toScrollablePane(winMgr:getWindow("zhuangbeichongzhu/left"))
	self.ScrollEquip:setMousePassThroughEnabled(true)
	self.ScrollEquip:EnableHorzScrollBar(true)
	self.ScrollEquip:subscribeEvent("NextPage", ZhuangBeiChongZhuDlg.OnNextPage, self)
	
	
	self.ItemCellTarget = CEGUI.toItemCell(winMgr:getWindow("zhuangbeichongzhu/right/part2/item2"))
	self.ImageTargetCanMake = winMgr:getWindow("zhuangbeichongzhu/right/part2/item2/yizhuangbei") 
	self.LabTargetName = winMgr:getWindow("zhuangbeichongzhu/right/part2/name2") 
	self.LabTargetNamec = winMgr:getWindow("zhuangbeichongzhu/right/part2/name22") 
	
	
	
	self.btnInfo = CEGUI.toPushButton(winMgr:getWindow("zhuangbeichongzhu/right/shuxinglist/tipsxiangqing"))
	self.btnInfo:subscribeEvent("MouseButtonDown", ZhuangBeiChongZhuDlg.PreHandlBtnClickInfo, self) 
    self.btnInfo:subscribeEvent("MouseButtonUp", ZhuangBeiChongZhuDlg.HandlBtnClickInfo, self) 
	
	
	self.xx = CEGUI.toPushButton(winMgr:getWindow("zhuangbeichongzhu"))
	self.xx:subscribeEvent("MouseButtonUp", ZhuangBeiChongZhuDlg.HandlBtnClickInfoClose) 
	self.xx2 = CEGUI.toPushButton(winMgr:getWindow("zhuangbeichongzhu/right"))
	self.xx2:subscribeEvent("MouseButtonUp", ZhuangBeiChongZhuDlg.HandlBtnClickInfoClose) 
	self.xx3 = CEGUI.toPushButton(winMgr:getWindow("zhuangbeichongzhu/right/part2/line1"))
	self.xx3:subscribeEvent("MouseButtonUp", ZhuangBeiChongZhuDlg.HandlBtnClickInfoClose) 
	self.xx5 = CEGUI.toPushButton(winMgr:getWindow("zhuangbeichongzhu/left"))
	self.xx5:subscribeEvent("MouseButtonUp", ZhuangBeiChongZhuDlg.HandlBtnClickInfoClose) 
	
	
	
	self.BtnMake = CEGUI.toGroupButton(winMgr:getWindow("zhuangbeichongzhu/right/putongbutton"))

	self.BtnMakeQh = CEGUI.toPushButton(winMgr:getWindow("zhuangbeichongzhu/right/teshubutton"))
    self.checkbox = CEGUI.toCheckbox(winMgr:getWindow("zhuangbeichongzhu/right/part2/line1/gou"))
    self.checkbox:subscribeEvent("MouseButtonUp", ZhuangBeiChongZhuDlg.CheckBoxStateChanged, self)
	
	self.cc_nztipsButton = CEGUI.toPushButton(winMgr:getWindow("zhuangbeichongzhu/right/tipsxiangqing1"))       --tips 法宝进阶tips
    self:addButtonAnimation(self.cc_nztipsButton, "xstudyBtnPress")
	self.cc_nztipsButton:subscribeEvent("Clicked", ZhuangBeiChongZhuDlg.handleClickTipButton, self)
	
	
	self.cc_nzicon = CEGUI.toItemCell(winMgr:getWindow("zhuangbeichongzhu/right/yinbi1"))
    self.cc_nzshuliang = winMgr:getWindow("zhuangbeichongzhu/right/bg1/one1")
	
	self.cc_nzduihuan = CEGUI.toPushButton(winMgr:getWindow("zhuangbeichongzhu/right/bg12/jia1"))---法宝兑换
	self.cc_nzduihuan:subscribeEvent("Clicked", ZhuangBeiChongZhuDlg.HandleduihuanbtnClicck, self)--法宝兑换
	
	
	self.smokeBg = winMgr:getWindow("zhuangbeichongzhu/Back/flagbg/smoke")-- 动画
	local s = self.smokeBg:getPixelSize()
	local flagSmoke = gGetGameUIManager():AddUIEffect(self.smokeBg, "geffect/ui/mt_shengqishi/cc_xingxingc2", true, s.width*0.5, s.height)

	self.cc_nzbtnClose = CEGUI.toPushButton(winMgr:getWindow("zhuangbeichongzhu/ccbtnClose")) -- 关闭
	self:addButtonAnimation(self.cc_nzbtnClose, "xstudyBtnPress")
    self.cc_nzbtnClose:subscribeEvent("Clicked", ZhuangBeiChongZhuDlg.btnCloseCallBack, self)
	
	
	self.cc_qhfbbtn = CEGUI.toPushButton(winMgr:getWindow("zhuangbeichongzhu/ccfbjiemianc1/ccqhbtn")) -- 进阶
	self:addButtonAnimation(self.cc_qhfbbtn, "xstudyBtnPress")
    self.cc_qhfbbtn:subscribeEvent("Clicked", ZhuangBeiChongZhuDlg.fbqhbtnCallBack, self)
	
	
	--self.cc_nzck = winMgr:getWindow("zhuangbeichongzhu/right/shuxinglist")
	
	self.cc_fbrichBox = CEGUI.toRichEditbox(winMgr:getWindow("zhuangbeichongzhu/right/shuxinglist/box"))
	self.cc_fbrichBox:subscribeEvent("MouseButtonUp", ZhuangBeiChongZhuDlg.HandlBtnClickInfoClose) 
	self.cc_fbrichBox:setReadOnly(true)
	
	self.cc_nzitem = CEGUI.toItemCell(winMgr:getWindow("zhuangbeichongzhu/right/part2/ccitem"))
	self.cc_nzname = winMgr:getWindow("zhuangbeichongzhu/right/part2/ccnzname") 
	
	--[[local aniMan = CEGUI.AnimationManager:getSingleton()
    local animation = aniMan:getAnimation("pane0Expand") 
    local animationInstance = aniMan:instantiateAnimation(animation)  
    animationInstance:setTargetWindow(self.cc_nzck) 
    animationInstance:start()  ]]
		
	self.ItemCellNeedItem1 = CEGUI.toItemCell(winMgr:getWindow("zhuangbeichongzhu/right/cailiaolist/item1"))
	self.LabNameNeedItem1 = winMgr:getWindow("zhuangbeichongzhu/right/cailiaolist/name1")
	self.ItemCellNeedItem2 = CEGUI.toItemCell(winMgr:getWindow("zhuangbeichongzhu/right/cailiaolist/item2"))
	self.LabNameNeedItem2 = winMgr:getWindow("zhuangbeichongzhu/right/cailiaolist/name2")
	self.needMoneyLabel = winMgr:getWindow("zhuangbeichongzhu/right/bg1/one") --zhuangbeichongzhu/right/bg1/one
	self.ownMoneyLabel = winMgr:getWindow("zhuangbeichongzhu/right/bg11/2") --zhuangbeichongzhu/right/bg11/2
	self.ImageNeedMoneyIcon = winMgr:getWindow("zhuangbeichongzhu/right/yinbi")
	self.ImageOwnMoneyIcon = winMgr:getWindow("zhuangbeichongzhu/right/yinbi2")
	
	self.BtnXl = CEGUI.toPushButton(winMgr:getWindow("zhuangbeichongzhu/right/button"))--逆转按钮
	self.BtnXl:subscribeEvent("Clicked", ZhuangBeiChongZhuDlg.HandlBtnClickedXl, self)--逆转按钮
	
	
	self.labelNormalDesc = winMgr:getWindow("zhuangbeichongzhu/right/part2/line1/text")
	self.labelSpecialDesc = winMgr:getWindow("zhuangbeichongzhu/right/part2/line1/textteshu1")
	self.ItemCellNeedItem1:setVisible(true)
	self.ItemCellNeedItem1:subscribeEvent("TableClick", Workshopmanager.HandleClickItemCell, Workshopmanager)

    self.BtnExchange = CEGUI.toPushButton(winMgr:getWindow("zhuangbeichongzhu/right/jiahao")) --zhuangbeichongzhu/right/jiahao
	self.BtnExchange:subscribeEvent("Clicked", ZhuangBeiChongZhuDlg.HandleExchangeBtnClicked, self)
end

function ZhuangBeiChongZhuDlg:HandleExchangeBtnClicked(e)
	local dlg = require "logic.currency.stonegoldexchangesilverdlg".getInstanceAndShow()
	dlg:GetWindow():setAlwaysOnTop(true)

	return true
	
end

function ZhuangBeiChongZhuDlg:fbqhbtnCallBack(e)----法宝进阶
	require "logic.workshop.workshopaq".getInstanceAndShow()
    ZhuangBeiChongZhuDlg.DestroyDialog()
end


function ZhuangBeiChongZhuDlg:DestroyDialogc()---动画
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

function ZhuangBeiChongZhuDlg:HandleduihuanbtnClicck( args )
	if fuliplane.getInstanceNotCreate() then
		fuliplane.DestroyDialog()
		return
	end
	local dlg = fuliplane.getInstanceAndShow(self.cc_fabaonizhuan);
end	


function ZhuangBeiChongZhuDlg:handleClickTipButton(args)
    local tipsStr = ""
    if IsPointCardServer() then
        tipsStr = require("utils.mhsdutils").get_resstring(11806)
    else
        tipsStr = require("utils.mhsdutils").get_resstring(11818)----第一条
    end
    local title = require("utils.mhsdutils").get_resstring(11817)----标题名称
    local tipdlg = require "logic.workshop.tips1".getInstanceAndShow(tipsStr, title)
    SetPositionScreenCenter(tipdlg:GetWindow())
end


 function ZhuangBeiChongZhuDlg:PreHandlBtnClickInfo(e)
 	--防止点击物品关闭表情界面--by yangbin
	local insetdlg = require("logic.chat.insertdlg").getInstanceNotCreate()
	if insetdlg then
		insetdlg.willCheckTipsWnd = true
	end
 end
 
 function ZhuangBeiChongZhuDlg:HandlBtnClickInfoClose()
	local equipDlg = require("logic.tips.equipinfotips").getInstanceAndShow()
	equipDlg:DestroyDialog()
 end

 function ZhuangBeiChongZhuDlg:HandlBtnClickInfo(e)
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

function ZhuangBeiChongZhuDlg:GetCurServerKey()
	local cellEquipItem = self:GetCellWithIndex(self.nItemCellSelId)
	if not cellEquipItem then
		return 0
	end
	return cellEquipItem.nServerKey
end

--重铸
function ZhuangBeiChongZhuDlg:HandlBtnClickedXl(e)

	if GetBattleManager() and GetBattleManager():IsInBattle() then
		local strShowTip = MHSD_UTILS.get_resstring(11693) 
		GetCTipsManager():AddMessageTip(strShowTip)
        return 
    end
	
	if self.nItemCellSelId == 0 then
        -- 没有选中物品，弹出提示
        GetCTipsManager():AddMessageTipById(193517) 
        return  -- 直接返回，不执行后续逻辑
    end
	
	local bCanXiuli, strResult = self:IsCanXiuli() --  调用 IsCanXiuli 函数检查物品是否足够
    if not bCanXiuli then
        GetCTipsManager():AddMessageTipById(193518)  -- 物品不足提示
        return
    end
	
	--//=======================================
	

	--//=======================================
	local nEquipKey = self:GetCurServerKey()
	local eBagType = self:GetCurItemBagType()
	
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local equipData = roleItemManager:FindItemByBagAndThisID(nEquipKey,eBagType)
	if equipData then
		local equipObj = equipData:GetObject() 
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

function ZhuangBeiChongZhuDlg:checkShowItemOverNeed()
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

function ZhuangBeiChongZhuDlg:clickConfirmBoxOk_xl()
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

function ZhuangBeiChongZhuDlg:clickConfirmBoxCancel_xl()
gGetMessageManager():CloseConfirmBox(eConfirmNormal,false)

end

function ZhuangBeiChongZhuDlg:SendRequestAllEndure()
	local p1 = require "protodef.fire.pb.item.creqallnaijiu":new()
	p1.packid = fire.pb.item.BagTypes.BAG
	require "manager.luaprotocolmanager":send(p1)
	local p2 = require "protodef.fire.pb.item.creqallnaijiu":new()
	p2.packid = fire.pb.item.BagTypes.EQUIP
	require "manager.luaprotocolmanager":send(p2)
end



function ZhuangBeiChongZhuDlg:RefreshEquipCellSel()
	for i = 1, #self.vItemCellEquip do 
		local equipCell = self.vItemCellEquip[i]
		if equipCell.nClientKey ~= self.nItemCellSelId then
			equipCell.btnBg:setSelected(false)
		else
			equipCell.btnBg:setSelected(true)
		end	
	end
end

function ZhuangBeiChongZhuDlg:RefreshEquipListState()
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

function ZhuangBeiChongZhuDlg:OnNextPage(args)
	local wsManager = Workshopmanager.getInstance()
	wsManager.nXilianPage = wsManager.nXilianPage + 1
	local vEquipKeyOrderIndex = {}
    wsManager:getchongzhulv(vEquipKeyOrderIndex,wsManager.nXilianPage)--控制点化等级
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

function ZhuangBeiChongZhuDlg:CreateEquipCell(equipCellData)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local nIndexEquip = #self.vItemCellEquip + 1
	local nEquipKey = equipCellData.nEquipKey
		local eBagType = equipCellData.eBagType
		local equipData = roleItemManager:FindItemByBagAndThisID(nEquipKey,eBagType)
		if equipData then
			local itemAttrCfg = equipData:GetBaseObject()

			local prefix = "ZhuangBeiChongZhuDlg_equip"..nIndexEquip
			local cellEquipItem = Workshopitemcell5.new(self.ScrollEquip, nIndexEquip - 1,prefix)

            local offsetX = 0
            for i = 1, nIndexEquip - 1 do --宽度
              offsetX = offsetX + self.vItemCellEquip[i].m_pMainFrame:getWidth():asAbsolute(0) 
            end
            offsetX = offsetX + 5 * (nIndexEquip - 1)  --加 5 的间距

            cellEquipItem.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, offsetX), CEGUI.UDim(0, 0)))
			cellEquipItem:RefreshVisibleWithType(4) --//1=dz 2xq 3hc 4xl
			self.vItemCellEquip[nIndexEquip] = cellEquipItem
			cellEquipItem.labItemName:setText(equipData:GetName())
			cellEquipItem.itemCell:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg.icon))
            SetItemCellBoundColorByQulityItemWithIdtm(cellEquipItem.itemCell,itemAttrCfg.id)

            if  itemAttrCfg.nquality > 0 then
                SetItemCellBoundColorByQulityItemWithIdtm(cellEquipItem.itemCell, itemAttrCfg.nquality )
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
			cellEquipItem.btnBg:subscribeEvent("MouseClick", ZhuangBeiChongZhuDlg.HandleClickedItem,self)
		end
		
end

function ZhuangBeiChongZhuDlg:RefreshEquipList(nBagId,nItemKey)
	local wsManager = Workshopmanager.getInstance()
	wsManager:RefreshEquipArray(nBagId,nItemKey)
	wsManager.nXilianPage = 1
	
	self:ClearCellAll()
	
	self.ScrollEquip:cleanupNonAutoChildren()
	self.vItemCellEquip = {}


	local vEquipKeyOrderIndex = {}
    wsManager:getchongzhulv(vEquipKeyOrderIndex,wsManager.nXilianPage)--控制点化等级

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

function ZhuangBeiChongZhuDlg:GetCellWithIndex(nIndex)
	if nIndex > #self.vItemCellEquip then
		return nil
	end
	return self.vItemCellEquip[nIndex]
end

function ZhuangBeiChongZhuDlg:GetCurItemBagType()
	local cellEquipItem = self:GetCellWithIndex(self.nItemCellSelId)
	if not cellEquipItem then
		return 0
	end
	return cellEquipItem.eBagType
end

function ZhuangBeiChongZhuDlg:HandleClickedItem(e)
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

function ZhuangBeiChongZhuDlg:ResetEquip()
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

function ZhuangBeiChongZhuDlg:getXlItemIdAndNeedNum(nEquipId)
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

function ZhuangBeiChongZhuDlg:RefreshEquip()
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
	self.cc_nzitem:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg.icon))
	SetItemCellBoundColorByQulityItemWithIdtm(self.cc_nzitem,itemAttrCfg.id)
	self.cc_nzname:setText(itemAttrCfg.name)
	
	self.ItemCellTarget:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg.icon))
    SetItemCellBoundColorByQulityItemWithIdtm(self.ItemCellTarget,itemAttrCfg.id)
    
    if itemAttrCfg.nquality > 0 then
        SetItemCellBoundColorByQulityItemtm(self.ItemCellTarget,itemAttrCfg.nquality)
    end
    refreshItemCellBind(self.ItemCellTarget,eBagType,nEquipKey)

	self.LabTargetName:setText(itemAttrCfg.name)
	self.LabTargetNamec:setText(itemAttrCfg.usemethod)
	local nEquipType = itemAttrCfg.itemtypeid
	local strTypeName = ""
	local itemTypeCfg = BeanConfigManager.getInstance():GetTableByName("item.citemtype"):getRecorder(nEquipType)
	if itemTypeCfg then
		strTypeName = itemTypeCfg.weapon
	end
	self.ItemCellNeedItem1:SetImage(gGetIconManager():GetItemIconByID(needItemCfg1.icon))
    SetItemCellBoundColorByQulityItemWithIdtm(self.ItemCellNeedItem1,needItemCfg1.id)
    self.cc_nzicon:SetImage(gGetIconManager():GetItemIconByID(needItemCfg1.icon))
	
	self.ItemCellNeedItem1:setID(needItemCfg1.id)
	local nOwnItemNum1 = roleItemManager:GetItemNumByBaseID(needItemCfg1.id)
	local nNeedItemNum1 = equipPropertyCfg.chongzhuitemnum
	local strNumNeed_own1 = nOwnItemNum1.."/"..nNeedItemNum1
	self.ItemCellNeedItem1:SetTextUnit(strNumNeed_own1)
	self.LabNameNeedItem1:setText(needItemCfg1.name)
	self.cc_nzshuliang:setText(strNumNeed_own1)
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

function ZhuangBeiChongZhuDlg:GetCurEquipData()
	local nServerKey = self:GetCurServerKey()
	local eBagType = self:GetCurItemBagType()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local equipData = roleItemManager:FindItemByBagAndThisID(nServerKey,eBagType)
	if not equipData then
		return nil
	end
	return equipData
end

function ZhuangBeiChongZhuDlg:RefreshRichBox(bUseLocal)
	LogInfo(" ZhuangBeiChongZhuDlg.RefreshRichBox(bUseLocal)")
	local equipData = self:GetCurEquipData()
	if not equipData then
		return 
	end
	local eBagType = self:GetCurItemBagType()
	local bHaveData,strParseText = WorkshopHelper.GetMapPropertyWithEquipData2(equipData,bUseLocal,eBagType, true)
	if bHaveData then
		self.cc_fbrichBox:Clear()
		self.cc_fbrichBox:show()
		self.cc_fbrichBox:AppendParseText(CEGUI.String(strParseText))
		self.cc_fbrichBox:Refresh()
	end
end

function ZhuangBeiChongZhuDlg:GetCurNeedMoney()
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

function ZhuangBeiChongZhuDlg:RefreshNeedMoneyLabel()
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

function ZhuangBeiChongZhuDlg:RefreshEquipDetailInfo(vProperty)
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

function ZhuangBeiChongZhuDlg:GetLabelWithIndex(nIndex)
	if nIndex > #self.vLabelTitleProperty then 
		return nil
	end
	return self.vLabelTitleProperty[nIndexLabel], self.vLabelProperty[nIndexLabel]
end



function ZhuangBeiChongZhuDlg:IsCanXiuli()
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
		LogInfo("ZhuangBeiChongZhuDlg:IsCanXiuli()=nNeedItemId1="..nNeedItemId1)
		return false, strResult
	end
		if nUserMoney < nNeedMoney1 then
			strResult = MHSD_UTILS.get_resstring(11006) 
			
			return false, strResult
		end
	return true, strResult
end


function ZhuangBeiChongZhuDlg:CheckBoxStateChanged(args)
    local state = self.checkbox:isSelected()
    if state then
	    --self:RefreshTwoBtnSel()
	    self:RefreshNeedMoneyLabel()
	end
end 

--//=========================================
function ZhuangBeiChongZhuDlg.getInstance()
    if not _instance then
        _instance = ZhuangBeiChongZhuDlg:new()
        _instance:OnCreate()
    end
    return _instance
end

function ZhuangBeiChongZhuDlg.getInstanceAndShow()
    if not _instance then
        _instance = ZhuangBeiChongZhuDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
	_instance:SendRequestAllEndure()
    return _instance
end

function ZhuangBeiChongZhuDlg.getInstanceNotCreate()
    return _instance
end

function ZhuangBeiChongZhuDlg.getInstanceOrNot()
	return _instance
end
	
function ZhuangBeiChongZhuDlg.GetLayoutFileName()
    return "zhuangbeichongzhu.layout"
end

function ZhuangBeiChongZhuDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ZhuangBeiChongZhuDlg)
	self:ClearData()
    return self
end

function ZhuangBeiChongZhuDlg.DestroyDialog()
	if not _instance then
		return
	end
		_instance.cc_nztipsButton.animation:stop()
	_instance.cc_qhfbbtn.animation:stop()
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

function ZhuangBeiChongZhuDlg:ClearData()
	self.vItemCellEquip = {}	
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
end

function ZhuangBeiChongZhuDlg:ClearDataInClose()
	self.vItemCellEquip = nil	
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
end

function ZhuangBeiChongZhuDlg:ClearCellAll()
	for k, v in pairs(self.vItemCellEquip) do
		LogInfo("ZhuangBeiChongZhuDlg:ClearCellAll()=k="..k)
		v:DestroyDialog()
	end
	self.vItemCellEquip = {}
end


function ZhuangBeiChongZhuDlg:OnClose()
	self:ClearCellAll()
	
	Dialog.OnClose(self)
	
	self:HandlBtnClickInfoClose()

	self:ClearDataInClose()
	gGetRoleItemManager().m_EventPackMoneyChange:RemoveScriptFunctor(self.m_hPackMoneyChange)
    gGetRoleItemManager():RemoveLuaItemNumChangeNotify(self.m_hItemNumChangeNotify)
	_instance = nil
end

function ZhuangBeiChongZhuDlg:btnCloseCallBack(args)
   _instance.cc_nzbtnClose.animation:stop()
   		if _instance.animationInstance then 
            _instance.animationInstance:stop()
            _instance.animationInstance = nil 
        end
    ZhuangBeiChongZhuDlg.DestroyDialog()
end

return ZhuangBeiChongZhuDlg


