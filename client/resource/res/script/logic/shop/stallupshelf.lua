------------------------------------------------------------------
-- 摆摊上架
------------------------------------------------------------------
require "logic.dialog"
require "logic.tips.commontiphelper"

local TYPE_UP		= 1 --上架
local TYPE_RE_UP	= 2 --重新上架

StallUpShelf = {}
setmetatable(StallUpShelf, Dialog)
StallUpShelf.__index = StallUpShelf

local _instance
function StallUpShelf.getInstance()
	if not _instance then
		_instance = StallUpShelf:new()
		_instance:OnCreate()
	end
	return _instance
end

function StallUpShelf.getInstanceAndShow(parent)
	if not _instance then
		_instance = StallUpShelf:new()
		_instance:OnCreate(parent)
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function StallUpShelf.getInstanceNotCreate()
	return _instance
end

function StallUpShelf.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function StallUpShelf.ToggleOpenClose()
	if not _instance then
		_instance = StallUpShelf:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function StallUpShelf.GetLayoutFileName()
	return "baitanshangjia.layout"
end

function StallUpShelf:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, StallUpShelf)
	return self
end

function StallUpShelf:OnCreate(parent)
	Dialog.OnCreate(self, parent)
	self:GetWindow():setRiseOnClickEnabled(false)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.winMgr = winMgr

	self.mainView = winMgr:getWindow("baitanshangjia/shangjia")
	self.itemCell = CEGUI.toItemCell(winMgr:getWindow("baitanshangjia/shangjia/wupin"))
	self.nameText = winMgr:getWindow("baitanshangjia/shangjia/mingzi")
	self.levelCharText = winMgr:getWindow("baitanshangjia/shangjia/yaoqiu1")
	self.levelText = winMgr:getWindow("baitanshangjia/shangjia/yaoqiu")
	self.desBg = winMgr:getWindow("baitanshangjia/shangjia/di")
	self.desBox = CEGUI.toRichEditbox(winMgr:getWindow("baitanshangjia/shangjia/di/gundongwenben"))
	self.tipText = winMgr:getWindow("baitanshangjia/shangjia/yixiajia")
	self.priceCell = winMgr:getWindow("baitanshangjia/shangjia/jiage")
	self.priceTipText = winMgr:getWindow("baitanshangjia/shangjia/jiage/tuijianjiage")
	self.priceText = winMgr:getWindow("baitanshangjia/shangjia/jiage/huobizhi")
	self.priceMinus = CEGUI.toPushButton(winMgr:getWindow("baitanshangjia/shangjia/jiage/xia"))
	self.priceAdd = CEGUI.toPushButton(winMgr:getWindow("baitanshangjia/shangjia/jiage/shang"))
	self.posPriceCell = winMgr:getWindow("baitanshangjia/shangjia/tanweifei")
	self.tipBtn = CEGUI.toPushButton(winMgr:getWindow("baitanshangjia/shangjia/tanweifei/anniu"))
	self.posCostText = winMgr:getWindow("baitanshangjia/shangjia/tanweifei/huobizhi")
	self.cancelBtn = CEGUI.toPushButton(winMgr:getWindow("baitanshangjia/shangjia/quhui"))
	self.upShelfBtn = CEGUI.toPushButton(winMgr:getWindow("baitanshangjia/shangjia/upshelf"))
	self.closeBtn = CEGUI.toPushButton(winMgr:getWindow("baitanshangjia/shangjia/guanbi"))
	self.numCell = winMgr:getWindow("baitanshangjia/shangjia/shuliang")
	self.numMinus = CEGUI.toPushButton(winMgr:getWindow("baitanshangjia/shangjia/shuliang/xia"))
	self.numAdd = CEGUI.toPushButton(winMgr:getWindow("baitanshangjia/shangjia/shuliang/shang"))
	self.numText = winMgr:getWindow("baitanshangjia/shangjia/shuliang/shurukuang/numtext")
	self.totalPriceCell = winMgr:getWindow("baitanshangjia/shangjia/zongjia")
	self.totalPriceText = winMgr:getWindow("baitanshangjia/shangjia/zongjia/huobizhi")
	self.othersListView = winMgr:getWindow("baitanshangjia/qitachushou")
	self.othersList = winMgr:getWindow("baitanshangjia/qitachushou/di/liebiao")
	self.inputPriceBg = winMgr:getWindow("baitanshangjia/shangjia/shurukuang1")
	self.inputPrice = winMgr:getWindow("baitanshangjia/shangjia/shurukuang/inputprice")

	self.priceAdd:subscribeEvent("Clicked", StallUpShelf.handlePriceAddClicked, self)
	self.priceMinus:subscribeEvent("Clicked", StallUpShelf.handlePriceMinusClicked, self)
	self.numAdd:subscribeEvent("Clicked", StallUpShelf.handleNumAddClicked, self)
	self.numMinus:subscribeEvent("Clicked", StallUpShelf.handleNumMinusClicked, self)
	self.numText:subscribeEvent("MouseClick", StallUpShelf.handleNumTextClicked, self)
	self.inputPrice:subscribeEvent("MouseClick", StallUpShelf.handlePriceTextClicked, self)
	self.tipBtn:subscribeEvent("Clicked", StallUpShelf.handleTipBtnClicked, self)
	self.cancelBtn:subscribeEvent("Clicked", StallUpShelf.handleCancelClicked, self)
	self.upShelfBtn:subscribeEvent("Clicked", StallUpShelf.handleUpShelfClicked, self)
	self.closeBtn:subscribeEvent("Clicked", StallUpShelf.DestroyDialog, self)

	------------- init -----------------
	self.priceTipStr = self.priceTipText:getText()
	self.priceTipText:setText("[colour='FFFFFF2DF']" .. self.priceTipStr)
	self.tipText:setVisible(false)

    local color = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("fffff2df"))
    self.desBox:SetColourRect(color)
	
    self.price = 0
	self.recommendPrice = 0
	self.deltaRatio = 1 --设置的价格相对于推荐价格的比例
	self.isRarity = false
    self.containertype = 1
