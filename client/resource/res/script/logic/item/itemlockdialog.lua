
require "logic.dialog"

Itemlockdialog = {}
setmetatable(Itemlockdialog, Dialog)
Itemlockdialog.__index = Itemlockdialog

local _instance = nil

function Itemlockdialog.getInstanceAndShow()
	if not _instance then
		_instance = Itemlockdialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function Itemlockdialog:clearData()
    self.nId = 0
    self.mapCallBack = {}
end

function Itemlockdialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Itemlockdialog)
    self:clearData()
	return self
end

function Itemlockdialog.DestroyDialog()
    if _instance then
        _instance:OnClose()
        _instance = nil
    end

end

function Itemlockdialog:OnClose()
    Dialog.OnClose(self)
end

function Itemlockdialog:OnCreate(parent,strPrefix)
    Dialog.OnCreate(self,parent,strPrefix)
	local winMgr = CEGUI.WindowManager:getSingleton()


    self.btnSetLock =  CEGUI.toPushButton(winMgr:getWindow("anquansuo/btn1"))
    self.btnSetLock:subscribeEvent("MouseClick", Itemlockdialog.clickSetLock, self)

    self.btnResetPassword =  CEGUI.toPushButton(winMgr:getWindow("anquansuo/btn2"))
    self.btnResetPassword:subscribeEvent("MouseClick", Itemlockdialog.clickResetPassword, self)

    self.btnUnlock =  CEGUI.toPushButton(winMgr:getWindow("anquansuo/btn3"))
    self.btnUnlock:subscribeEvent("MouseClick", Itemlockdialog.clickUnlock, self)

    self.btnUnlockForce =  CEGUI.toPushButton(winMgr:getWindow("anquansuo/btn4"))
    self.btnUnlockForce:subscribeEvent("MouseClick", Itemlockdialog.clickUnlockForce, self)

end

function Itemlockdialog:clickSetLock(args)
    
    local itemManager = require("logic.item.roleitemmanager").getInstance()
    if itemManager.m_nForceDelPsdBeginTime ~= 0 then
        GetCTipsManager():AddMessageTipById(191030)
        return
    end
    local itemManager = require("logic.item.roleitemmanager").getInstance()
    if  itemManager.strLockPsd ~= "" then
        GetCTipsManager():AddMessageTipById(191037)
        return
    end
    require("logic.item.itemsetpassworddialog").getInstanceAndShow()
end

function Itemlockdialog:clickResetPassword(args)
    
    local itemManager = require("logic.item.roleitemmanager").getInstance()
    if itemManager.m_nForceDelPsdBeginTime ~= 0 then
        GetCTipsManager():AddMessageTipById(191030)
        return
    end

    local itemManager = require("logic.item.roleitemmanager").getInstance()
     if  itemManager.strLockPsd == "" then
        GetCTipsManager():AddMessageTipById(191036)
        return
     end
    require("logic.item.itemnewpsddialog").getInstanceAndShow()
end

function Itemlockdialog:clickUnlock(args)
    
    local itemManager = require("logic.item.roleitemmanager").getInstance()
    if itemManager.m_nForceDelPsdBeginTime ~= 0 then
        GetCTipsManager():AddMessageTipById(191030)
        return
    end

    local itemManager = require("logic.item.roleitemmanager").getInstance()
    if  itemManager.strLockPsd == "" then
        GetCTipsManager():AddMessageTipById(191036)
        return
    end

    require("logic.item.itemdeletelockdialog").getInstanceAndShow()
end

function Itemlockdialog:clickUnlockForce(args)
    
    local itemManager = require("logic.item.roleitemmanager").getInstance()
    if itemManager.m_nForceDelPsdBeginTime ~= 0 then
        --GetCTipsManager():AddMessageTipById(191037)
        require("logic.item.itemforcecanceldialog").getInstanceAndShow() 
        return
    end

    local itemManager = require("logic.item.roleitemmanager").getInstance()
    if  itemManager.strLockPsd == "" then
        GetCTipsManager():AddMessageTipById(191036)
        return
    end

    local shoujianquanmgr = require "logic.shoujianquan.shoujianquanmgr"
    if shoujianquanmgr.isBindTel() then
        require("logic.item.itemdeletelockbinddialog").getInstanceAndShow()
    else
        require("logic.item.itemforcedeletelockdialog").getInstanceAndShow() 
    end

end


function Itemlockdialog:GetLayoutFileName()
	return "anquansuo.layout"
end


return Itemlockdialog