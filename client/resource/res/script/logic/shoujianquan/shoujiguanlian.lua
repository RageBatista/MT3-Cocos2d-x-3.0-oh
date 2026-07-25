require "logic.dialog"

ShouJiGuanLian = {}
setmetatable(ShouJiGuanLian, Dialog)
ShouJiGuanLian.__index = ShouJiGuanLian

local _instance
function ShouJiGuanLian.getInstance()
	if not _instance then
		_instance = ShouJiGuanLian:new()
		_instance:OnCreate()
	end
	return _instance
end

function ShouJiGuanLian.getInstanceAndShow()
	if not _instance then
		_instance = ShouJiGuanLian:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ShouJiGuanLian.getInstanceNotCreate()
	return _instance
end

function ShouJiGuanLian.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ShouJiGuanLian.ToggleOpenClose()
	if not _instance then
		_instance = ShouJiGuanLian:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ShouJiGuanLian.GetLayoutFileName()
	return "shoujiguanlian.layout"
end

function ShouJiGuanLian:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ShouJiGuanLian)
	return self
end

function ShouJiGuanLian:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_btn = CEGUI.toPushButton(winMgr:getWindow("shoujiguanlian/btn"))
    self.m_btn:subscribeEvent("Clicked", ShouJiGuanLian.OnClicked, self)
end

function ShouJiGuanLian:OnClicked()
    ShouJiGuanLian.DestroyDialog()
    require("logic.shoujianquan.shoujiguanlianshuru").getInstanceAndShow()
end

return ShouJiGuanLian