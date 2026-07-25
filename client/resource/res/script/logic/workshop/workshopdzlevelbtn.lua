require "utils.mhsdutils"
require "logic.dialog"

Workshopdzlevelbtn = 
{
	id=0
}
setmetatable(Workshopdzlevelbtn, Dialog)
Workshopdzlevelbtn.__index = Workshopdzlevelbtn

----/////////////////////////////////////////------
function Workshopdzlevelbtn.GetLayoutFileName()
    return "workshopdzlevelbtn.layout"
end


function Workshopdzlevelbtn.new(parent, posindex)
	local newcell = {}
	setmetatable(newcell, Workshopdzlevelbtn)
	newcell.__index = Workshopdzlevelbtn
	
	newcell:OnCreate(parent, Workshopdzlevelbtn.id)
	local height = newcell.m_pMainFrame:getHeight():asAbsolute(0)
	local offset = height * posindex or 1
	newcell.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, offset)))
	Workshopdzlevelbtn.id = Workshopdzlevelbtn.id + 1
	return newcell
end

function Workshopdzlevelbtn:OnCreate(parent, index)
	Dialog.OnCreate(self, parent, index)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.labTitle = winMgr:getWindow(index.."workshopdzlevelbtn/btn/jishu")
	self.btnBg = CEGUI.toPushButton(winMgr:getWindow(index.."workshopdzlevelbtn/btn"))
	self.btnBg:subscribeEvent("MouseClick", Workshopdzlevelbtn.HandleSelLevelBtnClicked, self)
	self.nLevelArea = 10* (index+1)
	local strLevel = MHSD_UTILS.get_resstring(351)
	local strShowTitle = self.nLevelArea..strLevel
	self.labTitle:setText(strShowTitle)
	local nChildcount = self.btnBg:getChildCount()
	for i = 0, nChildcount - 1 do
		local child = self.btnBg:getChildAtIdx(i)
		child:setMousePassThroughEnabled(true)
	end
	--self.btnBg:setMousePassThroughEnabled(true)
end

function Workshopdzlevelbtn:HandleSelLevelBtnClicked(e)
	if not self.listDlg then
		return
	end
	self.listDlg:RefreshLevelArea(self.nLevelArea)
end

return Workshopdzlevelbtn
