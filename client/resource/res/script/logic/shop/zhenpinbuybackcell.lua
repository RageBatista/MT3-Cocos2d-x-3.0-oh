------------------------------------------------------------------
-- ’‰∆∑cell
------------------------------------------------------------------
ZhenPinBuyBackCell = {}

setmetatable(ZhenPinBuyBackCell, Dialog)
ZhenPinBuyBackCell.__index = ZhenPinBuyBackCell
local prefix = 0
local ITEM = 1
local PET = 2

function ZhenPinBuyBackCell.CreateNewDlg(parent)
	local newDlg = ZhenPinBuyBackCell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function ZhenPinBuyBackCell.GetLayoutFileName()
	return "npcshopbuybackcell.layout"
end

function ZhenPinBuyBackCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ZhenPinBuyBackCell)
	return self
end

function ZhenPinBuyBackCell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

	self.window = CEGUI.toGroupButton(winMgr:getWindow(prefixstr .. "npcshopbuybackcell"))
	self.itemcell = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "npcshopbuybackcell/item"))
	self.nameText = winMgr:getWindow(prefixstr .. "npcshopbuybackcell/name")
	self.priceText = winMgr:getWindow(prefixstr .. "npcshopbuybackcell/textjiage")
	self.leftText = winMgr:getWindow(prefixstr .. "npcshopbuybackcell/lefttxt")
	self.leftTimeText = winMgr:getWindow(prefixstr .. "npcshopbuybackcell/leftnum")


end

--data: ItemRecoverInfoBean / PetRecoverInfoBean
function ZhenPinBuyBackCell:setData(data, goodstype)
	self.data = data

	local day = math.ceil(data.remaintime / (60*60*24))
	self.leftTimeText:setText(day .. MHSD_UTILS.get_resstring(317)) --ÃÏ
    self.priceText:setText(data.cost)

	if goodstype == ITEM then
		local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(data.itemid)
		if itemAttr then
            self.nameText:setProperty("TextColours", "ff50321a")
			self.nameText:setText(itemAttr.name)
			local image = gGetIconManager():GetImageByID(itemAttr.icon)
            SetItemCellBoundColorByQulityItem(self.itemcell, itemAttr.nquality, itemAttr.itemtypeid)
            self.itemcell:SetStyle(CEGUI.ItemCellStyle_IconInside)
			self.itemcell:SetImage(image)
			self.itemcell:SetCornerImageAtPos("ccui1", "newzp", 0, 1)

			local firstType = itemAttr.itemtypeid % 16
            local isEquip = (firstType == eItemType_EQUIP)
			if not isEquip then
				self.itemcell:SetCornerImageAtPos("ccui1", "newzp", 0, 1)
			else
				self.itemcell:SetCornerImageAtPos(nil, 0, 1)
			end
			return
		end
	elseif goodstype == PET then
		local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(data.petid)
        if petAttr then
            self.nameText:setProperty("TextColours", "FFFFFFFF")
			self.nameText:setText("[colour=\'" .. petAttr.colour .. "\']" .. petAttr.name)
			local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(petAttr.modelid)
			local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
            self.itemcell:SetStyle(CEGUI.ItemCellStyle_IconExtend)
			self.itemcell:SetImage(image)
            SetItemCellBoundColorByQulityPet(self.itemcell, petAttr.quality)
			self.itemcell:SetTextUnit("")
			self.itemcell:SetCornerImageAtPos("ccui1", "newzp", 0, 1)
			return
        end
	end

	--handle error
	self.nameText:setProperty("TextColours", "ff50321a")
	self.nameText:setText("ERROR")
	self.priceText:setText("")
	self.leftTimeText:setText("")
	self.itemcell:setID(0)
	self.itemcell:SetImage(nil)
	self.itemcell:SetCornerImageAtPos(nil, 0, 1)
	self.itemcell:SetBackGroundImage("ccui1", "kuang2")
end

return ZhenPinBuyBackCell