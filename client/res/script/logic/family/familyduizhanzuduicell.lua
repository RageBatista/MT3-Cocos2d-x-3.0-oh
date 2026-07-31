familyduizhanzuduicell = {}

setmetatable(familyduizhanzuduicell, Dialog)
familyduizhanzuduicell.__index = familyduizhanzuduicell
local prefix = 0

function familyduizhanzuduicell.CreateNewDlg(parent)
	local newDlg = familyduizhanzuduicell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function familyduizhanzuduicell.GetLayoutFileName()
	return "familyduizhanzuduicell.layout"
end

function familyduizhanzuduicell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, familyduizhanzuduicell)
	return self
end

function familyduizhanzuduicell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr    = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)
	
    self.m_width    = self:GetWindow():getPixelSize().width
	self.m_height   = self:GetWindow():getPixelSize().height 

	self.m_item 	= CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "familyduizhanzuduicell/item"))  
	self.m_item:Clear()
  
	self.m_Eventbtn = CEGUI.toGroupButton(winMgr:getWindow(prefixstr .. "familyduizhanzuduicell/item/button"));  
  
	 
	self.m_Name 	= winMgr:getWindow(prefixstr .. "familyduizhanzuduicell/name")
	self.m_Lv 	    = winMgr:getWindow(prefixstr .. "familyduizhanzuduicell/lv1")
	self.m_School 	= winMgr:getWindow(prefixstr .. "familyduizhanzuduicell/image")
	self.m_ID		= 0
end

 
function familyduizhanzuduicell:SetTeamInfo( id, level, name, shapeId , schoolId)
	self.m_ID = id
	local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(shapeId)
	local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
	self.m_item:SetImage(image)
	 
	self.m_Name:setText(name)
	self.m_Lv:setText(tostring(level))
	
	local schoolconf = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(schoolId)
	self.m_School:setProperty("Image", schoolconf.schooliconpath)
end

 
return familyduizhanzuduicell