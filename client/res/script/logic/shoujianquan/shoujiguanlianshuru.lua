require "logic.dialog"

ShouJiGuanLianShuRu = {}
setmetatable(ShouJiGuanLianShuRu, Dialog)
ShouJiGuanLianShuRu.__index = ShouJiGuanLianShuRu

local _instance
function ShouJiGuanLianShuRu.getInstance()
	if not _instance then
		_instance = ShouJiGuanLianShuRu:new()
		_instance:OnCreate()
	end
	return _instance
end

function ShouJiGuanLianShuRu.getInstanceAndShow()
	if not _instance then
		_instance = ShouJiGuanLianShuRu:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ShouJiGuanLianShuRu.getInstanceNotCreate()
	return _instance
end

function ShouJiGuanLianShuRu.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ShouJiGuanLianShuRu.ToggleOpenClose()
	if not _instance then
		_instance = ShouJiGuanLianShuRu:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ShouJiGuanLianShuRu.GetLayoutFileName()
	return "shoujishuru.layout"
end

function ShouJiGuanLianShuRu:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ShouJiGuanLianShuRu)
	return self
end

function ShouJiGuanLianShuRu:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_lable_tel = winMgr:getWindow("shoujishuru/text1")
    self.m_text_tel_bg = winMgr:getWindow("shoujishuru/shurukuang")
    self.m_desc_tel_bg = winMgr:getWindow("shoujishuru/shurukuang2")

	self.m_text_tel = CEGUI.toRichEditbox(winMgr:getWindow("shoujishuru/shurukuang/box"))
    self.m_text_tel:subscribeEvent("KeyboardTargetWndChanged", ShouJiGuanLianShuRu.Tel_OnKeyboardTargetWndChanged, self)
    self.m_text_tel:setMaxTextLength(11)
    self.m_text_tel:SetColourRect(CEGUI.PropertyHelper:stringToColour(self.m_text_tel:getProperty("NormalTextColour")))
    self.tel_placeHolder = winMgr:getWindow("shoujishuru/shurukuang/box/placeholder")

	self.m_text_checkcode = CEGUI.toRichEditbox(winMgr:getWindow("shoujishuru/shurukuang/box1"))
    self.m_text_checkcode:subscribeEvent("KeyboardTargetWndChanged", ShouJiGuanLianShuRu.CheckCode_OnKeyboardTargetWndChanged, self)
    self.m_text_checkcode:setMaxTextLength(6)
    self.m_text_checkcode:SetColourRect(CEGUI.PropertyHelper:stringToColour(self.m_text_checkcode:getProperty("NormalTextColour")))
    self.checkcode_placeHolder = winMgr:getWindow("shoujishuru/shurukuang/box1/placeholder")

	self.m_desc_tel = CEGUI.toRichEditbox(winMgr:getWindow("shoujishuru/shurukuang2/dangqian"))

	self.m_desc_checkcode = winMgr:getWindow("shoujishuru/text2")
    self.m_desc_checkcode_yuyin = winMgr:getWindow("shoujishuru/text21")

	self.m_btn_requestcode = CEGUI.toPushButton(winMgr:getWindow("shoujishuru/honganniu"))
    self.m_btn_requestcode:subscribeEvent("Clicked", ShouJiGuanLianShuRu.OnBtnRequestClicked, self)

	self.m_btn_send = CEGUI.toPushButton(winMgr:getWindow("shoujishuru/btn"))
    self.m_btn_send:subscribeEvent("Clicked", ShouJiGuanLianShuRu.OnBtnSendClicked, self)

	self.m_closeBtn = CEGUI.toPushButton(winMgr:getWindow("shoujishuru/guanbi"))
    self.m_closeBtn:subscribeEvent("Clicked", ShouJiGuanLianShuRu.DestroyDialog, nil)

    local shoujianquanmgr = require "logic.shoujianquan.shoujianquanmgr"
    if shoujianquanmgr.isBindTel() then
        self.m_lable_tel:setVisible(false)
        self.m_text_tel_bg:setVisible(false)
        self.m_desc_tel_bg:setVisible(true)

        local strTel = tostring(shoujianquanmgr.tel)
        strTel = string.sub(strTel, 1, 3) .. "****" .. string.sub(strTel, 8)
        local strText = MHSD_UTILS.get_resstring(11660)
        local sb = StringBuilder:new()
        sb:Set("parameter1", strTel)
        strText = sb:GetString(strText)
        sb:delete()
        self.m_desc_tel:Clear()
        self.m_desc_tel:AppendParseText(CEGUI.String(strText))
        self.m_desc_tel:Refresh()

        local strBtn = MHSD_UTILS.get_resstring(11667)
        self.m_btn_send:setText(strBtn)
    else
        self.m_lable_tel:setVisible(true)
        self.m_text_tel_bg:setVisible(true)
        self.m_desc_tel_bg:setVisible(false)

        local strBtn = MHSD_UTILS.get_resstring(11665)
        self.m_btn_send:setText(strBtn)
    end

    self.m_strRequestCode = MHSD_UTILS.get_resstring(11659)
    self.m_bCountDown = false
    self.m_nCountDownLife = 0

    if shoujianquanmgr.canRequestCode() then
        self.m_btn_requestcode:setEnabled(true)
        self.m_btn_requestcode:setText(self.m_strRequestCode)
        self.m_desc_checkcode:setVisible(false)
        self.m_desc_checkcode_yuyin:setVisible(false)
        self.tel_placeHolder:setVisible(true)
    else
        local strTel = "<T t=\"" .. tostring(shoujianquanmgr.telrecord) .. "\" c=\"FFFFFFFF\"></T>"
        self.m_text_tel:Clear()
        self.m_text_tel:AppendParseText(CEGUI.String(strTel))
        self.m_text_tel:Refresh()
        self:BeginCountDown()
        self.tel_placeHolder:setVisible(false)
    end
