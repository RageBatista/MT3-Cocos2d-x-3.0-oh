-- 公会UI的标签

require "logic.dialog"
Familylabelframe = { }

setmetatable(Familylabelframe, Dialog)
Familylabelframe.__index = Familylabelframe

local _instance

function Familylabelframe.getInstance()
    if not _instance then
        _instance = Familylabelframe:new()
        _instance:OnCreate()
    end
    return _instance
end

function Familylabelframe.getInstanceAndShow()
    if not _instance then
        _instance = Familylabelframe:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function Familylabelframe.getInstanceNotCreate()
    return _instance
end

function Familylabelframe:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, Familylabelframe)
    return self
end

function Familylabelframe.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide and _instance.m_CurDialog then
            local window = _instance.m_CurDialog:GetWindow()
            if not window then
                return
            end
            _instance:removeEvent(window)
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function Familylabelframe.GetLayoutFileName()
    return "Lablebp.layout"
end

function Familylabelframe:OnCreate()
    Dialog.OnCreate(self, nil, "familylabel")
    self:GetWindow():setRiseOnClickEnabled(false)

    local winMgr = CEGUI.WindowManager:getSingleton()

    -- 信息
    self.m_pButton1 = CEGUI.toPushButton(winMgr:getWindow("familylabelLable/button"))
    self.m_pButton1:SetMouseLeaveReleaseInput(false)
    self.m_pButton1:setText(MHSD_UTILS.get_resstring(11231))
    self.m_pButton1:EnableClickAni(false)
    self.m_pButton1:subscribeEvent("Clicked", Familylabelframe.HandleLabel1BtnClicked, self)

    -- 成员
    self.m_pButton2 = CEGUI.toPushButton(winMgr:getWindow("familylabelLable/button1"))
    self.m_pButton2:SetMouseLeaveReleaseInput(false)
    self.m_pButton2:setText(MHSD_UTILS.get_resstring(11232))
    self.m_pButton2:EnableClickAni(false)
    self.m_pButton2:subscribeEvent("Clicked", Familylabelframe.HandleLabel2BtnClicked, self)

    -- 福利
    self.m_pButton3 = CEGUI.toPushButton(winMgr:getWindow("familylabelLable/button2"))
    self.m_pButton3:SetMouseLeaveReleaseInput(false)
    self.m_pButton3:setText(MHSD_UTILS.get_resstring(11233))
    self.m_pButton3:EnableClickAni(false)
    self.m_pButton3:subscribeEvent("Clicked", Familylabelframe.HandleLabel3BtnClicked, self)

    -- 活动
    self.m_pButton4 = CEGUI.toPushButton(winMgr:getWindow("familylabelLable/button3"))
    self.m_pButton4:SetMouseLeaveReleaseInput(false)
    self.m_pButton4:setText(MHSD_UTILS.get_resstring(11234))
    self.m_pButton4:EnableClickAni(false)
    self.m_pButton4:subscribeEvent("Clicked", Familylabelframe.HandleLabel4BtnClicked, self)

    -- 成员标签的红点
    self.ChengyuanImageTips = winMgr:getWindow("familylabelLable/button/image2")
    self.FuliImageTips = winMgr:getWindow("familylabelLable/button/image3")

    self.m_PageIndex = -1
    self:ShowPage(1)

    -- 显示红点公会
    local datamanager = require "logic.faction.factiondatamanager"
    if datamanager then
        if datamanager.m_FactionTips then
            self.ChengyuanImageTips:setVisible(datamanager.m_FactionTips[1] == 1)
        end
        if datamanager.bonus > 0 then
            self.FuliImageTips:setVisible(true)
        end
    end
end

-- 设置标签的状态
function Familylabelframe:SetPage(index)
    self.m_pButton1:SetPushState(false)
    self.m_pButton2:SetPushState(false)
    self.m_pButton3:SetPushState(false)
    self.m_pButton4:SetPushState(false)
    if index == 1 then
        self.m_pButton1:SetPushState(true)
    elseif index == 2 then
        self.m_pButton2:SetPushState(true)
    elseif index == 3 then
        self.m_pButton3:SetPushState(true)
    elseif index == 4 then
        self.m_pButton4:SetPushState(true)
    end
end

-- 显示标签页
function Familylabelframe:ShowPage(index)
    if not index then
        return
    end
    if not self.m_PageIndex then
        return
    end
    if self.m_PageIndex == index then
        self:SetPage(index)
        return
    end

    if self.m_CurDialog then
        self:removeEvent(self.m_CurDialog:GetWindow())
    end

    self.m_PageIndex = index
    self:SetPage(index)

    Family.DestroyDialog(false)
    Familychengyuandialog.DestroyDialog(false)
    Familyhuodongdialog.DestroyDialog(false)
    Familyfulidialog.DestroyDialog(false)
    self.m_CurDialog = nil
    if index == 1 then
        self.m_CurDialog = Family.getInstanceAndShow()
    elseif index == 2 then
        self.m_CurDialog = Familychengyuandialog.getInstanceAndShow()
    elseif index == 3 then
        self.m_CurDialog = Familyfulidialog.getInstanceAndShow()
    elseif index == 4 then
        self.m_CurDialog = Familyhuodongdialog.getInstanceAndShow()
    end

    if self.m_CurDialog then
        self:subscribeEvent(self.m_CurDialog:GetWindow())
        self:GetWindow():getParent():bringWindowAbove(self:GetWindow(), self.m_CurDialog:GetWindow())
    end

end

-- 处理点击信息标签
function Familylabelframe:HandleLabel1BtnClicked(e)
    self:ShowPage(1)
    return true
end

-- 处理点击成员标签
function Familylabelframe:HandleLabel2BtnClicked(e)
    self:ShowPage(2)
    return true
end

-- 处理点击福利标签
function Familylabelframe:HandleLabel3BtnClicked(e)
    self:ShowPage(3)
    return true
end

-- 处理点击活动标签
function Familylabelframe:HandleLabel4BtnClicked(e)
    self:ShowPage(4)
    return true
end

-- 处理显示相关的事件
function Familylabelframe:handleDlgStateChangeShow(args)
    if not self.m_CurDialog then
        return
    end
    local window = self.m_CurDialog:GetWindow()
    if not window then
        return
    end
    if self.m_CurDialog:IsVisible() and window:getEffectiveAlpha() > 0.95 then
        self:SetVisible(true)
        return
    end
    self:SetVisible(false)
end

-- 注册显示相关的事件
function Familylabelframe:subscribeEvent(wnd)
    if not wnd then
        return
    end
    wnd:subscribeEvent("AlphaChanged", Familylabelframe.handleDlgStateChangeShow, self)
    wnd:subscribeEvent("Shown", Familylabelframe.handleDlgStateChangeShow, self)
    wnd:subscribeEvent("Hidden", Familylabelframe.handleDlgStateChangeShow, self)
    wnd:subscribeEvent("InheritAlphaChanged", Familylabelframe.handleDlgStateChangeShow, self)
end

-- 删除显示相关的事件
function Familylabelframe:removeEvent(wnd)
    if not wnd then
        return
    end
    wnd:removeEvent("Shown")
    wnd:removeEvent("Hidden")
    wnd:removeEvent("AlphaChanged")
    wnd:removeEvent("InheritAlphaChanged")
end

return Familylabelframe
