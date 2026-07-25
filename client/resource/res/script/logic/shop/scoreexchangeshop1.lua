------------------------------------------------------------------
-- 积分兑换商店
------------------------------------------------------------------
require "logic.dialog"

local nZhuanPanId = 999
--shopId在 NPCMT3买卖物品表.xlsx
local _scoreIds = {
	7,
	8,
	--9,
	--10
    nZhuanPanId,
    13
}
--scoreName在 程序内字符串.xlsx
local _scoreName = {
    [7] = 11277, --声望值
    [8] = 11278, --荣誉值
    --[9] = 11279, --节日积分
    --[10]= 11280  --良师值
    [nZhuanPanId] = 11352,
    [13] = 11693 --队长币
}

ScoreExchangeShop = {}
setmetatable(ScoreExchangeShop, Dialog)
ScoreExchangeShop.__index = ScoreExchangeShop

local _instance
function ScoreExchangeShop.getInstance()
	if not _instance then
		_instance = ScoreExchangeShop:new()
		_instance:OnCreate()
	end
	return _instance
end

function ScoreExchangeShop.getInstanceAndShow()
	if not _instance then
		_instance = ScoreExchangeShop:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ScoreExchangeShop.getInstanceNotCreate()
	return _instance
end

function ScoreExchangeShop:OnClose()
    if gGetRoleItemManager() and self.eventOtherMoneyChange then
        gGetRoleItemManager().m_EventTypeMoneyChange:RemoveScriptFunctor(self.eventOtherMoneyChange)
    end

    local Lotteryjifendlg = require("logic.lottery.lotteryjifendlg")
        
    if self.panelPanLayout then
        if self.panelPanLayout.state == Lotteryjifendlg.state_rotate then
            local p = require "protodef.fire.pb.game.cendschoolwheel":new()
	        require "manager.luaprotocolmanager":send(p)
        end
        self.panelPanLayout:DestroyDialog()
    end
    Dialog.OnClose(self)

end

function ScoreExchangeShop.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
            CurrencyManager.unregisterTextWidget(_instance.ownMoneyText)
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ScoreExchangeShop.ToggleOpenClose()
	if not _instance then
		_instance = ScoreExchangeShop:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ScoreExchangeShop.GetLayoutFileName()
	return "npcshopduihuan_mtg.layout"
end

function ScoreExchangeShop:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ScoreExchangeShop)
	return self
end

