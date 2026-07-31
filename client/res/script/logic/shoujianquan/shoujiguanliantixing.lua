require "logic.dialog"

ShouJiGuanLianTiXing = {}
setmetatable(ShouJiGuanLianTiXing, Dialog)
ShouJiGuanLianTiXing.__index = ShouJiGuanLianTiXing

local _instance
function ShouJiGuanLianTiXing.getInstance()
	if not _instance then
		_instance = ShouJiGuanLianTiXing:new()
		_instance:OnCreate()
	end
	return _instance
end

function ShouJiGuanLianTiXing.getInstanceAndShow()
	if not _instance then
		_instance = ShouJiGuanLianTiXing:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ShouJiGuanLianTiXing.getInstanceNotCreate()
	return _instance
end

function ShouJiGuanLianTiXing.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ShouJiGuanLianTiXing.ToggleOpenClose()
	if not _instance then
		_instance = ShouJiGuanLianTiXing:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ShouJiGuanLianTiXing.GetLayoutFileName()
	return "shoujiguanliantixing.layout"
end

function ShouJiGuanLianTiXing:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ShouJiGuanLianTiXing)
	return self
end

function ShouJiGuanLianTiXing:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_desc_free = winMgr:getWindow("shoujiguanliantixing/text2")
    self.m_desc_pointcard = winMgr:getWindow("shoujiguanliantixing/text3")
    if IsPointCardServer() then
        self.m_desc_free:setVisible(false)
        self.m_desc_pointcard:setVisible(true)
    else
        self.m_desc_free:setVisible(true)
        self.m_desc_pointcard:setVisible(false)
    end

	self.m_btn = CEGUI.toPushButton(winMgr:getWindow("shoujiguanliantixing/btn"))
    self.m_btn:subscribeEvent("Clicked", ShouJiGuanLianTiXing.OnClicked, self)

	self.m_closeBtn = CEGUI.toPushButton(winMgr:getWindow("shoujiguanliantixing/guanbi"))
    self.m_closeBtn:subscribeEvent("Clicked", ShouJiGuanLianTiXing.DestroyDialog, nil)
end

function ShouJiGuanLianTiXing:OnClicked()
    ShouJiGuanLianTiXing.DestroyDialog()
    require("logic.shoujianquan.shoujiguanlianshuru").getInstanceAndShow()
end

return ShouJiGuanLianTiXing