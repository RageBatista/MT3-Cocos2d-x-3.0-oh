require "utils.mhsdutils"
require "logic.dialog"



Tips1 = {}
setmetatable(Tips1, Dialog)
Tips1.__index = Tips1
local _instance;

function Tips1:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, Tips1)
    return self
end

function Tips1:clearList()
end

function Tips1:HandleCellClicked(args)
end

function Tips1:RefreshData(content,title)
    local winMgr = CEGUI.WindowManager:getSingleton()
    	self.bg = winMgr:getWindow("tips1") 
	if title then
		self.title_st = winMgr:getWindow("tips1/huoliduixian")
		self.title_st:setVisible(true)
		self.title_st:setText(title)
	end
	self.richBox = CEGUI.toRichEditbox(winMgr:getWindow("tips1/RichEditbox"))
	self.richBox:setMousePassThroughEnabled(true)
	--[[
	local strDzDeszi = MHSD_UTILS.get_resstring(11019) 
	local contentTbl = {{strID="11019",color="ffffffff"},
	{strID="11020",color="ffffffff"},
	{strID="11021",color="ffffffff"},
	{strID="11022",color="ffffffff"}}
	--]]
	
	local strAllString = content
	local lineCount = 0
	if type(content) == "table" then
		lineCount = table.getn(content)
		strAllString = Tips1:initWithTbl(content)
	else 
		-- ÐÐÊý
		for i, v in string.gmatch(strAllString, "<B/>") do
			lineCount = lineCount + 1
		end
	end
	
	local nBoxHeight = lineCount * 75
		
	--[[
	local strAllString = ""
	local str1 = MHSD_UTILS.get_resstring(11019) 
	local str2 = MHSD_UTILS.get_resstring(11020) 
	local str3 = MHSD_UTILS.get_resstring(11021) 
	local str4 = MHSD_UTILS.get_resstring(11022) 
	local strBreak = "<B></B>"
	strAllString = strAllString.."<T t=\""..str1.."\" c=\"ffffffff\"></T>"
	strAllString = strAllString..strBreak
	strAllString = strAllString.."<T t=\""..str2.."\" c=\"ffffffff\"></T>"
	strAllString = strAllString..strBreak
	strAllString = strAllString.."<T t=\""..str3.."\" c=\"ffffffff\"></T>"
	strAllString = strAllString..strBreak
	strAllString = strAllString.."<T t=\""..str4.."\" c=\"ffffffff\"></T>"
	strAllString = strAllString..strBreak
	--]]
	
	self.richBox:Clear()
	self.richBox:show()
	self.richBox:AppendParseText(CEGUI.String(strAllString))
	self.richBox:Refresh()
	--self.bg:setHeight(CEGUI.UDim(0, nBoxHeight))
	--self.richBox:setHeight(CEGUI.UDim(0, nBoxHeight))
	
	local size = self.richBox:GetExtendSize()
	local vec2 = NewVector2(size.width+10, size.height+10)
	self.richBox:setSize(vec2)
	
	vec2.x.offset = size.width+40
	vec2.y.offset = size.height+80
	self.bg:setSize(vec2)
end

function Tips1:OnCreate(content, title)
    Dialog.OnCreate(self)
	self:RefreshData(content,title)
end

function Tips1:initWithTbl(contentTbl)
	local totalString = ""
	local strBreak = "<B></B>"
	for i = 1, table.getn(contentTbl) do
		local str = MHSD_UTILS.get_resstring(contentTbl[i].strID)
		local color = contentTbl[i].color
		local entry = "<T t=\""..str.."\" c=\""..color.."\"></T>"
		entry = entry..strBreak
		totalString = totalString..entry
	end
	return totalString
end



--//========================================
function Tips1.getInstance(content, title)
    if not _instance then
        _instance = Tips1:new()
        _instance:OnCreate(content, title)
    end
    return _instance
end

function Tips1.getInstanceAndShow(content, title)
    if not _instance then
        _instance = Tips1:new()
        _instance:OnCreate(content, title)
	else
		_instance:SetVisible(true)
        _instance:RefreshData(content,title)
    end
    return _instance
end

function Tips1.getInstanceNotCreate()
    return _instance
end

function Tips1.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end
function Tips1.closeDialog()
	if not _instance then 
		return
	end
	_instance:OnClose()
	_instance = nil
end

function Tips1:OnClose()
	Dialog.OnClose(self)
	_instance = nil
end

function Tips1.getInstanceOrNot()
	return _instance
end

function Tips1.GetLayoutFileName()
    return "tips1.layout"
end

return Tips1