function ScoreExchangeShop:OnCreate()
	Dialog.OnCreate(self)
    SetPositionScreenCenter(self:GetWindow())
	local winMgr = CEGUI.WindowManager:getSingleton()
    self.winMgr = winMgr

	self.goodsListBg = winMgr:getWindow("npcshopduihuan_mtg/textbg/list")
	self.addBtn = CEGUI.toPushButton(winMgr:getWindow("npcshopduihuan_mtg/btnjiahao"))
	self.minusBtn = CEGUI.toPushButton(winMgr:getWindow("npcshopduihuan_mtg/btnjianhao"))
	self.numText = winMgr:getWindow("npcshopduihuan_mtg/shurukuang/numtext")
	self.priceText = winMgr:getWindow("npcshopduihuan_mtg/texthuafeizhi")
	self.priceIcon = winMgr:getWindow("npcshopduihuan_mtg/texthuafeizhi/image1")
	self.ownMoneyText = winMgr:getWindow("npcshopduihuan_mtg/textyongyouzhi")
	self.ownMoneyIcon = winMgr:getWindow("npcshopduihuan_mtg/texthuafeizhi/image2")
    --购买按钮
	self.exchangeBtn = CEGUI.toPushButton(winMgr:getWindow("npcshopduihuan_mtg/btnduihuan"))
	self.btnScroll = CEGUI.toScrollablePane(winMgr:getWindow("npcshopduihuan_mtg/liebiao"))

    self.panelBg = winMgr:getWindow("npcshopduihuan_mtg/1")
    self.panelPanBg = winMgr:getWindow("npcshopduihuan_mtg/textb1")

    self.panelCenter = winMgr:getWindow("npcshopduihuan_mtg/textb1/zhuanpan") 

    self.labelPanNeed =  winMgr:getWindow("npcshopduihuan_mtg/textb1/huafeidi/huafeishu") 
    self.labelPanOwn =  winMgr:getWindow("npcshopduihuan_mtg/textb1/huafeidi/huafeishu1") 

	self.exchangeBtn:subscribeEvent("Clicked", ScoreExchangeShop.handleExchangeClicked, self)
    self.numText:subscribeEvent("MouseClick", ScoreExchangeShop.handleNumTextClicked, self)
    self.minusBtn:subscribeEvent("Clicked", ScoreExchangeShop.handleMinusClicked, self)
	self.addBtn:subscribeEvent("Clicked", ScoreExchangeShop.handleAddClicked, self)

    --说明
    self.explain = CEGUI.toPushButton(winMgr:getWindow("npcshopduihuan_mtg/explain"))
    self.explainPan = CEGUI.toPushButton(winMgr:getWindow("npcshopduihuan_mtg/textb1/explain"))
    self.explainText = ""
    self.explainTitle = ""
    self.explain:subscribeEvent("Clicked", ScoreExchangeShop.handleExplainClicked, self)
    self.explainPan:subscribeEvent("Clicked", ScoreExchangeShop.handleExplainClicked, self)

    self.scoreShopId = -1
    self.selectedCellIdx = -1
    self:loadScoreShopList()

    self.panelPanLayout = require("logic.lottery.lotteryjifendlg").getInstanceAndShow(self.panelCenter)
    self.panelPanLayout:SetVisible(false)

    self:setPanVisible(false)

    self.helpSw = 0
    if gGetRoleItemManager() then
         self.eventOtherMoneyChange = gGetRoleItemManager().m_EventTypeMoneyChange:InsertScriptFunctor(ScoreExchangeShop.onOtherMoneyChange)
    end

	ShopManager:checkNumLimit() --检查限购数量，如果转天了会重新刷新
end
function ScoreExchangeShop:handleExplainClicked()
    local tips1 = require "logic.workshop.tips1"

    local level = gGetDataManager():GetMainCharacterLevel()
	local limitConfig = BeanConfigManager.getInstance():GetTableByName("role.cresmoneyconfig"):getRecorder(level)

    local sb = StringBuilder:new()
	sb:Set("parameter1", tostring(self.helpSw))
    sb:Set("parameter2", tostring(limitConfig.shengwangmax))
	self.explainText = sb:GetString(self.explainText)
	sb:delete()

    tips1.getInstanceAndShow(self.explainText, self.explainTitle)
end
function ScoreExchangeShop.onOtherMoneyChange(nMoneyType) --4 job score
    if not _instance then
        return
    end
    if fire.pb.game.MoneyType.MoneyType_ProfContribute==nMoneyType then
        _instance:refreshJobScore()
    end

end

function ScoreExchangeShop:refreshJobScore()
    if not gGetDataManager() then
        return
    end

    local data = gGetDataManager():GetMainCharacterData()
	local nJobScore = data:GetScoreValue(fire.pb.attr.RoleCurrency.PROF_CONTR)
    self.labelPanOwn:setText(tostring(nJobScore))

    local nNeedJobScore =  0 
    local commonTable = GameTable.common.GetCCommonTableInstance():getRecorder(237)
    if commonTable.id ~= -1 then
        nNeedJobScore = tonumber(commonTable.value)
    end
    
    self.labelPanNeed:setText(tostring(nNeedJobScore))

end

function ScoreExchangeShop:setPanVisible(bVisible)
    if bVisible then
        self.panelBg:setVisible(false)
        self.panelPanBg:setVisible(true)
        if self.panelPanLayout then
            self.panelPanLayout:SetVisible(true)
        end
        self:refreshJobScore()
    else
        self.panelBg:setVisible(true)
        self.panelPanBg:setVisible(false)
        
        if self.panelPanLayout then
            self.panelPanLayout:SetVisible(false)
        end
    end
end

