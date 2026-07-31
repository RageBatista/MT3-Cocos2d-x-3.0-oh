selectrolecell = {}

setmetatable(selectrolecell, Dialog)
selectrolecell.__index = selectrolecell
local prefix = 0

function selectrolecell.CreateNewDlg(parent)
	local newDlg = selectrolecell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function selectrolecell.GetLayoutFileName()
	return "duofujuesecell.layout"
end

function selectrolecell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, selectrolecell)
	return self
end

function selectrolecell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

	self.groupButton = CEGUI.toGroupButton(winMgr:getWindow(prefixstr .. "duofujuesecell"))
	self.item = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "duofujuesecell/item"))
	self.name = winMgr:getWindow(prefixstr .. "duofujuesecell/name")
	self.level = winMgr:getWindow(prefixstr .. "duofujuesecell/name1")


end

function selectrolecell:setData(name, level, shape)
    self.name:setText(name)
    self.level:setText(tostring(level))
    local config = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(shape)
    local img = gGetIconManager():GetImageByID(config.littleheadID)
    self.item:SetImage(img)
end

return selectrolecell