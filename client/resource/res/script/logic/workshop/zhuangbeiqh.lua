require "utils.mhsdutils"
require "logic.dialog"
require "logic.workshop.workshopitemcell"
require "logic.workshop.workshophelper"

require "utils.commonutil"

ZhuangBeiRongLianDlg = {}
setmetatable(ZhuangBeiRongLianDlg, Dialog)
ZhuangBeiRongLianDlg.__index = ZhuangBeiRongLianDlg
local _instance;


function ZhuangBeiRongLianDlg.OnDzResult()
	LogInfo("ZhuangBeiRongLianDlg.OnDzResult()")
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


function ZhuangBeiRongLianDlg:RefreshItemTips(item)
	LogInfo("ZhuangBeiRongLianDlg.RefreshItemTips")
	local bUseLocal = true  
	self:RefreshRichBox(bUseLocal)
end



function ZhuangBeiRongLianDlg.OnFailTimesResult(protocol)
	
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

function ZhuangBeiRongLianDlg.OnRefreshAllResult(protocol)
	LogInfo(" ZhuangBeiRongLianDlg.OnRefreshAllResult(protocol)")
	if not _instance then
		return
	end
	_instance:RefreshEquip()
	_instance:RefreshEquipListState()
end



function ZhuangBeiRongLianDlg.OnXlResult()
	if not _instance then
		return
	end

	_instance:RefreshRichBox(false)
	--_instance:RefreshEquipList()
	_instance:RefreshEquipListState()

	_instance:RefreshEquip()

end


function ZhuangBeiRongLianDlg.OnRefreshOneItemInfoResult(protocol)
	LogInfo("ZhuangBeiRongLianDlg.OnRefreshOneItemInfoResult")
	if not _instance then
		return
	end
	_instance:RefreshEquip()
end



function ZhuangBeiRongLianDlg:OnCreate()
    Dialog.OnCreate(self)
	SetPositionOfWindowWithLabel1(self:GetWindow())
	self.m_hItemNumChangeNotify = gGetRoleItemManager():InsertLuaItemNumChangeNotify(ZhuangBeiRongLianDlg.OnItemNumChange)
	self.m_hPackMoneyChange = gGetRoleItemManager().m_EventPackMoneyChange:InsertScriptFunctor(ZhuangBeiRongLianDlg.OnMoneyChange)
	self:InitUI()
	self.bLoadUI = true
	self:RefreshEquipList()
	self:RefreshEquipCellSel()
	self:RefreshEquip()
	self:SendRequestAllEndure()
	--self:RefreshTwoBtnSel()
    self:ResetEquip()
end


function ZhuangBeiRongLianDlg.AddItemInBag(nItemKey)
	if not _instance then
		return
	end
	
end

function ZhuangBeiRongLianDlg.DelItemInBag(nItemKey)
	if not _instance then
		return
	end
end

function ZhuangBeiRongLianDlg.AddItemInEquipBag(nItemKey)
	if not _instance then
		return
	end
end

function ZhuangBeiRongLianDlg.DelItemInEquipBag(nItemKey)
	if not _instance then
		return
	end
end


function ZhuangBeiRongLianDlg.OnMoneyChange()
	if not _instance then
		return
	end
	_instance:RefreshNeedMoneyLabel()
end

function ZhuangBeiRongLianDlg:AddCell(eBagType,nItemKey)
	
end

function ZhuangBeiRongLianDlg:DeleteCell(eBagType,nItemKey)
	
end

function ZhuangBeiRongLianDlg:RefreshAllCellSortData()
end


function ZhuangBeiRongLianDlg:SortAllCell()
end

function ZhuangBeiRongLianDlg:RefreshAllCellPos()
end


function ZhuangBeiRongLianDlg.OnItemNumChange(eBagType, nItemKey, nItemId)
	if _instance == nil then
		return
	end
	_instance:RefreshEquip()
end


function ZhuangBeiRongLianDlg:RefreshUI(nBagId,nItemKey)
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

