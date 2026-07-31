require "logic.dialog"

LyShopItemCell = {}
setmetatable(LyShopItemCell, Dialog)
LyShopItemCell.__index = LyShopItemCell

local prefix = 0
function LyShopItemCell.CreateNewDlg(pParentDlg)
    LogInfo("enter PetCardBookCell.CreateNewDlg")
    local newDlg = LyShopItemCell:new()
    newDlg:OnCreate(pParentDlg)
    return newDlg
end

function LyShopItemCell.GetLayoutFileName()
	return "lianyaoshopitemcell.layout"
end

function LyShopItemCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, LyShopItemCell)
	return self
end

function LyShopItemCell:OnCreate(pParentDlg)
	prefix = prefix + 1
    Dialog.OnCreate(self, pParentDlg, prefix)
	local winMgr = CEGUI.WindowManager:getSingleton()
    self.Item = CEGUI.toGroupButton(winMgr:getWindow(tostring(prefix) .. "lianyaoshopitem_cell"))
	self.ItemIcon = CEGUI.toItemCell(winMgr:getWindow(tostring(prefix) .. "lianyaoshopitem_cell/item"))
	self.ItemName = winMgr:getWindow(tostring(prefix) .. "lianyaoshopitem_cell/itemname")
	self.MoneyNum = winMgr:getWindow(tostring(prefix) .. "lianyaoshopitem_cell/xianyu1/text1")
	self.DisCount = winMgr:getWindow(tostring(prefix) .. "lianyaoshopitem_cell/xianyu1/zhekou_di/zhekou_wb")
	self.OriginalCost = winMgr:getWindow(tostring(prefix) .. "lianyaoshopitem_cell/yuanjianum")
	self.DayLimitNum = winMgr:getWindow(tostring(prefix) .. "lianyaoshopitem_cell/xiangounum")
	self.ItemIcon:subscribeEvent("MouseClick",  GameItemTable.HandleShowToolTipsWithItemID)	
	self.ItemIcon:subscribeEvent("MouseClick", LyShopItemCell.HandleSelectEvent,self)	
	self.Item:subscribeEvent("MouseClick",  LyShopItemCell.HandleSelectEvent,self)	
	self.events={}
end
function LyShopItemCell:registerCallback(func)
	self.events['selected']=func
end
function LyShopItemCell:HandleSelectEvent()
	self.Item:setSelected(true)
 	self.events['selected'](self.info)
 
end
 

function LyShopItemCell:getinfo()
    return self.info
end

function LyShopItemCell:setInfo(info)
	self.info=info
	local item = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(info.itemid)
	if item then
		self.ItemIcon:SetImage(gGetIconManager():GetImageByID(item.icon))
		SetItemCellBoundColorByQulityItemWithId(self.ItemIcon, info.itemid)
		self.ItemIcon:setID(info.itemid)
	end
	self.ItemName:setText(info.name)
	self.OriginalCost:setText(MoneyFormat(info.oprice))
	self.MoneyNum:setText(MoneyFormat(info.curprice))
	self.DisCount:setText(tostring(info.discount))
	self.DayLimitNum:setText(tostring(info.daylimited))
end

function LyShopItemCell:setLimit(val)
	self.DayLimitNum:setText(tostring(self.info.daylimited-val))
end

return LyShopItemCell