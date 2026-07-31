------------------------------------------------------------------
-- 商会
------------------------------------------------------------------
require "logic.dialog"
require "utils.tableutil"
require "logic.shop.commercecell"
require "logic.tips.commontiphelper"

local BUY_PAGE = 0
local SELL_PAGE = 1


CommerceDlg = {}
setmetatable(CommerceDlg, Dialog)
CommerceDlg.__index = CommerceDlg


local _instance
function CommerceDlg.getInstance()
	if not _instance then
		_instance = CommerceDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function CommerceDlg.getInstanceAndShow()
	if not _instance then
		_instance = CommerceDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function CommerceDlg.getInstanceNotCreate()
	return _instance
end

function CommerceDlg.DestroyDialog()
	if _instance then
	if _instance.textScrollAnimation then
            _instance.textScrollAnimation:stop() 
        end
        if _instance.textScrollAnimation1 then
            _instance.textScrollAnimation1:stop()
        end
		CurrencyManager.unregisterTextWidget(_instance.ownMoneyText)
        if _instance.tableview then
		    _instance.tableview:destroyCells()
        end
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function CommerceDlg.ToggleOpenClose()
	if not _instance then
		_instance = CommerceDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

local COMMERCE_FONT_SIZE = 13 --主节点字体大小
local COMMERCE_FONT_COLOR = "FFFFFF00" --主节点颜色 
local COMMERCE_FONT_COLORc = "FFFFFFFF" --白色 

function CommerceDlg:SetGroupBtnTreeItemStyle(item, isParent)
    if not item then
        return
    end
    local fontSize = COMMERCE_FONT_SIZE
    if not isParent then
        fontSize = 12  -- 设置子节点字体大小为 12
    end
    local color = COMMERCE_FONT_COLOR  -- 默认使用主节点颜色

    -- 如果是子节点，则使用子节点颜色
    if not isParent then
        color = COMMERCE_FONT_COLORc 
    end

    local text = item:getText()
    text = CEGUI.String(string.format("[font='simhei-%d'][colour='%s']%s[/colour][/font]", fontSize, color, text))
    item:setText(text)
end

function CommerceDlg.GetLayoutFileName()
	return "npcshopshanghui_mtg.layout"
end

function CommerceDlg.InitIfNeed()
	if _instance and ShopManager:checkNumLimit() and ShopManager.isPricesRecved then
		_instance:refreshGoodsList()
	end
end

function CommerceDlg:SetVisible(b)
    if b== false then
        local Taskmanager = require("logic.task.taskmanager")
        Taskmanager.getInstance():setTaskOpenShopType(-1)
    end
    if self:IsVisible() ~= b then
        if b then
            CurrencyManager.registerTextWidget(fire.pb.game.MoneyType.MoneyType_SilverCoin, self.ownMoneyText)

            if ShopLabel.getInstanceNotCreate() and ShopLabel.getInstanceNotCreate().isFirstOpenCommerceDlg then
                ShopLabel.getInstanceNotCreate().isFirstOpenCommerceDlg = false
                ShopManager:queryGoodsPrices()
            end

            --商会界面提示7402
            self.m_shcctips:Clear()
            self.m_shcctips:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7402)))
            self.m_shcctips:Refresh() 
            
        else
            CurrencyManager.unregisterTextWidget(self.ownMoneyText)
        end
    end
    Dialog.SetVisible(self, b)
end

function CommerceDlg:hideRequireGoods()
	if self.requireGoodsId then
		if self.tableview then
			for _,v in pairs(self.tableview.visibleCells) do
				if v.goodsid == self.requireGoodsId then
					v:showRequireCornerImage(false)
					break
				end
			end
		end
		self.requireGoodsId = nil
	end
end

function CommerceDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, CommerceDlg)
	return self
end

