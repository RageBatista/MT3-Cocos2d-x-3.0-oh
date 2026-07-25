require "utils.mhsdutils"
--require "logic.dialog"



JingMaiZhanShi = 
{
}

--setmetatable(JingMaiZhanShi, Dialog)
JingMaiZhanShi.__index = JingMaiZhanShi


function JingMaiZhanShi.GetLayoutFileName()
   -- return "workshopdzpreviewcell.layout"
end


function JingMaiZhanShi.new(parent, posindex,prefix)
	local newcell = {}
	setmetatable(newcell, JingMaiZhanShi)
	newcell.__index = JingMaiZhanShi
	
	newcell:OnCreate(parent,prefix)
	
	local height = newcell.m_pMainFrame:getHeight():asAbsolute(0)
	local offset = height * posindex or 1
	newcell.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, offset)))
	
	return newcell
end

function JingMaiZhanShi:OnCreate(parent, prefix)
	
	if prefix then
		print("JingMaiZhanShi=prefix="..prefix)
	else
		print("JingMaiZhanShi=prefix=nil")
		prefix = ""
	end
	self.parent = parent
	local layoutName = "jingmaizhanshi.layout"
	local winMgr = CEGUI.WindowManager:getSingleton()
	--print("JingMaiZhanShi=prefix="..prefix)
	self.m_pMainFrame = winMgr:loadWindowLayout(layoutName,prefix)
	self.btnBg = CEGUI.toGroupButton(winMgr:getWindow(prefix.."jingmaizhanshi/bg"))
	--toGroupButton
	self.btnBg:EnableClickAni(false)
	self.LabName = winMgr:getWindow(prefix.."jingmaizhanshi/bg/name")
	self.LabJieshao = winMgr:getWindow(prefix.."jingmaizhanshi/bg/jieshao")
	self.LabImage = winMgr:getWindow(prefix.."jingmaizhanshi/bg/image")
    --self.labelProperty3 = winMgr:getWindow(prefix.."xingyinqhpreviewcell/bg/teshudazao1")
	if parent then
	    parent:addChildWindow(self.m_pMainFrame)
    end
	
end


function JingMaiZhanShi:RefreshProperty(strName,strProperty1,strProperty2,strProperty3)
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

function JingMaiZhanShi:DestroyDialog()
	self:OnClose()
end

function JingMaiZhanShi:OnClose()
	if self.parent then
		self.parent:removeChildWindow(self.m_pMainFrame)
	end
	CEGUI.WindowManager:getSingleton():destroyWindow(self.m_pMainFrame)
end


return JingMaiZhanShi
