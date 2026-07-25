require "logic.dialog"

ShouJiGuanLianChengGong = {}
setmetatable(ShouJiGuanLianChengGong, Dialog)
ShouJiGuanLianChengGong.__index = ShouJiGuanLianChengGong

local _instance
function ShouJiGuanLianChengGong.getInstance()
	if not _instance then
		_instance = ShouJiGuanLianChengGong:new()
		_instance:OnCreate()
	end
	return _instance
end

function ShouJiGuanLianChengGong.getInstanceAndShow()
	if not _instance then
		_instance = ShouJiGuanLianChengGong:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ShouJiGuanLianChengGong.getInstanceNotCreate()
	return _instance
end

function ShouJiGuanLianChengGong.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ShouJiGuanLianChengGong.ToggleOpenClose()
	if not _instance then
		_instance = ShouJiGuanLianChengGong:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ShouJiGuanLianChengGong.GetLayoutFileName()
	return "shoujiguanlianchenggong.layout"
end

function ShouJiGuanLianChengGong:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ShouJiGuanLianChengGong)
	return self
end

function ShouJiGuanLianChengGong:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_btn = CEGUI.toPushButton(winMgr:getWindow("shoujiguanlianchenggong/btn"))
    self.m_btn:subscribeEvent("Clicked", ShouJiGuanLianChengGong.OnClicked, self)

    self.m_closeBtn = CEGUI.toPushButton(winMgr:getWindow("shoujiguanlianchenggong/guanbi"))
    self.m_closeBtn:subscribeEvent("Clicked", ShouJiGuanLianChengGong.DestroyDialog, nil)

    local shoujianquanmgr = require "logic.shoujianquan.shoujianquanmgr"
    local strTel = tostring(shoujianquanmgr.tel)
    strTel = string.sub(strTel, 1, 3) .. "****" .. string.sub(strTel, 8)
    local strText = MHSD_UTILS.get_resstring(11660)
    local sb = StringBuilder:new()
    sb:Set("parameter1", strTel)
    strText = sb:GetString(strText)
    sb:delete()

	self.m_text = CEGUI.toRichEditbox(winMgr:getWindow("shoujiguanlianchenggong/shurukuang/text"))
    self.m_text:Clear()
    self.m_text:AppendParseText(CEGUI.String(strText))
    self.m_text:Refresh()

    self.m_nCountDownLife = 15000
    self.m_strConfirm = MHSD_UTILS.get_resstring(1556)
end

function ShouJiGuanLianChengGong:CountDownUpdate(delta)
    self.m_nCountDownLife = self.m_nCountDownLife - delta
    if self.m_nCountDownLife < 0 then
        self.m_nCountDownLife = 0
        ShouJiGuanLianChengGong.DestroyDialog()
    else
        local remainSecond = math.floor(self.m_nCountDownLife / 1000) + 1
        local strCountDown = self.m_strConfirm .. "(" .. remainSecond .. ")"
        self.m_btn:setText(strCountDown)
    end
end

function ShouJiGuanLianChengGong:OnClicked()
    ShouJiGuanLianChengGong.DestroyDialog()
end

return ShouJiGuanLianChengGong