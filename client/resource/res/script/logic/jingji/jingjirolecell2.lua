
require "logic.dialog"

Jingjirolecell2 = {}
setmetatable(Jingjirolecell2, Dialog)
Jingjirolecell2.__index = Jingjirolecell2


function Jingjirolecell2.create(parent,prefix)
	local newcell = Jingjirolecell2:new()
	newcell:OnCreate(parent, prefix)
	return newcell
end

function Jingjirolecell2:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Jingjirolecell2)
	return self
end

function Jingjirolecell2.GetLayoutFileName()
    return "jingjichangcell.layout"
end


function Jingjirolecell2:OnCreate(parent, prefix)
	
    Dialog.OnCreate(self,parent,prefix)
	if prefix then
		print("Jingjirolecell2=prefix="..prefix)
	else
		print("Jingjirolecell2=prefix=nil")
		prefix = ""
	end
	self.parent = parent
    local winMgr = CEGUI.WindowManager:getSingleton()
	self.btnBg = CEGUI.toGroupButton(winMgr:getWindow(prefix.."jingjichangcell/diban"))
    
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
	
	--parent:addChildWindow(self.m_pMainFrame)
	
end



return Jingjirolecell2