function ZhuangBeiRongLianDlg:InitUI()
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.ScrollEquip = CEGUI.toScrollablePane(winMgr:getWindow("zhuangbeiqianghua/left"))
	self.ScrollEquip:setMousePassThroughEnabled(true)
	self.ScrollEquip:subscribeEvent("NextPage", ZhuangBeiRongLianDlg.OnNextPage, self)
	self.ItemCellTarget = CEGUI.toItemCell(winMgr:getWindow("zhuangbeiqianghua/right/part2/item2"))
	self.ImageTargetCanMake = winMgr:getWindow("zhuangbeiqianghua/right/part2/item2/yizhuangbei") 
	self.LabTargetName = winMgr:getWindow("zhuangbeiqianghua/right/part2/name2") 
	self.richBoxEquip = CEGUI.toRichEditbox(winMgr:getWindow("zhuangbeiqianghua/right/shuxinglist/box"))
	self.richBoxEquip:subscribeEvent("MouseButtonUp", ZhuangBeiRongLianDlg.HandlBtnClickInfoClose) 
	self.richBoxEquip:setReadOnly(true)
	self.richBoxtest = CEGUI.toRichEditbox(winMgr:getWindow("zhuangbeiqianghua/right/shuxinglist/box1"))
	self.richBoxtest:Clear()
	self.richBoxtest:show()
	self.richBoxtest:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(11709)))
	self.richBoxtest:Refresh()


		local newbutton = winMgr:createWindow("TaharezLook/GroupButtonan1") --common_roll
        self.btnPanel = CEGUI.toPushButton(newbutton)
		 
		local nPosX = 860 
		local nPosY = 510
		self.btnPanel:setSize(CEGUI.UVector2(CEGUI.UDim(0, 100), CEGUI.UDim(0, 35)))
		self.btnPanel:setPosition(CEGUI.UVector2(CEGUI.UDim(0,nPosX),CEGUI.UDim(0, nPosY)))
		self.btnPanel:subscribeEvent("Clicked", ZhuangBeiRongLianDlg.HandlBtnClickLockUnlock, self)
		self.btnPanel:setText("锁定")
		self.btnPanel:setAlwaysOnTop(true)
		self.btnPanel:setFont("simhei-12")
		local mainFrame = self:GetMainFrame()
		mainFrame:addChildWindow( self.btnPanel)
		self.btnPanel:setVisible(false)
	
	self.smokeBg = winMgr:getWindow("zhuangbeiqianghua/Back/flagbg/smoke")
	local s = self.smokeBg:getPixelSize()
	local flagSmoke = gGetGameUIManager():AddUIEffect(self.smokeBg, "geffect/ui/mt_shengqishi/mt_shengqishi3", true, s.width*0.5, s.height)
	
	self.btnInfo = CEGUI.toPushButton(winMgr:getWindow("zhuangbeiqianghua/right/shuxinglist/tipsxiangqing"))
	self.btnInfo:subscribeEvent("MouseButtonDown", ZhuangBeiRongLianDlg.PreHandlBtnClickInfo, self) 
    self.btnInfo:subscribeEvent("MouseButtonUp", ZhuangBeiRongLianDlg.HandlBtnClickInfo, self) 
	
	self.xx = CEGUI.toPushButton(winMgr:getWindow("zhuangbeiqianghua"))
	self.xx:subscribeEvent("MouseButtonUp", ZhuangBeiRongLianDlg.HandlBtnClickInfoClose) 
	self.xx2 = CEGUI.toPushButton(winMgr:getWindow("zhuangbeiqianghua/right"))
	self.xx2:subscribeEvent("MouseButtonUp", ZhuangBeiRongLianDlg.HandlBtnClickInfoClose) 
	self.xx3 = CEGUI.toPushButton(winMgr:getWindow("zhuangbeiqianghua/right/part2/line1"))
	self.xx3:subscribeEvent("MouseButtonUp", ZhuangBeiRongLianDlg.HandlBtnClickInfoClose) 
	self.xx5 = CEGUI.toPushButton(winMgr:getWindow("zhuangbeiqianghua/left"))
	self.xx5:subscribeEvent("MouseButtonUp", ZhuangBeiRongLianDlg.HandlBtnClickInfoClose) 
	
	----1
	self.skillTypeTabBtn1 = CEGUI.toGroupButton(winMgr:getWindow("zhuangbeiqianghua/jiemian/skill"))
	self.skillpanel = winMgr:getWindow("zhuangbeiqianghua/right")
	self.skillTypeTabBtn1:subscribeEvent("SelectStateChanged", ZhuangBeiRongLianDlg.handleSwitchSkillTypeTab, self)
	----2
	self.skillTypeTabBtn2 = CEGUI.toGroupButton(winMgr:getWindow("zhuangbeiqianghua/jiemian/neidan"))
	self.neidanpanel = winMgr:getWindow("zhuangbeiqianghua/neidanscroll")
	self.skillTypeTabBtn2:subscribeEvent("SelectStateChanged", ZhuangBeiRongLianDlg.handleSwitchSkillTypeTab, self)
	
	self.tipsButton1 = CEGUI.toPushButton(winMgr:getWindow("zhuangbeiqianghua/neidanscroll/tps1"))       --tips button
    self.tipsButton1:subscribeEvent("Clicked", ZhuangBeiRongLianDlg.handleClickTipButton1, self)
	
	self.tipsButton2 = CEGUI.toPushButton(winMgr:getWindow("zhuangbeiqianghua/neidanscroll/tps2"))       --tips button
    self.tipsButton2:subscribeEvent("Clicked", ZhuangBeiRongLianDlg.handleClickTipButton2, self)
	
	self.tipsButton3 = CEGUI.toPushButton(winMgr:getWindow("zhuangbeiqianghua/neidanscroll/tps3"))       --tips button
    self.tipsButton3:subscribeEvent("Clicked", ZhuangBeiRongLianDlg.handleClickTipButton3, self)
	
	self.tipsButton4 = CEGUI.toPushButton(winMgr:getWindow("zhuangbeiqianghua/neidanscroll/tps4"))       --tips button
    self.tipsButton4:subscribeEvent("Clicked", ZhuangBeiRongLianDlg.handleClickTipButton4, self)
	
	-----------======合成按钮
	self.m_hc1cc1 = CEGUI.Window.toPushButton(winMgr:getWindow("zhuangbeiqianghua/neidanscroll/hc1"))
	self.m_hc1cc2 = CEGUI.Window.toPushButton(winMgr:getWindow("zhuangbeiqianghua/neidanscroll/hc2"))
	self.m_hc1cc3 = CEGUI.Window.toPushButton(winMgr:getWindow("zhuangbeiqianghua/neidanscroll/hc3"))
	self.m_hc1cc4 = CEGUI.Window.toPushButton(winMgr:getWindow("zhuangbeiqianghua/neidanscroll/hc4"))
	-----------======
	
	self.BtnMake = CEGUI.toGroupButton(winMgr:getWindow("zhuangbeiqianghua/right/putongbutton"))
    
	self.BtnMakeQh = CEGUI.toPushButton(winMgr:getWindow("zhuangbeiqianghua/right/teshubutton"))
    self.checkbox = CEGUI.toCheckbox(winMgr:getWindow("zhuangbeiqianghua/right/part2/line1/gou"))
    self.checkbox:subscribeEvent("MouseButtonUp", ZhuangBeiRongLianDlg.CheckBoxStateChanged, self)
    
	self.ItemCellNeedItem1 = CEGUI.toItemCell(winMgr:getWindow("zhuangbeiqianghua/right/cailiaolist/item1"))
	self.LabNameNeedItem1 = winMgr:getWindow("zhuangbeiqianghua/right/cailiaolist/name1")
	self.LabNameNeedItem33 = winMgr:getWindow("zhuangbeiqianghua/right/cailiaolist/name33")
	self.LabNameNeedItem44 = winMgr:getWindow("zhuangbeiqianghua/right/cailiaolist/name44")
	self.ItemCellNeedItem2 = CEGUI.toItemCell(winMgr:getWindow("zhuangbeiqianghua/right/cailiaolist/item2"))
	self.LabNameNeedItem2 = winMgr:getWindow("zhuangbeiqianghua/right/cailiaolist/name2")
	self.needMoneyLabel = winMgr:getWindow("zhuangbeiqianghua/right/bg1/one") --zhuangbeiqianghua/right/bg1/one
	self.ownMoneyLabel = winMgr:getWindow("zhuangbeiqianghua/right/bg11/2") --zhuangbeiqianghua/right/bg11/2
	self.ImageNeedMoneyIcon = winMgr:getWindow("zhuangbeiqianghua/right/yinbi")
	self.ImageOwnMoneyIcon = winMgr:getWindow("zhuangbeiqianghua/right/yinbi2")
	self.BtnXl = CEGUI.toPushButton(winMgr:getWindow("zhuangbeiqianghua/right/button"))
	self.BtnXl:subscribeEvent("Clicked", ZhuangBeiRongLianDlg.HandlBtnClickedXl, self)
	self.BtnXl1 = CEGUI.toPushButton(winMgr:getWindow("zhuangbeiqianghua/right/button1"))
	self.BtnXl1:subscribeEvent("Clicked", ZhuangBeiRongLianDlg.HandlBtnClickedXl1, self)
	--self.labelNormalDesc = winMgr:getWindow("zhuangbeiqianghua/right/part2/line1/text")
	self.labelSpecialDesc = winMgr:getWindow("zhuangbeiqianghua/right/part2/line1/textteshu1")
	
	self.ItemCellNeedItem1:subscribeEvent("TableClick", Workshopmanager.HandleClickItemCell, Workshopmanager)
    
    self.BtnExchange = CEGUI.toPushButton(winMgr:getWindow("zhuangbeiqianghua/right/jiahao")) --zhuangbeiqianghua/right/jiahao
	self.BtnExchange:subscribeEvent("Clicked", ZhuangBeiRongLianDlg.HandleExchangeBtnClicked, self)
	
	self.m_hc1cc1:subscribeEvent("Clicked", ZhuangBeiRongLianDlg.hc1cc1, self)
	self.m_hc1cc2:subscribeEvent("Clicked", ZhuangBeiRongLianDlg.hc1cc2, self)
	self.m_hc1cc3:subscribeEvent("Clicked", ZhuangBeiRongLianDlg.hc1cc3, self)
	self.m_hc1cc4:subscribeEvent("Clicked", ZhuangBeiRongLianDlg.hc1cc4, self)
