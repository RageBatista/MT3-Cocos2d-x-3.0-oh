
require "logic.dialog"

ItemcloseLockinputpsddialog = {}
setmetatable(ItemcloseLockinputpsddialog, Dialog)
ItemcloseLockinputpsddialog.__index = ItemcloseLockinputpsddialog

local _instance = nil

function ItemcloseLockinputpsddialog.getInstanceAndShow()
	if not _instance then
		_instance = ItemcloseLockinputpsddialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ItemcloseLockinputpsddialog.getInstanceNotCreate()
    return _instance
end

function ItemcloseLockinputpsddialog.DestroyDialog()
    if _instance then
        _instance:OnClose()
        _instance = nil
        local sysDlg = require("logic.systemsettingdlgnew").getInstanceNotCreate()
        if sysDlg then
            sysDlg:refreshItemLockState()
        end
    end
end

function ItemcloseLockinputpsddialog:clearData()
    self.mapCallBack = {}
end

function ItemcloseLockinputpsddialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ItemcloseLockinputpsddialog)
    self:clearData()
	return self
end

function ItemcloseLockinputpsddialog:OnClose()
    Dialog.OnClose(self)
end

function ItemcloseLockinputpsddialog:OnCreate(parent)
    local strPrefix = "ItemcloseLockinputpsddialog"
    Dialog.OnCreate(self,parent,strPrefix)
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.richboxPsd1 = CEGUI.toRichEditbox(winMgr:getWindow(strPrefix.."anquansuoshiyong/shurukuang/box1"))
    self.labelNotice1 = winMgr:getWindow(strPrefix.."anquansuoshiyong/shurukuang/box1/placeholder")
    self.richboxPsd1:subscribeEvent("KeyboardTargetWndChanged", ItemcloseLockinputpsddialog.OnKeyboardTargetWndChanged, self)

    self.btnConfirm =  CEGUI.toPushButton(winMgr:getWindow(strPrefix.."anquansuoshiyong/btn"))
    self.btnConfirm:subscribeEvent("MouseClick", ItemcloseLockinputpsddialog.clickConfirm, self)

    self.btnClose =  CEGUI.toPushButton(winMgr:getWindow(strPrefix.."anquansuoshiyong/guanbi"))
    self.btnClose:subscribeEvent("MouseClick", ItemcloseLockinputpsddialog.clickClose, self)

end

function ItemcloseLockinputpsddialog:OnKeyboardTargetWndChanged(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    if wnd == self.richboxPsd1 then
        self.labelNotice1:setVisible(false)
    elseif self.richboxPsd1:GenerateParseText(false) == "" then
        self.labelNotice1:setVisible(true)
    end
end

function ItemcloseLockinputpsddialog:clickConfirm(args)
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
    LuaProtocolManager:send(p)
end

function ItemcloseLockinputpsddialog:clickClose(args)
    ItemcloseLockinputpsddialog.DestroyDialog()
end

function ItemcloseLockinputpsddialog:GetLayoutFileName()
	return "anquansuoshiyong.layout"
end

return ItemcloseLockinputpsddialog