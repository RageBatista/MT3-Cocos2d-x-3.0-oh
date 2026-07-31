require "logic.dialog"
--require "logic.zhuanzhi.JingMaiMainDlgcell"
--require "utils.temputil"

JingMaiMainDlg = {}
setmetatable(JingMaiMainDlg, Dialog)
JingMaiMainDlg.__index = JingMaiMainDlg

local _instance
function JingMaiMainDlg.getInstance()
    if not _instance then
        _instance = JingMaiMainDlg:new()
        _instance:OnCreate()
    end
    return _instance
end

function JingMaiMainDlg.getInstanceAndShow()
    if not _instance then
        _instance = JingMaiMainDlg:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function JingMaiMainDlg.getInstanceNotCreate()
    return _instance
end

function JingMaiMainDlg.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function JingMaiMainDlg.ToggleOpenClose()
    if not _instance then
        _instance = JingMaiMainDlg:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function JingMaiMainDlg.GetLayoutFileName()
    return "jingmaiui.layout"
end

function JingMaiMainDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, JingMaiMainDlg)
    return self
end

function JingMaiMainDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_CloseBtn = CEGUI.toPushButton(winMgr:getWindow("jingmaiui/guanbi"))
    self.m_CloseBtn:subscribeEvent("MouseButtonUp", JingMaiMainDlg.DestroyDialog, self)

end

function JingMaiMainDlg:SetJingMaiMainDlgDlgVisible(bVisible)
    self:SetVisible(bVisible)
end

return JingMaiMainDlg