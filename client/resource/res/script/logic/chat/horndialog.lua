require "logic.dialog"

HornDlg = { }
setmetatable(HornDlg, Dialog)
HornDlg.__index = HornDlg

local HORN_TEXT_MAX_LENGTH = 100
local HORN_MONEY_COST = 200
local HORN_PENDING_TIMEOUT_MS = 10000
local HORN_REFRESH_INTERVAL_MS = 500
local HORN_HISTORY_MAX = 30

local _instance
local _historyRecords = {}

local function trimText(text)
    if not text or text == "" then
        return ""
    end
    text = string.gsub(text, "^[%s%c]+", "")
    text = string.gsub(text, "[%s%c]+$", "")
    return text
end

local function safeText(text)
    if not text then
        return ""
    end
    text = string.gsub(text, "[\r\n]+", " ")
    return trimText(text)
end

function HornDlg.AddHistoryRecord(senderName, content, broadcastType)
    local sender = safeText(senderName)
    local msg = safeText(content)
    if msg == "" then
        return
    end

    local prefix = "本服"
    if tonumber(broadcastType) == 2 then
        prefix = "全服"
    end

    local line = "【" .. prefix .. "】" .. sender .. "：" .. msg
    table.insert(_historyRecords, line)
    while #_historyRecords > HORN_HISTORY_MAX do
        table.remove(_historyRecords, 1)
    end

    local dlg = HornDlg.getInstanceNotCreate()
    if dlg and dlg.refreshHistoryPanel then
        dlg:refreshHistoryPanel()
    end
end

function HornDlg.getInstance()
    if not _instance then
        _instance = HornDlg:new()
        _instance:OnCreate()
    end
    return _instance
end

function HornDlg.getInstanceAndShow(parent)
    if not _instance then
        _instance = HornDlg:new()
        _instance:OnCreate(parent)
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function HornDlg.getInstanceNotCreate()
    return _instance
end

function HornDlg.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function HornDlg.ToggleOpenClose()
    if not _instance then
        _instance = HornDlg:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function HornDlg.GetLayoutFileName()
    return "horndialog.layout"
end

function HornDlg:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, HornDlg)
    self.m_isSending = false
    self.m_sendPendingMs = 0
    self.m_refreshTickMs = 0
    self.m_lastPreviewText = nil
    self.m_broadcastType = 1
    return self
end

function HornDlg:getPureInputText()
    if not self.m_text then
        return ""
    end
    return self.m_text:GetPureText() or ""
end

function HornDlg:getInputCharCount()
    if not self.m_text then
        return 0
    end
    if self.m_text.GetCharCount then
        return self.m_text:GetCharCount()
    end
    return string.len(self:getPureInputText())
end

function HornDlg:getOwnSilverCount()
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    if not roleItemManager then
        return 0
    end
    return roleItemManager:GetPackMoney() or 0
end

function HornDlg:applyInputColour(colourHex)
    if not self.m_text or not colourHex or colourHex == "" then
        return
    end
    self.m_text:setProperty("NormalTextColour", colourHex)
    self.m_text:setProperty("SelectedTextColour", colourHex)
    self.m_text:setProperty("ActiveSelectionColour", colourHex)
    self.m_text:SetColourRect(CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(colourHex)))
end

function HornDlg:refreshTipState()
    if self.m_tip then
        self.m_tip:setVisible(self:getPureInputText() == "")
    end
end

function HornDlg:refreshContentPreview()
    if not self.m_previewBox then
        return
    end
    local content = self:getPureInputText()
    if content == self.m_lastPreviewText then
        return
    end
    self.m_lastPreviewText = content
    self.m_previewBox:setText(content)
end

function HornDlg:refreshBroadcastHint()
    if self.m_timerText then
        self.m_timerText:setText("本服播放传音持续 8 秒")
    end
end

function HornDlg:refreshConsumePanel()
    local ownMoney = self:getOwnSilverCount()
    if self.m_costText then
        self.m_costText:setText("消耗银币 " .. tostring(HORN_MONEY_COST))
    end
    if self.m_ownText then
        self.m_ownText:setText("拥有银币 " .. tostring(ownMoney))
    end
end

function HornDlg:refreshHistoryPanel()
    if not self.m_historyBox then
        return
    end

    local text = "暂无历史消息"
    if #_historyRecords > 0 then
        text = table.concat(_historyRecords, "\n")
    end

    self.m_historyBox:setText(text)
end

