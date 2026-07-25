require "logic.dialog"
require "utils.commonutil"

Addndpointintro = {}
setmetatable(Addndpointintro, Dialog)
Addndpointintro.__index = Addndpointintro


local _instance;

function Addndpointintro:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, Addndpointintro)
    return self
end

function Addndpointintro.getInstance(parent)
    if not _instance then
        _instance = Addndpointintro:new()
        _instance:OnCreate(parent)
    end
    
    return _instance
end

function Addndpointintro.getInstanceAndShow(parent)
    if not _instance then
        _instance = Addndpointintro:new()
        _instance:OnCreate(parent)
    else

    end
    _instance:SetVisible(true)
    return _instance
end

function Addndpointintro.getInstanceNotCreate()
    return _instance
end

function Addndpointintro.DestroyDialog()
    if _instance then
        if _instance.animationInstance then 
            _instance.animationInstance:stop()
            _instance.animationInstance = nil 
        end
        Dialog.OnClose(_instance)		
        _instance = nil
    end
end

function Addndpointintro:OnClose()
    Addndpointintro.DestroyDialog()
end

function Addndpointintro.ToggleOpenClose(parent)
    if not _instance then 
        _instance = Addndpointintro:new() 
        _instance:OnCreate(parent)
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end


function Addndpointintro.GetLayoutFileName()
    return "Addneidanhc.layout"
end

function Addndpointintro:OnCreate(parent)
    Dialog.OnCreate(self, parent)
    local winMgr = CEGUI.WindowManager:getSingleton()
    self.basewindow = CEGUI.toPushButton(winMgr:getWindow("Addneidanhc"))
    
    self:GetWindow():setVisible(false) 
    local aniMan = CEGUI.AnimationManager:getSingleton()
    local animationOpen = aniMan:getAnimation("neidanhc") 
    self.animationInstance = aniMan:instantiateAnimation(animationOpen) 
    self.animationInstance:setTargetWindow(self:GetWindow())
    self.animationInstance:start()--
	
	self.hechengtishi = CEGUI.toRichEditbox(winMgr:getWindow("Addneidanhc/bg/tishi/1"))
	self.hechengtishi:Clear()
    self.hechengtishi:AppendParseText(CEGUI.String(MHSD_UTILS.get_resstring(7412)))
    self.hechengtishi:Refresh()
	
	self.hcjmTabBtn1 = CEGUI.toGroupButton(winMgr:getWindow("Addneidanhc/bg/wuli"))
	self.jiemian1 = winMgr:getWindow("Addneidanhc/attriView1")
	self.hcjmTabBtn1:subscribeEvent("SelectStateChanged", Addndpointintro.hechengTypeTab, self)
	
	self.hcjmTabBtn2 = CEGUI.toGroupButton(winMgr:getWindow("Addneidanhc/bg/fashu"))
	self.jiemian2 = winMgr:getWindow("Addneidanhc/attriView2")
	self.hcjmTabBtn2:subscribeEvent("SelectStateChanged", Addndpointintro.hechengTypeTab, self)
	
	self.hcjmTabBtn3 = CEGUI.toGroupButton(winMgr:getWindow("Addneidanhc/bg/fuzhu"))
	self.jiemian3 = winMgr:getWindow("Addneidanhc/attriView3")
	self.hcjmTabBtn3:subscribeEvent("SelectStateChanged", Addndpointintro.hechengTypeTab, self)
	
	self.hcjmTabBtn4 = CEGUI.toGroupButton(winMgr:getWindow("Addneidanhc/bg/gaoji"))
	self.jiemian4 = winMgr:getWindow("Addneidanhc/attriView4")
	self.hcjmTabBtn4:subscribeEvent("SelectStateChanged", Addndpointintro.hechengTypeTab, self)
	
	self.gaoji1Btn = CEGUI.toGroupButton(winMgr:getWindow("Addneidanhc/bg/gaoji1")) 
    self.nei1 = winMgr:getWindow("Addneidanhc/nei1") 
    self.gaoji1Btn:subscribeEvent("SelectStateChanged", Addndpointintro.hechengTypeTab, self) 
    
    self.gaoji2Btn = CEGUI.toGroupButton(winMgr:getWindow("Addneidanhc/bg/gaoji2"))
    self.nei2 = winMgr:getWindow("Addneidanhc/nei2")
    self.gaoji2Btn:subscribeEvent("SelectStateChanged", Addndpointintro.hechengTypeTab, self) 
    
    self.gaoji3Btn = CEGUI.toGroupButton(winMgr:getWindow("Addneidanhc/bg/gaoji3"))
    self.nei3 = winMgr:getWindow("Addneidanhc/nei3")
    self.gaoji3Btn:subscribeEvent("SelectStateChanged", Addndpointintro.hechengTypeTab, self) 
    
    self.nei2:setVisible(false)
    self.nei3:setVisible(false)
    self:showSubPanel(self.nei1)  
    self.gaoji1Btn:setSelected(true) 


    local scrollPane1 = CEGUI.Window.toScrollablePane(winMgr:getWindow("Addneidanhc/huadong1"))
    self.wlhcButtons = {}
    self.wlhcServiceIds = {}  
    for i = 1, 20 do
        self.wlhcButtons[i] = CEGUI.Window.toPushButton(winMgr:getWindow("Addneidanhc/wlhc" .. i))
        scrollPane1:addChildWindow(self.wlhcButtons[i])
        self.wlhcServiceIds[i] = 254900 + i - 1  
        self.wlhcButtons[i]:subscribeEvent("Clicked", function()
            self:hechenc(self.wlhcServiceIds[i]) 
        end)
    end
 
 
 
    local scrollPane2 = CEGUI.Window.toScrollablePane(winMgr:getWindow("Addneidanhc/huadong2"))---≤‚ ‘∫œ≥…cc
    self.hcButtons2 = {}
    self.hcServiceIds = {
        254920, 254921, 254922, 254923, 254924,
        254925, 254926, 254927, 254928, 254929,
        254930, 254931, 254932, 254933, 254934,
        254935, 254936, 254937, 254938, 254939
    }
    for i = 1, 20 do
        self.hcButtons2[i] = CEGUI.Window.toPushButton(winMgr:getWindow("Addneidanhc/hc" .. i))
        scrollPane2:addChildWindow(self.hcButtons2[i])
        self.hcButtons2[i]:subscribeEvent("Clicked", function()
            self:hechenc(self.hcServiceIds[i])
        end)
    end
	
	local scrollPane3 = CEGUI.Window.toScrollablePane(winMgr:getWindow("Addneidanhc/huadong3"))
    self.fzhcButtons = {}  
    self.fzhcServiceIds = {}  

    for i = 1, 20 do
        self.fzhcButtons[i] = CEGUI.Window.toPushButton(winMgr:getWindow("Addneidanhc/fzhc" .. i))
        scrollPane3:addChildWindow(self.fzhcButtons[i])
        self.fzhcServiceIds[i] = 254940 + i - 1 
        self.fzhcButtons[i]:subscribeEvent("Clicked", function()
            self:hechenc(self.fzhcServiceIds[i]) 
        end)
    end
    local scrollPane4 = CEGUI.Window.toScrollablePane(winMgr:getWindow("Addneidanhc/huadong4"))
    self.gaojiwlButtons = {}
    self.gaojiwlServiceIds = {}

    for i = 1, 12 do
        self.gaojiwlButtons[i] = CEGUI.Window.toPushButton(winMgr:getWindow("Addneidanhc/gaojiwl" .. i))
        scrollPane4:addChildWindow(self.gaojiwlButtons[i])
        self.gaojiwlServiceIds[i] = 254960 + i - 1
        self.gaojiwlButtons[i]:subscribeEvent("Clicked", function()
            self:hechenc(self.gaojiwlServiceIds[i])
        end)
    end

    local scrollPane5 = CEGUI.Window.toScrollablePane(winMgr:getWindow("Addneidanhc/huadong5"))
    self.gaojifsButtons = {}
    self.gaojifsServiceIds = {}
    for i = 1, 12 do
        self.gaojifsButtons[i] = CEGUI.Window.toPushButton(winMgr:getWindow("Addneidanhc/gaojifs" .. i))
        scrollPane5:addChildWindow(self.gaojifsButtons[i])
        self.gaojifsServiceIds[i] = 254972 + i - 1
        self.gaojifsButtons[i]:subscribeEvent("Clicked", function()
            self:hechenc(self.gaojifsServiceIds[i])
        end)
    end

    local scrollPane6 = CEGUI.Window.toScrollablePane(winMgr:getWindow("Addneidanhc/huadong6"))
    self.gaojifzButtons = {}
    self.gaojifzServiceIds = {}
    for i = 1, 12 do
        self.gaojifzButtons[i] = CEGUI.Window.toPushButton(winMgr:getWindow("Addneidanhc/gaojifz" .. i))
        scrollPane6:addChildWindow(self.gaojifzButtons[i])
        self.gaojifzServiceIds[i] = 254984 + i - 1
        self.gaojifzButtons[i]:subscribeEvent("Clicked", function()
            self:hechenc(self.gaojifzServiceIds[i])
        end)
    end
