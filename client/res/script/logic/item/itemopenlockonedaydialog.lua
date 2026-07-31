
require "logic.dialog"

Itemopenlockonedaydialog = {}
setmetatable(Itemopenlockonedaydialog, Dialog)
Itemopenlockonedaydialog.__index = Itemopenlockonedaydialog

local _instance = nil

function Itemopenlockonedaydialog.getInstanceAndShow()
	if not _instance then
		_instance = Itemopenlockonedaydialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function Itemopenlockonedaydialog.DestroyDialog()
    if _instance then
        _instance:OnClose()
        _instance = nil
    end
end

function Itemopenlockonedaydialog:clearData()
    
end

function Itemopenlockonedaydialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Itemopenlockonedaydialog)
    self:clearData()
	return self
end

function Itemopenlockonedaydialog:OnClose()
    Dialog.OnClose(self)
end

function Itemopenlockonedaydialog:OnCreate(parent,strPrefix)
    Dialog.OnCreate(self,parent,strPrefix)
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.richboxPsd1 = CEGUI.toRichEditbox(winMgr:getWindow("anquansuozanshijiechu/shurukuang/box1"))
    self.labelNotice1 = winMgr:getWindow("anquansuozanshijiechu/shurukuang/box1/placeholder")
    self.richboxPsd1:subscribeEvent("KeyboardTargetWndChanged", Itemopenlockonedaydialog.OnKeyboardTargetWndChanged, self)

    self.btnConfirm =  CEGUI.toPushButton(winMgr:getWindow("anquansuozanshijiechu/btn"))
    self.btnConfirm:subscribeEvent("MouseClick", Itemopenlockonedaydialog.clickConfirm, self)

    self.btnCancel = CEGUI.toPushButton(winMgr:getWindow("anquansuozanshijiechu/btn1"))
    self.btnCancel:subscribeEvent("MouseClick", Itemopenlockonedaydialog.clickCancel, self)

    self.btnClose =  CEGUI.toPushButton(winMgr:getWindow("anquansuozanshijiechu/guanbi"))
    self.btnClose:subscribeEvent("MouseClick", Itemopenlockonedaydialog.clickClose, self)

end

function Itemopenlockonedaydialog:clickCancel(args)
     Itemopenlockonedaydialog.DestroyDialog()
end

function Itemopenlockonedaydialog:OnKeyboardTargetWndChanged(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    if wnd == self.richboxPsd1 then
        self.labelNotice1:setVisible(false)
    elseif self.richboxPsd1:GenerateParseText(false) == "" then
        self.labelNotice1:setVisible(true)
    end
end

function Itemopenlockonedaydialog:clickConfirm(args)
    local strPsd1 = self.richboxPsd1:GetPureText()
    if strPsd1 =="" then
        GetCTipsManager():AddMessageTipById(191035)
        return
    end

     if string.len(strPsd1) < 4 then
        GetCTipsManager():AddMessageTipById(191040)
        return
    end

    local bHaveSpecialCahr1 = g_isHaveSpecialChar(strPsd1)
    if bHaveSpecialCahr1 then
        GetCTipsManager():AddMessageTipById(191034)
        return 
    end

    local p =  require("protodef.fire.pb.cclosegoodlocks"):new()
    p.password = strPsd1
    p.closetype = 1 --1 notice 2 settting
    LuaProtocolManager:send(p)

    Itemopenlockonedaydialog.DestroyDialog()
end

function Itemopenlockonedaydialog:clickClose(args)
    Itemopenlockonedaydialog.DestroyDialog()
end

function Itemopenlockonedaydialog:GetLayoutFileName()
	return "anquansuozanshijiechu.layout"
end

return Itemopenlockonedaydialog