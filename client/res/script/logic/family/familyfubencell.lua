familyfubencell = {}

setmetatable(familyfubencell, Dialog)
familyfubencell.__index = familyfubencell
local prefix = 0

function familyfubencell.CreateNewDlg(parent)
	local newDlg = familyfubencell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function familyfubencell.GetLayoutFileName()
	return "gonghuifubenguanlicell.layout"
end

function familyfubencell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, familyfubencell)
	return self
end

function familyfubencell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

	self.name = winMgr:getWindow(prefixstr .. "gonghuifubencell/fubenmingcheng")
	self.tips = CEGUI.toPushButton(winMgr:getWindow(prefixstr .. "gonghuifubencell/tips"))
	self.checkbox = CEGUI.toCheckbox(winMgr:getWindow(prefixstr .. "gonghuifubencell/gouxuankuang"))
    self.tips:subscribeEvent("MouseClick", familyfubencell.OnClickedExplainBtn, self)
end

function familyfubencell:SetCellInfo(name)
    self.name:setText(name)
    self.fubenName = name
end

function familyfubencell:OnClickedExplainBtn(args)
	self.tips1 = require "logic.workshop.tips1"
	local strTitle = MHSD_UTILS.get_resstring(11513) 
	local strContent = MHSD_UTILS.get_resstring(11511) 
    strContent = string.gsub(strContent, "%$parameter1%$", self.fubenName)
	self.tips1.getInstanceAndShow(strContent, strTitle)
    return true
end


return familyfubencell