function ScoreExchangeShop:selectGoodsByItemid(itemid)
    --find shop id
    local shopId = nil
    local itemIdx = nil
    for i=1, #_scoreIds do
        local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cnpcsale")):getRecorder(_scoreIds[i])
        for j=0, conf.goodsids:size()-1 do
            local goods = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(conf.goodsids[j])
            if goods.itemId == itemid then
                shopId = _scoreIds[i]
                itemIdx = j
                break
            end
        end
        if shopId then
            break
        end
    end

    local shopBtn = self.shopBtns[shopId]
    if not shopBtn then
        return
    end
    shopBtn:setSelected(true)
    SetVeticalScrollCellTop(self.btnScroll, shopBtn)
    local cell = self.goodsTable:focusCellAtIdx(itemIdx)
	if cell then
		cell.window:setSelected(true)
	end
end

function ScoreExchangeShop:loadScoreShopList()
    self.shopBtns = {}
    local btnw = self.btnScroll:getPixelSize().width-20
	local btnh = 90
    for i=1, #_scoreIds do
        local btn = CEGUI.toGroupButton(self.winMgr:createWindow("TaharezLook/CellGroupButton"))
        btn:setGroupID(0)
        btn:setProperty("Font", "simhei-16")
        btn:setID(_scoreIds[i])
        btn:setText(MHSD_UTILS.get_resstring(_scoreName[_scoreIds[i]]))
        btn:setSize(CEGUI.UVector2(CEGUI.UDim(0,btnw), CEGUI.UDim(0,btnh)))
        btn:EnableClickAni(false)
        self.btnScroll:addChildWindow(btn)
        btn:setPosition(CEGUI.UVector2(CEGUI.UDim(0,10), CEGUI.UDim(0,(i-1)*(btnh+5))))
        btn:subscribeEvent("SelectStateChanged", ScoreExchangeShop.handleScoreGroupBtnClicked, self)
        self.shopBtns[_scoreIds[i]] = btn
        if i == 1 then
            btn:setSelected(true)
        end
    end
end

function ScoreExchangeShop:refreshSelectedGoods()
    if self.selectedCellIdx == -1 then
        return
    end
    
    local cell = self.goodsTable:getCellAtIdx(self.selectedCellIdx)
    if cell then
        self.numText:setText(1)
        self.priceText:setText(cell.price:getText())
        CurrencyManager.setCompareTextWidget(self.ownMoneyText, self.priceText)
        self.curPrice = MoneyNumber(cell.price:getText())
	end

    local goodsId = self.curShopConf.goodsids[self.selectedCellIdx]
    local goodsConf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(goodsId)
    if goodsConf and goodsConf.limitNum ~= 0 then
        self.maxBuyNum = goodsConf.limitNum - (ShopManager.goodsBuyNumLimit[goodsId] or 0)
    else
        self.maxBuyNum = 99
    end
end

function ScoreExchangeShop:refreshGoodsList()
    local s = self.goodsListBg:getPixelSize()
    if not self.goodsTable then
		self.goodsTable = TableView.create(self.goodsListBg)
		self.goodsTable:setViewSize(s.width, s.height)
		self.goodsTable:setPosition(0, 0)
		self.goodsTable:setColumCount(3)
		self.goodsTable:setDataSourceFunc(self, ScoreExchangeShop.tableViewGetCellAtIndex)
	end
	self.goodsTable:setCellCountAndSize(self.curShopConf.goodsids:size(), s.width*0.5, 105)
	self.goodsTable:setContentOffset(0)
	self.goodsTable:reloadData()
end