end

function StallUpShelf:refreshShowHide()
	local top = 0
	if self.maxItemNum == 1 then
		self.numCell:setVisible(false)
		self.totalPriceCell:setVisible(false)
		
		local y = self.totalPriceCell:getYPosition().offset + self.totalPriceCell:getPixelSize().height
		SetPositionYOffset(self.priceCell, y, 1)
		
		if self.tipText:isVisible() then
			SetPositionYOffset(self.tipText, self.priceCell:getYPosition().offset-10, 1)
			top = self.tipText:getYPosition().offset-10
		else
			top = self.priceCell:getYPosition().offset-10
		end
	else
		if not self.tipText:isVisible() then
			top = self.numCell:getYPosition().offset-10
		end
		if self.type == TYPE_RE_UP then
			self.numMinus:setVisible(false)
			self.numAdd:setVisible(false)
            self.numText:removeEvent("MouseClick")
		end
	end

	if top > 0 then
		local deltaH = top-self.desBg:getYPosition().offset-self.desBg:getPixelSize().height
		self.desBox:setHeight(CEGUI.UDim(0, self.desBox:getPixelSize().height+deltaH))
		self.desBg:setHeight(CEGUI.UDim(0, self.desBg:getPixelSize().height+deltaH))
	end
end

function StallUpShelf:setRecommendPrice(containertype, price, stallprice)
	if containertype ~= self.containertype then
		return
	end

    if price < 0 then
        return
    end

    self.price = price
	self.recommendPrice = price
	self.priceText:setText(MoneyFormat(price))
	if self.totalPriceCell:isVisible() then
		price = tonumber(self.numText:getText()) * price
		self.totalPriceText:setText(MoneyFormat(price))
	end
	
	local posCost = math.min(100000, math.max(1000, price))
	self.posCostText:setText(MoneyFormat(posCost))
end