end

function ZhuangBeiRongLianDlg:HandlBtnClickLockUnlock()
	local nEquipKey = self:GetCurServerKey()
	local eBagType = self:GetCurItemBagType()
	
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local equipData = roleItemManager:FindItemByBagAndThisID(nEquipKey,eBagType)
	local p = require "protodef.fire.pb.item.cqianghuaequipattr":new()
	if equipData then
		local equipObj = equipData:GetObject() --GetEndureUpperLimit
	    if equipObj.lockstate>0 then
			p.repairtype = 6 -- unlock
		else
			p.repairtype=5 --lock
		end
		p.keyinpack = nEquipKey
	local nBagType = eBagType
	p.packid = nBagType --fire.pb.item.BagTypes.BAG
	require "manager.luaprotocolmanager":send(p)
	end
end
function ZhuangBeiRongLianDlg:HandleExchangeBtnClicked(e)
	local dlg = require "logic.currency.stonegoldexchangesilverdlg".getInstanceAndShow()
	dlg:GetWindow():setAlwaysOnTop(true)

	return true
	
end

TaskHelper.m_hc1cc1 = 254018
TaskHelper.m_hc1cc2 = 254019
TaskHelper.m_hc1cc3 = 254020
TaskHelper.m_hc1cc4 = 254021

