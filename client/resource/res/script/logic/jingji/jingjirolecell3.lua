
Jingjirolecell3 = {}
Jingjirolecell3.__index = Jingjirolecell3


function Jingjirolecell3.new(parent, posindex,prefix)
	local newcell = {}
	setmetatable(newcell, Jingjirolecell3)
	newcell.__index = Jingjirolecell3
	newcell:OnCreate(parent, prefix)
	
	local height = newcell.m_pMainFrame:getHeight():asAbsolute(0)
	local offset = height * posindex or 1
	newcell.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, offset)))
	return newcell
end

function Jingjirolecell3:OnCreate(parent, prefix)
	
	if prefix then
		print("Jingjirolecell3=prefix="..prefix)
	else
		print("Jingjirolecell3=prefix=nil")
		prefix = ""
	end
	self.parent = parent
	local layoutName = "jingjichangcell3v3.layout"
	local winMgr = CEGUI.WindowManager:getSingleton()
	print("Jingjirolecell3=prefix="..prefix)
	self.m_pMainFrame = winMgr:loadWindowLayout(layoutName,prefix)
	
	--familyjiarudiacell/diban

	--self.btnBg = CEGUI.toPushButton(winMgr:getWindow(index..Workshopitemcell.mWndName_btnBg))
	self.btnBg = CEGUI.toGroupButton(winMgr:getWindow(prefix.."jingjichangcell3v3/diban"))
	--toGroupButton
	self.btnBg:EnableClickAni(false) 


	self.imageIconNumber = winMgr:getWindow(prefix.."jingjichangcell3v3/diban/icon") 
    self.labelNumber = winMgr:getWindow(prefix.."jingjichangcell3v3/number") 
    self.labelRoleName = winMgr:getWindow(prefix.."jingjichangcell3v3/play") 
    self.labelScore = winMgr:getWindow(prefix.."jingjichangcell3v3/jifen") 
   -- self.labelSuccessNum = winMgr:getWindow(prefix.."jingjichangcell3v3/shenglv") 

	local nChildcount = self.btnBg:getChildCount()
	for i = 0, nChildcount - 1 do
		local child = self.btnBg:getChildAtIdx(i)
		child:setMousePassThroughEnabled(true)
	end
	
    if parent then
    	parent:addChildWindow(self.m_pMainFrame)
    end
	
end

function Jingjirolecell3:DestroyDialog()
	self:OnClose()
end

function Jingjirolecell3:OnClose()
	if self.parent then
		self.parent:removeChildWindow(self.m_pMainFrame)
	end
	CEGUI.WindowManager:getSingleton():destroyWindow(self.m_pMainFrame)
end
return Jingjirolecell3


