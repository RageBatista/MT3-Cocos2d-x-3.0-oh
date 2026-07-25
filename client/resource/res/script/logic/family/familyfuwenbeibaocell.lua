Familyfuwenbeibaocell = { }

setmetatable(Familyfuwenbeibaocell, Dialog)
Familyfuwenbeibaocell.__index = Familyfuwenbeibaocell
local prefix = 0

function Familyfuwenbeibaocell.CreateNewDlg(parent)
    local newDlg = Familyfuwenbeibaocell:new()
    newDlg:OnCreate(parent)
    return newDlg
end

function Familyfuwenbeibaocell.GetLayoutFileName()
    return "familyfuwenbeibaocell.layout"
end

function Familyfuwenbeibaocell:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, Familyfuwenbeibaocell)
    return self
end

function Familyfuwenbeibaocell:OnCreate(parent)
    prefix = prefix + 1
    Dialog.OnCreate(self, parent, prefix)
    local winMgr = CEGUI.WindowManager:getSingleton()
    local prefixstr = tostring(prefix)
    self.m_GoodIcon = winMgr:getWindow(prefixstr .. "familyfuwenbeibaocell/item")
end
-- …Ë÷√–≈œ¢
function Familyfuwenbeibaocell:SetInfor(infor)
    self.m_Infor = infor
end

return Familyfuwenbeibaocell
