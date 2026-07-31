LeiTaiShaiXuan = { }

setmetatable(LeiTaiShaiXuan, Dialog)
LeiTaiShaiXuan.__index = LeiTaiShaiXuan
local prefix = 0

function LeiTaiShaiXuan.CreateNewDlg(parent)
    local newDlg = LeiTaiShaiXuan:new()
    newDlg:OnCreate(parent)
    return newDlg
end

function LeiTaiShaiXuan.GetLayoutFileName()
    return "leitaishaixuancell_mtg.layout"
end

function LeiTaiShaiXuan:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, LeiTaiShaiXuan)
    return self
end

function LeiTaiShaiXuan:OnCreate(parent)
    prefix = prefix + 1
    Dialog.OnCreate(self, parent, prefix)

    local winMgr = CEGUI.WindowManager:getSingleton()
    local prefixstr = tostring(prefix)

    self.m_Btn = CEGUI.toPushButton(winMgr:getWindow(prefixstr .. "leitaishaixuancell_mtg/btn1"))
    self.m_Btn:SetMouseLeaveReleaseInput(false)
    self.m_Text = winMgr:getWindow(prefixstr .. "leitaishaixuancell_mtg/text")
end
function LeiTaiShaiXuan:SetInfor(infor)
    if not infor then
        return
    end
    self.m_ID = infor.id
    self.m_Text:setText(infor.name)

    local datamanager = require "logic.leitai.leitaidatamanager"
    if datamanager then
        local schoolConfig = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(self.m_ID)
        if datamanager.m_FilterMode == self.m_ID then
            --self.m_Btn:SetPushState(true)
            if schoolConfig then
                self.m_Btn:setProperty("NormalImage", schoolConfig.pushbtnimage)
                self.m_Btn:setProperty("PushedImage", schoolConfig.pushbtnimage)
            end
            self.m_Btn:setID2(1)
        else
            if schoolConfig then
                self.m_Btn:setProperty("NormalImage", schoolConfig.normalbtnimage)
                self.m_Btn:setProperty("PushedImage", schoolConfig.normalbtnimage)
            end
           -- self.m_Btn:SetPushState(false)
            self.m_Btn:setID2(0)
        end
    end
end

return LeiTaiShaiXuan
