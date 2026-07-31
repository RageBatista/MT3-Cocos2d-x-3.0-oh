
Workshopdztargetcell = {}
Workshopdztargetcell.__index = Workshopdztargetcell

function Workshopdztargetcell.new(parent, posindex,prefix)
	local newcell = {}
	setmetatable(newcell, Workshopdztargetcell)
	newcell.__index = Workshopdztargetcell
	newcell:OnCreate(parent, prefix)
	
	local height = newcell.m_pMainFrame:getHeight():asAbsolute(0)
	local offset = height * posindex or 1
	newcell.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, offset)))
	
	return newcell
end

function Workshopdztargetcell:OnCreate(parent, prefix)
	
	if prefix then
		print("Workshopdztargetcell=prefix="..prefix)
	else
		print("Workshopdztargetcell=prefix=nil")
		prefix = ""
	end
	self.parent = parent
	local layoutName = "workshopdznewcell2.layout"
	local winMgr = CEGUI.WindowManager:getSingleton()
	--print("Workshopdztargetcell=prefix="..prefix)
	self.m_pMainFrame = winMgr:loadWindowLayout(layoutName,prefix)
	
    self.imageQuality = winMgr:getWindow(prefix.."workshopdznewcell2/tu")  
    self.labelPercent = winMgr:getWindow(prefix.."workshopdznewcell2/shuzhi") 
	
    --[[
	--self.btnBg = CEGUI.toPushButton(winMgr:getWindow(index..Workshopdztargetcell.mWndName_btnBg))
	self.btnBg = CEGUI.toGroupButton(winMgr:getWindow(prefix..Workshopdztargetcell.mWndName_btnBg))
	--toGroupButton
	self.btnBg:EnableClickAni(false) 
	self.imageBg = winMgr:getWindow(prefix..Workshopdztargetcell.mWndName_imageBg)  
	self.itemCell = CEGUI.Window.toItemCell(winMgr:getWindow(prefix..Workshopdztargetcell.mWndName_itemCell))
	self.imageHaveEquiped = winMgr:getWindow(prefix..Workshopdztargetcell.mWndName_imageHaveEquiped) 
	self.imageCanMake = winMgr:getWindow(prefix..Workshopdztargetcell.mWndName_imageCanMake) 
	self.labItemName = winMgr:getWindow(prefix..Workshopdztargetcell.mWndName_labItemName) 
	self.labBottom1 = winMgr:getWindow(prefix..Workshopdztargetcell.mWndName_labBottom1) 
	self.labBottom2 = winMgr:getWindow(prefix..Workshopdztargetcell.mWndName_labBottom2) 
	self.imageStone1 = winMgr:getWindow(prefix..Workshopdztargetcell.mWndName_imageStone1) 
	self.imageStone2 = winMgr:getWindow(prefix..Workshopdztargetcell.mWndName_imageStone2) 
	self.labDurance = winMgr:getWindow(prefix..Workshopdztargetcell.mWndName_labDurance) 
	self.imageRed  = winMgr:getWindow(prefix..Workshopdztargetcell.mWndName_imageRed) --Workshopdztargetcell.mWndName_imageRed 
     

	local nChildcount = self.m_pMainFrame:getChildCount()
	for i = 0, nChildcount - 1 do
		local child = self.m_pMainFrame:getChildAtIdx(i)
		child:setMousePassThroughEnabled(true)
	end
   --]]
	if parent then
	    parent:addChildWindow(self.m_pMainFrame)
    end
	
end


function Workshopdztargetcell:DestroyDialog()
	self:OnClose()
end

function Workshopdztargetcell:OnClose()
	if self.parent then
		self.parent:removeChildWindow(self.m_pMainFrame)
	end
	CEGUI.WindowManager:getSingleton():destroyWindow(self.m_pMainFrame)
end
return Workshopdztargetcell


