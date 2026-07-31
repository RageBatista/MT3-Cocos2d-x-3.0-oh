
familyduizhanzuduichildcell = {}
familyduizhanzuduichildcell.__index = familyduizhanzuduichildcell

local nfamilyduizhanzuduicell1Prefix = 1
function familyduizhanzuduichildcell.new(parent, posindex)
    local strPrefix = tostring(nfamilyduizhanzuduicell1Prefix)
    nfamilyduizhanzuduicell1Prefix = nfamilyduizhanzuduicell1Prefix + 1
	local newcell = {}
	setmetatable(newcell, familyduizhanzuduichildcell)
	newcell:OnCreate(parent, strPrefix)
	local height = newcell.m_pMainFrame:getHeight():asAbsolute(0)
	local offset = height * posindex or 1
	newcell.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, offset)))
	return newcell
end

function familyduizhanzuduichildcell:OnCreate(parent, prefix)
	if prefix then
		print("familyduizhanzuduichildcell=prefix="..prefix)
	else
		print("familyduizhanzuduichildcell=prefix=nil")
		prefix = ""
	end
	self.parent = parent
	
	local layoutName 	= "familyduizhanzuduicell1.layout"
	local winMgr 		= CEGUI.WindowManager:getSingleton()
	self.m_pMainFrame   = winMgr:loadWindowLayout(layoutName,prefix)
	
	self.m_item 		= CEGUI.toItemCell(winMgr:getWindow(prefix .. "familyduizhanzuduicell1/item"))  
	self.m_item			:Clear()
	self.m_Eventbtn 	= CEGUI.toGroupButton(winMgr:getWindow(prefix .. "familyduizhanzuduicell1/item/button"));  
	self.m_InfoBg 		= winMgr:getWindow(prefix .. "familyduizhanzuduicell1/kuang")
	self.m_Name 		= winMgr:getWindow(prefix .. "familyduizhanzuduicell1/name")
	self.m_Lv 	    	= winMgr:getWindow(prefix .. "familyduizhanzuduicell1/lv1")
	self.m_TeamIcon 	= winMgr:getWindow(prefix .. "familyduizhanzuduicell1/image")
	
	self.m_AddTeam 		= winMgr:getWindow(prefix .. "familyduizhanzuduicell1/item/jiahao")
	self.m_TipText 		= winMgr:getWindow(prefix .. "familyduizhanzuduicell1/text")
	self.m_AddTeam		:setVisible(false)
	self.m_TipText		:setVisible(false)
	self.m_nTeamid      = -1
	self.m_nTeamLeaderId= -1
	self.m_nMemberid    = -1
	
	
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
 
function familyduizhanzuduichildcell:DestroyDialog()
	self:OnClose()
end

function familyduizhanzuduichildcell:OnClose()
	CEGUI.WindowManager:getSingleton():destroyWindow(self.m_pMainFrame)
	self = nil
end

return familyduizhanzuduichildcell
