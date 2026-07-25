------------------------------------------------------------------
-- 快捷购买
------------------------------------------------------------------
require "logic.dialog"

QuickBuyDlg = {}
setmetatable(QuickBuyDlg, Dialog)
QuickBuyDlg.__index = QuickBuyDlg

local _instance
function QuickBuyDlg.getInstance()
	if not _instance then
		_instance = QuickBuyDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function QuickBuyDlg.getInstanceAndShow()
	if not _instance then
		_instance = QuickBuyDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function QuickBuyDlg.getInstanceNotCreate()
	return _instance
end

function QuickBuyDlg.DestroyDialog()
	if _instance then 
	_instance.minusBtn.animation:stop()
	_instance.addBtn.animation:stop()
	_instance.buyBtn.animation:stop()
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function QuickBuyDlg.ToggleOpenClose()
	if not _instance then
		_instance = QuickBuyDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function QuickBuyDlg.GetLayoutFileName()
	return "kuaijiegoumai.layout"
end

function QuickBuyDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, QuickBuyDlg)
	return self
end
function QuickBuyDlg:addButtonAnimation(button, animationName)
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation(animationName)
    if animationDef then
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        animation:setTargetWindow(button)
        animation:setSpeed(0.7)
        -- 保存动画实例
        button.animation = animation
        button:subscribeEvent("MouseButtonDown", function()
            animation:start()
        end, self)
    end
end
function QuickBuyDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.frameWindow = CEGUI.toFrameWindow(winMgr:getWindow("kuaijiegoumai/frame"))
	self.tipText = winMgr:getWindow("kuaijiegoumai/wenben1")
	self.itemCell = CEGUI.toItemCell(winMgr:getWindow("kuaijiegoumai/wupin"))
	self.itemNameText = winMgr:getWindow("kuaijiegoumai/mingzi")
	self.desText = winMgr:getWindow("kuaijiegoumai/leixing")
	self.minusBtn = CEGUI.toPushButton(winMgr:getWindow("kuaijiegoumai/jianhao"))
	self.numText = winMgr:getWindow("kuaijiegoumai/shurukuang/zhi")
	self.addBtn = CEGUI.toPushButton(winMgr:getWindow("kuaijiegoumai/jiahao"))
	self.currencyText = winMgr:getWindow("kuaijiegoumai/wenben4")
	self.currencyIcon1 = winMgr:getWindow("kuaijiegoumai/zhi3/tubiao")
	self.totalPriceText = winMgr:getWindow("kuaijiegoumai/zhi3/totalprice")
	self.currencyIcon2 = winMgr:getWindow("kuaijiegoumai/zhi4/tubiao")
	self.ownMoneyText = winMgr:getWindow("kuaijiegoumai/zhi3/totalprice1")
	self.buyBtn = CEGUI.toPushButton(winMgr:getWindow("kuaijiegoumai/goumai"))
	
	self:addButtonAnimation(self.minusBtn, "studyBtnPress")
	self:addButtonAnimation(self.addBtn, "studyBtnPress")
	self:addButtonAnimation(self.buyBtn, "studyBtnPress")


    self.frameWindow:getCloseButton():removeEvent("Clicked")
	self.frameWindow:getCloseButton():subscribeEvent("Clicked", QuickBuyDlg.DestroyDialog, nil)
    self.numText:subscribeEvent("MouseClick", QuickBuyDlg.handleNumTextClicked, self)
    self.minusBtn:subscribeEvent("Clicked", QuickBuyDlg.handleMinusBtnClicked, self)
    self.addBtn:subscribeEvent("Clicked", QuickBuyDlg.handleAddBtnClicked, self)
    self.buyBtn:subscribeEvent("Clicked", QuickBuyDlg.handleBuyClicked, self)
end

function QuickBuyDlg:setItemBaseId(baseid, num)
    num = num or 1
    local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(baseid)
    if not itemAttr then
        return
    end

    local quickBuyConf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cquickbuy")):getRecorder(baseid)
    if not quickBuyConf then
        return
    end
    self.goodsid = quickBuyConf.goodsid
    self.buyType = quickBuyConf.buytype

    local goodsConf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(self.goodsid)
    if not goodsConf then
        return
    end

	if goodsConf.floatingprice > 0 then --price is float
		ShopManager:queryGoodsPrices()
	end

    self.numText:setText(num)
    self.limitNum = goodsConf.limitNum
    self.price = ShopManager.goodsPrices[self.goodsid] or goodsConf.prices[0]
    self.totalPrice = self.price * num
    self.currencyType = goodsConf.currencys[0]

	local roleItem = RoleItem:new()
	roleItem:SetItemBaseData(baseid, 0)
    local _,str2  = Commontiphelper.getStringForBottomLabel(baseid, roleItem:GetObject())
	self.desText:setText(str2)

   
    local tipStr = string.gsub(self.tipText:getText(), "item", itemAttr.name)
    self.tipText:setText(tipStr)
    self.itemNameText:setText(itemAttr.name)
    local img = gGetIconManager():GetImageByID(itemAttr.icon)
	self.itemCell:SetImage(img)
	self.currencyText:setText(self.currencyText:getText() .. CurrencyManager.getCurrencyName(self.currencyType))
    CurrencyManager.setCurrencyIcon(self.currencyType, self.currencyIcon1)
	CurrencyManager.setCurrencyIcon(self.currencyType, self.currencyIcon2)
    self.totalPriceText:setText(MoneyFormat(self.totalPrice))
    self.ownMoney = CurrencyManager.getOwnCurrencyMount(self.currencyType)
    self.ownMoneyText:setText(MoneyFormat(self.ownMoney))
    self:checkMoneyEnough()
