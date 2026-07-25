recruitcell = {}

setmetatable(recruitcell, Dialog)
recruitcell.__index = recruitcell

function recruitcell.CreateNewDlg(parent, prefix)
	local newDlg = recruitcell:new()
	newDlg:OnCreate(parent, prefix)
	return newDlg
end

function recruitcell.GetLayoutFileName()
	return "recruitcell.layout"
end

function recruitcell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, recruitcell)
	return self
end

function recruitcell:OnCreate(parent, prefix)
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)
    self.m_height = self:GetWindow():getPixelSize().height
    self.m_cell = CEGUI.Window.toGroupButton(winMgr:getWindow(prefixstr.."recruitcell"))
    self.m_cell:setID(prefix)
	self.m_cell:subscribeEvent("SelectStateChanged", recruitcell.HandleClick, self)
    self.m_cell:setText(MHSD_UTILS.get_resstring(11631 + prefix))
end
function recruitcell:HandleClick(e)
    local cell = CEGUI.toWindowEventArgs(e).window
    local id = cell:getID()
    local dlg = require"logic.recruit.recruitdlg".getInstance()
    dlg:Show(id)
end
return recruitcell