------------------------------------------------------------------
-- NPC宠物商店
------------------------------------------------------------------
require "logic.dialog"

CommerceSellDlg = {}
setmetatable(CommerceSellDlg, Dialog)
CommerceSellDlg.__index = CommerceSellDlg

local _instance
function CommerceSellDlg.getInstance()
	if not _instance then
		_instance = CommerceSellDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function CommerceSellDlg.getInstanceAndShow()
	if not _instance then
		_instance = CommerceSellDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function CommerceSellDlg.getInstanceOrNot()
	return _instance
end

function CommerceSellDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function CommerceSellDlg:OnClose()
    CurrencyManager.unregisterTextWidget(_instance.ownMoneyText)
    gGetRoleItemManager():RemoveLuaItemNumChangeNotify(_instance.eventItemNumChange)
    Dialog.OnClose(_instance)
    _instance = nil
end

function CommerceSellDlg.ToggleOpenClose()
	if not _instance then
		_instance = CommerceSellDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function CommerceSellDlg.GetLayoutFileName()
	return "shanghuichushou_mtg.layout"
end

function CommerceSellDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, CommerceSellDlg)
	return self
end

function CommerceSellDlg:OnCreate()
	Dialog.OnCreate(self)
   -- SetPositionOfWindowWithLabel(self:GetWindow())
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.numText = winMgr:getWindow("shanghuichushou_mtg/shurukuang/buynum")
	self.priceText = winMgr:getWindow("shanghuichushou_mtg/textzong")
	self.ownMoneyText = winMgr:getWindow("shanghuichushou_mtg/textdan")
	---//--------
	self.buyBtn = CEGUI.toPushButton(winMgr:getWindow("shanghuichushou_mtg/btngoumai"))
	local buyBtnPressAnimationDef = CEGUI.AnimationManager:getSingleton():getAnimation("studyBtnPress")
    if buyBtnPressAnimationDef then
        local buyBtnPressAnimation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(buyBtnPressAnimationDef)
        buyBtnPressAnimation:setTargetWindow(self.buyBtn)
        buyBtnPressAnimation:setSpeed(0.7)  --  设置动画速度

        self.buyBtn:subscribeEvent("MouseButtonDown", 
            function()
                buyBtnPressAnimation:start()  -- 播放动画
            end, self)
    end
    self.buyBtn:subscribeEvent("Clicked", CommerceSellDlg.handleBuyClicked, self)
	---//------
	self.sellItemScroll = CEGUI.toScrollablePane(winMgr:getWindow("shanghuichushou_mtg/textbg3/list2"))
	self.sellItemTable = CEGUI.toItemTable(winMgr:getWindow("shanghuichushou_mtg/textbg3/list2/table"))
	self.minusBtn = CEGUI.toPushButton(winMgr:getWindow("shanghuichushou_mtg/btnjianhao"))
	local minusBtnPressAnimationDef = CEGUI.AnimationManager:getSingleton():getAnimation("studyBtnPress")
    if minusBtnPressAnimationDef then
        local minusBtnPressAnimation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(minusBtnPressAnimationDef)
        minusBtnPressAnimation:setTargetWindow(self.minusBtn)
        minusBtnPressAnimation:setSpeed(1)  --  

        self.minusBtn:subscribeEvent("MouseButtonDown", 
            function()
                minusBtnPressAnimation:start() -- 
            end, self)
    end
    self.minusBtn:subscribeEvent("Clicked", CommerceSellDlg.handleMinusClicked, self)
	----///---------
	self.addBtn = CEGUI.toPushButton(winMgr:getWindow("shanghuichushou_mtg/jiahao"))
	local addBtnPressAnimationDef = CEGUI.AnimationManager:getSingleton():getAnimation("studyBtnPress")
    if addBtnPressAnimationDef then
        local addBtnPressAnimation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(addBtnPressAnimationDef)
        addBtnPressAnimation:setTargetWindow(self.addBtn)
        addBtnPressAnimation:setSpeed(1)  -- 

        self.addBtn:subscribeEvent("MouseButtonDown", 
            function()
                addBtnPressAnimation:start() -- 
            end, self)
    end
    self.addBtn:subscribeEvent("Clicked", CommerceSellDlg.handleAddClicked, self)
    ----///---------
    self.sellItemScroll:EnableAllChildDrag(self.sellItemScroll)
    self.sellItemTable:subscribeEvent("TableClick", CommerceSellDlg.handleItemClicked, self)
    self.numText:subscribeEvent("MouseClick", CommerceSellDlg.handleNumTextClicked, self)
    self.eventItemNumChange = gGetRoleItemManager():InsertLuaItemNumChangeNotify(CommerceSellDlg.onEventItemNumChange)
    CurrencyManager.registerTextWidget(fire.pb.game.MoneyType.MoneyType_SilverCoin, self.ownMoneyText)

    self.selectedItemkey = 0
    self.selectedItemId = 0
    self.selectedGoodsId = 0
    self:refreshSellGoodsList()

    --请求商会商品新的价格
    local p = require("protodef.fire.pb.shop.crequstshopprice"):new()
	p.shopid = SHOP_TYPE.COMMERCE
	LuaProtocolManager:send(p)

	--检查限购限售数量
	ShopManager:checkNumLimit()