function HornDlg:setSendingState(isSending)
    self.m_isSending = isSending and true or false
    self.m_sendPendingMs = 0
    if self.m_sendBtn then
        self.m_sendBtn:setEnabled(not self.m_isSending)
    end
end

function HornDlg:validateSendInput()
    local content = self:getPureInputText()
    if trimText(content) == "" then
        GetCTipsManager():AddMessageTipById(200004)
        return false
    end
    if self:getInputCharCount() > HORN_TEXT_MAX_LENGTH then
        GetCTipsManager():AddMessageTipById(200004)
        return false
    end
    return true
end

function HornDlg:validateConsumeEnough()
    local ownMoney = self:getOwnSilverCount()
    if ownMoney < HORN_MONEY_COST then
        local tipMsg = nil
        if MHSD_UTILS and MHSD_UTILS.get_msgtipstring then
            tipMsg = MHSD_UTILS.get_msgtipstring(120025)
        end
        if tipMsg and tipMsg ~= "" then
            GetCTipsManager():AddMessageTip(tipMsg)
        else
            GetCTipsManager():AddMessageTip("银币不足")
        end
        return false
    end
    return true
end

function HornDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.closeBtn = CEGUI.toPushButton(winMgr:getWindow("gonghuixiangqing/jiemian/guanbi"))
    self.m_text = CEGUI.toRichEditbox(winMgr:getWindow("gonghuixiangqing/jiemian/xuanyan/wenben"))
    self.m_tip = winMgr:getWindow("gonghuixiangqing/jiemian/xuanyan/tishi")
    self.m_sendBtn = CEGUI.toPushButton(winMgr:getWindow("gonghuixiangqing/jiemian/lianxihuizhang"))
    self.m_colorBtn = CEGUI.toPushButton(winMgr:getWindow("gonghuixiangqing/jiemian/icon_color"))
    self.m_emoteBtn = CEGUI.toPushButton(winMgr:getWindow("gonghuixiangqing/jiemian/icon_emote"))
    self.m_previewBox = winMgr:getWindow("gonghuixiangqing/jiemian/preview_box")
    self.m_timerText = winMgr:getWindow("gonghuixiangqing/jiemian/timer_text")
    self.m_costText = winMgr:getWindow("gonghuixiangqing/jiemian/cost_text")
    self.m_ownText = winMgr:getWindow("gonghuixiangqing/jiemian/own_text")
    self.m_historyBox = winMgr:getWindow("gonghuixiangqing/jiemian/history_box")

    self.m_hornColorOptions = {
        {name = "绿色", textHex = "ff00ff00", protocolColor = 2},
        {name = "黄色", textHex = "ffffff00", protocolColor = 1},
    }
    self.m_selectedColorIndex = 1

    self.m_text:setMaxTextLength(HORN_TEXT_MAX_LENGTH)
    self.m_text:SetForceHideVerscroll(false)
    self.m_text:subscribeEvent("KeyboardTargetWndChanged", HornDlg.HandleIdeaKeyboardTargetWndChanged, self)
    pcall(function()
        self.m_text:subscribeEvent("TextChanged", HornDlg.OnHornTextChanged, self)
    end)
    if self.m_historyBox then
        pcall(function()
            self.m_historyBox:setReadOnly(true)
        end)
        pcall(function()
            self.m_historyBox:SetForceHideVerscroll(false)
        end)
        pcall(function()
            self.m_historyBox:setWordWrapping(true)
        end)
    end

    self.closeBtn:subscribeEvent("Clicked", HornDlg.OnClickedCloseBtn, self)
    self.m_sendBtn:subscribeEvent("Clicked", HornDlg.OnClickedSendBtn, self)
    if self.m_colorBtn then
        self.m_colorBtn:subscribeEvent("Clicked", HornDlg.OnClickedColorBtn, self)
    end
    if self.m_emoteBtn then
        self.m_emoteBtn:subscribeEvent("Clicked", HornDlg.OnClickedEmoteBtn, self)
    end

    self:setSendingState(false)
    self:applyInputColour(self.m_hornColorOptions[self.m_selectedColorIndex].textHex)
    self:refreshBroadcastHint()
    self:refreshConsumePanel()
    self:refreshTipState()
    self:refreshContentPreview()
    self:refreshHistoryPanel()
end

