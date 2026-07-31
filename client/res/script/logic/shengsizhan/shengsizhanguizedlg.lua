require "logic.dialog"

ShengSiZhanGuiZeDlg = {}
setmetatable(ShengSiZhanGuiZeDlg, Dialog)
ShengSiZhanGuiZeDlg.__index = ShengSiZhanGuiZeDlg

local _instance
function ShengSiZhanGuiZeDlg.getInstance()
	if not _instance then
		_instance = ShengSiZhanGuiZeDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function ShengSiZhanGuiZeDlg.getInstanceAndShow()
	if not _instance then
		_instance = ShengSiZhanGuiZeDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ShengSiZhanGuiZeDlg.getInstanceNotCreate()
	return _instance
end

function ShengSiZhanGuiZeDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ShengSiZhanGuiZeDlg.ToggleOpenClose()
	if not _instance then
		_instance = ShengSiZhanGuiZeDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ShengSiZhanGuiZeDlg.GetLayoutFileName()
	return "shengsizhanguize_mtg.layout"
end

function ShengSiZhanGuiZeDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ShengSiZhanGuiZeDlg)
	return self
end

function ShengSiZhanGuiZeDlg:OnCreate()
	Dialog.OnCreate(self)
end

return ShengSiZhanGuiZeDlg
