
require "logic.dialog"

Itemdeletelockdialog = {}
setmetatable(Itemdeletelockdialog, Dialog)
Itemdeletelockdialog.__index = Itemdeletelockdialog

local _instance = nil

function Itemdeletelockdialog.getInstanceAndShow()
	if not _instance then
		_instance = Itemdeletelockdialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function Itemdeletelockdialog.getInstanceNotCreate()
    return _instance
end


function Itemdeletelockdialog:clearData()
    
end

function Itemdeletelockdialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Itemdeletelockdialog)
    self:clearData()
	return self
end

function Itemdeletelockdialog.DestroyDialog()
    if _instance then
        _instance:OnClose()
        _instance = nil
    end
end

function Itemdeletelockdialog:OnClose()
    Dialog.OnClose(self)
end

function Itemdeletelockdialog:OnCreate()
    Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.richboxPsd1 = CEGUI.toRichEditbox(winMgr:getWindow("anquansuomimajiechu/shurukuang/box"))
    self.labelNotice1 = winMgr:getWindow("anquansuomimajiechu/shurukuang/box/placeholder")
    self.richboxPsd1:subscribeEvent("KeyboardTargetWndChanged", Itemdeletelockdialog.OnKeyboardTargetWndChanged, self)

    self.richboxPsd2 = CEGUI.toRichEditbox(winMgr:getWindow("anquansuomimajiechu/shurukuang/box1"))
    self.labelNotice2 = winMgr:getWindow("anquansuomimajiechu/shurukuang/box1/placeholder")
    self.richboxPsd2:subscribeEvent("KeyboardTargetWndChanged", Itemdeletelockdialog.OnKeyboardTargetWndChanged2, self)

    self.btnConfirm =  CEGUI.toPushButton(winMgr:getWindow("anquansuomimajiechu/btn"))
    self.btnConfirm:subscribeEvent("MouseClick", Itemdeletelockdialog.clickConfirm, self)

    
    self.btnClose =  CEGUI.toPushButton(winMgr:getWindow("anquansuomimajiechu/guanbi"))
    self.btnClose:subscribeEvent("MouseClick", Itemdeletelockdialog.clickClose, self)
    
end

function Itemdeletelockdialog:clickClose(args)
    Itemdeletelockdialog.DestroyDialog()

end

function Itemdeletelockdialog:OnKeyboardTargetWndChanged(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    if wnd == self.richboxPsd1 then
        self.labelNotice1:setVisible(false)
    elseif self.richboxPsd1:GenerateParseText(false) == "" then
        self.labelNotice1:setVisible(true)
    end
end

function Itemdeletelockdialog:OnKeyboardTargetWndChanged2(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    if wnd == self.richboxPsd2 then
        self.labelNotice2:setVisible(false)
    elseif self.richboxPsd2:GenerateParseText(false) == "" then
        self.labelNotice2:setVisible(true)
    end
end

function Itemdeletelockdialog:clickConfirm(args)
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

    local p =  require("protodef.fire.pb.cdelpassword"):new()
    p.initpd = self.richboxPsd1:GetPureText()
    p.repeatpd = self.richboxPsd2:GetPureText()
    LuaProtocolManager:send(p)

    --Itemdeletelockdialog.DestroyDialog()
end




function Itemdeletelockdialog:GetLayoutFileName()
	return "anquansuomimajiechu.layout"
end


return Itemdeletelockdialog