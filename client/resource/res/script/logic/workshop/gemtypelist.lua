require "logic.dialog"
require "logic.workshop.workshophccell"

gemtypelist = {}
setmetatable(gemtypelist, Dialog)
gemtypelist.__index = gemtypelist

local _instance
function gemtypelist.getInstance()
	if not _instance then
		_instance = gemtypelist:new()
		_instance:OnCreate()
	end
	return _instance
end

function gemtypelist.getInstanceAndShow()
	if not _instance then
		_instance = gemtypelist:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function gemtypelist.getInstanceNotCreate()
	return _instance
end

function gemtypelist.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function gemtypelist.ToggleOpenClose()
	if not _instance then
		_instance = gemtypelist:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function gemtypelist.GetLayoutFileName()
	return "baoshihechenglist.layout"
end

function gemtypelist:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, gemtypelist)
	return self
end

function gemtypelist:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.list = CEGUI.toScrollablePane(winMgr:getWindow("baoshihechenglist/list"))
    self:initList()
end
-- 初始化宝石类型列表
function gemtypelist:initList()
    local gemTypeTable = BeanConfigManager.getInstance():GetTableByName("item.cgemtype"):getAllID()
    for k,v  in pairs(gemTypeTable) do
        local info = BeanConfigManager.getInstance():GetTableByName("item.cgemtype"):getRecorder(v)
        local cell = workshophccell.CreateNewDlg(self.list)
        cell:initInfoByTable(info)
        cell:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0, 0), CEGUI.UDim(0, 1 +(k - 1) * cell:GetWindow():getPixelSize().height)))
    end
end

return gemtypelist