end

function QuickBuyDlg:refreshPrice()
	local newPrice = ShopManager.goodsPrices[self.goodsid]
	if not newPrice then
		return
	end
	self.price = newPrice
	self.totalPrice = newPrice * tonumber(self.numText:getText())
	self.totalPriceText:setText(MoneyFormat(self.totalPrice))
	self:checkMoneyEnough()
end

function QuickBuyDlg:checkMoneyEnough()
    if self.totalPrice > self.ownMoney then
        self.totalPriceText:setProperty("TextColours", "ffffffff")
        self.totalPriceText:setProperty("BorderEnable", "True")
    else
        local colour = self.ownMoneyText:getProperty("TextColours")
        self.totalPriceText:setProperty("TextColours", colour)
        self.totalPriceText:setProperty("BorderEnable", "True")
    end
end

function QuickBuyDlg:onNumInputChanged(num)
	if num == 0 then
        num = 1
    end
	self.numText:setText(num)
    self.totalPrice = self.price * num
	self.totalPriceText:setText(MoneyFormat(self.totalPrice))
	self:checkMoneyEnough()
end

function QuickBuyDlg:handleNumTextClicked(args)
    local dlg = NumKeyboardDlg.getInstanceAndShow(self:GetWindow())
	if dlg then
		dlg:setTriggerBtn(self.numText)
        local maxNum = 99
        if self.limitNum > 0 then
            maxNum = self.limitNum - (ShopManager.goodsBuyNumLimit[self.goodsid] or 0)
        end
		dlg:setMaxValue(maxNum)
		dlg:setInputChangeCallFunc(QuickBuyDlg.onNumInputChanged, self)
		
		local p = self.numText:GetScreenPos()
		SetPositionOffset(dlg:GetWindow(), p.x-15, p.y-10, 0.5, 1)
	end
end

function QuickBuyDlg:handleMinusBtnClicked(args)
    local num = tonumber(self.numText:getText())
	if num > 1 then
		self.numText:setText(num-1)
        self.totalPrice = self.price * (num-1)
		self.totalPriceText:setText(MoneyFormat(self.totalPrice))
        self:checkMoneyEnough()
	end
end

function QuickBuyDlg:handleAddBtnClicked(args)
    local num = tonumber(self.numText:getText())
    local maxNum = 99
    if self.limitNum > 0 then
        maxNum = self.limitNum - (ShopManager.goodsBuyNumLimit[self.goodsid] or 0)
    end
	if num < maxNum then
		self.numText:setText(num+1)
        self.totalPrice = self.price * (num+1)
		self.totalPriceText:setText(MoneyFormat(self.totalPrice))
        self:checkMoneyEnough()
	end
end

function QuickBuyDlg:handleBuyClicked(args)
    local num = tonumber(self.numText:getText())
    local p = nil
    if self.buyType == QUICKBUY_T.MALL then
        p = require("protodef.fire.pb.shop.cbuymallshop").Create()
        p.shopid = SHOP_TYPE.MALL
	    p.goodsid = self.goodsid
	    p.num = num
    elseif self.buyType == QUICKBUY_T.COMMERCE then
        p = require("protodef.fire.pb.shop.cchamberofcommerceshop"):new()
		p.shopid = SHOP_TYPE.COMMERCE
		p.goodsid = self.goodsid
		p.num = num
		p.buytype = fire.pb.shop.ShopBuyType.CHAMBER_OF_COMMERCE_SHOP_BUY
    end

    if self.totalPrice > self.ownMoney then
        CurrencyManager.handleCurrencyNotEnough(self.currencyType, self.totalPrice-self.ownMoney, self.totalPrice, p)
    elseif p then
        LuaProtocolManager:send(p)
    end

    QuickBuyDlg.DestroyDialog()
end

return QuickBuyDlg
