
require "logic.dialog"

Itemsetpassworddialog = {}
setmetatable(Itemsetpassworddialog, Dialog)
Itemsetpassworddialog.__index = Itemsetpassworddialog

local _instance = nil

function Itemsetpassworddialog.getInstanceAndShow()
	if not _instance then
		_instance = Itemsetpassworddialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function Itemsetpassworddialog.getInstanceNotCreate()
    return _instance
end

function Itemsetpassworddialog:clearData()
    self.strLockPsd = ""
end

function Itemsetpassworddialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Itemsetpassworddialog)
    self:clearData()
	return self
end

function Itemsetpassworddialog.DestroyDialog()
    if  _instance then
        _instance:OnClose()
        _instance = nil
    end
end

function Itemsetpassworddialog:OnClose()
    Dialog.OnClose(self)
end

function Itemsetpassworddialog:OnCreate(parent,strPrefix)
    Dialog.OnCreate(self,parent,strPrefix)
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.richboxPsd1 = CEGUI.toRichEditbox(winMgr:getWindow("anquansuomimashezhi/shurukuang/box"))
    self.labelNotice1 = winMgr:getWindow("anquansuomimashezhi/shurukuang/box/placeholder")
    self.richboxPsd1:subscribeEvent("KeyboardTargetWndChanged", Itemsetpassworddialog.OnKeyboardTargetWndChanged, self)

    self.richboxPsd2 = CEGUI.toRichEditbox(winMgr:getWindow("anquansuomimashezhi/shurukuang/box1"))
    self.labelNotice2 = winMgr:getWindow("anquansuomimashezhi/shurukuang/box1/placeholder")
    self.richboxPsd2:subscribeEvent("KeyboardTargetWndChanged", Itemsetpassworddialog.OnKeyboardTargetWndChanged2, self)

    self.btnConfirm =  CEGUI.toPushButton(winMgr:getWindow("anquansuomimashezhi/btn"))
    self.btnConfirm:subscribeEvent("MouseClick", Itemsetpassworddialog.clickConfirm, self)

    self.btnClose =  CEGUI.toPushButton(winMgr:getWindow("anquansuomimashezhi/guanbi"))
    self.btnClose:subscribeEvent("MouseClick", Itemsetpassworddialog.clickClose, self)
    

end

function Itemsetpassworddialog:clickClose(args)
    Itemsetpassworddialog.DestroyDialog()

end

function Itemsetpassworddialog:OnKeyboardTargetWndChanged(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    if wnd == self.richboxPsd1 then
        self.labelNotice1:setVisible(false)
    elseif self.richboxPsd1:GenerateParseText(false) == "" then
        self.labelNotice1:setVisible(true)
    end
end

function Itemsetpassworddialog:OnKeyboardTargetWndChanged2(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    if wnd == self.richboxPsd2 then
        self.labelNotice2:setVisible(false)
    elseif self.richboxPsd2:GenerateParseText(false) == "" then
        self.labelNotice2:setVisible(true)
    end
end

function Itemsetpassworddialog:clickConfirm(args)

    local strPsd1 = self.richboxPsd1:GetPureText()
    local strPsd2 = self.richboxPsd2:GetPureText()
    if strPsd1 =="" or  strPsd2=="" then
        GetCTipsManager():AddMessageTipById(191035)
        return
    end

    if string.len(strPsd1) < 4 or string.len(strPsd2)<4 then
        GetCTipsManager():AddMessageTipById(191040)
        return
    end

    local bHaveSpecialCahr1 = g_isHaveSpecialChar(strPsd1)
    local bHaveSpecialCahr2 = g_isHaveSpecialChar(strPsd2)

    if bHaveSpecialCahr1==true or bHaveSpecialCahr2==true then
        GetCTipsManager():AddMessageTipById(191034)
        return 
    end

    if strPsd1 ~= strPsd2 then
        GetCTipsManager():AddMessageTipById(191025)
        return
    end
    

    local p =  require("protodef.fire.pb.csetpassword"):new()
    p.initpd = strPsd1
    p.repeatpd = strPsd2
    LuaProtocolManager:send(p)

    self.strLockPsd = strPsd1
    --Itemsetpassworddialog.DestroyDialog()

end




function Itemsetpassworddialog:GetLayoutFileName()
	return "anquansuomimashezhi.layout"
end


return Itemsetpassworddialog