function ZhuangBeiRongLianDlg:handleClickTipButton1(args)
    local tipsStr = ""
    if IsPointCardServer() then
        -- 去掉第二条提示
    else
        tipsStr = require("utils.mhsdutils").get_resstring(7230)----第一条
    end
    local title = require("utils.mhsdutils").get_resstring(7229)----标题名称
    local tipdlg = require "logic.workshop.tips1".getInstanceAndShow(tipsStr, title)
    SetPositionScreenCenter(tipdlg:GetWindow())
end

function ZhuangBeiRongLianDlg:handleClickTipButton2(args)
    local tipsStr = ""
    if IsPointCardServer() then
        -- 去掉第二条提示
    else
        tipsStr = require("utils.mhsdutils").get_resstring(7231)----第一条
    end
    local title = require("utils.mhsdutils").get_resstring(7229)----标题名称
    local tipdlg = require "logic.workshop.tips1".getInstanceAndShow(tipsStr, title)
    SetPositionScreenCenter(tipdlg:GetWindow())
end

function ZhuangBeiRongLianDlg:handleClickTipButton3(args)
    local tipsStr = ""
    if IsPointCardServer() then
        -- 去掉第二条提示
    else
        tipsStr = require("utils.mhsdutils").get_resstring(7232)----第一条
    end
    local title = require("utils.mhsdutils").get_resstring(7229)----标题名称
    local tipdlg = require "logic.workshop.tips1".getInstanceAndShow(tipsStr, title)
    SetPositionScreenCenter(tipdlg:GetWindow())