function HornDlg:HandleIdeaKeyboardTargetWndChanged(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    if wnd == self.m_text then
        if self.m_tip then
            self.m_tip:setVisible(false)
        end
    else
        self:refreshTipState()
    end
    self:refreshContentPreview()
end

function HornDlg:OnHornTextChanged(args)
    self:refreshTipState()
    self:refreshContentPreview()
end

function HornDlg:OnClickedCloseBtn(args)
    HornDlg.DestroyDialog()
end

function HornDlg:OnClickedColorBtn(args)
    self.m_selectedColorIndex = self.m_selectedColorIndex + 1
    if self.m_selectedColorIndex > #self.m_hornColorOptions then
        self.m_selectedColorIndex = 1
    end
    local colour = self.m_hornColorOptions[self.m_selectedColorIndex]
    self:applyInputColour(colour.textHex)
    self:refreshContentPreview()
    return true
end

function HornDlg:OnInsertDlgCallBack(insertDlg, nType, nKey)
    local chatManager = GetChatManager()
    if not chatManager or not self.m_text then
        return
    end

    local insertType = require("logic.chat.insertdlg").eFunType
    if insertType.emotion == nType then
        chatManager:inputCallBack_emotion(insertDlg, nType, nKey, self.m_text)
    elseif insertType.normalChat == nType then
        chatManager:inputCallBack_normalChat(insertDlg, nType, nKey, self.m_text)
    elseif insertType.history == nType then
        chatManager:inputCallBack_history(insertDlg, nType, nKey, self.m_text)
    elseif insertType.item == nType then
        chatManager:inputCallBack_item(insertDlg, nType, nKey, self.m_text)
    elseif insertType.pet == nType then
        chatManager:inputCallBack_pet(insertDlg, nType, nKey, self.m_text)
    elseif insertType.task == nType then
        chatManager:inputCallBack_task(insertDlg, nType, nKey, self.m_text)
    elseif insertType.sell == nType then
        chatManager:inputCallBack_sell(insertDlg, nType, nKey, self.m_text)
    end

    if self.m_text then
        self.m_text:activate()
    end
    self:refreshTipState()
    self:refreshContentPreview()
end

function HornDlg:OnClickedEmoteBtn(args)
    if self.m_text then
        self.m_text:activate()
    end

    local insertDlg = require("logic.chat.insertdlg")
    local dlg = insertDlg.getInstanceNotCreate()
    if not dlg then
        dlg = insertDlg.getInstanceAndShow()
    else
        dlg:SetVisible(true)
    end

    if dlg then
        dlg.willCheckTipsWnd = true
        if dlg.setDelegate then
            dlg:setDelegate(self, HornDlg.OnInsertDlgCallBack)
        end
        if dlg.refreshFunctionBtn then
            dlg:refreshFunctionBtn({insertDlg.eFunType.emotion, insertDlg.eFunType.normalChat, insertDlg.eFunType.history})
        end
        if dlg.m_pInsetdialog_GroupButton1 then
            dlg.m_pInsetdialog_GroupButton1:setSelected(true)
        end
    end
    return true
end

function HornDlg:clearInput()
    if not self.m_text then
        return
    end
    self.m_text:Clear()
    self.m_text:Refresh()
    self.m_text:activate()
    self.m_lastPreviewText = nil
    self:refreshTipState()
    self:refreshContentPreview()
end

function HornDlg:OnHornSendResult(success, result)
    self:setSendingState(false)
    self:refreshConsumePanel()
    if success then
        self:clearInput()
    end
end

function HornDlg:OnClickedSendBtn(args)
    if self.m_isSending then
        return true
    end

    if not self:validateSendInput() then
        return true
    end

    if not self:validateConsumeEnough() then
        self:refreshConsumePanel()
        return true
    end

    local cmd = require "protodef.fire.pb.talk.chornsend":new()
    local colour = self.m_hornColorOptions[self.m_selectedColorIndex] or self.m_hornColorOptions[1]
    cmd.broadcastType = 1
    cmd.content = self:getPureInputText()
    cmd.itemId = 0
    cmd.color = colour.protocolColor or 0
    LuaProtocolManager.getInstance():send(cmd)

    self:setSendingState(true)
    self:refreshConsumePanel()
    return true
end

function HornDlg:update(delta)
    local dt = delta or 0
    self.m_refreshTickMs = self.m_refreshTickMs + dt
    if self.m_refreshTickMs >= HORN_REFRESH_INTERVAL_MS then
        self.m_refreshTickMs = 0
        self:refreshTipState()
        self:refreshContentPreview()
        self:refreshConsumePanel()
    end

    if self.m_isSending then
        self.m_sendPendingMs = self.m_sendPendingMs + dt
        if self.m_sendPendingMs >= HORN_PENDING_TIMEOUT_MS then
            self:setSendingState(false)
        end
    end
end

return HornDlg
