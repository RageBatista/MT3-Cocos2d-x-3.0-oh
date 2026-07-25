ZhenfaBookCell = {}

setmetatable(ZhenfaBookCell, Dialog)
ZhenfaBookCell.__index = ZhenfaBookCell
local prefix = 0

local LONG_PRESS_DUR = 0.2 --秒，长按时长
local INCREASE_DUR = 0.2 --秒，自动增长的时间间隔

function ZhenfaBookCell.CreateNewDlg(parent)
	local newDlg = ZhenfaBookCell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function ZhenfaBookCell.GetLayoutFileName()
	return "zhenfabookcell.layout"
end

function ZhenfaBookCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ZhenfaBookCell)
	self.mouseDown = false
	self.autoIncrease = false
	self.elapse = 0
	return self
end

function ZhenfaBookCell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

	self.itemBg = winMgr:getWindow(prefixstr .. "zhenfabookcell/itembg")
	self.image = winMgr:getWindow(prefixstr .. "zhenfabookcell/itembg/img")
	self.useNumBg = winMgr:getWindow(prefixstr .. "zhenfabookcell/itembg/usenumbg")
	self.useNumText = winMgr:getWindow(prefixstr .. "zhenfabookcell/itembg/usenum")
	self.totalNumText = winMgr:getWindow(prefixstr .. "zhenfabookcell/itembg/totoalnum")
	self.name = winMgr:getWindow(prefixstr .. "zhenfabookcell/name")
	self.delBtn = CEGUI.toPushButton(winMgr:getWindow(prefixstr .. "zhenfabookcell/delbtn"))

	self.delBtn:subscribeEvent("Clicked", ZhenfaBookCell.handleDelClicked, self)
	self.itemBg:subscribeEvent("MouseButtonDown", ZhenfaBookCell.handleIconMouseDown, self)
	self.itemBg:subscribeEvent("MouseButtonUp", ZhenfaBookCell.handleIconMouseUp, self)
	self.itemBg:subscribeEvent("MouseLeave", ZhenfaBookCell.handleIconMouseLeave, self)
    self.itemBg:subscribeEvent("MouseMove", ZhenfaBookCell.handleIconMouseLeave, self)
	self:GetWindow():subscribeEvent("WindowUpdate", ZhenfaBookCell.update, self)

	self:refreshCell(false)
end

function ZhenfaBookCell:setItemKey(itemkey)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local item = roleItemManager:FindItemByBagAndThisID(itemkey, fire.pb.item.BagTypes.BAG)
	if item ~= nil then
		self.itemData = item
		self.itemKey = itemkey
		self.image:setProperty("Image", gGetIconManager():GetItemIconPathByID(item:GetBaseObject().icon):c_str())
		self.totalNum = item:GetNum()
		self.totalNumText:setText(self.totalNum)
		self.useNum = 0
		self.useNumText:setText("0/" .. self.totalNum)
		self.name:setText(item:GetName())
	end
end

function ZhenfaBookCell:refreshCell(isSelected)
	self.delBtn:setVisible(isSelected)
	self.useNumBg:setVisible(isSelected)
	self.useNumText:setVisible(isSelected)
	self.totalNumText:setVisible(not isSelected)
end

function ZhenfaBookCell:refreshCount(isAdd)
	if self.useNum == 0 and isAdd == false then
		return
	end
	local newNum = self.useNum + (isAdd and 1 or -1)
	if newNum > self.totalNum then
		self.autoIncrease = false
		return
	end
	
	self.useNum = newNum
	ZhenfaBookChooseDlg.getInstance():onChoosedItemNumChanged(self.itemKey, self.itemData:GetObjectID(), newNum)
	
	if newNum == 0 then
		self:refreshCell(false)
		return
	end
	
	if not self.delBtn:isVisible() then
		self:refreshCell(true)
	end	
	self.useNumText:setText(newNum .. "/" .. self.totalNum)
end

function ZhenfaBookCell:handleDelClicked(args)
	self:refreshCount(false)
end

function ZhenfaBookCell:handleIconMouseDown(args)
	if ZhenfaBookChooseDlg.getInstance().expIsFull then
		return
	end
	self.mouseDown = true
end

function ZhenfaBookCell:handleIconMouseUp(args)
	self.mouseDown = false
	if not self.autoIncrease then
		if ZhenfaBookChooseDlg.getInstance().expIsFull then
			return
		end
		self:refreshCount(true)
	else
		self.autoIncrease = false
		self.elapse = 0
	end
end

function ZhenfaBookCell:handleIconMouseLeave(args)
	print("ZhenfaBookCell:handleIconMouseLeave")
	self.mouseDown = false
	self.autoIncrease = false
	self.elapse = 0
end

function ZhenfaBookCell:update(e)	
	if not self.mouseDown and not self.autoIncrease then
		return
	end
	
	local updateArgs = CEGUI.toUpdateEventArgs(e)
	local elapsed = updateArgs.d_timeSinceLastFrame

	if not self.autoIncrease then
		if self.mouseDown then
			self.elapse = self.elapse+elapsed
			if self.elapse >= LONG_PRESS_DUR then
				self.elapse = 0
				self.mouseDown = false
				self.autoIncrease = true
				self:refreshCount(true)
			end
		end
	else
		if ZhenfaBookChooseDlg.getInstance().expIsFull then
			self.autoIncrease = false
			self.elapse = 0
			return
		end
		self.elapse = self.elapse + elapsed
		if self.elapse >= INCREASE_DUR then
			self.elapse = 0
			self:refreshCount(true)
		end
	end
end

return ZhenfaBookCell