--上架时调用这个 
function StallUpShelf:setItemKey(itemkey)
	self.type = TYPE_UP
	self.key = itemkey
	
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local roleItem = roleItemManager:GetBagItem(itemkey)
	local img = gGetIconManager():GetImageByID(roleItem:GetIcon())
	self.itemCell:SetImage(img)
	self.nameText:setText(roleItem:GetName())

    local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(roleItem:GetBaseObject().id)
    if itemAttr then
	    SetItemCellBoundColorByQulityItem(self.itemCell, itemAttr.nquality, itemAttr.itemtypeid)
    end

	--[[local itemtype = roleItem:GetFirstType()
	if itemtype == eItemType_FOOD or itemtype == eItemType_DRUG then
		self.levelCharText:setText(MHSD_UTILS.get_resstring(1456)) --品质
		local obj = roleItem:GetObject()
		local data = (itemtype == eItemType_FOOD and obj)
		if data then
			self.levelText:setText(data.qualiaty)
		end
	else
		self.levelText:setText(roleItem:GetItemLevel())
	end--]]
	
	--check whether need show number input box
	self.maxItemNum = roleItem:GetNum()
	self:refreshShowHide()
	
	--short description
	local baseid = roleItem:GetBaseObject().id
	local str1,str2  = Commontiphelper.getStringForBottomLabel(baseid, roleItem:GetObject())
	self.levelCharText:setText(str1)
	self.levelText:setText(str2)
	
	--detail description
	Commontiphelper.RefreshRichBox(self.desBox, baseid, roleItem:GetObject())
	if self.desBox:GetLineCount() == 0 then
		local baseConf = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(baseid)
        if baseConf then
		    self.desBox:AppendText(CEGUI.String(baseConf.destribe))
		    self.desBox:Refresh()
        end
	end

	--如果不是珍品则请求推荐价格
	if not ShopManager:isRarity(STALL_GOODS_T.ITEM, baseid) then
        self.containertype = 1

		local p = require("protodef.fire.pb.shop.cgetmarketupprice"):new()
		p.containertype = 1 --1.背包物品 2.宠物 3.摊位上宠物 4.摊位上物品
		p.key = itemkey
		LuaProtocolManager:send(p)
	else
		self.isRarity = true
	end

    if self.isRarity or IsPointCardServer() then
        self.priceMinus:setVisible(false)
		self.priceAdd:setVisible(false)
		self.priceTipText:setVisible(false)
		self.priceText:setVisible(false)
		self.inputPriceBg:setVisible(true)
		self.priceText = self.inputPrice
    end
	
	if self.isRarity and roleItem:GetFirstType() == eItemType_EQUIP then
		self.othersListView:setVisible(false)
		SetPositionScreenCenter(self.mainView)
	else
		--请求其他人正在出售价格
		local levelValue = Commontiphelper.getItemLevelValue(baseid, roleItem:GetObject())
		self:queryOthersGoodsList(baseid, levelValue)
	end
end

