require "logic.dialog"
require "utils.commonutil"

AddcpointIntro = {}
setmetatable(AddcpointIntro, Dialog)
AddcpointIntro.__index = AddcpointIntro


local _instance;

function AddcpointIntro:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, AddcpointIntro)
    return self
end

function AddcpointIntro.getInstance(parent)
    if not _instance then
        _instance = AddcpointIntro:new()
        _instance:OnCreate(parent)
    end
    
    return _instance
end

function AddcpointIntro.getInstanceAndShow(parent)
    if not _instance then
        _instance = AddcpointIntro:new()
        _instance:OnCreate(parent)
	else

    end
    _instance:SetVisible(true)
    return _instance
end

function AddcpointIntro.getInstanceNotCreate()
    return _instance
end

function AddcpointIntro.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function AddcpointIntro.ToggleOpenClose(parent)
	if not _instance then 
		_instance = AddcpointIntro:new() 
		_instance:OnCreate(parent)
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end


function AddcpointIntro.GetLayoutFileName()
    return "Addcshuoming.layout"
end

function AddcpointIntro:OnCreate(parent)
    Dialog.OnCreate(self, parent)
    local winMgr = CEGUI.WindowManager:getSingleton()
	self.basewindow = CEGUI.toPushButton(winMgr:getWindow("Addcshuoming"))------¿Õ°×´°¿Ú
end

function AddcpointIntro:HandleBaseBgClicked(args)
	
	self.DestroyDialog()
end

return AddcpointIntro