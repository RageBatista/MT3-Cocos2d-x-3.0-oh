familyduizhantext = {}

setmetatable(familyduizhantext, Dialog)
familyduizhantext.__index = familyduizhantext
local prefix = 0

function familyduizhantext.CreateNewDlg(parent)
	local newDlg = familyduizhantext:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function familyduizhantext.GetLayoutFileName()
	return "familyduizhanlist.layout"
end

function familyduizhantext:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, familyduizhantext)
	return self
end

function familyduizhantext:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)
	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr =   tostring(prefix)
    
	self.richBox = CEGUI.toRichEditbox(winMgr:getWindow(prefixstr .. "familyduizhanlist"))
    self.richBox:setMousePassThroughEnabled(true)

end

function familyduizhantext:SetShowContent(content)
    self.richBox:Clear()
	self.richBox:show()
	self.richBox:AppendParseText(CEGUI.String(content))
	self.richBox:Refresh()
	local size = self.richBox:GetExtendSize()
	local vec2 = NewVector2(size.width, size.height+10)
	self.m_width = size.width
	self.m_height = size.height+10
	self.richBox:setSize(vec2) 
end

 

return familyduizhantext