gemshopcell = {}

setmetatable(gemshopcell, Dialog)
gemshopcell.__index = gemshopcell
local prefix = 0

function gemshopcell.CreateNewDlg(parent)
	local newDlg = gemshopcell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function gemshopcell.GetLayoutFileName()
	return "baoshihechengcell2.layout"
end

function gemshopcell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, gemshopcell)
	return self
end

function gemshopcell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

	self.window = CEGUI.toGroupButton(winMgr:getWindow(prefixstr .. "baoshihechengcell2_mtg"))
	self.itemcell = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "baoshihechengcell2_mtg/item"))
	self.nameText = winMgr:getWindow(prefixstr .. "baoshihechengcell2_mtg/name")
	self.priceText = winMgr:getWindow(prefixstr .. "baoshihechengcell2_mtg/textjiage")
	self.currencyIcon = winMgr:getWindow(prefixstr .. "baoshihechengcell2_mtg/textjiage/yinbi")
	self.buyNumLimit = winMgr:getWindow(prefixstr .. "baoshihechengcell2_mtg/number")
	--self.noGoodsSign = winMgr:getWindow(prefixstr .. "baoshihechengcell2_mtg/")
	self.explainText = winMgr:getWindow(prefixstr .. "baoshihechengcell2_mtg/weizhi")
	self.btnRemove = CEGUI.toPushButton(winMgr:getWindow(prefixstr .. "baoshihechengcell2_mtg/btn"))
    self.btnReduce = CEGUI.toPushButton(winMgr:getWindow(prefixstr .. "baoshihechengcell2_mtg/jian"))
    self.btnReduce:subscribeEvent("MouseClick", gemshopcell.HandleReduceClicked, self)
    self.btnReduce:setVisible(false)
   -- self.noGoodsSign:setVisible(false)
end

function gemshopcell:setShopInfo(info)
    self.window:setID(info.id)
    local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(info.id)
	if not itemAttrCfg then
		return
	end
	self.itemcell:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg.icon))
    SetItemCellBoundColorByQulityItemWithId(self.itemcell, info.id)
    self.nameText:setText(info.name)
    local goodsId = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(info.id).bCanSaleToNpc
    local price = ShopManager.goodsPrices[goodsId]
    if price then
        self.priceText:setText(price)
    end
    local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(goodsId)
    
	local buyNum = ShopManager.goodsBuyNumLimit[goodsId]
    local leaveNum
	if buyNum then
        leaveNum = conf.limitNum-buyNum
		self.buyNumLimit:setText("0".."/"..leaveNum)
	end
    if conf.limitNum-buyNum < 1 then
		return
        --self.noGoodsSign:setVisible(true)
    end
    self.m_goodId = goodsId
    self.m_id = info.id
    self.m_leaveNum = leaveNum
    self.m_boughtNum = 0
    self.m_level = itemAttrCfg.level
    self.window:subscribeEvent("MouseClick", gemshopcell.HandleWindowClicked, self)
end

function gemshopcell:setEquipGemInfo(info, equipName, keyinpack, isequip, gempos)
    self.priceText:setVisible(false)
	self.currencyIcon:setVisible(false)
    self.btnRemove:setVisible(true)
    self.buyNumLimit:setVisible(false)
    self.btnReduce:setVisible(false)
    self.explainText:setVisible(true)
    self.window:setID(info.id)
    self.btnRemove:subscribeEvent("MouseClick", gemshopcell.HandleRemoveClicked, self)
    local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(info.id)
	if not itemAttrCfg then
		return
	end
	self.itemcell:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg.icon))
    SetItemCellBoundColorByQulityItemWithId(self.itemcell, info.id)
    self.nameText:setText(info.name)
    self.explainText:setText(equipName)

    self.keyinpack = keyinpack
    self.isequip = isequip
    self.gempos = gempos

end