end

function Addndpointintro:hechengTypeTab()
    local selectedBtn = self.hcjmTabBtn1:getSelectedButtonInGroup()

    if self.hcjmTabBtn1 == selectedBtn then
        self:showPanel(self.jiemian1)
        self.hechengtishi:setVisible(true)  
    elseif self.hcjmTabBtn2 == selectedBtn then
        self:showPanel(self.jiemian2)
        self.hechengtishi:setVisible(true) 
    elseif self.hcjmTabBtn3 == selectedBtn then
        self:showPanel(self.jiemian3)
        self.hechengtishi:setVisible(true)
    elseif self.hcjmTabBtn4 == selectedBtn then
        self:showPanel(self.jiemian4)
        self.hechengtishi:setVisible(false)  
    end
    local gaojiSelectedBtn = self.gaoji1Btn:getSelectedButtonInGroup() 
    if self.gaoji1Btn == gaojiSelectedBtn then
            self:showSubPanel(self.nei1)
    elseif self.gaoji2Btn == gaojiSelectedBtn then
            self:showSubPanel(self.nei2)
    elseif self.gaoji3Btn == gaojiSelectedBtn then
            self:showSubPanel(self.nei3)
    end
end


function Addndpointintro:showPanel(panelToShow) 
    for i=1, 4 do
        local panel = self["jiemian"..i] 
        if panel == panelToShow then 
            panel:setVisible(true)
        else
            panel:setVisible(false)
        end
    end
end

function Addndpointintro:showSubPanel(panelToShow)
    self.nei1:setVisible(false)
    self.nei2:setVisible(false)
    self.nei3:setVisible(false)

    panelToShow:setVisible(true) 
end

function Addndpointintro:hechenc(nServiceId)
    local nNpcKey = 0
    require "manager.npcservicemanager".SendNpcService(nNpcKey, nServiceId)
end

function Addndpointintro:HandleBaseBgClicked(args)
    self.DestroyDialog()
end

return Addndpointintro