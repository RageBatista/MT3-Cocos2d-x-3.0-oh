require "logic.dialog"

Familytichudialog = { }
setmetatable(Familytichudialog, Dialog)
Familytichudialog.__index = Familytichudialog

local _instance
function Familytichudialog.getInstance()
    if not _instance then
        _instance = Familytichudialog:new()
        _instance:OnCreate()
    end

    return _instance
end

function Familytichudialog.getInstanceAndShow()
    if not _instance then
        _instance = Familytichudialog:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function Familytichudialog.getInstanceNotCreate()
    return _instance
end

function Familytichudialog.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function Familytichudialog.ToggleOpenClose()
    if not _instance then
        _instance = Familytichudialog:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function Familytichudialog.GetLayoutFileName()
    return "familytichudialog.layout"
end

function Familytichudialog:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, Familytichudialog)
    return self
end

function Familytichudialog:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
    self.m_TitleText = winMgr:getWindow("familytichudialog/tishi")
    self.m_OkBtn = CEGUI.toPushButton(winMgr:getWindow("familytichudialog/OK"))
    self.m_CheckBox_1 = CEGUI.toCheckbox(winMgr:getWindow("familytichudialog/text1"))
    self.m_CheckBox_2 = CEGUI.toCheckbox(winMgr:getWindow("familytichudialog/text2"))
    self.m_CheckBox_3 = CEGUI.toCheckbox(winMgr:getWindow("familytichudialog/text3"))
    self.m_CheckBox_4 = CEGUI.toCheckbox(winMgr:getWindow("familytichudialog/text4"))

    self.m_CheckBox_1:setID(1)
    self.m_CheckBox_2:setID(2)
    self.m_CheckBox_3:setID(3)
    self.m_CheckBox_4:setID(4)

    self.m_CheckBox_1:subscribeEvent("MouseButtonUp", self.CheckBoxStateChanged, self)
    self.m_CheckBox_2:subscribeEvent("MouseButtonUp", self.CheckBoxStateChanged, self)
    self.m_CheckBox_3:subscribeEvent("MouseButtonUp", self.CheckBoxStateChanged, self)
    self.m_CheckBox_4:subscribeEvent("MouseButtonUp", self.CheckBoxStateChanged, self)

    self.m_CancelBtn = CEGUI.toPushButton(winMgr:getWindow("familytichudialog/close"))

    self.m_OkBtn:subscribeEvent("Clicked", Familytichudialog.OnClickedOk, self)
    self.m_CancelBtn:subscribeEvent("Clicked", Familytichudialog.OnClickedCancel, self)
    self.m_SelectedID = 1
    self.m_CheckBox_1:setSelected(true)
end
function Familytichudialog:ResetCheck()
    self.m_CheckBox_1:setSelected(false)
    self.m_CheckBox_2:setSelected(false)
    self.m_CheckBox_3:setSelected(false)
    self.m_CheckBox_4:setSelected(false)
end
function Familytichudialog:CheckBoxStateChanged(args)
    self:ResetCheck()
    local list =
    {
        [1] = self.m_CheckBox_1,
        [2] = self.m_CheckBox_2,
        [3] = self.m_CheckBox_3,
        [4] = self.m_CheckBox_4
    }
    self.m_SelectedID = CEGUI.toWindowEventArgs(args).window:getID()
    if list[self.m_SelectedID] then
        list[self.m_SelectedID]:setSelected(true)
    end
end
-- 确定按钮
function Familytichudialog:OnClickedOk(args)
    local send = require "protodef.fire.pb.clan.cfiremember":new()
    send.memberroleid = self.m_ID
    send.reasontype = self.m_SelectedID
    require "manager.luaprotocolmanager":send(send)
    self.DestroyDialog()
end
-- 取消按钮
function Familytichudialog:OnClickedCancel(args)
    self.DestroyDialog()
end
function Familytichudialog:RefreshInfor(id, name)
    self.m_ID = id
    self.m_Name = name
    local sb = require "utils.stringbuilder":new()
    local formatstr = MHSD_UTILS.get_msgtipstring(145117)
    sb:Set("parameter1", self.m_Name)
    sb:delete()
    local msg = sb:GetString(formatstr)
    self.m_TitleText:setText(msg)
end

return Familytichudialog