function ScoreExchangeShop:tableViewGetCellAtIndex(tableView, idx, cell)
    if not cell then
        local prefix = "scoreshop_" .. tableView:genCellPrefix()
		cell = {}
		cell.window = CEGUI.toGroupButton(self.winMgr:loadWindowLayout("npcshopduihuancell.layout", prefix))
		cell.window:EnableClickAni(false)
		cell.itemcell = CEGUI.toItemCell(self.winMgr:getWindow(prefix .. "npcduihuancell/wupin"))
		cell.name = self.winMgr:getWindow(prefix .. "npcduihuancell/mingzi")
        cell.currencyIcon = self.winMgr:getWindow(prefix .. "npcduihuancell/huobizhi/tubiao")
		cell.price = self.winMgr:getWindow(prefix .. "npcduihuancell/huobizhi/price")
		cell.window:subscribeEvent("MouseClick", ScoreExchangeShop.handleGoodsSelected, self)
        cell.itemcell:subscribeEvent("MouseClick", ScoreExchangeShop.handleGoodsItemCellSelected, self)
    end
    
    local goodsId = self.curShopConf.goodsids[idx]
    --sMT3商品表
    local goodsConf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(goodsId)
    --goodsConf.itemId 对应类型道具的道具id
    cell.itemcell:setID(goodsConf.itemId)
    if goodsConf.limitNum > 0 then
        local leftnum = goodsConf.limitNum - (ShopManager.goodsBuyNumLimit[goodsId] or 0)
        cell.itemcell:SetTextUnit(leftnum > 1 and leftnum or "")
        if leftnum == 0 then
            cell.itemcell:SetCornerImageAtPos("shopui", "shop_shoukong", 0, 1)
        else
            cell.itemcell:SetCornerImageAtPos(nil, 0, 1)
        end
    else
        cell.itemcell:SetTextUnit("")
    end

    cell.price:setText(MoneyFormat(goodsConf.prices[0]))
    CurrencyManager.setCurrencyIcon(goodsConf.currencys[0], cell.currencyIcon)
    if goodsConf.type == 1 then --item
        local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(goodsConf.itemId)
		if itemAttr then
			cell.name:setText(itemAttr.name)
			local image = gGetIconManager():GetImageByID(itemAttr.icon)
			cell.itemcell:SetImage(image)
        end
    end

    if (self.selectedCellIdx == -1 and idx == 0) or self.selectedCellIdx == idx then
        self.selectedCellIdx = idx
        cell.window:setSelected(true, false)
    else
        cell.window:setSelected(false)
    end
    cell.window:setID(idx)

    return cell
end

function ScoreExchangeShop:onNumInputChanged(num)
    if num == 0 then
        self.numText:setText(1)
        self.priceText:setText(MoneyFormat(self.curPrice))
    else
        self.numText:setText(num)
        self.priceText:setText(MoneyFormat(self.curPrice * num))
    end
    CurrencyManager.setCompareTextWidget(self.ownMoneyText, self.priceText)
end

function ScoreExchangeShop:handleNumTextClicked(args)
    if NumKeyboardDlg.getInstanceNotCreate() then
		NumKeyboardDlg.getInstanceNotCreate():SetVisible(true) --保持键盘在最上面
		return
	end
	
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.numText)
		dlg:setMaxValue(self.maxBuyNum)
		dlg:setInputChangeCallFunc(ScoreExchangeShop.onNumInputChanged, self)
		
		local p = self.numText:GetScreenPos()
		SetPositionOffset(dlg:GetWindow(), p.x-110, p.y-10, 0, 1)
	end
end

function ScoreExchangeShop:handleMinusClicked(args)
    local num = tonumber(self.numText:getText())
	if num > 1 then
		self.numText:setText(num-1)
		self.priceText:setText(MoneyFormat(self.curPrice * (num-1)))
	end
	CurrencyManager.setCompareTextWidget(self.ownMoneyText, self.priceText)
end

function ScoreExchangeShop:handleAddClicked(args)
    local num = tonumber(self.numText:getText())
	if num < self.maxBuyNum then
		self.numText:setText(num+1)
		self.priceText:setText(MoneyFormat(self.curPrice * (num+1)))
	end
	CurrencyManager.setCompareTextWidget(self.ownMoneyText, self.priceText)
end

function ScoreExchangeShop:handleGoodsSelected(args)
    local idx = CEGUI.toWindowEventArgs(args).window:getID()
    if idx == self.selectedCellIdx then
        self:handleAddClicked()
    else
        self.selectedCellIdx = idx
        self:refreshSelectedGoods()
    end
end

