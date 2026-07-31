------------------------------------------------------------------
-- 合服背包cell
------------------------------------------------------------------
require "logic.tips.commontiphelper"

HeFuBagCell = {}

setmetatable(HeFuBagCell, Dialog)
HeFuBagCell.__index = HeFuBagCell
local prefix = 0

function HeFuBagCell.CreateNewDlg(parent)
	local newDlg = HeFuBagCell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function HeFuBagCell.GetLayoutFileName()
	return "hefubagcell.layout"
end

function HeFuBagCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, HeFuBagCell)
	return self
end

function HeFuBagCell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

	self.window = CEGUI.toGroupButton(winMgr:getWindow(prefixstr .. "hefubagcell"))
	self.itemcell = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "hefubagcell/item"))
	self.nameText = winMgr:getWindow(prefixstr .. "hefubagcell/name")
	self.typeText = winMgr:getWindow(prefixstr .. "hefubagcell/type")

    self.itemcell:subscribeEvent("MouseClick", HeFuBagCell.handleItemCellClicked, self)

    self.nameDefaultColor = self.nameText:getProperty("TextColours")
    self.typeNames = {
        MHSD_UTILS.get_resstring(679), --物品
        MHSD_UTILS.get_resstring(11626),  --宠物
        MHSD_UTILS.get_resstring(2666) --装备
    }
end

--stHeFuGoods
function HeFuBagCell:setData(data, idx)
    self.data = data
	self.idx = idx
    self.nameText:setText(data.name)
    self.typeText:setText(self.typeNames[data.itemtype])
    if data.itemtype == STALL_GOODS_T.PET then
        SetItemCellBoundColorByQulityPet(self.itemcell, data.quality)
        self.itemcell:SetStyle(CEGUI.ItemCellStyle_IconExtend)
        self.nameText:setProperty("TextColours", "FFFFFFFF")
    else
        SetItemCellBoundColorByQulityItem(self.itemcell, data.quality)
        self.itemcell:SetStyle(CEGUI.ItemCellStyle_IconInside)
        self.nameText:setProperty("TextColours", self.nameDefaultColor)

		if data.maxnum > 1 then --可堆叠的物品
			self.itemcell:SetTextUnit(data.num>1 and data.num or "")
		elseif data.level > 0 then
			self.itemcell:SetTextUnit("Lv." .. data.level)
		end
    end

	--显示珍品角标
	if data.itemtype ~= STALL_GOODS_T.EQUIP and ShopManager:isRarity(data.itemtype, data.itemid) then
		self.itemcell:SetCornerImageAtPos("ccui1", "newzp", 0, 1)
	end

    self.typeText:setText(self.typeNames[self.data.itemtype])
    local image = gGetIconManager():GetImageByID(data.icon)
    self.itemcell:SetImage(image)
end

function HeFuBagCell:handleItemCellClicked(args)
    self.window:setSelected(true)

	local roleid = gGetDataManager():GetMainCharacterID()

    if self.data.itemtype == STALL_GOODS_T.PET then
        local dlg = PetDetailDlg.getInstanceAndShow()
		dlg:setPet(self.data.itemid, self.data.key, roleid)
		dlg:GetWindow():setVisible(false) --先隐藏，收到详细数据后再显示

    else
        local p = require("protodef.fire.pb.item.cotheritemtips"):new()
        p.roleid = roleid
        p.packid = fire.pb.item.BagTypes.MARKET
        p.keyinpack = self.data.key
	    LuaProtocolManager:send(p)

		local pos = self.itemcell:GetScreenPosOfCenter()
        local roleItem = RoleItem:new()
	    roleItem:SetItemBaseData(self.data.itemid, 0)
        roleItem:SetObjectID(self.data.itemid)
        local tip = Commontiphelper.showItemTip(self.data.itemid, roleItem:GetObject(), false, false, pos.x, pos.y)
		tip:showSwitchPageArrow(false)
        tip.isStallTip = true
        tip.roleid = roleid
        tip.roleItem = roleItem
        tip.itemkey = self.data.key

		--调整位置
		local winH = GetScreenSize().height
		local tipH = tip:GetWindow():getPixelSize().height
		if self.idx % 2 == 0 then --左列
			local x = self.itemcell:getParent():GetScreenPos().x + self.itemcell:getParent():getPixelSize().width
			local y = (winH - tipH)*0.5
			tip:GetWindow():setPosition(NewVector2(x, y))
		else
			local x = self.itemcell:getParent():GetScreenPos().x-tip:GetWindow():getPixelSize().width
			local y = (winH - tipH)*0.5
			tip:GetWindow():setPosition(NewVector2(x, y))
		end
	end
end

return HeFuBagCell