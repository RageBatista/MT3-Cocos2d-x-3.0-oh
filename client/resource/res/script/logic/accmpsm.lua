require "logic.dialog"
require "utils.commonutil"

Accmpsm = {}
setmetatable(Accmpsm, Dialog)
Accmpsm.__index = Accmpsm


local _instance;

function Accmpsm:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, Accmpsm)
    return self
end

function Accmpsm.getInstance(parent)
    if not _instance then
        _instance = Accmpsm:new()
        _instance:OnCreate(parent)
    end
    
    return _instance
end

function Accmpsm.getInstanceAndShow(parent)
    if not _instance then
        _instance = Accmpsm:new()
        _instance:OnCreate(parent)
    else

    end
    _instance:SetVisible(true)
    return _instance
end

function Accmpsm.getInstanceNotCreate()
    return _instance
end

function Accmpsm:DestroyDialog()
    if _instance then
        if _instance.animationInstance then 
            _instance.animationInstance:stop()
            _instance.animationInstance = nil 
        end
        Dialog.OnClose(_instance)		
        _instance = nil
    end
end

function Accmpsm:OnClose()
    Accmpsm.DestroyDialog()
end

function Accmpsm.ToggleOpenClose(parent)
    if not _instance then 
        _instance = Accmpsm:new() 
        _instance:OnCreate(parent)
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end


function Accmpsm.GetLayoutFileName()
    return "accmpsm.layout"
end

function Accmpsm:OnCreate(parent)
    Dialog.OnCreate(self, parent)
    local winMgr = CEGUI.WindowManager:getSingleton()
    self.basewindow = CEGUI.toPushButton(winMgr:getWindow("Accmpsm"))
    self.basewindow:subscribeEvent("Clicked", Accmpsm.HandleBaseBgClicked,self)
    self.cc_jsck = winMgr:getWindow("Accmpsm/bg")
    local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen = aniMan:getAnimation("FrameWindow3ani") 
    self.animationInstance = aniMan:instantiateAnimation(animationOpen) 
    self.animationInstance:setTargetWindow(self.cc_jsck)
    self.animationInstance:start()
end

function Accmpsm:HandleBaseBgClicked(args)
    self.DestroyDialog()
end

return Accmpsm