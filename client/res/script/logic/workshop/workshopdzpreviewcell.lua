require "utils.mhsdutils"
--require "logic.dialog"



Workshopdzpreviewcell = 
{
}

--setmetatable(Workshopdzpreviewcell, Dialog)
Workshopdzpreviewcell.__index = Workshopdzpreviewcell


function Workshopdzpreviewcell.GetLayoutFileName()
   -- return "workshopdzpreviewcell.layout"
end


function Workshopdzpreviewcell.new(parent, posindex,prefix)
	local newcell = {}
	setmetatable(newcell, Workshopdzpreviewcell)
	newcell.__index = Workshopdzpreviewcell
	
	newcell:OnCreate(parent,prefix)
	
	local height = newcell.m_pMainFrame:getHeight():asAbsolute(0)
	local offset = height * posindex or 1
	newcell.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, offset)))
	
	return newcell
end

function Workshopdzpreviewcell:OnCreate(parent, prefix)
	
	if prefix then
		print("Workshopdzpreviewcell=prefix="..prefix)
	else
		print("Workshopdzpreviewcell=prefix=nil")
		prefix = ""
	end
	self.parent = parent
	local layoutName = "workshopdzpreviewcell.layout"
	local winMgr = CEGUI.WindowManager:getSingleton()
	--print("Workshopdzpreviewcell=prefix="..prefix)
	self.m_pMainFrame = winMgr:loadWindowLayout(layoutName,prefix)	
	
	self.LabName = winMgr:getWindow(prefix.."workshopdzpreviewcell/bg/wulishanghai")
	self.labelProperty1 = winMgr:getWindow(prefix.."workshopdzpreviewcell/bg/putongdazao")
	self.labelProperty2 = winMgr:getWindow(prefix.."workshopdzpreviewcell/bg/teshudazao")
    self.labelProperty3 = winMgr:getWindow(prefix.."workshopdzpreviewcell/bg/teshudazao1")
	if parent then
	    parent:addChildWindow(self.m_pMainFrame)
    end
	
end


function Workshopdzpreviewcell:RefreshProperty(strName,strProperty1,strProperty2,strProperty3)
	if strName then
		self.LabName:setText(strName)
	end

	if strProperty1 then
		self.labelProperty1:setText(strProperty1)
	end

	if strProperty2 then
		self.labelProperty2:setText(strProperty2)
	end

    if strProperty3 then
		self.labelProperty3:setText(strProperty3)
	end
end

function Workshopdzpreviewcell:DestroyDialog()
	self:OnClose()
end

function Workshopdzpreviewcell:OnClose()
	if self.parent then
		self.parent:removeChildWindow(self.m_pMainFrame)
	end
	CEGUI.WindowManager:getSingleton():destroyWindow(self.m_pMainFrame)
end


return Workshopdzpreviewcell