function CommerceDlg:OnCreate()
	Dialog.OnCreate(self)
	SetPositionOfWindowWithLabel1(self:GetWindow())
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.buyView = winMgr:getWindow("npcshopshanghui_mtg/buyview")
	self.tree = CEGUI.toGroupBtnTree(winMgr:getWindow("npcshopshanghui_mtg/tree"))
	self.buylistBg = winMgr:getWindow("npcshopshanghui_mtg/textbg")
	self.minusBtn = CEGUI.toPushButton(winMgr:getWindow("npcshopshanghui_mtg/btnjianhao"))
	self.buyNumText = winMgr:getWindow("npcshopshanghui_mtg/shurukuang/buynum")
	self.addBtn = CEGUI.toPushButton(winMgr:getWindow("npcshopshanghui_mtg/jiahao"))
	self.priceText = winMgr:getWindow("npcshopshanghui_mtg/textzong")

	self.ownMoneyText = winMgr:getWindow("npcshopshanghui_mtg/textdan")
	self.ownMoneyText:setProperty("TextColours", "FFFFFFFF")
	self.buyBtn = CEGUI.toPushButton(winMgr:getWindow("npcshopshanghui_mtg/btngoumai"))
	self.m_shcctips = CEGUI.toRichEditbox(winMgr:getWindow("npcshopshanghui_mtg/shuoming"))
    
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation("shangchenggundong1")
    self.textScrollAnimation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
    self.textScrollAnimation:setTargetWindow(self.m_shcctips)
    self.textScrollAnimation:start()
    
	local animationDef1 = CEGUI.AnimationManager:getSingleton():getAnimation("shangchenggundong2")
    self.textScrollAnimation1 = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef1)
    self.textScrollAnimation1:setTargetWindow(self.m_shcctips) 
	
    self.m_shcctips:subscribeEvent(
        "AnimationEnded", 
        function(args)
            self.textScrollAnimation1:start() 
        end
    )

	self.buyBtn:subscribeEvent("Clicked", CommerceDlg.handleBuyClicked, self)
	self.tree:subscribeEvent("ItemSelectionChanged", CommerceDlg.handleItemSelectionChanged, self)
	self.minusBtn:subscribeEvent("Clicked", CommerceDlg.handleMinusClicked, self)
	self.addBtn:subscribeEvent("Clicked", CommerceDlg.handleAddClicked, self)
	self.buyNumText:subscribeEvent("MouseClick", CommerceDlg.handleBuyNumClicked, self)
	self:addButtonAnimation(self.addBtn, "studyBtnPress")
    self:addButtonAnimation(self.buyBtn, "studyBtnPress")
    self:addButtonAnimation(self.minusBtn, "studyBtnPress")
	
	self:GetCloseBtn():removeEvent("Clicked")
	self:GetCloseBtn():subscribeEvent("Clicked", ShopLabel.hide, nil)
		
	CurrencyManager.registerTextWidget(fire.pb.game.MoneyType.MoneyType_SilverCoin, self.ownMoneyText) --显示默认的商会货币类型
    CurrencyManager.setCompareTextWidget(self.ownMoneyText, self.priceText)
	
	self.curPrice = 0
	self.selectedCellIdx = -1
	self.selectedItemkey = 0
	self:loadTree()
	
	ShopManager:queryGoodsPrices()

    self.lastOffset = {}
    self.lastSelectedMenuId = 1
	

end

function CommerceDlg:addButtonAnimation(button, animationName)
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation(animationName)
    if animationDef then
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        animation:setTargetWindow(button)
        animation:setSpeed(0.7)  
        button:subscribeEvent("MouseButtonDown", function()
            animation:start()
        end, self)
    end
end

