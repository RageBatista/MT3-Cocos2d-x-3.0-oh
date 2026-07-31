require "logic.dialog"

BusyTextDlg = {}
setmetatable(BusyTextDlg, Dialog)
BusyTextDlg.__index = BusyTextDlg

local _instance
function BusyTextDlg.getInstance()
	if not _instance then
		_instance = BusyTextDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function BusyTextDlg.getInstanceAndShow()
	if not _instance then
		_instance = BusyTextDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function BusyTextDlg.getInstanceNotCreate()
	return _instance
end

function BusyTextDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function BusyTextDlg.ToggleOpenClose()
	if not _instance then
		_instance = BusyTextDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function BusyTextDlg.GetLayoutFileName()
	return "paomadeng_mtg.layout"----跑马灯公告cc254
end

function BusyTextDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, BusyTextDlg)
	return self
end

function BusyTextDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    self.m_richEditBox = CEGUI.toRichEditbox(winMgr:getWindow("paomadeng/richedit"))
    self.m_widthRich = self.m_richEditBox:getWidth().offset
    self.m_bg = winMgr:getWindow("paomadeng")
    self.m_widthOld =0
    self.m_width = 0
    self.m_Msgs ={}
end
function BusyTextDlg:addMsg(msg)
    local size = #self.m_Msgs
    table.insert(self.m_Msgs, msg)
    if msg ~= nil and size <=0 then
        self:CreateNewMsg(msg, 0)
    end
end
function BusyTextDlg:CreateNewMsg(msg, widthOffset)
    local text = msg
	if not string.find(text, "<T") then 
		    text = "<T c=\"FFFFFF00\" t=\""..tostring(msg).."\"></T>"
	end
    self.m_richEditBox:Clear()
             
    if string.find(text, "FF693F00") then
        text = string.gsub(text, "FF693F00", "FFFFF2DF")
    end

    self.m_richEditBox:AppendParseText(CEGUI.String(text))
    self.m_richEditBox:Refresh()
    self.m_richEditBox:setWordWrapping(false)
    self.m_width = self.m_richEditBox:GetExtendSize().width * 0.8 + self.m_bg:getWidth().offset
    
    self.m_widthOld = self.m_width
    self.m_richEditBox:setWidth(CEGUI.UDim(0, self.m_richEditBox:GetExtendSize().width + 100))
    self.m_richEditBox:setPosition(CEGUI.UVector2(CEGUI.UDim(0, self.m_bg:getWidth().offset + widthOffset), self.m_richEditBox:getPosition().y))
    self.m_richEditBox:Refresh()
end
function BusyTextDlg:update(delta)
    local sizeMsg = #self.m_Msgs
    if sizeMsg > 0 then
        if self.m_width <=0 then
            table.remove(self.m_Msgs, 1)
            local size = #self.m_Msgs
            if size <=0 then
                self:SetVisible(false)
            else
                
                self:SetVisible(true)
                local msg = self.m_Msgs[1]
                if msg ~= nil then
                    local width = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(299).value)
                    self:CreateNewMsg(msg, width)
                end
            end
        
        end
        local speed = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(294).value)
        self.m_width = self.m_width - delta * speed / 1000
        self.m_richEditBox:setPosition(CEGUI.UVector2(CEGUI.UDim(0, self.m_richEditBox:getPosition().x.offset - delta * speed / 1000), self.m_richEditBox:getPosition().y))

    else
        self:SetVisible(false)
    end
   
end
return BusyTextDlg