--过期重新上架时调用这个
--goods: MarketGoods
function StallUpShelf:setGoodsData(goods)
	self.type = TYPE_RE_UP
	self.goods = goods
    self.key = goods.key
    self.roleid = goods.saleroleid

    self.cancelBtn:setText(MHSD_UTILS.get_resstring(11197)) --取回
    self.upShelfBtn:setText(MHSD_UTILS.get_resstring(11196)) --重新上架

	--是否是珍品或点卡服
	self.isRarity = ShopManager:isRarity(STALL_GOODS_T.ITEM, goods.itemid)
    if self.isRarity or IsPointCardServer() then
		self.priceMinus:setVisible(false)
		self.priceAdd:setVisible(false)
		self.priceTipText:setVisible(false)
		self.priceText:setVisible(false)
		self.inputPriceBg:setVisible(true)
		self.priceText = self.inputPrice
	end
	
	local baseConf = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(goods.itemid)
    if not baseConf then
        return
    end
    SetItemCellBoundColorByQulityItem(self.itemCell, baseConf.nquality, baseConf.itemtypeid)
	local img = gGetIconManager():GetImageByID(baseConf.icon)
	self.itemCell:SetImage(img)
	self.nameText:setText(baseConf.name)
	self.numText:setText(goods.num)
	self.priceText:setText(MoneyFormat(goods.price))
	self.totalPriceText:setText(MoneyFormat(goods.price*goods.num))
	self.price = goods.price --珍品用

    --如果不是珍品则请求推荐价格
	if not ShopManager:isRarity(STALL_GOODS_T.ITEM, goods.itemid) then
        self.containertype = 4
        self.recommendPrice = 0 --非珍品用

		local p = require("protodef.fire.pb.shop.cgetmarketupprice"):new()
		p.containertype = 4 --1.背包物品 2.宠物 3.摊位上宠物 4.摊位上物品
		p.key = goods.key
		LuaProtocolManager:send(p)
    else
        self.recommendPrice = goods.price
	end
	
	self.maxItemNum = goods.num
    self.tipText:setVisible(goods.num == 1)
	self:refreshShowHide()
	self:refreshPriceShow()
	
    self.roleItem = RoleItem:new()
	self.roleItem:SetItemBaseData(goods.itemid, 0)
    self.roleItem:SetObjectID(goods.itemid)

    local str1,str2  = Commontiphelper.getStringForBottomLabel(goods.itemid, self.roleItem:GetObject())
	self.levelCharText:setText(str1)
	self.levelText:setText(str2)

	--[[if string.find(baseConf.destribe, "<T") then
        self.desBox:AppendParseText(CEGUI.String(baseConf.destribe))
    else
	    self.desBox:AppendText(CEGUI.String(baseConf.destribe))
    end
	self.desBox:Refresh()--]]

	Commontiphelper.RefreshRichBox(self.desBox, goods.itemid, self.roleItem:GetObject())
	if self.desBox:GetLineCount() == 0 then
		self.desBox:AppendText(CEGUI.String(baseConf.destribe), textColor)
		self.desBox:Refresh()
	end
	
	--[[self.desBox:AppendParseText(CEGUI.String("<T t='" .. baseConf.destribe .. "' c='FF7F4601'/>"))
	self.desBox:Refresh()--]]

    --request tips data
    local p = require("protodef.fire.pb.item.cotheritemtips"):new()
    p.roleid = goods.saleroleid
    p.packid = fire.pb.item.BagTypes.MARKET
    p.keyinpack = goods.key
	LuaProtocolManager:send(p)

	if self.isRarity and self.roleItem:GetFirstType() == eItemType_EQUIP then
		self.othersListView:setVisible(false)
		SetPositionScreenCenter(self.mainView)
	else
		--请求其他人正在出售价格
		local levelValue = Commontiphelper.getItemLevelValue(goods.itemid, self.roleItem:GetObject())
		self:queryOthersGoodsList(goods.itemid, levelValue)
	end
end

function StallUpShelf:recvTipsData(data)
    self.roleItem:GetObject():MakeTips(data)
    local str1,str2  = Commontiphelper.getStringForBottomLabel(self.roleItem:GetBaseObject().id, self.roleItem:GetObject())
	self.levelCharText:setText(str1)
	self.levelText:setText(str2)
    Commontiphelper.RefreshRichBox(self.desBox, self.roleItem:GetBaseObject().id, self.roleItem:GetObject())

    if self.mainView:isVisible() and not self.goodslist then
        --请求其他人正在出售价格
        local levelValue = Commontiphelper.getItemLevelValue(self.roleItem:GetBaseObject().id, self.roleItem:GetObject())
	    self:queryOthersGoodsList(self.roleItem:GetBaseObject().id, levelValue)
    end
end

