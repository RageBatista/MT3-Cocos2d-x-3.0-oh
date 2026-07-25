
require "logic.dialog"

Itemopenlockdialog = {}
setmetatable(Itemopenlockdialog, Dialog)
Itemopenlockdialog.__index = Itemopenlockdialog

local _instance = nil

Itemopenlockdialog.eCallBackType = 
{
    success = 1,
    failed=2,
}


function Itemopenlockdialog.getInstanceAndShow()
	if not _instance then
		_instance = Itemopenlockdialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function Itemopenlockdialog.getInstanceNotCreate()
    return _instance
end


function Itemopenlockdialog.DestroyDialog()
    if _instance then
        _instance:OnClose()
        _instance = nil
    end
end

function Itemopenlockdialog:clearData()
    self.mapCallBack = {}
end

function Itemopenlockdialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Itemopenlockdialog)
    self:clearData()
	return self
end

function Itemopenlockdialog:OnClose()
    Dialog.OnClose(self)
end

function Itemopenlockdialog:OnCreate(parent,strPrefix)
    Dialog.OnCreate(self,parent,strPrefix)
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.richboxPsd1 = CEGUI.toRichEditbox(winMgr:getWindow("anquansuoshiyong/shurukuang/box1"))
    self.labelNotice1 = winMgr:getWindow("anquansuoshiyong/shurukuang/box1/placeholder")
    self.richboxPsd1:subscribeEvent("KeyboardTargetWndChanged", Itemopenlockdialog.OnKeyboardTargetWndChanged, self)

    self.btnConfirm =  CEGUI.toPushButton(winMgr:getWindow("anquansuoshiyong/btn"))
    self.btnConfirm:subscribeEvent("MouseClick", Itemopenlockdialog.clickConfirm, self)

    self.btnClose =  CEGUI.toPushButton(winMgr:getWindow("anquansuoshiyong/guanbi"))
    self.btnClose:subscribeEvent("MouseClick", Itemopenlockdialog.clickClose, self)

end

function Itemopenlockdialog:setDelegate(pTarget,callBackType,callBack)
    self.mapCallBack[callBackType] = {}
    self.mapCallBack[callBackType].pTarget = pTarget
    self.mapCallBack[callBackType].callBack = callBack
end

function Itemopenlockdialog:callEvent(eType)
    local callBackData =  self.mapCallBack[eType]
    if not callBackData then
        return
    end
    if not callBackData.pTarget then
        return
    end
    callBackData.callBack(callBackData.pTarget,self)
end

function Itemopenlockdialog:protocolResult(bSuccess)
    if bSuccess then
        self:callEvent(Itemopenlockdialog.eCallBackType.success)
    else
        self:callEvent(Itemopenlockdialog.eCallBackType.failed)
    end
    Itemopenlockdialog.DestroyDialog()
end

function Itemopenlockdialog:OnKeyboardTargetWndChanged(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    if wnd == self.richboxPsd1 then
        self.labelNotice1:setVisible(false)
    elseif self.richboxPsd1:GenerateParseText(false) == "" then
        self.labelNotice1:setVisible(true)
    end
end

function Itemopenlockdialog:clickConfirm(args)
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

    local p =  require("protodef.fire.pb.cgoodunlock"):new()
    p.password = strPsd1
    LuaProtocolManager:send(p)
end

function Itemopenlockdialog:clickClose(args)
    Itemopenlockdialog.DestroyDialog()
end

function Itemopenlockdialog:GetLayoutFileName()
	return "anquansuoshiyong.layout"
end

return Itemopenlockdialog