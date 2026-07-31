
require "logic.dialog"

Itemnewpsddialog = {}
setmetatable(Itemnewpsddialog, Dialog)
Itemnewpsddialog.__index = Itemnewpsddialog

local _instance = nil

function Itemnewpsddialog.getInstanceAndShow()
	if not _instance then
		_instance = Itemnewpsddialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function Itemnewpsddialog.getInstanceNotCreate()
    return _instance
end

function Itemnewpsddialog:clearData()
    
end

function Itemnewpsddialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Itemnewpsddialog)
    self:clearData()
	return self
end

function Itemnewpsddialog.DestroyDialog()
    if _instance then
        _instance:OnClose()
        _instance = nil
    end
end



function Itemnewpsddialog:OnClose()
    Dialog.OnClose(self)
end

function Itemnewpsddialog:OnCreate()
    Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.richboxPsd1 = CEGUI.toRichEditbox(winMgr:getWindow("anquansuomimachongzhi/shurukuang/box"))
    self.labelNotice1 = winMgr:getWindow("anquansuomimachongzhi/shurukuang/box/placeholder")
    self.richboxPsd1:subscribeEvent("KeyboardTargetWndChanged", Itemnewpsddialog.OnKeyboardTargetWndChanged, self)

    self.richboxPsd2 = CEGUI.toRichEditbox(winMgr:getWindow("anquansuomimachongzhi/shurukuang/box1"))
    self.labelNotice2 = winMgr:getWindow("anquansuomimachongzhi/shurukuang/box1/placeholder")
    self.richboxPsd2:subscribeEvent("KeyboardTargetWndChanged", Itemnewpsddialog.OnKeyboardTargetWndChanged2, self)

    self.richboxPsd3 = CEGUI.toRichEditbox(winMgr:getWindow("anquansuomimachongzhi/shurukuang/box11"))
    self.labelNotice3 = winMgr:getWindow("anquansuomimachongzhi/shurukuang/box1/placeholder1")
    self.richboxPsd3:subscribeEvent("KeyboardTargetWndChanged", Itemnewpsddialog.OnKeyboardTargetWndChanged3, self)

    self.btnConfirm =  CEGUI.toPushButton(winMgr:getWindow("anquansuomimachongzhi/btn"))
    self.btnConfirm:subscribeEvent("MouseClick", Itemnewpsddialog.clickConfirm, self)

    
    self.btnClose =  CEGUI.toPushButton(winMgr:getWindow("anquansuomimachongzhi/guanbi"))
    self.btnClose:subscribeEvent("MouseClick", Itemnewpsddialog.clickClose, self)

end

function Itemnewpsddialog:clickClose(args)
    Itemnewpsddialog.DestroyDialog()

end

function Itemnewpsddialog:OnKeyboardTargetWndChanged(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    if wnd == self.richboxPsd1 then
        self.labelNotice1:setVisible(false)
    elseif self.richboxPsd1:GenerateParseText(false) == "" then
        self.labelNotice1:setVisible(true)
    end
end

function Itemnewpsddialog:OnKeyboardTargetWndChanged2(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    if wnd == self.richboxPsd2 then
        self.labelNotice2:setVisible(false)
    elseif self.richboxPsd2:GenerateParseText(false) == "" then
        self.labelNotice2:setVisible(true)
    end
end

function Itemnewpsddialog:OnKeyboardTargetWndChanged3(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    if wnd == self.richboxPsd3 then
        self.labelNotice3:setVisible(false)
    elseif self.richboxPsd3:GenerateParseText(false) == "" then
        self.labelNotice3:setVisible(true)
    end
end

function Itemnewpsddialog:clickConfirm(args)
    local strPsd1 = self.richboxPsd1:GetPureText()
    local strPsd2 = self.richboxPsd2:GetPureText()
    local strPsd3 = self.richboxPsd3:GetPureText()

    if strPsd1 =="" or  strPsd2=="" or strPsd3=="" then
        GetCTipsManager():AddMessageTipById(191035)
        return
    end

    if string.len(strPsd1) < 4 or string.len(strPsd2)<4 or string.len(strPsd3)<4 then
        GetCTipsManager():AddMessageTipById(191040)
        return
    end

    local bHaveSpecialCahr1 = g_isHaveSpecialChar(strPsd1)
    local bHaveSpecialCahr2 = g_isHaveSpecialChar(strPsd2)
    local bHaveSpecialCahr3 = g_isHaveSpecialChar(strPsd3)

    if bHaveSpecialCahr1==true or bHaveSpecialCahr2==true or bHaveSpecialCahr3==true then
        GetCTipsManager():AddMessageTipById(191034)
        return 
    end

    if strPsd2 ~= strPsd3 then
        GetCTipsManager():AddMessageTipById(191025)
        return
    end

    local p =  require("protodef.fire.pb.cresetpassword"):new()
    p.initpd = self.richboxPsd1:GetPureText()
    p.newtpd = self.richboxPsd2:GetPureText()
    p.repeatpd = self.richboxPsd3:GetPureText()
    LuaProtocolManager:send(p)

    self.strLockPsd = strPsd2
    --Itemnewpsddialog.DestroyDialog()
end




function Itemnewpsddialog:GetLayoutFileName()
	return "anquansuomimachongzhi.layout"
end


return Itemnewpsddialog