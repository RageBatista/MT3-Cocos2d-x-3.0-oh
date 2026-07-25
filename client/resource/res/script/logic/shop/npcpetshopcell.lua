-- NPC宠物商店cell
------------------------------------------------------------------
NpcPetShopCell = {}

setmetatable(NpcPetShopCell, Dialog)
NpcPetShopCell.__index = NpcPetShopCell
local prefix = 0

function NpcPetShopCell.CreateNewDlg(parent)
    local newDlg = NpcPetShopCell:new()
    newDlg:OnCreate(parent)
    return newDlg
end

function NpcPetShopCell.GetLayoutFileName()
    return "chongwushangdiancell.layout"
end

function NpcPetShopCell:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, NpcPetShopCell)
    return self
end

function NpcPetShopCell:OnCreate(parent)
    prefix = prefix + 1
    Dialog.OnCreate(self, parent, prefix)

    local winMgr = CEGUI.WindowManager:getSingleton()
    local prefixstr = tostring(prefix)

    self.window = CEGUI.toGroupButton(winMgr:getWindow(prefixstr .. "chongwushangdiancell/di"))
    self.nameText = winMgr:getWindow(prefixstr .. "chongwushangdiancell/di/mingchen/name")
	self.petNameText = winMgr:getWindow(prefixstr .. "chongwushangdiancell/di/mingchen/namec")
    self.priceText = winMgr:getWindow(prefixstr .. "chongwushangdiancell/di/diwen/wenzidi/shuzikuang")
    self.cornerImg = winMgr:getWindow(prefixstr .. "chongwushangdiancell/di/diwen/xuqiu")
    self.touxiangbg = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "chongwushangdiancell/di/ccyyc"))

    self.window:EnableClickAni(false)
    self.cornerImg:setVisible(false)
end

function NpcPetShopCell:setGoodsDataById(goodsid)
    local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(goodsid)
    if not conf then
        self.window:setID(0)
        self.nameText:setText("Error")
        return
    end

    self.window:setID(goodsid)
    self.nameText:setProperty("TextColours", "FF800000")--宠物名字颜色--改不了
    self.nameText:setText(GetGoodsNameByItemId(conf.type, conf.itemId))
    self.priceText:setText(MoneyFormat(conf.prices[0]))

    -- 改为读取头像
    local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(conf.itemId)
    if petAttr then
        local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(petAttr.modelid) 
        if shapeData then
            local image = gGetIconManager():GetImageByID(shapeData.littleheadID) 
            self.touxiangbg:SetImage(image)
			SetItemCellBoundColorByQulityPet(self.touxiangbg, petAttr.quality)
        end
		if petAttr.name then
            self.petNameText:setText(petAttr.name)--新读取namec
        end
    end
end

return NpcPetShopCell