end

function ZhuangBeiRongLianDlg:handleClickTipButton4(args)
    local tipsStr = ""
    if IsPointCardServer() then
        -- 去掉第二条提示
    else
        tipsStr = require("utils.mhsdutils").get_resstring(7233)----第一条
    end
    local title = require("utils.mhsdutils").get_resstring(7229)----标题名称
    local tipdlg = require "logic.workshop.tips1".getInstanceAndShow(tipsStr, title)
    SetPositionScreenCenter(tipdlg:GetWindow())
end

function ZhuangBeiRongLianDlg:handleSwitchSkillTypeTab()
	local selectedBtn = self.skillTypeTabBtn1:getSelectedButtonInGroup()
	
	if self.skillTypeTabBtn1 == selectedBtn then
		if not self.skillpanel:isVisible() then
			self.skillpanel:setVisible(true)
			self.neidanpanel:setVisible(false)
		end
	else
		if not self.neidanpanel:isVisible() then
			self.skillpanel:setVisible(false)
			self.neidanpanel:setVisible(true)
		end
	end
end

function ZhuangBeiRongLianDlg:DestroyDialog()
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

function ZhuangBeiRongLianDlg.hc1cc1()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1cc1
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end

function ZhuangBeiRongLianDlg.hc1cc2()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1cc2
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end

function ZhuangBeiRongLianDlg.hc1cc3()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1cc3
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end

function ZhuangBeiRongLianDlg.hc1cc4()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1cc4
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end

 function ZhuangBeiRongLianDlg:PreHandlBtnClickInfo(e)
 	--防止点击物品关闭表情界面--by yangbin
	local insetdlg = require("logic.chat.insertdlg").getInstanceNotCreate()
	if insetdlg then
		insetdlg.willCheckTipsWnd = true
	end
 end
 
 function ZhuangBeiRongLianDlg:HandlBtnClickInfoClose()
	local equipDlg = require("logic.tips.equipinfotips").getInstanceAndShow()
	equipDlg:DestroyDialog()
 end

 function ZhuangBeiRongLianDlg:HandlBtnClickInfo(e)
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

function ZhuangBeiRongLianDlg:GetCurServerKey()
	local cellEquipItem = self:GetCellWithIndex(self.nItemCellSelId)
	if not cellEquipItem then
		return 0
	end
	return cellEquipItem.nServerKey
end

--重铸
function ZhuangBeiRongLianDlg:HandlBtnClickedXl(e)
	if GetBattleManager() and GetBattleManager():IsInBattle() then
		local strShowTip = MHSD_UTILS.get_resstring(11693) 
		GetCTipsManager():AddMessageTip(strShowTip)
        return 
    end
	
	--//=======================================
	local nNeedMoney = tonumber(self.needMoneyLabel:getText())
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local nUserMoney = roleItemManager:GetGold()
	
	if nUserMoney < nNeedMoney then
		GetCTipsManager():AddMessageTipById(160118)
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
            if nFailTimes >= nFialTimesMax then
                local strDadaozuidazishuzi = MHSD_UTILS.get_resstring(11291) --
			    GetCTipsManager():AddMessageTip(strDadaozuidazishuzi)
                return
            end
	end

    -- local bCheckShow = self:checkShowItemOverNeed()
    -- if bCheckShow == true then
        -- return
    -- end

	local p = require "protodef.fire.pb.item.cqianghuaequipattr":new()
	p.repairtype = 1 --normal
	p.keyinpack = nEquipKey
	local nBagType = eBagType
	p.packid = nBagType --fire.pb.item.BagTypes.BAG
	require "manager.luaprotocolmanager":send(p)