function gemshopcell:setBagGemInfo(info)
    self.priceText:setVisible(false)
	self.currencyIcon:setVisible(false)
    --self.buyNumLimit:setVisible(false)
    self.explainText:setVisible(true)
    self.window:setID(info.nGemId)
    local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(info.nGemId)
	if not itemAttrCfg then
		return
	end
    self.buyNumLimit:setText("0".."/"..info.nNum)
	self.itemcell:SetImage(gGetIconManager():GetItemIconByID(itemAttrCfg.icon))
    SetItemCellBoundColorByQulityItemWithId(self.itemcell, info.id)
    self.nameText:setText(itemAttrCfg.name)
    self.explainText:setText(itemAttrCfg.effectdes)
    self.itemcell:SetTextUnit(info.nNum)
    self.window:subscribeEvent("MouseClick", gemshopcell.HandleBagWindowClicked, self)
    self.m_bagGemNum = info.nNum
    self.m_selectedNum = 0
    self.m_itemId = info.nGemId
    self.m_level = itemAttrCfg.level
end

function gemshopcell:HandleBagWindowClicked(args)
    local dlg = require "logic.workshop.workshophcnew":getInstanceOrNot()
    if dlg and dlg:isPlanFull() == true then
        if self.m_selectedNum == 0 then
            self.window:setSelected(false)
        end
        return true
    end
    if self.m_selectedNum < self.m_bagGemNum then
        self.m_selectedNum = self.m_selectedNum + 1
        self.buyNumLimit:setText(self.m_selectedNum.."/"..self.m_bagGemNum)
        if self.m_selectedNum == 1 then
            self.btnReduce:setVisible(true)
        end
        if dlg then
            dlg:addBagGem(self.m_level, self.m_itemId)
        end 
    end
    return true
end

function gemshopcell:HandleWindowClicked(args)
    local dlg = require "logic.workshop.workshophcnew":getInstanceOrNot()
    if dlg and dlg:isPlanFull() == true then
        if self.m_boughtNum == 0 then
            self.window:setSelected(false)
        end
        return true
    end
    if self.m_boughtNum < self.m_leaveNum then
        self.m_boughtNum = self.m_boughtNum + 1
        self.buyNumLimit:setText(self.m_boughtNum.."/"..self.m_leaveNum)
        if self.m_boughtNum == 1 then
            self.btnReduce:setVisible(true)
        end
        if dlg then
            dlg:addShopGem(self.m_level, self.m_goodId, self.m_id)
        end
    end

    return true
end

function gemshopcell:HandleReduceClicked(args)
    if self.m_boughtNum then
        if self.m_boughtNum > 0 then
            self.m_boughtNum = self.m_boughtNum - 1
            self.buyNumLimit:setText(self.m_boughtNum.."/"..self.m_leaveNum)
            if self.m_boughtNum == 0 then
                self.window:setSelected(false)
                self.btnReduce:setVisible(false)
            end
        end
        local dlg = require "logic.workshop.workshophcnew":getInstanceOrNot()
        if dlg then
            dlg:removeShopGem(self.m_level, self.m_goodId, self.m_id)
        end
    end
    if self.m_bagGemNum then
        if self.m_selectedNum > 0 then
            self.m_selectedNum = self.m_selectedNum - 1
            self.buyNumLimit:setText(self.m_selectedNum.."/"..self.m_bagGemNum)
        end
        if self.m_selectedNum == 0 then
            self.window:setSelected(false)
            self.btnReduce:setVisible(false)
        end

        local dlg = require "logic.workshop.workshophcnew":getInstanceOrNot()
        if dlg then
            dlg:removeBagGem(self.m_level, self.m_id)
        end
    end

    return true
end

function gemshopcell:HandleRemoveClicked(args)
    require "protodef.fire.pb.item.cdelgem"
	local p = CDelGem.Create()
	p.keyinpack = self.keyinpack
	p.isequip = self.isequip
	p.gempos = self.gempos
    LuaProtocolManager.getInstance():send(p)
    return true
end

return gemshopcell