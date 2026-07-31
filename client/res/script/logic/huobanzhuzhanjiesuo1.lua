require "logic.dialog"

huobanzhuzhanjiesuo = {}
setmetatable(huobanzhuzhanjiesuo, Dialog)
huobanzhuzhanjiesuo.__index = huobanzhuzhanjiesuo

local _instance
function huobanzhuzhanjiesuo.getInstance()
	if not _instance then
		_instance = huobanzhuzhanjiesuo:new()
		_instance:OnCreate()
	end
	return _instance
end

function huobanzhuzhanjiesuo.getInstanceAndShow()
	if not _instance then
		_instance = huobanzhuzhanjiesuo:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function huobanzhuzhanjiesuo.getInstanceNotCreate()
	return _instance
end

function huobanzhuzhanjiesuo.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function huobanzhuzhanjiesuo.ToggleOpenClose()
	if not _instance then
		_instance = huobanzhuzhanjiesuo:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function huobanzhuzhanjiesuo.GetLayoutFileName()
	return "huobanzhuzhanjiesuo1.layout"
end

function huobanzhuzhanjiesuo:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, huobanzhuzhanjiesuo)
	return self
end

function huobanzhuzhanjiesuo:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()



end

return huobanzhuzhanjiesuo