--请求其他人在出售的同类商品
function StallUpShelf:queryOthersGoodsList(id, level)
	local market3conf = ShopManager.marketThreeTable[id]
	if not market3conf then
		return
	end

	self.firstno = market3conf.firstno
	self.twono = market3conf.twono
	self.threeno = market3conf.id
	self.itemtype = market3conf.itemtype

    level = level or 0
    self.limitmin = level
	self.limitmax = level

    --LOGIC_QUALITY_RANGE/LOGIC_LEVEL_RANGE
    if market3conf.logictype == 3 or market3conf.logictype == 4 then
        local valueRange = market3conf.valuerange
        for i=1, #valueRange-1 do
            local valueMin = valueRange[i]
            local valueMax = valueRange[i+1]
            if level > valueMin and level <= valueMax then
                self.limitmin = valueMin+1
                self.limitmax = valueMax
                break
            end
        end
    end

    if market3conf.logictype == 0 then
        self.threeno = {0}
    else
        self.threeno = {market3conf.id}
    end
	
	local p = require("protodef.fire.pb.shop.cmarketbrowse"):new()
	p.browsetype = 1 --buy
	p.firstno = self.firstno
	p.twono = self.twono
    p.threeno = self.threeno
	p.itemtype = self.itemtype
	p.limitmin = self.limitmin
	p.limitmax = self.limitmax
	p.currpage = 1
    p.pricesort = 1  --1升序  2降序

    --[[if dumpT then
        dumpT(p, "cmarketbrowse")
    end--]]
	
	LuaProtocolManager:send(p)
end