function ScoreExchangeShop:handleGoodsItemCellSelected(args)
    local cell = CEGUI.toGroupButton(CEGUI.toWindowEventArgs(args).window:getParent())
    if cell then
        cell:setSelected(true, false)
        if cell:getID() ~= self.selectedCellIdx then
            self.selectedCellIdx = cell:getID()
            self:refreshSelectedGoods()
        end
    end

    GameItemTable.HandleShowToolTipsWithItemID(args)

    local goodsId = self.curShopConf.goodsids[self.selectedCellIdx]
    local goodsConf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(goodsId)
    if goodsConf and goodsConf.limitNum ~= 0 then
        local commontipdlg = Commontipdlg.getInstanceNotCreate()

        -- 描述
        commontipdlg.richBox:AppendBreak()
        commontipdlg.richBox:AppendParseText(CEGUI.String("<T t=' '/>"))
        local str = MHSD_UTILS.get_resstring(11281) --今日已经购买num个，每日限制购买limit个。
        str = string.gsub(str, "num", ShopManager.goodsBuyNumLimit[goodsId] or 0)
        str = string.gsub(str, "limit", goodsConf.limitNum)
        commontipdlg.richBox:AppendParseText(CEGUI.String(str))
	    commontipdlg.richBox:Refresh()
        commontipdlg:RefreshSize(false)

        local pos = CEGUI.toWindowEventArgs(args).window:GetScreenPosOfCenter()
	    commontipdlg:RefreshPosCorrect(pos.x, pos.y)
    end
end

--点击左边分类按钮
function ScoreExchangeShop:handleScoreGroupBtnClicked(args)
    self.scoreShopId = CEGUI.toWindowEventArgs(args).window:getID()
    if nZhuanPanId==self.scoreShopId then
        self:refreshExplainIsPan(true)
        self:setPanVisible(true)
        return
    else
        self:setPanVisible(false)
    end

    local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cnpcsale")):getRecorder(self.scoreShopId)
	if not conf then
		return
	end
    self.curShopConf = conf
    CurrencyManager.setCurrencyIcon(conf.currency, self.priceIcon)
    CurrencyManager.setCurrencyIcon(conf.currency, self.ownMoneyIcon)
    CurrencyManager.registerTextWidget(conf.currency, self.ownMoneyText)
    self.numText:setText(1)
    self.selectedCellIdx = -1
    self:refreshGoodsList()
    self:refreshSelectedGoods()
    self:refreshExplainIsPan(false)
end
function ScoreExchangeShop:refreshExplainIsPan(bln)
    if bln then
        local conf = BeanConfigManager.getInstance():GetTableByName("shop.ccurrencyiconpath"):getRecorder(fire.pb.game.MoneyType.MoneyType_ProfContribute)
        self.explainText = conf.explain
        self.explainTitle = conf.name
    else 
        local conf = BeanConfigManager.getInstance():GetTableByName("shop.ccurrencyiconpath"):getRecorder(self.curShopConf.currency)
        self.explainText = conf.explain
        self.explainTitle = conf.name
    end

end
function ScoreExchangeShop:handleExchangeClicked(args)
    if MoneyNumber(self.priceText:getText()) > MoneyNumber(self.ownMoneyText:getText()) then
        local str = MHSD_UTILS.get_msgtipstring(160159)
        str = string.gsub(str, "%$parameter1%$", MHSD_UTILS.get_resstring(_scoreName[self.scoreShopId]))
        GetCTipsManager():AddMessageTip(str) --您的xxx不足，无法兑换
        return
    end

    --限购数量
	if self.maxBuyNum == 0 then
		GetCTipsManager():AddMessageTipById(160400) --已达今日限购数量，请明日在购买
		return
	end

    local p = require("protodef.fire.pb.shop.cexchangeshop"):new()
    p.shopid = self.scoreShopId
    p.goodsid = self.curShopConf.goodsids[self.selectedCellIdx]
    p.num = tonumber(self.numText:getText())
    p.buytype = fire.pb.shop.ShopBuyType.EXCHANGE_BUY
    LuaProtocolManager:send(p)
end

function ScoreExchangeShop:recvBuyNumChanged()
    if self.goodsTable then
        self.goodsTable:reloadData()
    end
    self:refreshSelectedGoods()
end

function ScoreExchangeShop:setHelpSW(helpSw)
   self.helpSw = helpSw
end

return ScoreExchangeShop
