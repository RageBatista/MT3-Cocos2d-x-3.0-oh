ZhuanZhiWuQiCell = {}

setmetatable(ZhuanZhiWuQiCell, Dialog)
ZhuanZhiWuQiCell.__index = ZhuanZhiWuQiCell
local prefix = 0

function ZhuanZhiWuQiCell.CreateNewDlg(parent)
	local newDlg = ZhuanZhiWuQiCell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function ZhuanZhiWuQiCell.GetLayoutFileName()
	return "zhuanzhiwuqicell.layout"
end

function ZhuanZhiWuQiCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ZhuanZhiWuQiCell)
	return self
end

function ZhuanZhiWuQiCell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)
	self.btnBg = CEGUI.toGroupButton(winMgr:getWindow(prefixstr .. "zhuanzhiwuqicell"))
	self.itemCell = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "zhuanzhiwuqicell/daojukuang"))
	self.name = winMgr:getWindow(prefixstr .. "zhuanzhiwuqicell/mingcheng")
	self.name1 = winMgr:getWindow(prefixstr .. "zhuanzhiwuqicell/lv")

end

return ZhuanZhiWuQiCell