require "logic.dialog"

Familyqunfaxiaoxidialog = { }
setmetatable(Familyqunfaxiaoxidialog, Dialog)
Familyqunfaxiaoxidialog.__index = Familyqunfaxiaoxidialog

local _instance
function Familyqunfaxiaoxidialog.getInstance()
    if not _instance then
        _instance = Familyqunfaxiaoxidialog:new()
        _instance:OnCreate()
    end
    return _instance
end

function Familyqunfaxiaoxidialog.getInstanceAndShow()
    if not _instance then
        _instance = Familyqunfaxiaoxidialog:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function Familyqunfaxiaoxidialog.getInstanceNotCreate()
    return _instance
end

function Familyqunfaxiaoxidialog.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function Familyqunfaxiaoxidialog.ToggleOpenClose()
    if not _instance then
        _instance = Familyqunfaxiaoxidialog:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function Familyqunfaxiaoxidialog.GetLayoutFileName()
    return "familyqunfaxiaoxidialog.layout"
end

function Familyqunfaxiaoxidialog:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, Familyqunfaxiaoxidialog)
    return self
end

function Familyqunfaxiaoxidialog:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_QunfaText = CEGUI.toRichEditbox(winMgr:getWindow("familyqunfaxiaoxidialog/shurukuang/text"))
    self.m_BtnSendMessage = CEGUI.toPushButton(winMgr:getWindow("familyqunfaxiaoxidialog/fasong"))

    self.m_BtnSendMessage:subscribeEvent("Clicked", Familyqunfaxiaoxidialog.OnClickMessage, self)
    self.m_CloseBtnEx = CEGUI.toPushButton(winMgr:getWindow("familyqunfaxiaoxidialog/close"))
    self.m_CloseBtnEx:subscribeEvent("Clicked", Familyqunfaxiaoxidialog.OnCloseBtnEx, self)
    self.m_TextTips = winMgr:getWindow("familyqunfaxiaoxidialog/shurukuang/tishi")
    self.m_QunfaText:setMaxTextLength(50)
end

-- 点击群发消息
function Familyqunfaxiaoxidialog:OnClickMessage(args)
    -- 发送空字符串时候
    local text = self.m_QunfaText:GetPureText()
    if text == "" then
        local str = MHSD_UTILS.get_msgtipstring(160230)
        GetCTipsManager():AddMessageTip(str)
        return
    end
    local ret = MHSD_UTILS.ShiedText(text)
    if ret then
      GetCTipsManager():AddMessageTipById(142261)
      return
    end
    -- 金钱不足时候
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local money = roleItemManager:GetPackMoney()
    local moneySt = GameTable.common.GetCCommonTableInstance():getRecorder(174)
    if money <tonumber(moneySt.value) then
        local str = MHSD_UTILS.get_msgtipstring(120025)
        GetCTipsManager():AddMessageTip(str)
        return
    end
    local p = require "protodef.fire.pb.clan.cclanmessage":new()
    p.message = text
    require "manager.luaprotocolmanager":send(p)
    Familyqunfaxiaoxidialog.DestroyDialog()
end

-- 点击关闭
function Familyqunfaxiaoxidialog:OnCloseBtnEx(args)
    Familyqunfaxiaoxidialog.DestroyDialog()
end

-- 群发消息提示
function Familyqunfaxiaoxidialog:update(delta)
    local text1 = self.m_QunfaText:GetPureText()
    self.m_TextTips:setVisible(text1 == "")
end

return Familyqunfaxiaoxidialog
