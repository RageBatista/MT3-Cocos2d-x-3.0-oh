------------------------------------------------------------------
-- 购买摆摊物品，可设置购买数量
------------------------------------------------------------------
require "logic.dialog"

StallBuyDlg = {}
setmetatable(StallBuyDlg, Dialog)
StallBuyDlg.__index = StallBuyDlg

local _instance
function StallBuyDlg.getInstance()
	if not _instance then
		_instance = StallBuyDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function StallBuyDlg.getInstanceAndShow(parent)
	if not _instance then
		_instance = StallBuyDlg:new()
		_instance:OnCreate(parent)
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function StallBuyDlg.getInstanceNotCreate()
	return _instance
end

function StallBuyDlg.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function StallBuyDlg.ToggleOpenClose()
	if not _instance then
		_instance = StallBuyDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function StallBuyDlg.GetLayoutFileName()
	return "baitangoumaishuliang.layout"
end

function StallBuyDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, StallBuyDlg)
	return self
end

function StallBuyDlg:OnCreate(parent)
	Dialog.OnCreate(self, parent)
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.frameWindow = CEGUI.toFrameWindow(winMgr:getWindow("baitangoumaishuliang/jiemian"))
	self.itemcell = CEGUI.toItemCell(winMgr:getWindow("baitangoumaishuliang/jiemian/wupin"))
	self.name = winMgr:getWindow("baitangoumaishuliang/jiemian/mingzi")
	self.namec = winMgr:getWindow("baitangoumaishuliang/jiemian/mingzi1")
	self.shortDes = winMgr:getWindow("baitangoumaishuliang/jiemian/tiaojian")
	self.desBox = CEGUI.toRichEditbox(winMgr:getWindow("baitangoumaishuliang/jiemian/di"))
	self.minusBtn = CEGUI.toPushButton(winMgr:getWindow("baitangoumaishuliang/jiemian/shuliang/jianhao"))
	self.numText = winMgr:getWindow("baitangoumaishuliang/jiemian/shuliang/shuru/shuliang")
	self.addBtn = CEGUI.toPushButton(winMgr:getWindow("baitangoumaishuliang/jiemian/shuliang/jiahao"))
	self.price = winMgr:getWindow("baitangoumaishuliang/jiemian/danjia/huobizhi")
	self.totalPrice = winMgr:getWindow("baitangoumaishuliang/jiemian/zongjia/huobizhi")
	self.cancelBtn = CEGUI.toPushButton(winMgr:getWindow("baitangoumaishuliang/jiemian/quxiao"))
	self.buyBtn = CEGUI.toPushButton(winMgr:getWindow("baitangoumaishuliang/jiemian/goumai"))

	self.cancelBtn:subscribeEvent("Clicked", StallBuyDlg.handleCancelClicked, self)
	self.buyBtn:subscribeEvent("Clicked", StallBuyDlg.handleBuyClicked, self)
	self.addBtn:subscribeEvent("Clicked", StallBuyDlg.handleNumAddClicked, self)
	self.minusBtn:subscribeEvent("Clicked", StallBuyDlg.handleNumMinusClicked, self)
	self.numText:subscribeEvent("MouseClick", StallBuyDlg.handleNumTextClicked, self)

    self.frameWindow:getCloseButton():removeEvent("Clicked")
	self.frameWindow:getCloseButton():subscribeEvent("Clicked", StallBuyDlg.DestroyDialog, nil)
end

function StallBuyDlg:setGoodsData(goods)
	self.goods = goods
	
	local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(goods.itemid)
    if not itemAttr then
        return
    end
	self.name:setText(itemAttr.name)
	self.namec:setText(itemAttr.effectdes)
	local image = gGetIconManager():GetImageByID(itemAttr.icon)
	self.itemcell:SetImage(image)
	self.price:setText(MoneyFormat(goods.price))
	self.totalPrice:setText(MoneyFormat(goods.price))
	
    if string.find(itemAttr.destribe, "<T") then
        self.desBox:AppendParseText(CEGUI.String(itemAttr.destribe))
    else
        local color = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FF7F4601"))
	    self.desBox:AppendText(CEGUI.String(itemAttr.destribe), color)
    end
	self.desBox:Refresh()
end

function StallBuyDlg:onNumInputChanged(num)
	if num == 0 then
		num = 1
	end
	
	self.numText:setText(num)
	self.totalPrice:setText(MoneyFormat(num*self.goods.price))
end

function StallBuyDlg:handleNumAddClicked(args)
	local num = tonumber(self.numText:getText()) + 1
	if num <= self.goods.num then
		self.numText:setText(num)
		self.totalPrice:setText(MoneyFormat(num*self.goods.price))
	end
end

function StallBuyDlg:handleNumMinusClicked(args)
	local num = tonumber(self.numText:getText()) - 1
	if num > 0 then
		self.numText:setText(num)
		self.totalPrice:setText(MoneyFormat(num*self.goods.price))
	end
end

function StallBuyDlg:handleNumTextClicked(args)
	if NumKeyboardDlg.getInstanceNotCreate() then
		NumKeyboardDlg.getInstanceNotCreate():SetVisible(true) --保持键盘在最上面
		return
	end
	
	local dlg = NumKeyboardDlg.getInstanceAndShow(self:GetWindow())
	if dlg then
		dlg:setTriggerBtn(self.numText)
		dlg:setMaxValue(self.goods.num)
		dlg:setInputChangeCallFunc(StallBuyDlg.onNumInputChanged, self)
		
		local p = self.numText:GetScreenPos()
		SetPositionOffset(dlg:GetWindow(), p.x+self.numText:getPixelSize().width*0.5, p.y-10, 0.5, 1)
	end
end

function StallBuyDlg:handleCancelClicked(args)
	StallBuyDlg.DestroyDialog()
end

function StallBuyDlg:handleBuyClicked(args)
	local p = require("protodef.fire.pb.shop.cmarketbuy"):new()
	p.id = self.goods.id
	p.saleroleid = self.goods.saleroleid
	p.itemid = self.goods.itemid
	p.num = tonumber(self.numText:getText())
	
	print('--------cmarketbuy-------')
	for k,v in pairs(p) do
		print(k,v)
	end
	
	--金币是否够
	local totalprice = self.goods.price*p.num
	local needMoney = CurrencyManager.canAfford(fire.pb.game.MoneyType.MoneyType_GoldCoin, totalprice)
	if needMoney > 0 then
		CurrencyManager.handleCurrencyNotEnough(fire.pb.game.MoneyType.MoneyType_GoldCoin, needMoney, totalprice, p)
		StallBuyDlg.DestroyDialog()
		return
	end
	
	LuaProtocolManager:send(p)
	StallBuyDlg.DestroyDialog()
end

return StallBuyDlg
