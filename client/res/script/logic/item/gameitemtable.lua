------------------------------------------------------------------
-- 游戏格子的逻辑类
------------------------------------------------------------------
GameItemTable = {}
GameItemTable.__index = GameItemTable

ItemCellType = {
	None	= 0,
	Item	= 1		--道具
}

local tresureMapId = 331300
local superTresureMapId = 331301

function GameItemTable:new(packId)
	local ret = {mPackId = packId};
	setmetatable(ret, GameItemTable)
	return ret
end

function GameItemTable:SetItemTable(itemTable, rowCount, colCount, cellSelected)
	if self.itemTable then
		self.itemTable:DestroyAllCell()
	end
	self.itemTable = itemTable
	if not itemTable then
		return
	end
	itemTable:SetRowCount(rowCount)
	itemTable:SetColCount(colCount)
	for r=0, rowCount-1 do
		for c=0, colCount-1 do
			local index = r * colCount + c
			local cell = itemTable:GetCell(index)
			if cell then
				cell:SetHaveSelectedState(cellSelected)
				cell:SetCellTypeMask(ItemCellType.Item)
				cell:subscribeEvent("MouseClick", GameItemTable.HandleShowToolTips, self)
			end
		end
	end
end

function GameItemTable:GetCellCount()
	if self.itemTable then
		return self.itemTable:GetCellCount()
	end
	return -1
end

function GameItemTable:GetCell(idx)
	if self.itemTable then
		return self.itemTable:GetCell(idx)
	end
	return nil
end

function GameItemTable:AddCell(idx)
	if self.itemTable then
		self.itemTable:AddCell(idx)
	end
end

function GameItemTable:AddNewCell()
	if self.itemTable then
		local idx = self:GetCellCount()
		self:AddCell(idx)
		return self:GetCell(idx+1)
	end
	return nil
end

function GameItemTable:AddItem(data, idx)
	local cell = self:GetCell(idx)
	if cell then
        cell:setID2(data:GetThisID())
		return true
	end
	return false
end

function GameItemTable:GetItem(idx)
	local cell = self:GetCell(idx)
	if not cell then
		return nil
	end
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local data = roleItemManager:getItem(cell:getID2(), self.mPackId)
	if not data then
		return nil
	end
	if cell:GetCellTypeMask() == ItemCellType.Item then
		return data
	end
	return nil
end

--pt: CEGUI::Point
function GameItemTable:GetCellAtPoint(pt)
	if self.itemTable then
		return self.itemTable:GetCellAtPoint(pt)
	end
	return nil
end

function GameItemTable:DelCell(idx)
	if self.itemTable then
		self.itemTable:DestroyCell(idx)
	end
end

function GameItemTable:DestroyAllCell()
	if self.itemTable then
		self.itemTable:DestroyAllCell()
	end
end

--格子类型不再使用掩码，直接按ItemCellType的值来定义
function GameItemTable:GetCellType(idx)
	local cell = self:GetCell(idx)
	if cell then
		return cell:GetCellTypeMask()
	end
	return ItemCellType.None
end

function GameItemTable:HandleShowToolTips(args)
	print('GameItemTable.HandleShowToolTips')
	local cell = CEGUI.toItemCell(CEGUI.toWindowEventArgs(args).window)
	if not cell then
		return true
	end
	local t = cell:GetCellTypeMask()
	if t == ItemCellType.Item then
	    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
        local item = roleItemManager:FindItemByBagAndThisID(cell:getID2(), self.mPackId);
		if item then
			local bagId = item:GetLocation().tableType
			local itemkey = item:GetThisID()
			local pos = cell:GetScreenPosOfCenter()
            if (item:GetObjectID() == tresureMapId or item:GetObjectID() == superTresureMapId) and item:GetObject().x == 0 and item:GetObject().y == 0 then
                require "protodef.fire.pb.item.cgetitemtips"
	            local itemTip = CGetItemTips.Create()
	            itemTip.packid = fire.pb.item.BagTypes.BAG
	            itemTip.keyinpack = item:GetThisID()
	            LuaProtocolManager.getInstance():send(itemTip)
                return true
            else
                LuaShowItemTip(bagId, itemkey, pos.x, pos.y)
            end
			if cell:HasFloodLight() then
				gGetGameUIManager():RemoveUIEffect(cell)
				cell:SetFloodLight(false)
			end

			if item:GetObject().data.isnew == 1 then
				item:GetObject().data.isnew = 0
			end
		end
	end
	return true
end

--通用的弹物品tips方法，不通过self调用
function GameItemTable.HandleShowToolTipsWithItemID(args)
	local cell = CEGUI.toItemCell(CEGUI.toWindowEventArgs(args).window)
	if not cell then
		return true
	end
	local pos = cell:GetScreenPosOfCenter()
	LuaShowItemTipWithBaseId(cell:getID(), pos.x, pos.y, 0)
    if cell:getID2() > 0 then
        local dlg = require "logic.tips.commontipdlg".getInstanceNotCreate()
        if dlg then
            dlg:setNum(cell:getID2())
        end
    end
	return true
end

function GameItemTable:SetImage(idx, imageset, imagename)
	local cell = self:GetCell(idx)
	if cell then
		cell:SetImage(imageset, imagename)
	end
end

--textType: enum ItemCellTextType
function GameItemTable:SetText(idx, text, textType)
	local cell = self:GetCell(idx)
	if cell then
		cell:SetTextUnitText(CEGUI.String(text), textType)
	end
end

function GameItemTable:SetVisible(b)
	if self.itemTable then
		self.itemTable:setVisible(b)
	end
end

--根据道具获得格子
function GameItemTable:GetCellByItem(item)
	if not item then
		return nil
	end
	local cellCount = self:GetCellCount()
	if cellCount then
		for i=0, cellCount do
			if item == self:GetItem(i) then
				return self:GetCell(i)
			end
		end
	end
end

return GameItemTable
