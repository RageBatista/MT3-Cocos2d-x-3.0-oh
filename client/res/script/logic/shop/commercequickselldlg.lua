------------------------------------------------------------------
-- 商会快捷出售
------------------------------------------------------------------
require "logic.dialog"
require "logic.tips.commontiphelper"
require "logic.shop.shopmanager"

CommerceQuickSellDlg = {}
setmetatable(CommerceQuickSellDlg, Dialog)
CommerceQuickSellDlg.__index = CommerceQuickSellDlg

local _instance
function CommerceQuickSellDlg.getInstance()
	if not _instance then
		_instance = CommerceQuickSellDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function CommerceQuickSellDlg.getInstanceAndShow()
	if not _instance then
		_instance = CommerceQuickSellDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function CommerceQuickSellDlg.getInstanceNotCreate()
	return _instance
end

function CommerceQuickSellDlg.DestroyDialog()
	if _instance then 
        CurrencyManager.unregisterTextWidget(_instance.ownMoneyText)
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function CommerceQuickSellDlg.ToggleOpenClose()
	if not _instance then
		_instance = CommerceQuickSellDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function CommerceQuickSellDlg.GetLayoutFileName()
	return "npcshanghuikuaijiechushou.layout"
end

function CommerceQuickSellDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, CommerceQuickSellDlg)
	return self
end

function CommerceQuickSellDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.itemCell = CEGUI.toItemCell(winMgr:getWindow("npcshanghuikuaijiechushou/zhujiemian/wupin"))
	self.nameText = winMgr:getWindow("npcshanghuikuaijiechushou/zhujiemian/mingzi")
	self.shortDesText = winMgr:getWindow("npcshanghuikuaijiechushou/zhujiemian/tiaojian")
	self.desBox = CEGUI.toRichEditbox(winMgr:getWindow("npcshanghuikuaijiechushou/zhujiemian/di/liebiao"))
	self.minusBtn = CEGUI.toPushButton(winMgr:getWindow("npcshanghuikuaijiechushou/zhujiemian/jianhao"))
	self.numText = winMgr:getWindow("npcshanghuikuaijiechushou/zhujiemian/shuru/shuliang")
	self.addBtn = CEGUI.toPushButton(winMgr:getWindow("npcshanghuikuaijiechushou/zhujiemian/jiahao"))
	self.priceText = winMgr:getWindow("npcshanghuikuaijiechushou/zhujiemian/zongjiazhi")
	self.ownMoneyText = winMgr:getWindow("npcshanghuikuaijiechushou/zhujiemian/myyinbizhi")
	self.sellBtn = CEGUI.toPushButton(winMgr:getWindow("npcshanghuikuaijiechushou/zhujiemian/chushou"))
	self.closeBtn = CEGUI.toPushButton(winMgr:getWindow("npcshanghuikuaijiechushou/zhujiemian/guanbi"))

	self.sellBtn:subscribeEvent("Clicked", CommerceQuickSellDlg.handleSellClicked, self)
    self.minusBtn:subscribeEvent("Clicked", CommerceQuickSellDlg.handleMinusClicked, self)
    self.addBtn:subscribeEvent("Clicked", CommerceQuickSellDlg.handleAddClicked, self)
    self.numText:subscribeEvent("MouseClick", CommerceQuickSellDlg.handleNumTextClicked, self)
    self.closeBtn:subscribeEvent("Clicked", CommerceQuickSellDlg.DestroyDialog, nil)

    local color = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FF00D6FF"))
    self.desBox:SetColourRect(color)
end

