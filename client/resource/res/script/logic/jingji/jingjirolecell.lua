
Jingjirolecell = {}
Jingjirolecell.__index = Jingjirolecell



function Jingjirolecell.new(parent, posindex,prefix)
	local newcell = {}
	setmetatable(newcell, Jingjirolecell)
	newcell.__index = Jingjirolecell
	newcell:OnCreate(parent, prefix)
	
	local height = newcell.m_pMainFrame:getHeight():asAbsolute(0)
	local offset = height * posindex or 1
	newcell.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, offset)))
	return newcell
end

function Jingjirolecell:GetWindow()
    return self.m_pMainFrame
end

function Jingjirolecell:OnCreate(parent, prefix)
	
	if prefix then
		print("Jingjirolecell=prefix="..prefix)
	else
		print("Jingjirolecell=prefix=nil")
		prefix = ""
	end
	self.parent = parent
	local layoutName = "jingjichangcell.layout"
	local winMgr = CEGUI.WindowManager:getSingleton()
	print("Jingjirolecell=prefix="..prefix)
	self.m_pMainFrame = winMgr:loadWindowLayout(layoutName,prefix)
	
	--familyjiarudiacell/diban

	--self.btnBg = CEGUI.toPushButton(winMgr:getWindow(index..Workshopitemcell.mWndName_btnBg))
	self.btnBg = CEGUI.toGroupButton(winMgr:getWindow(prefix.."jingjichangcell/diban"))
	--toGroupButton
	self.btnBg:EnableClickAni(false) 


	self.imageIconNumber = winMgr:getWindow(prefix.."jingjichangcell/diban/icon") 
    self.labelNumber = winMgr:getWindow(prefix.."jingjichangcell/number") 
    self.labelRoleName = winMgr:getWindow(prefix.."jingjichangcell/play") 
    self.labelScore = winMgr:getWindow(prefix.."jingjichangcell/jifen") 
    self.labelSuccessNum = winMgr:getWindow(prefix.."jingjichangcell/shenglv") 

	local nChildcount = self.btnBg:getChildCount()
	for i = 0, nChildcount - 1 do
		local child = self.btnBg:getChildAtIdx(i)
		child:setMousePassThroughEnabled(true)
	end
	
    if parent then
        parent:addChildWindow(self.m_pMainFrame)
    end
	
end

function Jingjirolecell:DestroyDialog()
	self:OnClose()
end

function Jingjirolecell:OnClose()

	CEGUI.WindowManager:getSingleton():destroyWindow(self.m_pMainFrame)
end
return Jingjirolecell


