ZhuanZhiBaoShiCell = {}

setmetatable(ZhuanZhiBaoShiCell, Dialog)
ZhuanZhiBaoShiCell.__index = ZhuanZhiBaoShiCell
local prefix = 0

function ZhuanZhiBaoShiCell.CreateNewDlg(parent)
	local newDlg = ZhuanZhiBaoShiCell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function ZhuanZhiBaoShiCell.GetLayoutFileName()
	return "zhuanzhibaoshicell.layout"
end

function ZhuanZhiBaoShiCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ZhuanZhiBaoShiCell)
	return self
end

function ZhuanZhiBaoShiCell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

	self.btnBg = CEGUI.toGroupButton(winMgr:getWindow(prefixstr .. "zhuanzhibaoshicell"))
	self.itemCell = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "zhuanzhibaoshicell/daojukuang"))
	self.num = winMgr:getWindow(prefixstr .. "zhuanzhibaoshicell/daojukuang/shuliang")
	self.name = winMgr:getWindow(prefixstr .. "zhuanzhibaoshicell/mingcheng")
	self.describe = winMgr:getWindow(prefixstr .. "zhuanzhibaoshicell/miaoshu")
	self.level = winMgr:getWindow(prefixstr .. "zhuanzhibaoshicell/mingchengLv")
	--self.value = winMgr:getWindow(prefixstr .. "baoshihechengcell/miaoshushuzhi")

end

return ZhuanZhiBaoShiCell