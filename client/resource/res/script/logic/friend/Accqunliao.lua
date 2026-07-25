require "logic.dialog"
require "utils.commonutil"

Accqunliao = {}
setmetatable(Accqunliao, Dialog)
Accqunliao.__index = Accqunliao


local _instance;

function Accqunliao:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, Accqunliao)
    return self
end

function Accqunliao.getInstance(parent)
    if not _instance then
        _instance = Accqunliao:new()
        _instance:OnCreate(parent)
    end
    
    return _instance
end

function Accqunliao.getInstanceAndShow(parent)
    if not _instance then
        _instance = Accqunliao:new()
        _instance:OnCreate(parent)
    else

    end
    _instance:SetVisible(true)
    return _instance
end

function Accqunliao.getInstanceNotCreate()
    return _instance
end

function Accqunliao.DestroyDialog()
    if _instance then
        -- 停止自身动画
        if _instance.animationInstance then 
            _instance.animationInstance:stop()
            _instance.animationInstance = nil 
        end

        -- 停止动画
        local aniMan = CEGUI.AnimationManager:getSingleton()
        local expandAnimation = aniMan:getAnimation("ckmian1Shrink1") 
        if expandAnimation then
            aniMan:destroyAllInstancesOfAnimation(expandAnimation)  
        end

        Dialog.OnClose(_instance)		
        _instance = nil
    end
end

function Accqunliao:OnClose()
    Accqunliao.DestroyDialog()
end

function Accqunliao.ToggleOpenClose(parent)
    if not _instance then 
        _instance = Accqunliao:new() 
        _instance:OnCreate(parent)
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end


function Accqunliao.GetLayoutFileName()
    return "Accqunliao.layout"
end

function Accqunliao:OnCreate(parent)
    Dialog.OnCreate(self, parent)
    local winMgr = CEGUI.WindowManager:getSingleton()
    self.basewindow = CEGUI.toPushButton(winMgr:getWindow("Accqunliao"))
    
    self:GetWindow():setVisible(false) 
    local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen = aniMan:getAnimation("pane0Expand") 
    self.animationInstance = aniMan:instantiateAnimation(animationOpen) 
    self.animationInstance:setTargetWindow(self:GetWindow())
    self.animationInstance:start()
	
	self.ccbtn1 = CEGUI.toGroupButton(winMgr:getWindow("Accqunliao/bg/btn1"))
	self.ckmian1 = winMgr:getWindow("Accqunliao/bg/ck1")
	self.ccbtn1:subscribeEvent("SelectStateChanged", Accqunliao.ckqiehuantabBtn, self)

	self.ccbtn2 = CEGUI.toGroupButton(winMgr:getWindow("Accqunliao/bg/btn2"))
	self.ckmian2 = winMgr:getWindow("Accqunliao/bg/ck2")
	self.ccbtn2:subscribeEvent("SelectStateChanged", Accqunliao.ckqiehuantabBtn, self)
	
	self.cckefutips1 = CEGUI.toRichEditbox(winMgr:getWindow("Accqunliao/bg/ck1/qimeng/tishic1"))
	self.cckefutips1:Clear()
    self.cckefutips1:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7562)))
    self.cckefutips1:Refresh()
	
	self.cckefutips2 = CEGUI.toRichEditbox(winMgr:getWindow("Accqunliao/bg/ck1/qimeng/tishic2"))
	self.cckefutips2:Clear()
    self.cckefutips2:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7563)))
    self.cckefutips2:Refresh()
	
end

function Accqunliao:ckqiehuantabBtn()
    local selectedBtn = self.ccbtn1:getSelectedButtonInGroup()
    local aniMan = CEGUI.AnimationManager:getSingleton()

    if self.ccbtn1 == selectedBtn then
        if not self.ckmian1:isVisible() then
            self.ckmian2:setVisible(false)
            self.ckmian1:setVisible(true) 

            local expandAnimation = aniMan:instantiateAnimation("ckmian1Shrink1")
            expandAnimation:setTargetWindow(self.ckmian1) 
            expandAnimation:start()
        end
    elseif self.ccbtn2 == selectedBtn then
        if not self.ckmian2:isVisible() then
            self.ckmian1:setVisible(false)
            self.ckmian2:setVisible(true)

            local expandAnimation = aniMan:instantiateAnimation("ckmian1Shrink1") 
            expandAnimation:setTargetWindow(self.ckmian2)
            expandAnimation:start()
        end
    end
end
		
function Accqunliao:HandleBaseBgClicked(args)
    self.DestroyDialog()
end

return Accqunliao