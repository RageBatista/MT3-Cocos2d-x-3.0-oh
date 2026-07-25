require "logic.dialog"

Familygaiming1dialog = { }
setmetatable(Familygaiming1dialog, Dialog)
Familygaiming1dialog.__index = Familygaiming1dialog

local _instance
function Familygaiming1dialog.getInstance()
    if not _instance then
        _instance = Familygaiming1dialog:new()
        _instance:OnCreate()
    end
    return _instance
end

function Familygaiming1dialog.getInstanceAndShow()
    if not _instance then
        _instance = Familygaiming1dialog:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function Familygaiming1dialog.getInstanceNotCreate()
    return _instance
end

function Familygaiming1dialog.DestroyDialog()
    if _instance then
	_instance.m_OkBtn.animation:stop()
	_instance.m_CloseBtnEx.animation:stop()
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function Familygaiming1dialog.ToggleOpenClose()
    if not _instance then
        _instance = Familygaiming1dialog:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function Familygaiming1dialog.GetLayoutFileName()
    return "familygaiming1dialog.layout"
end

function Familygaiming1dialog:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, Familygaiming1dialog)
    return self
end

function Familygaiming1dialog:addButtonAnimation(button, animationName)
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation(animationName)
    if animationDef then
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        animation:setTargetWindow(button)
        animation:setSpeed(0.5)
        button.animation = animation
        button:subscribeEvent("MouseButtonDown", function()
            animation:start()
        end, self)
    end
end

function Familygaiming1dialog:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()

    -- 名字输入框
    self.m_NowName = winMgr:getWindow("familygaiming1dialog/name")
    self.m_NewNameInputEditBox = CEGUI.toRichEditbox(winMgr:getWindow("familygaiming1dialog/shurukuang"))
    self.m_NewNameInputEditBox:setMaxTextLength(5)
	self.m_NewNameInputEditBox:SetColourRect(CEGUI.PropertyHelper:stringToColour(self.m_NewNameInputEditBox:getProperty("NormalTextColour")))
    self.m_CostText = winMgr:getWindow("familygaiming1dialog/xiaohao/diban")
    self.m_HasText = winMgr:getWindow("familygaiming1dialog/yongyou/diban")
    self.m_OkBtn = CEGUI.toPushButton(winMgr:getWindow("familygaiming1dialog/OK"))
	self:addButtonAnimation(self.m_OkBtn, "studyBtnPress")
    self.m_CloseBtnEx = CEGUI.toPushButton(winMgr:getWindow("familygaiming1dialog/close"))
	self:addButtonAnimation(self.m_CloseBtnEx, "xstudyBtnPress")

    self.m_CloseBtnEx:subscribeEvent("Clicked", Familygaiming1dialog.OnCloseBtnEx, self)
    self.m_OkBtn:subscribeEvent("Clicked", Familygaiming1dialog.OnYesBtnHandler, self)
    self:Refreshinfor()
end
function Familygaiming1dialog:OnCloseBtnEx(args)
    self:DestroyDialog()
end
-- 点击确认
local confirmtype
local function HuaQianOK()
    gGetMessageManager():CloseConfirmBox(confirmtype, false)
    ShopLabel.showRecharge()
    Familygaiming1dialog.DestroyDialog()
    Family.DestroyDialog()
end
-- 点击改名
function Familygaiming1dialog:OnYesBtnHandler(args)
    local has = gGetDataManager():GetYuanBaoNumber()
    local cost = GameTable.common.GetCCommonTableInstance():getRecorder(171).value
    local msg = MHSD_UTILS.get_msgtipstring(150506)
    if tonumber(has) < tonumber(cost) then
        confirmtype = MHSD_UTILS.addConfirmDialog(msg, HuaQianOK)
        return
    end
    local text = self.m_NewNameInputEditBox:GetPureText()
    local send = require "protodef.fire.pb.clan.cchangeclanname":new()
    send.newname = text
    require "manager.luaprotocolmanager":send(send)
end
-- 刷新消耗
function Familygaiming1dialog:Refreshinfor()
    -- 显示现有名字
    local datamanager = require "logic.faction.factiondatamanager"
    local cost = GameTable.common.GetCCommonTableInstance():getRecorder(171).value
    self.m_CostText:setText(tostring(cost))
    local has = gGetDataManager():GetYuanBaoNumber()
    self.m_HasText:setText(tostring(has))
    self.m_NowName:setText(datamanager.factionname)
end
return Familygaiming1dialog
