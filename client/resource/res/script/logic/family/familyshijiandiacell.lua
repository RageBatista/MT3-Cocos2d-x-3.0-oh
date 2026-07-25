Familyshijiandiacell = { }

setmetatable(Familyshijiandiacell, Dialog)
Familyshijiandiacell.__index = Familyshijiandiacell
local prefix = 0

function Familyshijiandiacell.CreateNewDlg(parent)
    local newDlg = Familyshijiandiacell:new()
    newDlg:OnCreate(parent)
    return newDlg
end

function Familyshijiandiacell.GetLayoutFileName()
    return "familyshijiandiacell.layout"
end

function Familyshijiandiacell:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, Familyshijiandiacell)
    return self
end

function Familyshijiandiacell:OnCreate(parent)
    prefix = prefix + 1
    Dialog.OnCreate(self, parent, prefix)

    local winMgr = CEGUI.WindowManager:getSingleton()
    local prefixstr = tostring(prefix)

    self.m_Btn = CEGUI.toGroupButton(winMgr:getWindow(prefixstr .. "familyshijiandiacell/diban"))
    self.m_TimeText = winMgr:getWindow(prefixstr .. "familyshijiandiacell/time")
    self.m_EventString = CEGUI.toRichEditbox(winMgr:getWindow(prefixstr .. "familyshijiandiacell/shijian"))
end

-- …Ë÷√–≈œ¢
function Familyshijiandiacell:SetInfor(infor)
    if infor and self.m_TimeText and self.m_EventString then
        self.m_TimeText:setText(infor.eventtime)
        self.m_EventString:Clear()
        self.m_EventString:AppendParseText(CEGUI.String(infor.eventinfo))
        self.m_EventString:AppendBreak()
        self.m_EventString:Refresh()
        self.m_Type = infor.eventtype
        self.m_RoleID = infor.eventvalue
    end
end

return Familyshijiandiacell