function CommerceDlg:selectGoodsByItemid(itemid, num)
	if not self.tableview then
		self.requireGoodsId = itemid
		return
	end

	num = (num and math.max(num, 1) or 1)

	--search secondmenu id
	for k,v in pairs(self.goodsids) do
		for i=0, v:size()-1 do
			
			local goods = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(v[i])
			if goods and goods.itemId == itemid then --found secondmenuid: k
				
				--search firstmenu id
				local ids = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.ccommercefirstmenu")):getAllID()
				for _,id in pairs(ids) do
					
					local firstmenu = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.ccommercefirstmenu")):getRecorder(id)
					for m=0, firstmenu.secondmenu:size()-1 do
						if firstmenu.secondmenu[m] == k then --found firstmenuid: id
							
							--select btn
							self.tree:SetLastOpenItem(self.lv1Btns[id])
							self.tree:SetLastSelectItem(self.lv2Btns[k])
							self.tree:initialise()
							
							self.selectedMenuId = k
							self.selectedCellIdx = i
							--[[self:refreshGoodsDetail()
							self:refreshGoodsList()--]]
							
							local bar = self.tree:getVertScrollbar()
							--[[local pageH = bar:getPageSize()
							local docH  = bar:getDocumentSize()
							print('--------', pageH, docH)--]]
							local offset = self.tree:getHeightToItem(self.lv2Btns[k])
							bar:Stop()
							bar:setScrollPosition(offset)
							
							--select cell
							local cell = self.tableview:focusCellAtIdx(i)
							if cell then
								cell.window:setSelected(true)
								cell:showRequireCornerImage(true)
								self.requireGoodsId = cell.goodsid
								self:refreshGoodsDetail()
							end
							
							--set num
							self.buyNumText:setText(num)
							self.priceText:setText(MoneyFormat(self.curPrice * num))
                            CurrencyManager.setCompareTextWidget(self.ownMoneyText, self.priceText)
							
							ids = nil
							return
						end
					end
				end
				ids = nil
				
				return
			end
		end
	end
end

function CommerceDlg:loadTree()
    --key: 二级菜单的id, val:二级菜单对应的商品id
    self.goodsids = {}
    self.selectedMenuId = 0
    self.lv1Btns = {}
    self.lv2Btns = {}
    
    local ids = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.ccommercefirstmenu")):getAllID()
    for i=1, #ids do
        local firstmenu = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.ccommercefirstmenu")):getRecorder(ids[i])
        local btn = self.tree:addItem(CEGUI.String(firstmenu.name), 0)
        self:SetGroupBtnTreeItemStyle(btn, true) -- 主节点
        SetGroupBtnTreeFirstIcon3(btn)
        self.lv1Btns[ids[i]] = btn
        
        for j=0, firstmenu.secondmenu:size()-1 do
            local secondmenu = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.ccommercesecondmenu")):getRecorder(firstmenu.secondmenu[j])
            self.goodsids[secondmenu.id] = secondmenu.goodsids
            
            local btn2 = btn:addItem(CEGUI.String(secondmenu.name), secondmenu.id)
            self:SetGroupBtnTreeItemStyle(btn2, false) -- 子节点
            SetGroupBtnTreeSecondIcon3(btn2)
            self.lv2Btns[secondmenu.id] = btn2
            
            if i==1 and j==0 then
                self.selectedMenuId = secondmenu.id
                self.tree:SetLastOpenItem(btn)
                self.tree:SetLastSelectItem(btn2)
            end
        end
    end
    ids = nil
end

function CommerceDlg:recvBuyNumChanged()
	for _,v in pairs(self.tableview.visibleCells) do
		local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(v.goodsid)
		local buyNum = ShopManager.goodsBuyNumLimit[v.goodsid]
		if buyNum then
			v.buyNumLimit:setText(conf.limitNum-buyNum)
		else
			v.buyNumLimit:setText("-")
		end

	end
end

function CommerceDlg:getLimitNumByVIP()
    local vipLevel = gGetDataManager():GetVipLevel()
	local record = BeanConfigManager.getInstance():GetTableByName("fushi.cvipinfo"):getRecorder(vipLevel)
	if record then
        return record.limitnumber2
    end
    return 0
end

function CommerceDlg:refreshGoodsDetail()
	if self.selectedCellIdx == -1 then
		self.buyNumText:setText(0)
		self.priceText:setText(0)

		
		return
	end
	
	local goodsId = self.goodsids[self.selectedMenuId][self.selectedCellIdx]
	local goodsConf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(goodsId)
	
	self.buyNumText:setText(1)
	
	self.curPrice = ShopManager.goodsPrices[goodsId] or goodsConf.prices[0]
	local prePrice = ShopManager.goodsPreviousPrices[goodsId] or goodsConf.prices[0]
	
	self.curGoodsPrice = self.curPrice
	self.priceText:setText(MoneyFormat(self.curPrice))
    CurrencyManager.setCompareTextWidget(self.ownMoneyText, self.priceText)
		
	--限购数量
	if goodsConf.limitType ~= 0 then
		local limitNum = goodsConf.limitNum + self:getLimitNumByVIP()
		local buyNum = ShopManager.goodsBuyNumLimit[goodsId]
		self.maxNum = buyNum and limitNum - buyNum or 0
	else
		self.maxNum = 99
	end
