
workpetitemcell = {}
workpetitemcell.__index = workpetitemcell


workpetitemcell.strImageSelName = "set:common_sangongge4 image:common_equipzhengtu" 
workpetitemcell.mWndName_btnBg = "workpetitemcell/back"
workpetitemcell.mWndName_imageBg = "workpetitemcell/back/level" 
workpetitemcell.mWndName_itemCell = "workpetitemcell/back/item"
workpetitemcell.mWndName_labItemName = "workpetitemcell/back/name"



function workpetitemcell.new(parent, posindex,prefix)
	local newcell = {}
	setmetatable(newcell, workpetitemcell)
	newcell.__index = workpetitemcell
	newcell:OnCreate(parent, prefix)
	
	local height = newcell.m_pMainFrame:getHeight():asAbsolute(0)
	local offset = height * posindex or 1
	newcell.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, offset)))
	return newcell
end

function workpetitemcell:OnCreate(parent, prefix)
	
	if prefix then
		print("workpetitemcell=prefix="..prefix)
	else
		print("workpetitemcell=prefix=nil")
		prefix = ""
	end
	self.parent = parent
	local layoutName = "workpetitemcell.layout"
	local winMgr = CEGUI.WindowManager:getSingleton()
	print("workpetitemcell=prefix="..prefix)
	self.m_pMainFrame = winMgr:loadWindowLayout(layoutName,prefix)
	
	self.btnBg = CEGUI.toGroupButton(winMgr:getWindow(prefix..workpetitemcell.mWndName_btnBg))
	self.btnBg:EnableClickAni(false) 
	self.imageBg = winMgr:getWindow(prefix..workpetitemcell.mWndName_imageBg)  
	self.itemCell = CEGUI.Window.toItemCell(winMgr:getWindow(prefix..workpetitemcell.mWndName_itemCell))
	self.imageHaveEquiped = winMgr:getWindow(prefix..workpetitemcell.mWndName_imageHaveEquiped) 
	self.imageCanMake = winMgr:getWindow(prefix..workpetitemcell.mWndName_imageCanMake) 
	self.labItemName = winMgr:getWindow(prefix..workpetitemcell.mWndName_labItemName) 
	self.labBottom1 = winMgr:getWindow(prefix..workpetitemcell.mWndName_labBottom1) 
	self.labBottom2 = winMgr:getWindow(prefix..workpetitemcell.mWndName_labBottom2) 
	self.imageStone1 = winMgr:getWindow(prefix..workpetitemcell.mWndName_imageStone1) 
	self.imageStone2 = winMgr:getWindow(prefix..workpetitemcell.mWndName_imageStone2) 
	self.imageStone3 = winMgr:getWindow(prefix..workpetitemcell.mWndName_imageStone3) 
	self.labDurance = winMgr:getWindow(prefix..workpetitemcell.mWndName_labDurance) 
	self.imageRed  = winMgr:getWindow(prefix..workpetitemcell.mWndName_imageRed) --workpetitemcell.mWndName_imageRed 

    

	local nChildcount = self.btnBg:getChildCount()
	for i = 0, nChildcount - 1 do
		local child = self.btnBg:getChildAtIdx(i)
		child:setMousePassThroughEnabled(true)
	end
	if parent then
	    parent:addChildWindow(self.m_pMainFrame)
    end
	
end

function workpetitemcell:RefreshVisibleWithType(eType)
	self.imageHaveEquiped:setVisible(false)
	self.imageCanMake:setVisible(false)
	self.labBottom1:setVisible(false)
	self.labBottom2:setVisible(false)
	self.imageStone1:setVisible(false)
	self.imageStone2:setVisible(false)
	self.imageStone3:setVisible(false)
	self.labDurance:setVisible(false)

	self.imageRed:setVisible(false)
	
	if eType == 1 then
		self.labBottom1:setVisible(true)
		self.labBottom2:setVisible(true)
	elseif eType==2 then
		self.imageStone1:setVisible(true)
		self.imageStone2:setVisible(true)
		self.imageStone3:setVisible(true)
	elseif eType==3 then
		self.labBottom1:setVisible(true)
	elseif eType==4 then
		self.labBottom1:setVisible(true)
		self.labDurance:setVisible(true)
	elseif eType==5 then --baoshi
		self.labBottom1:setVisible(true)
	elseif eType==6 then 
	end
end

function workpetitemcell.GetLayoutFileName()
end

function workpetitemcell:DestroyDialog()
	self:OnClose()
end

function workpetitemcell:OnClose()
	if self.parent then
		self.parent:removeChildWindow(self.m_pMainFrame)
	end
	CEGUI.WindowManager:getSingleton():destroyWindow(self.m_pMainFrame)
end
return workpetitemcell


