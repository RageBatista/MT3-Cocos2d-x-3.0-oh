require "logic.dialog"
require "utils.commonutil"

Addqimentishi = {}
setmetatable(Addqimentishi, Dialog)
Addqimentishi.__index = Addqimentishi


local _instance;

function Addqimentishi:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, Addqimentishi)
    return self
end

function Addqimentishi.getInstance(parent)
    if not _instance then
        _instance = Addqimentishi:new()
        _instance:OnCreate(parent)
    end
    
    return _instance
end

function Addqimentishi.getInstanceAndShow(parent)
    if not _instance then
        _instance = Addqimentishi:new()
        _instance:OnCreate(parent)
    else

    end
    _instance:SetVisible(true)
    return _instance
end

function Addqimentishi.getInstanceNotCreate()
    return _instance
end

function Addqimentishi:DestroyDialog()
    if _instance then
        if self.sprite then
            self.sprite:delete()
            self.sprite = nil
        end
        if self.smokeBg then
            gGetGameUIManager():RemoveUIEffect(self.smokeBg)
        end
        if self.roleEffectBg then
            gGetGameUIManager():RemoveUIEffect(self.roleEffectBg)
        end 

        if _instance.animationInstance then 
            _instance.animationInstance:stop()
            _instance.animationInstance = nil 
        end
        Dialog.OnClose(_instance)		
        _instance = nil
    end
end

function Addqimentishi:OnClose()
    Addqimentishi.DestroyDialog()
end

function Addqimentishi.ToggleOpenClose(parent)
    if not _instance then 
        _instance = Addqimentishi:new() 
        _instance:OnCreate(parent)
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end


function Addqimentishi.GetLayoutFileName()
    return "Addqmyl.layout"
end

function Addqimentishi:OnCreate(parent)
    Dialog.OnCreate(self, parent)
    local winMgr = CEGUI.WindowManager:getSingleton()
    self.basewindow = CEGUI.toPushButton(winMgr:getWindow("Addqimentishi"))
    
    self:GetWindow():setVisible(false) 
    local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen = aniMan:getAnimation("neidanhc") 
    self.animationInstance = aniMan:instantiateAnimation(animationOpen) 
    self.animationInstance:setTargetWindow(self:GetWindow())
    self.animationInstance:start()--

	
	self.shuiming1 = CEGUI.toRichEditbox(winMgr:getWindow("Addqimentishi/bg/shuoming1/huadong1/ck1"))
	self.shuiming1:Clear()
    self.shuiming1:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7480)))
    self.shuiming1:Refresh()
	
	self.shuiming2 = CEGUI.toRichEditbox(winMgr:getWindow("Addqimentishi/bg/shuoming1/huadong1/ck2"))
	self.shuiming2:Clear()
    self.shuiming2:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7481)))
    self.shuiming2:Refresh()
	
	self.shuiming3 = CEGUI.toRichEditbox(winMgr:getWindow("Addqimentishi/bg/shuoming1/huadong1/ck3"))
	self.shuiming3:Clear()
    self.shuiming3:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7482)))
    self.shuiming3:Refresh()

	
	self.smokeBg = winMgr:getWindow("Addqimentishi/bg/ccy")
	local s = self.smokeBg:getPixelSize()
	local flagSmoke = gGetGameUIManager():AddUIEffect(self.smokeBg, "geffect/ui/mt_shengqishi/mt_qimeng", true, s.width*0.5, s.height)
	
end

function Addqimentishi:HandleBaseBgClicked(args)
    self.DestroyDialog()
end

return Addqimentishi