function CommerceQuickSellDlg:setItemKey(itemkey)
	self.key = itemkey
	
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local roleItem = roleItemManager:GetBagItem(itemkey)
	if not roleItem then
		CommerceQuickSellDlg.DestroyDialog()
		return
	end

	local img = gGetIconManager():GetImageByID(roleItem:GetIcon())
	self.itemCell:SetImage(img)
	self.nameText:setText(roleItem:GetName())

	SetItemCellBoundColorByQulityItem(self.itemCell, roleItem:GetBaseObject().nquality)
	
	--short description
	local baseid = roleItem:GetBaseObject().id
	local str1,str2  = Commontiphelper.getStringForBottomLabel(baseid, roleItem:GetObject())
    self.shortDesText:setText(str1 .. str2)
	
	--detail description
	Commontiphelper.RefreshRichBox(self.desBox, baseid, roleItem:GetObject())
	if self.desBox:GetLineCount() == 0 then
		local baseConf = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(baseid)
        if baseConf then
		    self.desBox:AppendText(CEGUI.String(baseConf.destribe), textColor)
		    self.desBox:Refresh()
        end
	end

    --price
    local goodsId = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(baseid).bCanSaleToNpc
    local goodsConf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(goodsId)
    if not goodsConf then
        return
    end
    self.goodsId = goodsId
    self.limitSaleNum = goodsConf.limitSaleNum
    self.curPrice = ShopManager.goodsPrices[goodsId] or goodsConf.prices[0]
    self.curPrice = math.floor(self.curPrice * 5 / 6)
    self.priceText:setText(MoneyFormat(self.curPrice))

    local sellNum = ShopManager.goodsSellNumLimit[self.goodsId]
	self.maxItemNum = sellNum and math.min(roleItem:GetNum(), self.limitSaleNum-sellNum) or 0

	if goodsConf.floatingprice > 0 then --price is float
		ShopManager:queryGoodsPrices()
	end

	CurrencyManager.registerTextWidget(fire.pb.game.MoneyType.MoneyType_SilverCoin, self.ownMoneyText)
end

function CommerceQuickSellDlg:refreshPrice()
	self.curPrice = ShopManager.goodsPrices[self.goodsId]
	if not self.curPrice then
		local goodsConf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(self.goodsId)
		self.curPrice = goodsConf.prices[0]
	end
	if self.curPrice then
		self.curPrice = math.floor(self.curPrice * 5 / 6)
		local num = tonumber(self.numText:getText())
		self.priceText:setText(MoneyFormat(self.curPrice * num))
	end
end

function CommerceQuickSellDlg:onNumInputChanged(num)
	if num == 0 then
		self.numText:setText(1)
		self.priceText:setText(MoneyFormat(self.curPrice))
	else
		self.numText:setText(num)
		self.priceText:setText(MoneyFormat(self.curPrice * num))
	end
end

function CommerceQuickSellDlg:handleNumTextClicked(args)
	local dlg = NumKeyboardDlg.getInstanceAndShow(self:GetWindow())
	if dlg then
		dlg:setTriggerBtn(self.numText)
		dlg:setMaxValue(self.maxItemNum)
		dlg:setInputChangeCallFunc(CommerceQuickSellDlg.onNumInputChanged, self)
		
		local p = self.numText:GetScreenPos()
		SetPositionOffset(dlg:GetWindow(), p.x-15, p.y-10, 0.5, 1)
	end
end

function CommerceQuickSellDlg:handleMinusClicked(args)
    local num = tonumber(self.numText:getText())
	if num > 1 then
		self.numText:setText(num-1)
		self.priceText:setText(MoneyFormat(self.curPrice * (num-1)))
	end
end

function CommerceQuickSellDlg:handleAddClicked(args)
    local num = tonumber(self.numText:getText())
	if num < self.maxItemNum then
		self.numText:setText(num+1)
		self.priceText:setText(MoneyFormat(self.curPrice * (num+1)))
	end
end

function CommerceQuickSellDlg:handleSellClicked(args)
    local sellNum = ShopManager.goodsSellNumLimit[self.goodsId]
	if sellNum and self.limitSaleNum > 0 and sellNum >= self.limitSaleNum then
		local str = MHSD_UTILS.get_msgtipstring(150505)
		str = string.gsub(str, "%$parameter1%$", self.limitSaleNum)
		GetCTipsManager():AddMessageTip(str)  --已达到出售上限，此物品每日出售上限xx个
		return
	end

    local p = require("protodef.fire.pb.shop.cchamberofcommerceshop"):new()
	p.shopid = SHOP_TYPE.COMMERCE
	p.itemkey = self.key
	p.goodsid = self.goodsId
	p.num = tonumber(self.numText:getText())
	p.buytype = fire.pb.shop.ShopBuyType.CHAMBER_OF_COMMERCE_SHOP_SALE
	LuaProtocolManager:send(p)

    CommerceQuickSellDlg.DestroyDialog()
end

return CommerceQuickSellDlg
