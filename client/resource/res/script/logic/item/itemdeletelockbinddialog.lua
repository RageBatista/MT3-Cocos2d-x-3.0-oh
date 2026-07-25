
require "logic.dialog"

Itemdeletelockbinddialog = {}
setmetatable(Itemdeletelockbinddialog, Dialog)
Itemdeletelockbinddialog.__index = Itemdeletelockbinddialog

local _instance = nil

function Itemdeletelockbinddialog.getInstanceAndShow()
	if not _instance then
		_instance = Itemdeletelockbinddialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function Itemdeletelockbinddialog:clearData()
    
end

function Itemdeletelockbinddialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Itemdeletelockbinddialog)
    self:clearData()
	return self
end

function Itemdeletelockbinddialog.DestroyDialog()
    if _instance then
        _instance:OnClose()
        _instance = nil
    end
end

function Itemdeletelockbinddialog:OnClose()
    Dialog.OnClose(self)
end

function Itemdeletelockbinddialog:OnCreate()
    Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.richboxPsd1 = CEGUI.toRichEditbox(winMgr:getWindow("anquansuoqiangzhiyanzhengma/shurukuang/box1"))
    self.labelNotice1 = winMgr:getWindow("anquansuoqiangzhiyanzhengma/shurukuang/box1/placeholder")
    self.richboxPsd1:subscribeEvent("KeyboardTargetWndChanged", Itemdeletelockbinddialog.OnKeyboardTargetWndChanged, self)


    self.btnConfirm =  CEGUI.toPushButton(winMgr:getWindow("anquansuoqiangzhiyanzhengma/btn"))
    self.btnConfirm:subscribeEvent("MouseClick", Itemdeletelockbinddialog.clickConfirm, self)

    self.btnGetPhoneCheckNum =  CEGUI.toPushButton(winMgr:getWindow("anquansuoqiangzhiyanzhengma/honganniu"))
    self.btnGetPhoneCheckNum:subscribeEvent("MouseClick", Itemdeletelockbinddialog.clickGetPhoneCheckNum, self)

    self.strOldTitle = self.btnGetPhoneCheckNum:getText()

    self:GetWindow():subscribeEvent("WindowUpdate", Itemdeletelockbinddialog.HandleWindowUpate, self)
    self.nRefreshCd  = 500
    self.nRefreshCdDt  = 0

    self.btnClose =  CEGUI.toPushButton(winMgr:getWindow("anquansuoqiangzhiyanzhengma/guanbi"))
    self.btnClose:subscribeEvent("MouseClick", Itemdeletelockbinddialog.clickClose, self)
    
end

function Itemdeletelockbinddialog:clickClose(args)
    Itemdeletelockbinddialog.DestroyDialog()
end

function Itemdeletelockbinddialog:HandleWindowUpate(args)
    local ue = CEGUI.toUpdateEventArgs(args)
    self.nRefreshCdDt = self.nRefreshCdDt + ue.d_timeSinceLastFrame

    if self.nRefreshCdDt > self.nRefreshCd then
        self:refreshBtnTitle()
        self.nRefreshCdDt = 0
    end

    return true
end

function Itemdeletelockbinddialog:OnKeyboardTargetWndChanged(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    if wnd == self.richboxPsd1 then
        self.labelNotice1:setVisible(false)
    elseif self.richboxPsd1:GenerateParseText(false) == "" then
        self.labelNotice1:setVisible(true)
    end
end


function  Itemdeletelockbinddialog:refreshBtnTitle()
    local nnTimeNowSecond = gGetServerTime()/1000
    local itemManager = require("logic.item.roleitemmanager").getInstance()
    local nLeftTime = itemManager.nValidTime/1000 - nnTimeNowSecond

    local strSecondzi = require("utils.mhsdutils").get_resstring(10015) 

    if nLeftTime> 0 then
        self.btnGetPhoneCheckNum:setText(nLeftTime..strSecondzi)
        self.btnGetPhoneCheckNum:setEnabled(false)
    else
        self.btnGetPhoneCheckNum:setText(self.strOldTitle)
        self.btnGetPhoneCheckNum:setEnabled(true)
    end

end

--local itemManager = require("logic.item.roleitemmanager").getInstance()
--itemManager.nValidTime = self.finishtimepoint

function Itemdeletelockbinddialog:clickConfirm(args)
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


    local p =  require("protodef.fire.pb.cforcedelpassword"):new()
    p.code = strPsd1
    LuaProtocolManager:send(p)
end

function Itemdeletelockbinddialog:clickGetPhoneCheckNum(args)
    
    local p =  require("protodef.fire.pb.creceivecheckcode"):new()
    p.checkCodeType = 2  --2 道具安全锁 3藏宝阁
    LuaProtocolManager:send(p)
end




function Itemdeletelockbinddialog:GetLayoutFileName()
	return "anquansuoqiangzhiyanzhengma.layout"
end


return Itemdeletelockbinddialog