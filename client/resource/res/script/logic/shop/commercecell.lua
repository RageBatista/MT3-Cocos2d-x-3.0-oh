------------------------------------------------------------------
-- 商会商品cell
------------------------------------------------------------------
CommerceCell = {}

setmetatable(CommerceCell, Dialog)
CommerceCell.__index = CommerceCell
local prefix = 0

function CommerceCell.CreateNewDlg(parent)
	local newDlg = CommerceCell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function CommerceCell.GetLayoutFileName()
	return "npcshopshanghuicell_mtg.layout"
end

function CommerceCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, CommerceCell)
	return self
end

function CommerceCell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

	self.window = CEGUI.toGroupButton(winMgr:getWindow(prefixstr .. "npcshopshanghuicell_mtg"))
	self.itemcell = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "npcshopshanghuicell_mtg/item"))
	self.nameText = winMgr:getWindow(prefixstr .. "npcshopshanghuicell_mtg/name")
	self.priceText = winMgr:getWindow(prefixstr .. "npcshopshanghuicell_mtg/textjiage")
	self.priceText:setProperty("TextColours", "FFFFFFFF")
	self.currencyIcon = winMgr:getWindow(prefixstr .. "npcshopshanghuicell_mtg/textjiage/yinbi")
	self.buyNumLimit = winMgr:getWindow(prefixstr .. "npcshopshanghuicell_mtg/number")
    self.priceFloatSign = winMgr:getWindow(prefixstr .. "npcshopshanghuicell_mtg/add")
    self.priceFloatText = winMgr:getWindow(prefixstr .. "npcshopshanghuicell_mtg/add/lv")
	
    self.cc_shoukong = winMgr:getWindow(prefixstr .. "npcshopshanghuicell_mtg/c1")--售空
	self.cc_xiangou = winMgr:getWindow(prefixstr .. "npcshopshanghuicell_mtg/c2")--限购
	self.cc_xuqiu = winMgr:getWindow(prefixstr .. "npcshopshanghuicell_mtg/c3")--需求
	
    self.cc_shoukong:setVisible(false)
    self.cc_xiangou:setVisible(false)
    self.cc_xuqiu:setVisible(false)
    self.priceFloatSign:setVisible(false)
    --self.priceFloatText:setVisible(false)
    self.priceFloatText:setProperty("TextColours", "FFFFFFFF")

	self.window:EnableClickAni(false)
    self.orginColor = self.buyNumLimit:getProperty("TextColours")
end

function CommerceCell:setGoodsDataById(goodsid)
	self.goodsid = goodsid
	
	local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(goodsid)
	if not conf then
		return
	end
	
    local buyNum = ShopManager.goodsBuyNumLimit[goodsid]
    local limitNum = conf.limitNum  
	

    local curPrice = ShopManager.goodsPrices[goodsid] or conf.prices[0]
	local prePrice = ShopManager.goodsPreviousPrices[goodsid] or conf.prices[0]
    -- Cc:商会浮动需要完善，感觉逻辑不太对。。。
    self.priceText:setText(MoneyFormat(curPrice))
        if curPrice == prePrice then
        self.priceFloatSign:setVisible(false)
        self.priceFloatText:setText("[colour='FF50321a']价格涨跌   -")
    else
    local floatPriceVal = curPrice / prePrice + 0.0005
        self.priceFloatSign:setVisible(true)
        if curPrice > prePrice then
        self.priceFloatText:setText("[colour='FF50321a']价格涨跌      [colour='ff1d953f']" .. math.max( math.floor(1000 * (floatPriceVal-1))/1000, 0.001)*100 .. "%")
        self.priceFloatSign:setProperty("Image", "set:ccui1 image:up11")
    else
        self.priceFloatText:setText("[colour='FF50321a']价格涨跌      [colour='ffff0000']" .. math.max( math.floor(1000 * (1-floatPriceVal))/1000, 0.001)*100 .. "%")
        self.priceFloatSign:setProperty("Image", "set:ccui1 image:dwon11")
    end
    end
	
	CurrencyManager.setCurrencyIcon(conf.currencys[0], self.currencyIcon)
	
	local item = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(conf.itemId)
	if not item then
		return
	end
	
    self.itemcell:setID(conf.itemId)
	self.itemcell:SetImage(gGetIconManager():GetImageByID(item.icon))
	self.itemcell:SetTextUnit(item.level > 150 and "Lv." .. item.level or "")
	SetItemCellBoundColorByQulityItem(self.itemcell, item.nquality)
	
	local buyNum = ShopManager.goodsBuyNumLimit[goodsid]
    if buyNum then
	
    local vipLevel = gGetDataManager():GetVipLevel()
    local record = BeanConfigManager.getInstance():GetTableByName("fushi.cvipinfo"):getRecorder(vipLevel)
    limitNum = limitNum + record.limitnumber2

    local isSoldOut = buyNum and buyNum >= limitNum
    local hasLimit = buyNum ~= nil and not isSoldOut
    local isRequirement = false

    self.nameText:setText(conf.name)

    self.cc_shoukong:setVisible(isSoldOut)
    self.cc_xiangou:setVisible(hasLimit) 
    self.cc_xuqiu:setVisible(isRequirement)

    if hasLimit then 
        local prefixStr = MHSD_UTILS.get_resstring(7405) .. tostring(limitNum - buyNum)
        local suffixStr = MHSD_UTILS.get_resstring(7406)
        local finalStr = prefixStr .. suffixStr
        self.buyNumLimit:setText(finalStr)
    else
        self.buyNumLimit:setText("") -- 清空
    end
end
end

function CommerceCell:showRequireCornerImage(willShow)
    self.cc_xuqiu:setVisible(willShow) 
end

return CommerceCell