end

function CommerceDlg:isDataReady()
	--检查限购数量数据
	if not ShopManager:checkNumLimit() then
		return false
	end
	--检查商品价格数据
	if not ShopManager.isPricesRecved then
		return false
	end
	return true
end

function CommerceDlg:refreshGoodsList()
	if not self:isDataReady() then
		return
	end

	local isFirstCreate = false
	if not self.tableview then
		local s = self.buylistBg:getPixelSize()
		self.tableview = TableView.create(self.buylistBg)
		self.tableview:setViewSize(s.width-80, s.height-30)
		self.tableview:setPosition(40, 30)
        self.tableview:setColumCount(3)
		self.tableview:setCellInterval(5, 5)
		self.tableview:setDataSourceFunc(self, CommerceDlg.tableViewGetCellAtIndex)
		isFirstCreate = true
	end
	
	self.tableview:setCellCount(self.goodsids[self.selectedMenuId]:size())
	self.tableview:reloadData()
	if isFirstCreate and self.requireGoodsId then
		self:selectGoodsByItemid(self.requireGoodsId)
	end

    self:refreshGoodsDetail()
end

function CommerceDlg:tableViewGetCellAtIndex(tableView, idx, cell)
	if not cell then
		cell = CommerceCell.CreateNewDlg(tableView.container)
		cell.window:setGroupID(1)
		cell.window:subscribeEvent("MouseClick", CommerceDlg.handleGoodsCellClicked, self)
        cell.itemcell:subscribeEvent("MouseClick", CommerceDlg.handleGoodsItemCellClicked, self)
	end
	cell:setGoodsDataById(self.goodsids[self.selectedMenuId][idx])
	cell.window:setID(idx)
	cell.window:setSelected( self.selectedCellIdx == idx )
	
	--显示需求角标
	if self.requireGoodsId then
		cell:showRequireCornerImage(self.requireGoodsId == self.goodsids[self.selectedMenuId][idx])
	end
	return cell
end

function CommerceDlg:onNumInputChanged(num)
	if num == 0 then
		self.buyNumText:setText(1)
		self.priceText:setText(MoneyFormat(self.curPrice))
        CurrencyManager.setCompareTextWidget(self.ownMoneyText, self.priceText)
	else
		self.buyNumText:setText(num)
		self.priceText:setText(MoneyFormat(self.curPrice * num))
        CurrencyManager.setCompareTextWidget(self.ownMoneyText, self.priceText)
	end
end

function CommerceDlg:handleMinusClicked(args)
	if self.selectedCellIdx == -1 then
		return
	end
	local num = tonumber(self.buyNumText:getText())
	if num > 1 then
		self.buyNumText:setText(num-1)
		self.priceText:setText(MoneyFormat(self.curPrice * (num-1)))
        CurrencyManager.setCompareTextWidget(self.ownMoneyText, self.priceText)
	end
end

function CommerceDlg:handleAddClicked(args)
	if self.selectedCellIdx == -1 then
		return
	end
	local num = tonumber(self.buyNumText:getText())

	if num < self.maxNum then
		self.buyNumText:setText(num+1)
		self.priceText:setText(MoneyFormat(self.curPrice * (num+1)))
        CurrencyManager.setCompareTextWidget(self.ownMoneyText, self.priceText)
	end
end

