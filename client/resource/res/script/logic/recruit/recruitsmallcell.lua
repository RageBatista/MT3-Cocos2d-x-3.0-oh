recruitsmallcell = {}

setmetatable(recruitsmallcell, Dialog)
recruitsmallcell.__index = recruitsmallcell

function recruitsmallcell.CreateNewDlg(parent, prefix)
	local newDlg = recruitsmallcell:new()
	newDlg:OnCreate(parent,prefix)
	return newDlg
end

function recruitsmallcell.GetLayoutFileName()
	return "recruitsmallcell.layout"
end

function recruitsmallcell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, recruitsmallcell)
	return self
end

function recruitsmallcell:OnCreate(parent,prefix)
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

    self.m_height = self:GetWindow():getPixelSize().height

    self.m_cell = CEGUI.Window.toGroupButton(winMgr:getWindow(prefixstr.."recruitsmallcell"))
    self.m_cell:setGroupID(5)
    self.m_cell:setID(prefix)
	self.m_cell:subscribeEvent("SelectStateChanged", recruitsmallcell.HandleClick, self)
    self.m_data = nil
end
function recruitsmallcell:setData(data)
    self.m_data = data
    self.m_cell:setText(data.name)
end
function recruitsmallcell:HandleClick(e)
    local dlg = require"logic.recruit.recruitdlg".getInstanceNotCreate()
    if dlg then
        if dlg.m_index == 3 then
            dlg.m_dlg:setData(self.m_data)
        end
    end
end
return recruitsmallcell