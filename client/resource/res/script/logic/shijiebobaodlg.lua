require "logic.dialog"

ShiJieBoBaoDlg = { }
setmetatable(ShiJieBoBaoDlg, Dialog)
ShiJieBoBaoDlg.__index = ShiJieBoBaoDlg

local STATE_HIDING = "hiding"
local STATE_MOVING = "moving"
local STATE_SHOWING = "showing"
local STATE_ENDING = "ending"

local _instance
function ShiJieBoBaoDlg.getInstance()
    if not _instance then
        _instance = ShiJieBoBaoDlg:new()
        _instance:OnCreate()
    end
    return _instance
end

function ShiJieBoBaoDlg.getInstanceAndShow()
    if not _instance then
        _instance = ShiJieBoBaoDlg:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function ShiJieBoBaoDlg.getInstanceNotCreate()
    return _instance
end

function ShiJieBoBaoDlg.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function ShiJieBoBaoDlg.ToggleOpenClose()
    if not _instance then
        _instance = ShiJieBoBaoDlg:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function ShiJieBoBaoDlg.GetLayoutFileName()
    return "shijiebobao_mtg.layout"
end

function ShiJieBoBaoDlg:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, ShiJieBoBaoDlg)
    return self
end

function ShiJieBoBaoDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_editbox =  CEGUI.toRichEditbox(winMgr:getWindow("shijiebobao/richedit"))
    self.m_boxSize = self.m_editbox:getPixelSize().height
    self.m_editboxOrgScreenPos = self.m_editbox:GetScreenPos()
    self.m_editboxOrgPos = self.m_editbox:getPosition()
    self:resetPos()

    self.m_sysMsg = { }
    self.m_dlgState = STATE_HIDING
    self.m_curMsgTotalTime = 0
    self.m_curMsgStartTime = 0

    self.m_editbox:setReadOnly(true)
    self:GetWindow():setTopMost(true)
    self:SetVisible(false)
   
end 

function ShiJieBoBaoDlg.addMsg(msg)
    if _instance then
       table.insert(_instance.m_sysMsg, msg)
        _instance:checkShowNextMsg()
    end
end

function ShiJieBoBaoDlg:addBoBaoMsg(msg)
    ShiJieBoBaoDlg.addMsg(msg)
end

function ShiJieBoBaoDlg:resetPos()
     self.m_editbox:setYPosition(CEGUI.UDim(1, self.m_boxSize))
end

function ShiJieBoBaoDlg:update(delta)
    if _instance == nil then
        return
    end

    if self.m_dlgState == STATE_HIDING or self.m_dlgState == STATE_ENDING then
        return
    end

    if self.m_dlgState == STATE_SHOWING or self.m_dlgState == STATE_MOVING then
        self.m_curMsgStartTime = self.m_curMsgStartTime + delta

        if self.m_dlgState == STATE_MOVING then
            local size = self.m_editbox:getSize()
            local curpos = self.m_editbox:getPosition()

            curpos.y.offset = curpos.y.offset - 5
            self.m_editbox:setPosition(curpos)
            self.m_editbox:setSize(size)
            local boxScreenPos = self.m_editbox:GetScreenPos()
            if math.abs(boxScreenPos.y - self.m_editboxOrgScreenPos.y) <= 10 then
                self.m_editbox:setPosition(self.m_editboxOrgPos)
                self.m_dlgState = STATE_SHOWING
            end
        end

        if self.m_curMsgStartTime > self.m_curMsgTotalTime then
            self.m_dlgState = STATE_ENDING
            self:SetVisible(false)
            self:resetPos()
            self.m_curMsgStartTime = 0
            self.m_curMsgTotalTime = 0
            self:checkShowNextMsg()
        end
    end

end

function ShiJieBoBaoDlg:checkShowNextMsg()
    local size = #self.m_sysMsg
    if size > 1 then
        self.m_curMsgTotalTime = 3000
    elseif size == 1 then
        self.m_curMsgTotalTime = 5000
    elseif size <= 0 then
        self.m_dlgState = STATE_HIDING
        self:SetVisible(false)
        return
    end

    if self.m_dlgState == STATE_HIDING or self.m_dlgState == STATE_ENDING then
        local msg = table.remove(self.m_sysMsg, 1)

        if msg ~= nil then
            self:SetVisible(true)
            local text = msg
	        if not string.find(text, "<T") then 
		         text = "<T c=\"FFFFFF00\" t=\""..tostring(msg).."\"></T>"
	        end
            self.m_editbox:Clear()
             
            if string.find(text, "FF693F00") then
                text = string.gsub(text, "FF693F00", "FFFFF2DF")
            end

            self.m_editbox:AppendParseText(CEGUI.String(text))
            self.m_editbox:Refresh()
            local textWidth = self.m_editbox:GetExtendSize().width
            self.m_editbox:setPosition(CEGUI.UVector2(CEGUI.UDim(0.5, -textWidth * 0.5), CEGUI.UDim(1, self.m_boxSize)))

            self.m_dlgState = STATE_MOVING
        end
    end

end

return ShiJieBoBaoDlg