function CommerceDlg:handleBuyNumClicked(args)
	if self.selectedCellIdx == -1 then
		return
	end
	
	if NumKeyboardDlg.getInstanceNotCreate() then
		NumKeyboardDlg.getInstanceNotCreate():SetVisible(true) --保持键盘在最上面
		return
	end
	
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.buyNumText)
		dlg:setMaxValue(self.maxNum)
		dlg:setInputChangeCallFunc(CommerceDlg.onNumInputChanged, self)
		
		local p = self.buyNumText:GetScreenPos()
		SetPositionOffset(dlg:GetWindow(), p.x-110, p.y-10, 0, 1)
	end
end

function CommerceDlg:handleGoodsCellClicked(args)
	local idx = CEGUI.toWindowEventArgs(args).window:getID()
	if idx == self.selectedCellIdx then
		self:handleAddClicked()
	else
		self.selectedCellIdx = idx
		self:refreshGoodsDetail()
	end
end

function CommerceDlg:handleGoodsItemCellClicked(args)
    GameItemTable.HandleShowToolTipsWithItemID(args)
    local cell = CEGUI.toGroupButton(CEGUI.toWindowEventArgs(args).window:getParent())
    if cell then
        cell:setSelected(true, false)
        local idx = cell:getID()
        if self.selectedCellIdx ~= idx then
            self.selectedCellIdx = idx
		    self:refreshGoodsDetail()
        end
    end
end

function CommerceDlg:resetData()
    if self.tableview then
        self.tableview:setContentOffset(0)
    end
    self.lastOffset = {}
end

function CommerceDlg:handleItemSelectionChanged(args)
	local item = self.tree:getSelectedItem()
	print('tree item selected', item:getID())
	if item:getID() == 0 then
		return
	end
	self.selectedMenuId = item:getID()
	self.selectedCellIdx = -1
	self:refreshGoodsDetail()

    local offset = 0
    if self.tableview and self.lastOffset then
        offset = self.tableview:getContentOffset()
        self.lastOffset[self.lastSelectedMenuId] = offset
        self.lastSelectedMenuId = item:getID()
    end

	self:refreshGoodsList()
    local offpos = 0
	if self.tableview and self.lastOffset then
        if self.lastOffset[self.selectedMenuId] then
            offpos = self.lastOffset[self.selectedMenuId]
        end

		self.tableview:setContentOffset(offpos)
	end
end

function CommerceDlg:handleBuyClicked(args)
	--test
	--[[self:selectGoodsByItemid(350304, 3)
	do return end--]]
	
	if self.selectedCellIdx == -1 then
		return
	end
	
	--限购数量
	local goodsid = self.goodsids[self.selectedMenuId][self.selectedCellIdx]
	local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(goodsid)
	local buyNum = ShopManager.goodsBuyNumLimit[goodsid]
	local limitNum = conf.limitNum + self:getLimitNumByVIP()

	if buyNum and buyNum >= limitNum then
		GetCTipsManager():AddMessageTipById(160013) --今日购买的数量已达上限
		return
	end
		
	--检查背包容量
	if not CheckBagCapacityForItem(conf.itemId, tonumber(self.buyNumText:getText())) then
		GetCTipsManager():AddMessageTipById(160062) --背包空间不足
		return
	end
		
	local p = require("protodef.fire.pb.shop.cchamberofcommerceshop"):new()
	p.shopid = SHOP_TYPE.COMMERCE
	p.goodsid = goodsid
	p.num = tonumber(self.buyNumText:getText())
	p.buytype = fire.pb.shop.ShopBuyType.CHAMBER_OF_COMMERCE_SHOP_BUY
		
		
	local price = MoneyNumber(self.priceText:getText())
	local needMoney = price - MoneyNumber(self.ownMoneyText:getText())
	if needMoney > 0 then
		--GET MONEY
		CurrencyManager.handleCurrencyNotEnough(fire.pb.game.MoneyType.MoneyType_SilverCoin, needMoney, price, p, self.ownMoneyText)
		return
	end
		
	LuaProtocolManager:send(p)
	
	self:refreshGoodsDetail()
end

function CommerceDlg.onVipLevelChanged()
    if _instance then
        if _instance.tableview then
            _instance.tableview:reloadData()
        end

        if _instance.curGroupType ~= BUY_PAGE then
            _instance:refreshGoodsDetail()
        end
    end
end

return CommerceDlg
