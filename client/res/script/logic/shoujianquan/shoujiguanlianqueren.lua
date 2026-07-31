require "logic.dialog"

ShouJiGuanLianQueRen = {}
setmetatable(ShouJiGuanLianQueRen, Dialog)
ShouJiGuanLianQueRen.__index = ShouJiGuanLianQueRen

local _instance
function ShouJiGuanLianQueRen.getInstance()
	if not _instance then
		_instance = ShouJiGuanLianQueRen:new()
		_instance:OnCreate()
	end
	return _instance
end

function ShouJiGuanLianQueRen.getInstanceAndShow()
	if not _instance then
		_instance = ShouJiGuanLianQueRen:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ShouJiGuanLianQueRen.getInstanceNotCreate()
	return _instance
end

function ShouJiGuanLianQueRen.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ShouJiGuanLianQueRen.ToggleOpenClose()
	if not _instance then
		_instance = ShouJiGuanLianQueRen:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ShouJiGuanLianQueRen.GetLayoutFileName()
	return "shoujiguanlianqueren.layout"
end

function ShouJiGuanLianQueRen:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ShouJiGuanLianQueRen)
	return self
end

function ShouJiGuanLianQueRen:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_btn = CEGUI.toPushButton(winMgr:getWindow("shoujiguanlianqueren/btn"))
    self.m_btn:subscribeEvent("Clicked", ShouJiGuanLianQueRen.OnClicked, self)

	self.m_closeBtn = CEGUI.toPushButton(winMgr:getWindow("shoujiguanlianqueren/guanbi"))
    self.m_closeBtn:subscribeEvent("Clicked", ShouJiGuanLianQueRen.DestroyDialog, nil)
end

function ShouJiGuanLianQueRen:OnClicked()
    ShouJiGuanLianQueRen.DestroyDialog()
    require("logic.shoujianquan.shoujiguanlianshuru").getInstanceAndShow()
end

return ShouJiGuanLianQueRen