end	
function ZhuangBeiRongLianDlg:HandlBtnClickedXl1(e)
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
	local nNeedMoney = tonumber(self.needMoneyLabel:getText())
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local nUserMoney = roleItemManager:GetGold()
	
	if nUserMoney < nNeedMoney then
		GetCTipsManager():AddMessageTipById(160118)
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
            if nFailTimes >= nFialTimesMax then
                local strDadaozuidazishuzi = MHSD_UTILS.get_resstring(11291) --
			    GetCTipsManager():AddMessageTip(strDadaozuidazishuzi)
                return
            end
	end

    -- local bCheckShow = self:checkShowItemOverNeed()
    -- if bCheckShow == true then
        -- return
    -- end

	local p = require "protodef.fire.pb.item.cqianghuaequipattr":new()
	p.repairtype = 2 --normal
	p.keyinpack = nEquipKey
	local nBagType = eBagType
	p.packid = nBagType --fire.pb.item.BagTypes.BAG
	require "manager.luaprotocolmanager":send(p)
end	
function ZhuangBeiRongLianDlg:checkShowItemOverNeed()
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

function ZhuangBeiRongLianDlg:clickConfirmBoxOk_xl()
    gGetMessageManager():CloseConfirmBox(eConfirmNormal,false)
    local nEquipKey = self:GetCurServerKey()
	local eBagType = self:GetCurItemBagType()

    local p = require "protodef.fire.pb.item.cqianghuaequipattr":new()
	p.repairtype = 1 --normal
	p.keyinpack = nEquipKey
	local nBagType = eBagType
	p.packid = nBagType --fire.pb.item.BagTypes.BAG
	require "manager.luaprotocolmanager":send(p)

end

function ZhuangBeiRongLianDlg:clickConfirmBoxCancel_xl()
gGetMessageManager():CloseConfirmBox(eConfirmNormal,false)

end

function ZhuangBeiRongLianDlg:SendRequestAllEndure()
	local p1 = require "protodef.fire.pb.item.creqallnaijiu":new()
	p1.packid = fire.pb.item.BagTypes.BAG
	require "manager.luaprotocolmanager":send(p1)
	local p2 = require "protodef.fire.pb.item.creqallnaijiu":new()
	p2.packid = fire.pb.item.BagTypes.EQUIP
	require "manager.luaprotocolmanager":send(p2)
end



function ZhuangBeiRongLianDlg:RefreshEquipCellSel()
	for i = 1, #self.vItemCellEquip do 
		local equipCell = self.vItemCellEquip[i]
		if equipCell.nClientKey ~= self.nItemCellSelId then
			equipCell.btnBg:setSelected(false)
		else
			equipCell.btnBg:setSelected(true)
		end	
	end
end

function ZhuangBeiRongLianDlg:RefreshEquipListState()
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

function ZhuangBeiRongLianDlg:OnNextPage(args)
	local wsManager = Workshopmanager.getInstance()
	wsManager.nXilianPage = wsManager.nXilianPage + 1
	local vEquipKeyOrderIndex = {}
    wsManager:getdianhualv(vEquipKeyOrderIndex,wsManager.nXilianPage)--控制点化等级
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

function ZhuangBeiRongLianDlg:CreateEquipCell(equipCellData)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local nIndexEquip = #self.vItemCellEquip + 1
	local nEquipKey = equipCellData.nEquipKey
		local eBagType = equipCellData.eBagType
		local equipData = roleItemManager:FindItemByBagAndThisID(nEquipKey,eBagType)
		if equipData then
			local itemAttrCfg = equipData:GetBaseObject()

			local prefix = "ZhuangBeiRongLianDlg_equip"..nIndexEquip
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
			cellEquipItem.btnBg:subscribeEvent("MouseClick", ZhuangBeiRongLianDlg.HandleClickedItem,self)
		end
		
