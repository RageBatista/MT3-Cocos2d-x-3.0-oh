------------------------------------------------------------------
-- NPC售卖CELL
------------------------------------------------------------------
NewGoodsCell = {  
    CORNER_IMG_NEW	= 1,	--新品
    CORNER_IMG_HOT	= 2,	--热卖
    CORNER_IMG_EMP	= 3		--售完
}

setmetatable(NewGoodsCell, Dialog)  
NewGoodsCell.__index = NewGoodsCell
local prefix = 0

function NewGoodsCell.CreateNewDlg(parent) 
    local newDlg = NewGoodsCell:new()
    newDlg:OnCreate(parent)
    return newDlg
end

function NewGoodsCell.GetLayoutFileName()
    return "newnpcshopcell_mtg.layout"  -- new新的脚本，区别开和官方一样
end

function NewGoodsCell:new()
    local self = {}
    self = Dialog:new()
    -- ?????? 5. 再次修改元表  ??????  
    setmetatable(self, NewGoodsCell) 
    return self
end

function NewGoodsCell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

	self.window = CEGUI.toGroupButton(winMgr:getWindow(prefixstr .. "newnpcshopcell_mtg"))
	self.itemCell = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "newnpcshopcell_mtg/itemcell"))
	self.itemName = winMgr:getWindow(prefixstr .. "newnpcshopcell_mtg/textname")
	self.priceText = winMgr:getWindow(prefixstr .. "newnpcshopcell_mtg/textnumber")
	self.currencyIcon = winMgr:getWindow(prefixstr .. "newnpcshopcell_mtg/textnumber/yinbi")
	self.zhekouBg = winMgr:getWindow(prefixstr .. "newnpcshopcell_mtg/imagejiangjia")
	self.zhekouValue = winMgr:getWindow(prefixstr .. "newnpcshopcell_mtg/imagejiangjia/text6")

	self.window:EnableClickAni(false)
end

function NewGoodsCell:getMallShopLimitNumByVIP()
    local vipLevel = gGetDataManager():GetVipLevel()
    local record = BeanConfigManager.getInstance():GetTableByName("fushi.cvipinfo"):getRecorder(vipLevel)
    if record then
        return record.limitnumber1
    end
    return 0
end

function NewGoodsCell:setGoodsDataById(goodsid)
	self.goodsid = goodsid
	
	local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(goodsid)
	if not conf then
		return
	end
	
	self.itemName:setText(GetGoodsNameByItemId(conf.type, conf.itemId))
	self.priceText:setText(MoneyFormat(conf.prices[0]))

	if conf.oldprices[0] and conf.oldprices[0] ~= conf.prices[0] then
		self.zhekouBg:setVisible(true)
		self.zhekouValue:setText(math.floor(conf.prices[0]/conf.oldprices[0]*100)*0.1)
	else
		self.zhekouBg:setVisible(false)
	end
	
	CurrencyManager.setCurrencyIcon(conf.currencys[0], self.currencyIcon)
	
	if conf.type == 1 then --item
		local item = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(conf.itemId)
		if not item then
			return
		end
        self.itemCell:SetStyle(CEGUI.ItemCellStyle_IconInside)
		self.itemCell:SetImage( gGetIconManager():GetImageByID(item.icon))
        self.itemCell:setID(conf.itemId)
        SetItemCellBoundColorByQulityItem(self.itemCell, item.nquality, item.itemtypeid)

		local mallConf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmallshop")):getRecorder(goodsid)
		if mallConf then
			local buyNum = ShopManager.goodsBuyNumLimit[goodsid]
            local maxAddNum = 0
            if conf.limitType == 2 then
                maxAddNum = self:getMallShopLimitNumByVIP()
            end
			if buyNum and conf.limitNum > 0 and buyNum >= conf.limitNum + maxAddNum then --售空
				self:setCornerImage(NewGoodsCell.CORNER_IMG_EMP)
		
			elseif mallConf.cuxiaotype == 1 then --新品
				self:setCornerImage(NewGoodsCell.CORNER_IMG_NEW)
		
			elseif mallConf.cuxiaotype == 2 then --热卖
				self:setCornerImage(NewGoodsCell.CORNER_IMG_HOT)
		
			else
				self:setCornerImage(nil)
			end
		end

	elseif conf.type == 2 then --pet
		local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(conf.itemId)
        if petAttr then
		    local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(petAttr.modelid)
		    local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
            self.itemCell:SetStyle(CEGUI.ItemCellStyle_IconExtend)
		    self.itemCell:SetImage(image)
            SetItemCellBoundColorByQulityPet(self.itemCell, petAttr.quality)
        end
	end
end

function NewGoodsCell:setCornerImage(t)
	self.cornerImgType = t
	if not t then
		self.itemCell:SetCornerImageAtPos(nil, 0, 1)
	end
	if t == NewGoodsCell.CORNER_IMG_NEW then
		self.itemCell:SetCornerImageAtPos("shopui", "shop_xinpin", 0, 1)
	elseif t == NewGoodsCell.CORNER_IMG_HOT then
		self.itemCell:SetCornerImageAtPos("shopui", "shop_remai", 0, 1)
	elseif t == NewGoodsCell.CORNER_IMG_EMP then
		self.itemCell:SetCornerImageAtPos("shopui", "shop_shoukong", 0, 1)
	end
end

function NewGoodsCell:showRequireCornerImage(willShow)
	if willShow then
		self.itemCell:SetCornerImageAtPos("ccui1", "newxq", 0, 1)
	else
		self:setCornerImage(self.cornerImgType) --还原
	end
end

return NewGoodsCell
