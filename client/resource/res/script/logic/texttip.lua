-------------------------------------------------------------------------------------------
-- example:
-- <T t='hello world, hello world'></T><B/>$dot$<T t='hello'></T><B/>$dot$<T t='world'></T>
-------------------------------------------------------------------------------------------
TextTip = {}
setmetatable(TextTip, Dialog)
TextTip.__index = TextTip
local prefix = 0

function TextTip.CreateNewDlg(parent)
	local newDlg = TextTip:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function TextTip.GetLayoutFileName()
	return "texttip.layout"
end

function TextTip:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, TextTip)
	return self
end

function TextTip:OnClose()
    Dialog.OnClose(self)
end

function TextTip:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

	self.back = winMgr:getWindow(prefixstr .. "texttip/back")
	self.editbox = CEGUI.toRichEditbox(winMgr:getWindow(prefixstr .. "texttip/editbox"))
	
	self:GetWindow():subscribeEvent("MouseButtonDown", TextTip.OnClose, self)
	SetPositionScreenCenter(self.back)
end

function TextTip:setTipText(str)
	str = string.gsub(str, "%$dot%$", "<I s='common' i='common_dian'></I><T t=' '></T>")
	self.editbox:AppendParseText(CEGUI.String(str))
	self.editbox:Refresh()
	
	local size = self.editbox:GetExtendSize()
	local vec2 = NewVector2(size.width+10, size.height+10)
	self.editbox:setSize(vec2)
	
	vec2.x.offset = size.width+40
	vec2.y.offset = size.height+40
	self.back:setSize(vec2)
	
	SetPositionScreenCenter(self.back)
end

function TextTip:setTipTextByID(id)
	self:setTipText(MHSD_UTILS.get_msgtipstring(id))
end

return TextTip
