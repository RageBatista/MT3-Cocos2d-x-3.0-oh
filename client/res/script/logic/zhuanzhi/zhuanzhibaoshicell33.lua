ZhuanZhiBaoShiCell33 = {}

setmetatable(ZhuanZhiBaoShiCell33, Dialog)
ZhuanZhiBaoShiCell33.__index = ZhuanZhiBaoShiCell33
local prefix = 0

function ZhuanZhiBaoShiCell33.CreateNewDlg(parent)
	local newDlg = ZhuanZhiBaoShiCell33:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function ZhuanZhiBaoShiCell33.GetLayoutFileName()
	return "zhuanzhibaoshicell.layout"
end

function ZhuanZhiBaoShiCell33:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ZhuanZhiBaoShiCell33)
	return self
end

function ZhuanZhiBaoShiCell33:OnCreate(parent)
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

return ZhuanZhiBaoShiCell33