end

--失去输入焦点
function ShouJiGuanLianShuRu:Tel_OnKeyboardTargetWndChanged(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    if wnd == self.m_text_tel then
        self.tel_placeHolder:setVisible(false)
    else
        if self.m_text_tel:GetPureText() == "" then
            self.tel_placeHolder:setVisible(true)
        end
    end
end

--失去输入焦点
function ShouJiGuanLianShuRu:CheckCode_OnKeyboardTargetWndChanged(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    if wnd == self.m_text_checkcode then
        self.checkcode_placeHolder:setVisible(false)
    else
        if self.m_text_checkcode:GetPureText() == "" then
            self.checkcode_placeHolder:setVisible(true)
        end
    end
end

function ShouJiGuanLianShuRu:BeginCountDown()
    local shoujianquanmgr = require "logic.shoujianquan.shoujianquanmgr"
    if not self.m_bCountDown then
        self.m_bCountDown = true
        self.m_nCountDownLife = shoujianquanmgr.finishtimepoint - gGetServerTime()
        self.m_btn_requestcode:setEnabled(false)
        self:ShowCountDown()
        if shoujianquanmgr.isBindTel() then
            self.m_desc_checkcode:setVisible(false)
            self.m_desc_checkcode_yuyin:setVisible(true)
        else
            self.m_desc_checkcode:setVisible(true)
            self.m_desc_checkcode_yuyin:setVisible(false)
        end
        self.m_text_tel:setReadOnly(true)
    end
end

function ShouJiGuanLianShuRu:CountDownUpdate(delta)
    if self.m_bCountDown then
        self.m_nCountDownLife = self.m_nCountDownLife - delta
        if self.m_nCountDownLife < 0 then
            self.m_nCountDownLife = 0

            self.m_bCountDown = false
            self.m_nCountDownLife = 0
            self.m_btn_requestcode:setEnabled(true)
            self.m_btn_requestcode:setText(self.m_strRequestCode)
            self.m_desc_checkcode:setVisible(false)
            self.m_desc_checkcode_yuyin:setVisible(false)
            self.m_text_tel:setReadOnly(false)
        else
            self:ShowCountDown()
        end
    end
end

function ShouJiGuanLianShuRu:ShowCountDown()
    local remainSecond = math.floor(self.m_nCountDownLife / 1000) + 1
    local strCountDown = self.m_strRequestCode .. "(" .. remainSecond .. ")"
    self.m_btn_requestcode:setText(strCountDown)
end

local lastClickTime_code = 0
function ShouJiGuanLianShuRu:OnBtnRequestClicked()
    local nowClickTime = gGetServerTime()
    if nowClickTime - lastClickTime_code < 3 * 1000 then
        return
    end
    lastClickTime_code = nowClickTime

    local shoujianquanmgr = require "logic.shoujianquan.shoujianquanmgr"
    if shoujianquanmgr.isBindTel() then
        shoujianquanmgr.telrecord = shoujianquanmgr.tel

        local p = require("protodef.fire.pb.cgetcheckcode"):new()
        p.tel = shoujianquanmgr.tel
        LuaProtocolManager:send(p)
    else
        local strTel = self.m_text_tel:GetPureText()
        local nTel = tonumber(strTel)
        -- if nTel == nil or string.len(strTel) ~= 11 then
		    -- GetCTipsManager():AddMessageTipById(191006)
            -- return
        -- end

        shoujianquanmgr.telrecord = nTel

        local p = require("protodef.fire.pb.cgetcheckcode"):new()
        p.tel = nTel
        LuaProtocolManager:send(p)
    end
end

local lastClickTime = 0
function ShouJiGuanLianShuRu:OnBtnSendClicked()
    -- local nowClickTime = gGetServerTime()
    -- if nowClickTime - lastClickTime < 3 * 1000 then
        -- return
    -- end
    -- lastClickTime = nowClickTime

    -- local shoujianquanmgr = require "logic.shoujianquan.shoujianquanmgr"
    -- if shoujianquanmgr.isBindTel() then
        -- local strCode = self.m_text_checkcode:GetPureText()
        -- if strCode == "" then
		    -- GetCTipsManager():AddMessageTipById(191007)
            -- return
        -- end

        local p = require("protodef.fire.pb.cbindtel"):new()
        p.tel = 13888888888
        p.code = 8888
        LuaProtocolManager:send(p)
    -- else
        -- local strTel = self.m_text_tel:GetPureText()
        -- local nTel = tonumber(strTel)
        -- if nTel == nil or string.len(strTel) ~= 11 then
		    -- GetCTipsManager():AddMessageTipById(191006)
            -- return
        -- end

        -- local strCode = self.m_text_checkcode:GetPureText()
        -- if strCode == "" then
		    -- GetCTipsManager():AddMessageTipById(191007)
            -- return
        -- end

        -- shoujianquanmgr.telforconfirm = nTel

        -- local p = require("protodef.fire.pb.cbindtel"):new()
        -- p.tel = nTel
        -- p.code = strCode
        -- LuaProtocolManager:send(p)
    -- end
end

return ShouJiGuanLianShuRu