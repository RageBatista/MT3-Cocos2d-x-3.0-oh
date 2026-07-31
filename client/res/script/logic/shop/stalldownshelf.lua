------------------------------------------------------------------
-- 摆摊商品（非宠物）下架
------------------------------------------------------------------
require "logic.dialog"
require "logic.tips.commontiphelper"

StallDownShelf = {}
setmetatable(StallDownShelf, Dialog)
StallDownShelf.__index = StallDownShelf

local _instance
function StallDownShelf.getInstance()
	if not _instance then
		_instance = StallDownShelf:new()
		_instance:OnCreate()
	end
	return _instance
end

function StallDownShelf.getInstanceAndShow(parent)
	if not _instance then
		_instance = StallDownShelf:new()
		_instance:OnCreate(parent)
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function StallDownShelf.getInstanceNotCreate()
	return _instance
end

function StallDownShelf.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function StallDownShelf.ToggleOpenClose()
	if not _instance then
		_instance = StallDownShelf:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function StallDownShelf.GetLayoutFileName()
	return "baitanxiajia.layout"
end

function StallDownShelf:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, StallDownShelf)
	return self
end

function StallDownShelf:OnCreate(parent)
	Dialog.OnCreate(self, parent)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.itemCell = CEGUI.toItemCell(winMgr:getWindow("baitanxiajia/xiajia/wupin"))
	self.nameText = winMgr:getWindow("baitanxiajia/xiajia/mingzi")
	self.levelCharText = winMgr:getWindow("baitanxiajia/xiajia/yaoqiu1")
	self.levelText = winMgr:getWindow("baitanxiajia/xiajia/yaoqiu")
	self.desBg = winMgr:getWindow("baitanxiajia/xiajia/di")
	self.desBox = CEGUI.toRichEditbox(winMgr:getWindow("baitanxiajia/xiajia/di/gundongwenben"))
	self.tipText = winMgr:getWindow("baitanxiajia/xiajia/yixiajia")
	self.cancelBtn = CEGUI.toPushButton(winMgr:getWindow("baitanxiajia/xiajia/quhui"))
	self.downShelfBtn = CEGUI.toPushButton(winMgr:getWindow("baitanxiajia/xiajia/upshelf"))
	self.closeBtn = CEGUI.toPushButton(winMgr:getWindow("baitanxiajia/xiajia/guanbi"))
	self.totalPriceCell = winMgr:getWindow("baitanxiajia/xiajia/shoujia")
	self.priceText = winMgr:getWindow("baitanxiajia/xiajia/zongjia/shoujia")
	self.numCell = winMgr:getWindow("baitanxiajia/xiajia/shuliang")
	self.numText = winMgr:getWindow("baitanxiajia/xiajia/shuliang/shuliangzhi")
	self.totalPriceCell = winMgr:getWindow("baitanxiajia/xiajia/zongjia")
	self.totalPriceText = winMgr:getWindow("baitanxiajia/xiajia/zongjia/zongjia")

	self.cancelBtn:subscribeEvent("Clicked", StallDownShelf.handleCancelClicked, self)
	self.downShelfBtn:subscribeEvent("Clicked", StallDownShelf.handleDownShelfClicked, self)
	self.closeBtn:subscribeEvent("Clicked", StallDownShelf.DestroyDialog, self)

    local color = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("fffff2df"))
    self.desBox:SetColourRect(color)
end

--MarketGoods
function StallDownShelf:setGoodsData(goods)
	self.goods = goods
	
	local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(goods.itemid)
    if itemAttr then
	    self.nameText:setText(itemAttr.name)
	    local image = gGetIconManager():GetImageByID(itemAttr.icon)
	    self.itemCell:SetImage(image)
    end
    
    self.roleItem = RoleItem:new()
	self.roleItem:SetItemBaseData(goods.itemid, 0)
    self.roleItem:SetObjectID(goods.itemid)

	local str1,str2  = Commontiphelper.getStringForBottomLabel(goods.itemid, self.roleItem:GetObject())
	self.levelCharText:setText(str1)
	self.levelText:setText(str2)

	local baseConf = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(goods.itemid)
    if baseConf then
        SetItemCellBoundColorByQulityItem(self.itemCell, baseConf.nquality, baseConf.itemtypeid)
        if string.find(baseConf.destribe, "<T") then
            self.desBox:AppendParseText(CEGUI.String(baseConf.destribe))
        else
            local color = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("fffff2df"))
	        self.desBox:AppendText(CEGUI.String(baseConf.destribe), color)
        end
	    self.desBox:Refresh()
    end
	
	self.priceText:setText(MoneyFormat(goods.price))
	
	
	if goods.num == 1 then
		self.numCell:setVisible(false)
		self.totalPriceCell:setVisible(false)
		
		self.tipText:setYPosition(self.totalPriceCell:getYPosition())
		
		local y = self.desBg:getYPosition().offset
		local y1 = self.numCell:getYPosition().offset+self.numCell:getPixelSize().height
		local deltaH = y1-y-self.desBg:getPixelSize().height
		self.desBox:setHeight(CEGUI.UDim(0, self.desBox:getPixelSize().height+deltaH))
		self.desBg:setHeight(CEGUI.UDim(0, y1-y))
		
	else
		self.numText:setText(goods.num)
		self.totalPriceText:setText(MoneyFormat(goods.num * goods.price))
	end

    --request tips data
    --print('request market goods tip ', goods.key)
    local p = require("protodef.fire.pb.item.cotheritemtips"):new()
    p.roleid = goods.saleroleid
    p.packid = fire.pb.item.BagTypes.MARKET
    p.keyinpack = goods.key
	LuaProtocolManager:send(p)

    self.itemkey = goods.key
    self.roleid = goods.saleroleid
end

function StallDownShelf:recvTipsData(data)
    self.roleItem:GetObject():MakeTips(data)
    local str1,str2  = Commontiphelper.getStringForBottomLabel(self.roleItem:GetBaseObject().id, self.roleItem:GetObject())
	self.levelCharText:setText(str1)
	self.levelText:setText(str2)
    Commontiphelper.RefreshRichBox(self.desBox, self.roleItem:GetBaseObject().id, self.roleItem:GetObject())
end

function StallDownShelf:handleCancelClicked(args)
	StallDownShelf.DestroyDialog()
end

function StallDownShelf:handleDownShelfClicked(args)
	if not CheckBagCapacityForItem(0, 1) then
		GetCTipsManager():AddMessageTipById(160062) --背包空间不足
	else
        -- 限制下架
        --local shoujianquanmgr = require "logic.shoujianquan.shoujianquanmgr"
        --if shoujianquanmgr.needBindTelAgain() then
         --   require("logic.shoujianquan.shoujiyanzheng").getInstanceAndShow()
         --   return
       -- elseif shoujianquanmgr.notBind7Days() then
        --    require("logic.shoujianquan.shoujiguanlianqueren").getInstanceAndShow()
        --    return
     --   end

		local p = require("protodef.fire.pb.shop.cmarketdown"):new()
		p.downtype = STALL_GOODS_T.ITEM
		p.key = self.goods.key
		LuaProtocolManager:send(p)
	end
	StallDownShelf.DestroyDialog()
end

return StallDownShelf
