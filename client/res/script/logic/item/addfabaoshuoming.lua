require "logic.dialog"
require "utils.commonutil"

addfabaoshuoming = {}
setmetatable(addfabaoshuoming, Dialog)
addfabaoshuoming.__index = addfabaoshuoming


local _instance;

function addfabaoshuoming:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, addfabaoshuoming)
    return self
end

function addfabaoshuoming.getInstance(parent)
    if not _instance then
        _instance = addfabaoshuoming:new()
        _instance:OnCreate(parent)
    end
    
    return _instance
end

function addfabaoshuoming.getInstanceAndShow(parent)
    if not _instance then
        _instance = addfabaoshuoming:new()
        _instance:OnCreate(parent)
    else

    end
    _instance:SetVisible(true)
    return _instance
end

function addfabaoshuoming.getInstanceNotCreate()
    return _instance
end

function addfabaoshuoming.DestroyDialog()
    if _instance then
        if _instance.animationInstance then 
            _instance.animationInstance:stop()
            _instance.animationInstance = nil 
        end
        Dialog.OnClose(_instance)		
        _instance = nil
    end
end

function addfabaoshuoming:OnClose()
    addfabaoshuoming.DestroyDialog()
end

function addfabaoshuoming.ToggleOpenClose(parent)
    if not _instance then 
        _instance = addfabaoshuoming:new() 
        _instance:OnCreate(parent)
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end


function addfabaoshuoming.GetLayoutFileName()
    return "Addfabaoshuoming.layout"
end

function addfabaoshuoming:OnCreate(parent)
    Dialog.OnCreate(self, parent)
    local winMgr = CEGUI.WindowManager:getSingleton()
    self.basewindow = CEGUI.toPushButton(winMgr:getWindow("Addfabaoshuoming"))
    
    self:GetWindow():setVisible(false) 
    local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen = aniMan:getAnimation("pane1Expand") 
    self.animationInstance = aniMan:instantiateAnimation(animationOpen) 
    self.animationInstance:setTargetWindow(self:GetWindow())
    self.animationInstance:start()--

	self.cc_btn1 = CEGUI.toGroupButton(winMgr:getWindow("Addfabaoshuoming/bg/hdck1/CCgroubtn1")) 
    self.cc_btn1:subscribeEvent("SelectStateChanged", addfabaoshuoming.cckTypeTab, self) 

    self.cc_btn2 = CEGUI.toGroupButton(winMgr:getWindow("Addfabaoshuoming/bg/hdck1/CCgroubtn2"))
    self.cc_btn2:subscribeEvent("SelectStateChanged", addfabaoshuoming.cckTypeTab, self) 

    self.cc_btn3 = CEGUI.toGroupButton(winMgr:getWindow("Addfabaoshuoming/bg/hdck1/CCgroubtn3"))
    self.cc_btn3:subscribeEvent("SelectStateChanged", addfabaoshuoming.cckTypeTab, self) 
	
	self.cc_ck1 = winMgr:getWindow("Addfabaoshuoming/bg/ck1")
	self.cc_ck2 = winMgr:getWindow("Addfabaoshuoming/bg/ck2")
	self.cc_ck3 = winMgr:getWindow("Addfabaoshuoming/bg/ck3")
	
	self.tipsc1 = CEGUI.toRichEditbox(winMgr:getWindow("Addfabaoshuoming/bg/ck1/shuomingc1"))
	self.tipsc1:Clear()
    self.tipsc1:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7890)))
    self.tipsc1:Refresh()
--	require("utils.mhsdutils").get_resstring(11816)
end

function addfabaoshuoming:cckTypeTab()
    local selectedBtn = self.cc_btn1:getSelectedButtonInGroup()
    if self.cc_btn1 == selectedBtn then
        self:showPanel(self.cc_ck1)
    elseif self.cc_btn2 == selectedBtn then
        self:showPanel(self.cc_ck2)
    elseif self.cc_btn3 == selectedBtn then
        self:showPanel(self.cc_ck3)
    end
end

function addfabaoshuoming:showPanel(panel)
    -- 确保只有选中的面板可见
    self.cc_ck1:setVisible(false)
    self.cc_ck2:setVisible(false)
    self.cc_ck3:setVisible(false)

    panel:setVisible(true)
end

function addfabaoshuoming:HandleBaseBgClicked(args)
    self.DestroyDialog()
end

return addfabaoshuoming