--收到摆摊商品 p:smarketbrowse
function StallUpShelf:recvStallGoods(p)
	print('StallUpShelf goodslist size', #p.goodslist)
	if p.browsetype ~= 1 then
		return
	end
	if not (self.firstno == p.firstno and
			self.twono == p.twono and
			self.threeno[1] == p.threeno[1])
		then
		return
	end

	self.goodslist = p.goodslist
	self:loadOthersList()
end

--显示其他人出售列表
function StallUpShelf:loadOthersList()
	local s = self.othersList:getPixelSize()
    if not self.tableView then
	    self.tableView = TableView.create(self.othersList)
	    self.tableView:setViewSize(s.width, s.height)
	    self.tableView:setPosition(0, 0)
	    self.tableView:setDataSourceFunc(self, StallUpShelf.tableViewGetCellAtIndex)
    end
	local n = (self.goodslist and #self.goodslist or 0)
	self.tableView:setCellCountAndSize(n, s.width*0.5, 110)
	self.tableView:reloadData()
end

function StallUpShelf:tableViewGetCellAtIndex(tableView, idx, cell)
	if not cell then
		local prefix = "othersStall" .. tableView:genCellPrefix()
		cell = {}
		cell.window = CEGUI.toGroupButton(self.winMgr:loadWindowLayout("baitancell2.layout", prefix))
		cell.window:EnableClickAni(false)
		cell.itemcell = CEGUI.toItemCell(self.winMgr:getWindow(prefix .. "baitancell2/daoju"))
		cell.name = self.winMgr:getWindow(prefix .. "baitancell2/mingzi")
		cell.price = self.winMgr:getWindow(prefix .. "baitancell2/di")
		cell.currencyIcon = self.winMgr:getWindow(prefix .. "baitancell2/di/huobi")
        self.winMgr:getWindow(prefix .. "baitancell2/time"):setVisible(false)
		cell.itemcell:subscribeEvent("TableClick", StallUpShelf.handleGoodsCellItemClicked, self)
		cell.window:subscribeEvent("SelectStateChanged", StallUpShelf.handleGoodsCellClicked, self)
	end
	
	cell.window:setSelected(self.selectedGoodsIdx == idx+1)
	
	local goods = self.goodslist[idx+1]
	if goods then
		cell.window:setID(idx+1)
		cell.itemcell:setID(idx+1)
		local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(goods.itemid)
        if itemAttr then
		    cell.name:setText(itemAttr.name)
		    local image = gGetIconManager():GetImageByID(itemAttr.icon)
		    cell.itemcell:SetImage(image)
		    cell.price:setText(MoneyFormat(goods.price))
		
		    if goods.itemtype == STALL_GOODS_T.ITEM then
                SetItemCellBoundColorByQulityItem(cell.itemcell, itemAttr.nquality, itemAttr.itemtypeid)
                cell.name:setText(itemAttr.name)
                local image = gGetIconManager():GetImageByID(itemAttr.icon)
                cell.itemcell:SetImage(image)
                if itemAttr.maxNum > 1 then --可堆叠的物品
                cell.itemcell:SetTextUnit(goods.num)
            elseif goods.level > 0 then
                local jiCi = require "utils.mhsdutils".get_resstring(3) -- 级数
                cell.itemcell:SetTextUnit(goods.level .. jiCi)
            end
		    end
        end
		
		--显示珍品角标
		if ShopManager:needShowRarityIcon(goods.itemtype, goods.itemid) then
			cell.itemcell:SetCornerImageAtPos("ccui1", "newzp", 0, 1)
		else
			cell.itemcell:SetCornerImageAtPos(nil, 0, 0)
		end
	end
	return cell
end

function StallUpShelf:refreshPriceShow()
	if not self.isRarity and not IsPointCardServer() then
		self.deltaRatio = math.floor(self.deltaRatio*10)*0.1
		local price = math.floor(self.recommendPrice * self.deltaRatio)
		self.priceText:setText(MoneyFormat(price))
		if self.totalPriceCell:isVisible() then
			price = tonumber(self.numText:getText()) * price
			self.totalPriceText:setText(MoneyFormat(price))
		end
		
		local posCost = math.floor(math.min(100000, math.max(1000, price)))
		self.posCostText:setText(MoneyFormat(posCost))
		
		if self.deltaRatio == 1 then
			self.priceTipText:setText("[colour='FFFFFF2DF']" .. self.priceTipStr)
		elseif self.deltaRatio > 1 then
			self.priceTipText:setText("[colour='FF00FF00']" .. self.priceTipStr .. "+" .. (self.deltaRatio-1)*100 .. "%")
		elseif self.deltaRatio < 1 then
			self.priceTipText:setText("[colour='FFFF0000']" .. self.priceTipStr .. "-" .. (1-self.deltaRatio)*100 .. "%")
		end
	else
		local price = self.price
		self.priceText:setText(MoneyFormat(self.price))
		if self.totalPriceCell:isVisible() then
			price = tonumber(self.numText:getText()) * self.price
			self.totalPriceText:setText(MoneyFormat(price))
		end
		local posCost = math.min(100000, math.max(1000, price))
		self.posCostText:setText(MoneyFormat(posCost))
	end
end

function StallUpShelf:handleGoodsCellItemClicked(args)
	local idx = CEGUI.toWindowEventArgs(args).window:getID()
	
	local cell = self.tableView:getCellAtIdx(idx-1)
	if cell then
		cell.window:setSelected(true)
	end
	
	local goods = self.goodslist[idx]
	if not goods then
		return
	end

    --request tips data
    local p = require("protodef.fire.pb.item.cotheritemtips"):new()
    p.roleid = goods.saleroleid
    p.packid = fire.pb.item.BagTypes.MARKET
    p.keyinpack = goods.key
	LuaProtocolManager:send(p)
	
	local pos = cell.itemcell:GetScreenPosOfCenter()
    local roleItem = RoleItem:new()
	roleItem:SetItemBaseData(goods.itemid, 0)
    roleItem:SetObjectID(goods.itemid)
    local tip = Commontiphelper.showItemTip(goods.itemid, roleItem:GetObject(), true, false, pos.x, pos.y)
    tip.isStallUpShelfTip = true
    tip.roleid = goods.saleroleid
    tip.roleItem = roleItem
    tip.itemkey = goods.key

	local winH = GetScreenSize().height
	local tipH = tip:GetWindow():getPixelSize().height
	local x = cell.window:GetScreenPos().x-tip:GetWindow():getPixelSize().width
	local y = (winH-tipH)*0.5
	tip:GetWindow():setPosition(NewVector2(x, y))
end

function StallUpShelf:handleGoodsCellClicked(args)
	self.selectedGoodsIdx = CEGUI.toWindowEventArgs(args).window:getID()
end

function StallUpShelf:handlePriceAddClicked(args)
	if self.recommendPrice == 0 then
		return
	end
	if self.deltaRatio == 1.5 then
		GetCTipsManager():AddMessageTipById(160382) --已经是最高价格了
		return
	end
	self.deltaRatio = math.min(1.5, self.deltaRatio+0.1)

	self:refreshPriceShow()
end

function StallUpShelf:handlePriceMinusClicked(args)
	if self.recommendPrice == 0 then
		return
	end
	if self.deltaRatio == 0.5 then
		GetCTipsManager():AddMessageTipById(160383) --已经是最低价格了
		return
	end
	self.deltaRatio = math.max(0.5, self.deltaRatio-0.1)
	
	self:refreshPriceShow()
end

function StallUpShelf:onPriceInputChanged(num)
	self.price = num
	self:refreshPriceShow()
end

function StallUpShelf:handlePriceTextClicked(args)
	if NumKeyboardDlg.getInstanceNotCreate() then
		NumKeyboardDlg.getInstanceNotCreate():SetVisible(true) --保持键盘在最上面
		return
	end
	
	local dlg = NumKeyboardDlg.getInstanceAndShow(self:GetWindow())
	if dlg then
		dlg:setTriggerBtn(self.priceText)
		dlg:setMaxValue(999999999)
		dlg:setInputChangeCallFunc(StallUpShelf.onPriceInputChanged, self)
		
		local p = self.priceText:GetScreenPos()
		SetPositionOffset(dlg:GetWindow(), p.x+self.priceText:getPixelSize().width*0.5, p.y-10, 0.5, 1)
	end
end


function StallUpShelf:onNumInputChanged(num)
	if num == 0 then
		num = 1
	end
	
	self.numText:setText(num)
	self:refreshPriceShow()
end

function StallUpShelf:handleNumAddClicked(args)
	local num = tonumber(self.numText:getText()) + 1
	if num <= self.maxItemNum then
		self.numText:setText(num)
		self:refreshPriceShow()
	end
end

function StallUpShelf:handleNumMinusClicked(args)
	local num = tonumber(self.numText:getText()) - 1
	if num > 0 then
		self.numText:setText(num)
		self:refreshPriceShow()
	end
end

function StallUpShelf:handleNumTextClicked(args)
	if NumKeyboardDlg.getInstanceNotCreate() then
		NumKeyboardDlg.getInstanceNotCreate():SetVisible(true) --保持键盘在最上面
		return
	end
	
	local dlg = NumKeyboardDlg.getInstanceAndShow(self:GetWindow())
	if dlg then
		dlg:setTriggerBtn(self.numText)
		dlg:setMaxValue(self.maxItemNum)
		dlg:setInputChangeCallFunc(StallUpShelf.onNumInputChanged, self)
		
		local p = self.numText:GetScreenPos()
		SetPositionOffset(dlg:GetWindow(), p.x+self.numText:getPixelSize().width*0.5, p.y-10, 0.5, 1)
	end
end

function StallUpShelf:handleTipBtnClicked(args)
	local tip = TextTip.CreateNewDlg()
	local str = MHSD_UTILS.get_msgtipstring(150507)
	tip:setTipText(str)
end

function StallUpShelf:handleCancelClicked(args)
    if self.type == TYPE_RE_UP then
		if not CheckBagCapacityForItem(0, 1) then
			GetCTipsManager():AddMessageTipById(160062) --背包空间不足
		else
			--取回
			local p = require("protodef.fire.pb.shop.cmarketdown"):new()
			p.downtype = STALL_GOODS_T.ITEM
			p.key = self.key
			LuaProtocolManager:send(p)
		end
    end
	StallUpShelf.DestroyDialog()
end

function StallUpShelf:doUpShelf(optType)
	local p = nil
	if optType == TYPE_UP then
		p = require("protodef.fire.pb.shop.cmarketup"):new()
	    p.containertype = STALL_GOODS_T.ITEM
	    p.key = self.key
	    p.num = (self.numCell:isVisible() and tonumber(self.numText:getText()) or 1)
	    p.price = MoneyNumber(self.priceText:getText())
	elseif optType == TYPE_RE_UP then
		local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.goods.itemid)
        p = require("protodef.fire.pb.shop.cremarketup"):new()
        p.itemtype = (itemAttr and itemAttr.itemtypeid % 16 == eItemType_EQUIP) and STALL_GOODS_T.EQUIP or STALL_GOODS_T.ITEM
        p.id = self.goods.id
		p.money = MoneyNumber(self.priceText:getText())
	end

	print('---cmarketup---')
    for k,v in pairs(p) do
        print(k,v)
    end
	
	--摆摊费是否够
	local upshelfCost = MoneyNumber(self.posCostText:getText())
	local needMoney = CurrencyManager.canAfford(fire.pb.game.MoneyType.MoneyType_SilverCoin, upshelfCost)
	if needMoney > 0 then
		StallUpShelf.DestroyDialog()
		CurrencyManager.handleCurrencyNotEnough(fire.pb.game.MoneyType.MoneyType_SilverCoin, needMoney, upshelfCost, p)
		return
	end

	LuaProtocolManager:send(p)
	StallUpShelf.DestroyDialog()
end

function StallUpShelf:handleConfirUpShelf()
	self:doUpShelf(TYPE_RE_UP)
end

function StallUpShelf:handleUpShelfClicked(args)
	local dlg = StallDlg.getInstance()
	if dlg.myStallGoods and #dlg.myStallGoods == 24 and self.type == TYPE_UP then
		GetCTipsManager():AddMessageTipById(160048) --同时上架的物品不能超过8件哦
		return
	end
	
	if MoneyNumber(self.priceText:getText()) == 0 then
		GetCTipsManager():AddMessageTipById(150510) --请点击售价框输入价格
		return
	end
	
	
	
		local vipLevel = gGetDataManager():GetVipLevel()
	    if vipLevel < 1 then
		    --GetCTipsManager():AddMessageTip(MHSD_UTILS.get_resstring(7401))
			GetCTipsManager():AddMessageTipById(193111) --不是vip无法摆摊vip2
            return
        end

    -- 限制上架手机安全
    --local shoujianquanmgr = require "logic.shoujianquan.shoujianquanmgr"
    --if shoujianquanmgr.needBindTelAgain() then
    --    require("logic.shoujianquan.shoujiyanzheng").getInstanceAndShow()
     --   return
    --elseif shoujianquanmgr.notBind7Days() then
     --   require("logic.shoujianquan.shoujiguanlianqueren").getInstanceAndShow()
     --   return
    --end

    local p = nil
    if self.type == TYPE_UP then
	    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
        local roleItem = roleItemManager:GetBagItem(self.key)
		if not roleItem then
			StallUpShelf.DestroyDialog()
			return
		end
        if roleItem:GetFirstType() == eItemType_EQUIP then
            local equipObj = roleItem:GetObject()
            local gemlist = equipObj:GetGemlist()
            if gemlist:size() > 0 then
                GetCTipsManager():AddMessageTipById(160111) --镶嵌宝石的装备不能上架哦
                return
            end
        end

       if roleItem:isBind() then
            GetCTipsManager():AddMessageTipById(160209) --此物品已绑定，无法上架
            return
        end

        self:doUpShelf(TYPE_UP)

    elseif self.isRarity and not IsPointCardServer() then
        if MoneyNumber(self.priceText:getText()) == self.recommendPrice then
			MessageBoxSimple.show(
				MHSD_UTILS.get_msgtipstring(160377),  --商品价格未做修改，将按当前价格不进入公示期，直接上架出售。
				StallUpShelf.handleConfirUpShelf, self, nil, nil
			)
		else
			MessageBoxSimple.show(
				MHSD_UTILS.get_msgtipstring(160381),  --修改价格后，需要重新进行8小时公示，修改吗？
				StallUpShelf.handleConfirUpShelf, self, nil, nil
			)
		end

	else
		self:doUpShelf(TYPE_RE_UP)
    end
end

return StallUpShelf