end

function ZhuangBeiRongLianDlg:RefreshEquipList(nBagId,nItemKey)
	local wsManager = Workshopmanager.getInstance()
	wsManager:RefreshEquipArray(nBagId,nItemKey)
	wsManager.nXilianPage = 1
	
	self:ClearCellAll()
	
	self.ScrollEquip:cleanupNonAutoChildren()
	self.vItemCellEquip = {}


	local vEquipKeyOrderIndex = {}
    wsManager:getdianhualv(vEquipKeyOrderIndex,wsManager.nXilianPage)--控制点化等级

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

function ZhuangBeiRongLianDlg:GetCellWithIndex(nIndex)
	if nIndex > #self.vItemCellEquip then
		return nil
	end
	return self.vItemCellEquip[nIndex]
end

function ZhuangBeiRongLianDlg:GetCurItemBagType()
	local cellEquipItem = self:GetCellWithIndex(self.nItemCellSelId)
	if not cellEquipItem then
		return 0
	end
	return cellEquipItem.eBagType
end

function ZhuangBeiRongLianDlg:HandleClickedItem(e)
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

function ZhuangBeiRongLianDlg:ResetEquip()
	self.ItemCellTarget:SetImage(nil)
    SetItemCellBoundColorByQulityItemWithIdtm(self.ItemCellTarget,0)

    self.ImageTargetCanMake:setVisible(false)
	self.LabTargetName:setText("")
	self.ItemCellNeedItem1:SetTextUnit("")
	self.LabNameNeedItem1:setText("")
	self.LabNameNeedItem33:setText("")
	self.LabNameNeedItem44:setText("")
	self.ItemCellNeedItem2:SetTextUnit("")
	self.LabNameNeedItem2:setText("")
	self.needMoneyLabel:setText("")
end

function ZhuangBeiRongLianDlg:getXlItemIdAndNeedNum(nEquipId)
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

function ZhuangBeiRongLianDlg:RefreshEquip()
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
	local needItemCfg1 = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(equipPropertyCfg.ronglianitem)
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

	self.LabTargetName:setText(itemAttrCfg.name)
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
	local nNeedItemNum1 = equipPropertyCfg.rongliannum
	local strNumNeed_own1 = nOwnItemNum1.."/"..nNeedItemNum1
	self.ItemCellNeedItem1:SetTextUnit(strNumNeed_own1)
	self.LabNameNeedItem1:setText(needItemCfg1.name)
	self.LabNameNeedItem33:setText(needItemCfg1.name)
	self.LabNameNeedItem44:setText(needItemCfg1.namecc5)
	if nOwnItemNum1 >= nNeedItemNum1 then
		self.ItemCellNeedItem1:SetTextUnitColor(MHSD_UTILS.get_greencolor())
	else
		self.ItemCellNeedItem1:SetTextUnitColor(MHSD_UTILS.get_redcolor())
	end
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

function ZhuangBeiRongLianDlg:GetCurEquipData()
	local nServerKey = self:GetCurServerKey()
	local eBagType = self:GetCurItemBagType()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local equipData = roleItemManager:FindItemByBagAndThisID(nServerKey,eBagType)
	if not equipData then
		return nil
	end
	return equipData
end

function ZhuangBeiRongLianDlg:RefreshRichBox(bUseLocal)
	LogInfo(" ZhuangBeiRongLianDlg.RefreshRichBox(bUseLocal)")
	local equipData = self:GetCurEquipData()
	if not equipData then
		return 
	end
	local eBagType = self:GetCurItemBagType()
	local bHaveData,strParseText,bHaveFujia = WorkshopHelper.GetMapPropertyEquipData(equipData,bUseLocal,eBagType, true)
	if bHaveFujia then
		self.BtnXl1:setVisible(true)
	else
		self.BtnXl1:setVisible(false)
	end
	if bHaveData then
		self.richBoxEquip:Clear()
		self.richBoxEquip:show()
		self.richBoxEquip:AppendParseText(CEGUI.String(strParseText))
		self.richBoxEquip:Refresh()
	end
	local equipObj = equipData:GetObject()
	if equipObj.shuangjia then
		self.btnPanel:setVisible(true)
	if equipObj.lockstate>0 then
		self.btnPanel:setText("解锁")
	else
		self.btnPanel:setText("锁定")
	end
	else
		self.btnPanel:setVisible(false)
	end
