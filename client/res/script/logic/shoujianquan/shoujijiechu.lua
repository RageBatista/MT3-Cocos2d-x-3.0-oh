require "logic.dialog"

ShouJiJieChu = {}
setmetatable(ShouJiJieChu, Dialog)
ShouJiJieChu.__index = ShouJiJieChu

local _instance
function ShouJiJieChu.getInstance()
	if not _instance then
		_instance = ShouJiJieChu:new()
		_instance:OnCreate()
	end
	return _instance
end

function ShouJiJieChu.getInstanceAndShow()
	if not _instance then
		_instance = ShouJiJieChu:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ShouJiJieChu.getInstanceNotCreate()
	return _instance
end

function ShouJiJieChu.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ShouJiJieChu.ToggleOpenClose()
	if not _instance then
		_instance = ShouJiJieChu:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ShouJiJieChu.GetLayoutFileName()
	return "shoujijiechu.layout"
end

function ShouJiJieChu:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ShouJiJieChu)
	return self
end

function ShouJiJieChu:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_btn = CEGUI.toPushButton(winMgr:getWindow("shoujijiechu/btn"))
    self.m_btn:subscribeEvent("Clicked", ShouJiJieChu.OnClicked, self)

    local shoujianquanmgr = require "logic.shoujianquan.shoujianquanmgr"
    local strTel = tostring(shoujianquanmgr.tel)
    strTel = string.sub(strTel, 1, 3) .. "****" .. string.sub(strTel, 8)
    local strText = MHSD_UTILS.get_resstring(11660)
    local sb = StringBuilder:new()
    sb:Set("parameter1", strTel)
    strText = sb:GetString(strText)
    sb:delete()

	self.m_text = CEGUI.toRichEditbox(winMgr:getWindow("shoujijiechu/shurukuang/dangqian"))
    self.m_text:Clear()
    self.m_text:AppendParseText(CEGUI.String(strText))
    self.m_text:Refresh()
end

function ShouJiJieChu:OnClicked()
    ShouJiJieChu.DestroyDialog()
    require("logic.shoujianquan.shoujijiechushuru").getInstanceAndShow()
end

return ShouJiJieChu