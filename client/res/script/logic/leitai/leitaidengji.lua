LeiTaiDengji = { }

setmetatable(LeiTaiDengji, Dialog)
LeiTaiDengji.__index = LeiTaiDengji
local prefix = 0

function LeiTaiDengji.CreateNewDlg(parent)
    local newDlg = LeiTaiDengji:new()
    newDlg:OnCreate(parent)
    return newDlg
end

function LeiTaiDengji.GetLayoutFileName()
    return "leitaidengjishaixuancell_mtg.layout"
end

function LeiTaiDengji:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, LeiTaiDengji)
    return self
end

function LeiTaiDengji:OnCreate(parent)
    prefix = prefix + 1
    Dialog.OnCreate(self, parent, prefix)

    local winMgr = CEGUI.WindowManager:getSingleton()
    local prefixstr = tostring(prefix)

    self.m_Btn = CEGUI.toPushButton(winMgr:getWindow(prefixstr .. "leitaishaixuancell_mtg/btn1"))
    self.m_Btn:SetMouseLeaveReleaseInput(false)

end
function LeiTaiDengji:SetInfor(infor)
    self.m_ID = infor.id
    self.m_Btn:setText(tostring(infor.levelmin) .. "~" .. tostring(infor.levelmax))


    local datamanager = require "logic.leitai.leitaidatamanager"
    if datamanager then
        if datamanager.m_LevelArea == self.m_ID then
            self.m_Btn:SetPushState(true)
            self.m_Btn:setID2(1)
        else
            self.m_Btn:SetPushState(false)
            self.m_Btn:setID2(0)
        end
    end
end

return LeiTaiDengji
