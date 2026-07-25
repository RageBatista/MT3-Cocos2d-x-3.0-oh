bingfengwangzuozhiyecell = {}

setmetatable(bingfengwangzuozhiyecell, Dialog)
bingfengwangzuozhiyecell.__index = bingfengwangzuozhiyecell
local prefix = 0

function bingfengwangzuozhiyecell.CreateNewDlg(parent)
	local newDlg = bingfengwangzuozhiyecell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function bingfengwangzuozhiyecell.GetLayoutFileName()
	return "bingfengwangzuomenpaicell_mtg.layout"
end

function bingfengwangzuozhiyecell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, bingfengwangzuozhiyecell)
	return self
end

function bingfengwangzuozhiyecell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

	self.btn = CEGUI.toPushButton(winMgr:getWindow(prefixstr .. "bingfengwangzuomenpaicell_mtg"))
	self.schoolName = winMgr:getWindow(prefixstr .. "bingfengwangzuobtncell_mtg/schoolName")
	self.icon = winMgr:getWindow(prefixstr .. "bingfengwangzuomenpaicell_mtg/icon")
  --  self.btn = CEGUI.toPushButton(winMgr:getWindow(prefixstr .. "bingfengwangzuomenpaicell_mtg"))
end

return bingfengwangzuozhiyecell
