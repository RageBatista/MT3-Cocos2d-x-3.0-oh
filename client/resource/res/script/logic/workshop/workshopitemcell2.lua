
Workshopitemcell2 = {}
Workshopitemcell2.__index = Workshopitemcell2

local nWorkshopitemcell2Prefix = 1
function Workshopitemcell2.new(parent, posindex)
    local strPrefix = tostring(nWorkshopitemcell2Prefix)
    nWorkshopitemcell2Prefix = nWorkshopitemcell2Prefix + 1
	local newcell = {}
	setmetatable(newcell, Workshopitemcell2)
	newcell:OnCreate(parent, strPrefix)
	local height = newcell.m_pMainFrame:getHeight():asAbsolute(0)
	local offset = height * posindex or 1
	newcell.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, offset)))
	return newcell
end

function Workshopitemcell2:OnCreate(parent, prefix)
	if prefix then
		print("Workshopitemcell=prefix="..prefix)
	else
		print("Workshopitemcell=prefix=nil")
		prefix = ""
	end
	self.parent = parent
	
	local layoutName = "workshopitemcell2.layout"
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pMainFrame = winMgr:loadWindowLayout(layoutName,prefix)
	
	self.itemCell = CEGUI.Window.toItemCell(winMgr:getWindow(prefix.."workshopitemcell2/back/item"))
	self.labItemName = winMgr:getWindow(prefix.."workshopitemcell2/back/name") 
	self.labBottom1 = winMgr:getWindow(prefix.."workshopitemcell2/back/label1") 
    self.imageAdd = winMgr:getWindow(prefix.."workshopitemcell2/back/item/xqyizhuangbei")  
    self.imageAdd:setVisible(false)
	
	local nChildcount = self.m_pMainFrame:getChildCount()
	for i = 0, nChildcount - 1 do
		local child = self.m_pMainFrame:getChildAtIdx(i)
		child:setMousePassThroughEnabled(true)
	end
    self.m_pMainFrame:setMousePassThroughEnabled(true)
    if parent then
	    parent:addChildWindow(self.m_pMainFrame)
    end
end

function Workshopitemcell2:DestroyDialog()
	self:OnClose()
end

function Workshopitemcell2:OnClose()
	
	CEGUI.WindowManager:getSingleton():destroyWindow(self.m_pMainFrame)
	self = nil
end

return Workshopitemcell2


