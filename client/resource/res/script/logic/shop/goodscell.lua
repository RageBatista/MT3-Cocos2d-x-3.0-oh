------------------------------------------------------------------
-- 物品cell
------------------------------------------------------------------
GoodsCell = {
	CORNER_IMG_NEW	= 1,	--新品
	CORNER_IMG_HOT	= 2,	--热卖
	CORNER_IMG_EMP	= 3		--售完
}

setmetatable(GoodsCell, Dialog)
GoodsCell.__index = GoodsCell
local prefix = 0

function GoodsCell.CreateNewDlg(parent)
	local newDlg = GoodsCell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function GoodsCell.GetLayoutFileName()
	return "npcshopcell_mtg.layout"
end

function GoodsCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, GoodsCell)
	return self
end

function GoodsCell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

	self.window = CEGUI.toGroupButton(winMgr:getWindow(prefixstr .. "npcshopcell_mtg"))
	self.itemCell = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "npcshopcell_mtg/itemcell"))
	self.itemCellfg = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "npcshopcell_mtg/itemcellfg"))
	self.itemName = winMgr:getWindow(prefixstr .. "npcshopcell_mtg/textname")
	self.itemNamec = winMgr:getWindow(prefixstr .. "npcshopcell_mtg/textname1")
	self.priceText = winMgr:getWindow(prefixstr .. "npcshopcell_mtg/textnumber")
	self.priceText:setProperty("TextColours", "FFFFFFFF")
	self.currencyIcon = winMgr:getWindow(prefixstr .. "npcshopcell_mtg/textnumber/yinbi")
	self.zhekouBg = winMgr:getWindow(prefixstr .. "npcshopcell_mtg/imagejiangjia")
	self.zhekouValue = winMgr:getWindow(prefixstr .. "npcshopcell_mtg/imagejiangjia/text6")
	
    self.biaoshi1 = winMgr:getWindow(prefixstr .. "npcshopcell_mtg/biaoshi/1")
    self.biaoshi2 = winMgr:getWindow(prefixstr .. "npcshopcell_mtg/biaoshi/2")
    self.biaoshi3 = winMgr:getWindow(prefixstr .. "npcshopcell_mtg/biaoshi/3")
    self.biaoshi4 = winMgr:getWindow(prefixstr .. "npcshopcell_mtg/biaoshi/4")
	
	self.xiangoubs = winMgr:getWindow(prefixstr .. "npcshopcell_mtg/biaoshi/xiangoubs")
	self.xiangoucishu = winMgr:getWindow(prefixstr .. "npcshopcell_mtg/biaoshi/xiangoubs/xiangoucishu")

	self.window:EnableClickAni(false)
end

function GoodsCell:getMallShopLimitNumByVIP()
    local vipLevel = gGetDataManager():GetVipLevel()
    local record = BeanConfigManager.getInstance():GetTableByName("fushi.cvipinfo"):getRecorder(vipLevel)
    if record then
        return record.limitnumber1
    end
    return 0
end

function GoodsCell:setGoodsDataById(goodsid)
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

        self.itemCellfg:SetStyle(CEGUI.ItemCellStyle_IconInside) 
        self.itemCellfg:SetImage(gGetIconManager():GetImageByID(item.icon))
        self.itemCellfg:setID(conf.itemId)
        SetItemCellBoundColorByQulityItem(self.itemCellfg, item.nquality, item.itemtypeid)

         local mallConf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmallshop")):getRecorder(goodsid)
        if mallConf then
            local buyNum = ShopManager.goodsBuyNumLimit[goodsid]
            local maxAddNum = 0
            if conf.limitType == 2 then
                maxAddNum = self:getMallShopLimitNumByVIP()
            end
            -- 计算剩余购买次数
            local remainingBuyCount = conf.limitNum + maxAddNum
            if buyNum then
              remainingBuyCount = remainingBuyCount - buyNum 
            end
            
            
            if buyNum and conf.limitNum > 0 and remainingBuyCount <= 0 then 
                --售空
                self:setCornerImage(GoodsCell.CORNER_IMG_EMP)
            elseif mallConf.cuxiaotype == 1 then 
                --新品
                self:setCornerImage(GoodsCell.CORNER_IMG_NEW)
            elseif mallConf.cuxiaotype == 2 then 
                --热卖
                self:setCornerImage(GoodsCell.CORNER_IMG_HOT)
            else
                self:setCornerImage(nil)
            end
            
            -- 根据剩余购买次数决定是否显示限购信息
            if conf.limitNum > 0 and remainingBuyCount > 0 then 
                self.xiangoubs:setVisible(true)
              
                local xianGouQianZhui = require "utils.mhsdutils".get_resstring(7405) -- 限购前缀--限购
                local xianGouHouZhui = require "utils.mhsdutils".get_resstring(7406) -- 限购后缀--个
                self.xiangoucishu:setText(string.format("%s%d%s", xianGouQianZhui, remainingBuyCount, xianGouHouZhui)) 
            else
                self.xiangoubs:setVisible(false)  
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

            self.itemCellfg:SetStyle(CEGUI.ItemCellStyle_IconExtend)
            self.itemCellfg:SetImage(image) 
            SetItemCellBoundColorByQulityPet(self.itemCellfg, petAttr.quality)

        end
    end
end

function GoodsCell:setCornerImage(t)
    self.cornerImgType = t
    self.biaoshi1:setVisible(false)---新品
    self.biaoshi2:setVisible(false)---热卖
    self.biaoshi3:setVisible(false)---售空
    self.biaoshi4:setVisible(false)---需求

    if not t then
        self.itemCell:SetCornerImageAtPos(nil, 0, 1)
    elseif t == GoodsCell.CORNER_IMG_NEW then
        self.itemCell:SetCornerImageAtPos("ccui1", "tm", 0, 1)---不去修改
        self.biaoshi1:setVisible(true)
    elseif t == GoodsCell.CORNER_IMG_HOT then
        self.itemCell:SetCornerImageAtPos("ccui1", "tm", 0, 1)---不去修改
        self.biaoshi2:setVisible(true)
    elseif t == GoodsCell.CORNER_IMG_EMP then
        self.itemCell:SetCornerImageAtPos("ccui1", "tm", 0, 1)---不去修改
        self.biaoshi3:setVisible(true)
    end
end

function GoodsCell:showRequireCornerImage(willShow)
    self.biaoshi1:setVisible(false)---新品
    self.biaoshi2:setVisible(false)---热卖
    self.biaoshi3:setVisible(false)---售空
    self.biaoshi4:setVisible(false)---需求

    if willShow then
        self.itemCell:SetCornerImageAtPos("ccui1", "tm", 0, 1)---需求
        self.biaoshi4:setVisible(true)
    else
        self:setCornerImage(self.cornerImgType) --还原
    end
end

return GoodsCell