end

function CommerceSellDlg:refreshSellGoodsList()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local roleItems = roleItemManager:FilterBagItem(eItemFilterType_CanSale, true)
	
	local foundLastSelected = false
	local column = self.sellItemTable:GetColCount()
	
	if roleItems:size() > 0 then
		self.sellItemTable:setVisible(true)
		local row = math.ceil(roleItems:size() / column)
		if self.sellItemTable:GetRowCount() ~= row then
			self.sellItemTable:SetRowCount(row)
			local h = self.sellItemTable:GetCellHeight()
			local spaceY = self.sellItemTable:GetSpaceY()
			self.sellItemTable:setHeight(CEGUI.UDim(0, (h+spaceY)*row))
			self.sellItemScroll:EnableAllChildDrag(self.sellItemScroll)
		end
		
		for i=0, row*column-1 do
			local cell = self.sellItemTable:GetCell(i)
			cell:Clear()
			cell:SetHaveSelectedState(true)
			if i < roleItems:size() then
				cell:setVisible(true)
				local item = roleItems[i]
				local img = gGetIconManager():GetImageByID(item:GetIcon())
				cell:SetImage(img)
				refreshItemCellBind(cell, item:GetObject().loc.tableType, item:GetThisID())
				SetItemCellBoundColorByQulityItem(cell, item:GetBaseObject().nquality)
				
				local curNum = item:GetNum()
				cell:SetTextUnit(curNum > 1 and curNum or "")
				
				cell:setID(item:GetObjectID()) --baseid
				cell:setID2(item:GetThisID())  --itemkey
				
				if self.selectedItemkey == item:GetThisID() then
					foundLastSelected = true
					cell:SetSelected(true)
				end
			else
				cell:setVisible(false)
			end
		end
	else
		self.sellItemTable:setVisible(false)
	end
	
	if not foundLastSelected then
		self.selectedItemkey = 0
        self.selectedItemId = 0
        self.numText:setText(0)
        self.priceText:setText(0)
	end
	
	roleItems = nil
end

function CommerceSellDlg:handleItemClicked(args)
    local cell = CEGUI.toItemCell(CEGUI.toWindowEventArgs(args).window)
	if not cell then
		return
	end

    local itemkey = cell:getID2()
    local item = RoleItemManager.getInstance():FindItemByBagAndThisID(itemkey, fire.pb.item.BagTypes.BAG)
	if item then
        LuaShowItemTip(fire.pb.item.BagTypes.BAG, itemkey, 0, 0)
        local pos = cell:GetScreenPosOfCenter()
        local commontip = Commontipdlg.getInstanceAndShow()
        commontip:RefreshSize(false)
        commontip:RefreshPosCorrect(pos.x, pos.y)
	end

    if itemkey == self.selectedItemkey then
        return
    end
    self.selectedItemkey = itemkey

    local itemid = cell:getID()
    self.selectedItemId = itemid

    self.selectedGoodsId = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemid).bCanSaleToNpc
    self:refreshPriceAndNumLimit()
end

function CommerceSellDlg:refreshPriceAndNumLimit()
    self.numText:setText(1)

    --限售数量
	local num = RoleItemManager.getInstance():GetBagItem(self.selectedItemkey):GetNum()
    local goodsConf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(self.selectedGoodsId)
	if goodsConf and goodsConf.limitType ~= 0 then
		local sellNum = ShopManager.goodsSellNumLimit[self.selectedGoodsId]
		self.maxNum = sellNum and math.min(num, goodsConf.limitSaleNum-sellNum) or 0
	else
		self.maxNum = num
	end

    self.curPrice = ShopManager.goodsPrices[self.selectedGoodsId] or goodsConf.prices[0]
    self.curPrice = math.floor(self.curPrice * 5 / 6)
    self.priceText:setText(MoneyFormat(self.curPrice))
end

