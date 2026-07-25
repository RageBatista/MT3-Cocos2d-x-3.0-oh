require "logic.dialog"

ShouJiJieChuShuRu = {}
setmetatable(ShouJiJieChuShuRu, Dialog)
ShouJiJieChuShuRu.__index = ShouJiJieChuShuRu

local _instance
function ShouJiJieChuShuRu.getInstance()
	if not _instance then
		_instance = ShouJiJieChuShuRu:new()
		_instance:OnCreate()
	end
	return _instance
end

function ShouJiJieChuShuRu.getInstanceAndShow()
	if not _instance then
		_instance = ShouJiJieChuShuRu:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ShouJiJieChuShuRu.getInstanceNotCreate()
	return _instance
end

function ShouJiJieChuShuRu.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ShouJiJieChuShuRu.ToggleOpenClose()
	if not _instance then
		_instance = ShouJiJieChuShuRu:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ShouJiJieChuShuRu.GetLayoutFileName()
	return "shoujijiechushuru.layout"
end

function ShouJiJieChuShuRu:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ShouJiJieChuShuRu)
	return self
end

function ShouJiJieChuShuRu:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_btn = CEGUI.toPushButton(winMgr:getWindow("shoujijiechushuru/btn"))
    self.m_btn:subscribeEvent("Clicked", ShouJiJieChuShuRu.OnClicked, self)

	self.m_closeBtn = CEGUI.toPushButton(winMgr:getWindow("shoujijiechushuru/guanbi"))
    self.m_closeBtn:subscribeEvent("Clicked", ShouJiJieChuShuRu.DestroyDialog, nil)

	self.m_text = CEGUI.toRichEditbox(winMgr:getWindow("shoujijiechushuru/shurukuang/shuru"))
    self.m_text:setMaxTextLength(11)
    self.m_text:SetColourRect(CEGUI.PropertyHelper:stringToColour(self.m_text:getProperty("NormalTextColour")))

    local shoujianquanmgr = require "logic.shoujianquan.shoujianquanmgr"
    local strTel = tostring(shoujianquanmgr.tel)
    strTel = string.sub(strTel, 1, 3) .. "****" .. string.sub(strTel, 8)
    local strText = MHSD_UTILS.get_resstring(11661)
    local sb = StringBuilder:new()
    sb:Set("parameter1", strTel)
    strText = sb:GetString(strText)
    sb:delete()

	self.m_desc = CEGUI.toRichEditbox(winMgr:getWindow("shoujijiechushuru/box"))
    self.m_desc:Clear()
    self.m_desc:AppendParseText(CEGUI.String(strText))
    self.m_desc:Refresh()
end

function ShouJiJieChuShuRu:OnClicked()
    local shoujianquanmgr = require "logic.shoujianquan.shoujianquanmgr"

    local strTel = self.m_text:GetPureText()
    local nTel = tonumber(strTel)
    if nTel == nil or string.len(strTel) ~= 11 or nTel ~= shoujianquanmgr.tel then
		GetCTipsManager():AddMessageTipById(191006)
        return
    end

    local p = require("protodef.fire.pb.cunbindtel"):new()
    p.tel = nTel
    LuaProtocolManager:send(p)
end

return ShouJiJieChuShuRu