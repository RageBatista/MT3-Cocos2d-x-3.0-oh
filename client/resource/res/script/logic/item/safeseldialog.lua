
require "logic.dialog"

Safeseldialog = {}
setmetatable(Safeseldialog, Dialog)
Safeseldialog.__index = Safeseldialog

local _instance = nil

function Safeseldialog.getInstanceAndShow()
	if not _instance then
		_instance = Safeseldialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function Safeseldialog:getInstanceNotCreate()
    return _instance
end

function Safeseldialog:clearData()
   
end

function Safeseldialog.DestroyDialog()
    if  _instance then
        _instance:OnClose()
        _instance = nil
    end
end

function Safeseldialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Safeseldialog)
    self:clearData()
	return self
end

function Safeseldialog:OnClose()
    Dialog.OnClose(self)
end

function Safeseldialog:OnCreate()
    Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()


    self.btnPhoneBind =  CEGUI.toPushButton(winMgr:getWindow("shoujianquan/btn1"))
    self.btnPhoneBind:subscribeEvent("MouseClick", Safeseldialog.clickPhoneBind, self)

    self.btnItemLock =  CEGUI.toPushButton(winMgr:getWindow("shoujianquan/btn2"))
    self.btnItemLock:subscribeEvent("MouseClick", Safeseldialog.clickItemLock, self)

    --self.btnCheckPhone =  CEGUI.toPushButton(winMgr:getWindow("shoujianquan/btn3"))
    --self.btnCheckPhone:subscribeEvent("MouseClick", Safeseldialog.clickCheckPhone, self)

    self:refreshShouJiAnQuan()

end

function Safeseldialog:refreshShouJiAnQuan()
    local strBtn = ""
    local shoujianquanmgr = require "logic.shoujianquan.shoujianquanmgr"
    if shoujianquanmgr.needBindTelAgain() then
        strBtn = MHSD_UTILS.get_resstring(11667)
    else
        if shoujianquanmgr.isBindTel() then
            strBtn = MHSD_UTILS.get_resstring(11666)
        else
            strBtn = MHSD_UTILS.get_resstring(11665)
        end
    end
    self.btnPhoneBind:setText(strBtn)
end

function Safeseldialog:clickPhoneBind(args)
    local shoujianquanmgr = require "logic.shoujianquan.shoujianquanmgr"

    -- 需要验证手机
    if shoujianquanmgr.needBindTelAgain() then
        require("logic.shoujianquan.shoujiguanlianshuru").getInstanceAndShow()
    -- 不需验证手机
    else
        -- 已关联手机，则解除关联
        if shoujianquanmgr.isBindTel() then
            require("logic.shoujianquan.shoujijiechushuru").getInstanceAndShow()
        -- 未关联手机，则关联手机
        else
            require("logic.shoujianquan.shoujiguanlianshuru").getInstanceAndShow()
        end
    end
end


function Safeseldialog:clickItemLock(args)
    require("logic.item.itemlockdialog").getInstanceAndShow()
end

function Safeseldialog:clickCheckPhone(args)

end


function Safeseldialog:GetLayoutFileName()
	return "shoujianquan.layout"
end


return Safeseldialog