function CommerceSellDlg:handleBuyClicked(args)
	local num = tonumber(self.numText:getText())
	if num == 0 then
		return
	end

    if self.selectedGoodsId ~= 0 then
		local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(self.selectedGoodsId)
		local sellNum = ShopManager.goodsSellNumLimit[self.selectedGoodsId]
		if not sellNum then
			return
		end
		
		if conf.limitSaleNum > 0 and sellNum >= conf.limitSaleNum then
			local str = MHSD_UTILS.get_msgtipstring(150505)
			str = string.gsub(str, "%$parameter1%$", conf.limitSaleNum)
			GetCTipsManager():AddMessageTip(str)  --已达到出售上限，次物品每日出售上限xx个
			return
		end
		
		local p = require("protodef.fire.pb.shop.cchamberofcommerceshop"):new()
		p.shopid = SHOP_TYPE.COMMERCE
		p.itemkey = self.selectedItemkey
		p.goodsid = self.selectedGoodsId
		p.num = num
		p.buytype = fire.pb.shop.ShopBuyType.CHAMBER_OF_COMMERCE_SHOP_SALE
		LuaProtocolManager:send(p)
    end
end

function CommerceSellDlg:handleMinusClicked(args)
	if  self.selectedItemkey == 0 then
		return
	end
	local num = tonumber(self.numText:getText())
	if num > 1 then
		self.numText:setText(num-1)
		self.priceText:setText(MoneyFormat(self.curPrice * (num-1)))
	end
end

function CommerceSellDlg:handleAddClicked(args)
	if self.selectedItemkey == 0 then
		return
	end
	local num = tonumber(self.numText:getText())
	if num < self.maxNum then
		self.numText:setText(num+1)
		self.priceText:setText(MoneyFormat(self.curPrice * (num+1)))
	end
end

function CommerceSellDlg:handleNumTextClicked(args)
	if self.selectedItemkey == 0 then
		return
	end
	
	if NumKeyboardDlg.getInstanceNotCreate() then
		NumKeyboardDlg.getInstanceNotCreate():SetVisible(true) --保持键盘在最上面
		return
	end
	
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.numText)
		dlg:setMaxValue(self.maxNum)
		dlg:setInputChangeCallFunc(CommerceSellDlg.onNumInputChanged, self)
		
		local p = self.numText:GetScreenPos()
		SetPositionOffset(dlg:GetWindow(), p.x-110, p.y-10, 0, 1)
	end
end

function CommerceSellDlg:onNumInputChanged(num)
	if num == 0 then
		self.numText:setText(1)
		self.priceText:setText(MoneyFormat(self.curPrice))
	else
		self.numText:setText(num)
		self.priceText:setText(MoneyFormat(self.curPrice * num))
	end
end

function CommerceSellDlg:onSellNumLimitChanged()
    if self.selectedItemkey == 0 then
        return
    end
    --限售数量
    local item = RoleItemManager.getInstance():GetBagItem(self.selectedItemkey)
    if not item then
        return
    end
	local num = item:GetNum()
    local goodsConf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(self.selectedGoodsId)
	if goodsConf and goodsConf.limitType ~= 0 then
		local sellNum = ShopManager.goodsSellNumLimit[self.selectedGoodsId]
		self.maxNum = sellNum and math.min(num, goodsConf.limitSaleNum-sellNum) or 0
	else
		self.maxNum = num
	end

    local curNum = tonumber(self.numText:getText())
    if curNum > 1 and curNum > self.maxNum then
        self.numText:setText(self.maxNum)
        self.priceText:setText(MoneyFormat(self.curPrice * self.maxNum))
    end
end

function CommerceSellDlg.onEventItemNumChange(bagid, itemkey, itembaseid)
	if not _instance or bagid ~= fire.pb.item.BagTypes.BAG then
		return
	end

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local item = roleItemManager:GetBagItem(itemkey)
	if item and item:GetBaseObject().bCanSaleToNpc == 0 then
		return
	end

	for i=0, _instance.sellItemTable:GetCellCount()-1 do
		local cell = _instance.sellItemTable:GetCell(i)
		if not cell:isVisible() then
			break
		end
		
		if cell:getID() == itembaseid then
			local curNum = (item and item:GetNum() or 0)
			--print('item num change', itembaseid, curNum)
			if curNum == 0 then
				_instance:refreshSellGoodsList()
			elseif itemkey == _instance.selectedItemkey then
                _instance:refreshPriceAndNumLimit()
				cell:SetTextUnit(curNum > 1 and curNum or "")
			end
			return
		end
	end

	_instance:refreshSellGoodsList()
end

function CommerceSellDlg.onInternetReconnected()
	if _instance then
		_instance:refreshSellGoodsList() --刷新出售物品列表
	end
end

return CommerceSellDlg