end

function ZhuangBeiRongLianDlg:GetCurNeedMoney()
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

function ZhuangBeiRongLianDlg:RefreshNeedMoneyLabel()
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
	local nNeedMoney=equipPropertyCfg.ronglianmoney
   
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

function ZhuangBeiRongLianDlg:RefreshEquipDetailInfo(vProperty)
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

function ZhuangBeiRongLianDlg:GetLabelWithIndex(nIndex)
	if nIndex > #self.vLabelTitleProperty then 
		return nil
	end
	return self.vLabelTitleProperty[nIndexLabel], self.vLabelProperty[nIndexLabel]
end



function ZhuangBeiRongLianDlg:IsCanXiuli()
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
    nNeedItemId1=equipPropertyCfg.ronglianitem
	nNeedItemNum1=equipPropertyCfg.rongliannum
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
		LogInfo("ZhuangBeiRongLianDlg:IsCanXiuli()=nNeedItemId1="..nNeedItemId1)
		return false, strResult
	end
		if nUserMoney < nNeedMoney1 then
			strResult = MHSD_UTILS.get_resstring(11006) 
			
			return false, strResult
		end
	return true, strResult
end

-- function ZhuangBeiRongLianDlg:RefreshTwoBtnSel()
	
	
	-- local strTitleCur = ""
		-- strTitleCur = self.BtnMake:getText()
		-- self.labelNormalDesc:setVisible(true)
		-- self.labelSpecialDesc:setVisible(false)
	-- self.BtnXl:setText(strTitleCur)
-- end



function ZhuangBeiRongLianDlg:CheckBoxStateChanged(args)
    local state = self.checkbox:isSelected()
    if state then
	    --self:RefreshTwoBtnSel()
	    self:RefreshNeedMoneyLabel()
	end
end 

--//=========================================
function ZhuangBeiRongLianDlg.getInstance()
    if not _instance then
        _instance = ZhuangBeiRongLianDlg:new()
        _instance:OnCreate()
    end
    return _instance
end

function ZhuangBeiRongLianDlg.getInstanceAndShow()
    if not _instance then
        _instance = ZhuangBeiRongLianDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
	_instance:SendRequestAllEndure()
    return _instance
end

function ZhuangBeiRongLianDlg.getInstanceNotCreate()
    return _instance
end

function ZhuangBeiRongLianDlg.getInstanceOrNot()
	return _instance
end
	
function ZhuangBeiRongLianDlg.GetLayoutFileName()
    return "zhuangbeiqh.layout"
end

function ZhuangBeiRongLianDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ZhuangBeiRongLianDlg)
	self:ClearData()
    return self
end

function ZhuangBeiRongLianDlg.DestroyDialog()
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

function ZhuangBeiRongLianDlg:ClearData()
	self.vItemCellEquip = {}	
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
end

function ZhuangBeiRongLianDlg:ClearDataInClose()
	self.vItemCellEquip = nil	
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
end

function ZhuangBeiRongLianDlg:ClearCellAll()
	for k, v in pairs(self.vItemCellEquip) do
		LogInfo("ZhuangBeiRongLianDlg:ClearCellAll()=k="..k)
		v:DestroyDialog()
	end
	self.vItemCellEquip = {}
end


function ZhuangBeiRongLianDlg:OnClose()
	self:ClearCellAll()
	
	Dialog.OnClose(self)
	
	self:HandlBtnClickInfoClose()

	self:ClearDataInClose()
	gGetRoleItemManager().m_EventPackMoneyChange:RemoveScriptFunctor(self.m_hPackMoneyChange)
    gGetRoleItemManager():RemoveLuaItemNumChangeNotify(self.m_hItemNumChangeNotify)
	_instance = nil
end

return ZhuangBeiRongLianDlg


