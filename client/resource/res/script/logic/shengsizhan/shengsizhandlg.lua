require "logic.dialog"

ShengSiZhanDlg = {}
setmetatable(ShengSiZhanDlg, Dialog)
ShengSiZhanDlg.__index = ShengSiZhanDlg

local _instance
function ShengSiZhanDlg.getInstance()
	if not _instance then
		_instance = ShengSiZhanDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function ShengSiZhanDlg.getInstanceAndShow()
	if not _instance then
		_instance = ShengSiZhanDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ShengSiZhanDlg.getInstanceNotCreate()
	return _instance
end

function ShengSiZhanDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ShengSiZhanDlg.ToggleOpenClose()
	if not _instance then
		_instance = ShengSiZhanDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ShengSiZhanDlg.GetLayoutFileName()
	return "shengsizhan_mtg.layout"
end

function ShengSiZhanDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ShengSiZhanDlg)
	return self
end

function ShengSiZhanDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    
    self.rsCancelBtn = CEGUI.toPushButton(winMgr:getWindow("shengsizhan_mtg/framewindow/buton2"));
	self.rsCancelBtn:subscribeEvent("MouseButtonUp", ShengSiZhanDlg.handleCANCELClicked, self)
    
    self.placeHolder = winMgr:getWindow("shengsizhan_mtg/framewindow/shurukuang/tishiwenzi")
	self.inputBox = CEGUI.toEditbox(winMgr:getWindow("shengsizhan_mtg/framewindow/shurukuang/richieditbox"))
	self.inputBox:SetNormalColourRect(0xff50321a);
	self.inputBox:subscribeEvent("TextChanged", self.OnEditNumChange, self)
	self.inputBox:subscribeEvent("CaptureLost", self.OnEditActive, self)
	
	self.tipsButton = CEGUI.toPushButton(winMgr:getWindow("shengsizhan_mtg/framewindow/tipsm"))       --tips 生死战说明
    self.tipsButton:subscribeEvent("Clicked", ShengSiZhanDlg.handleClickssTipButton, self)

	self.sureBtn = CEGUI.toPushButton(winMgr:getWindow("shengsizhan_mtg/framewindow/buton1"))
	self.sureBtn:subscribeEvent("Clicked", self.handleSureClicked, self)
    self.sureBtn:setEnabled(false);
    
	self.closeBtn = CEGUI.toPushButton(winMgr:getWindow("shengsizhan_mtg/framewindow/close"))
	self.closeBtn:subscribeEvent("Clicked", self.handleCANCELClicked, self)
    
	self.single = CEGUI.toRadioButton(winMgr:getWindow("shengsizhan_mtg/framewindow/radiobutton1"))
	self.team = CEGUI.toRadioButton(winMgr:getWindow("shengsizhan_mtg/framewindow/radiobutton2"))
    
	self.single:EnableClickAni(false)    
	self.team:EnableClickAni(false)

    self.single:setSelected(true)
    self.team:setSelected(false)
	self.single:setProperty("NormalTextColour","FF000000")
	self.team:setProperty("NormalTextColour","FF000000")
	self.inputBox:setProperty("NormalTextColour","FF000000")

    self.targetID = 0
    self.fType = 0
end

function ShengSiZhanDlg:handleSureClicked(args) 
	local p = require "protodef.fire.pb.battle.livedie.cinvitationlivediebattle":new()
    p.idorname = self.inputBox:getText()
    local zhanshutype = 0
    if self.team:isSelected() == true then
        zhanshutype = 1
    end
    p.selecttype = zhanshutype
    require "manager.luaprotocolmanager".getInstance():send(p)
    return true
end

function ShengSiZhanDlg:handleClickssTipButton(args)
    local tipsStr = ""
    if IsPointCardServer() then
        tipsStr = require("utils.mhsdutils").get_resstring(11806)
    else
        tipsStr = require("utils.mhsdutils").get_resstring(11835)----第一条
    end
    local title = require("utils.mhsdutils").get_resstring(11834)----标题名称
    local tipdlg = require "logic.workshop.tips1".getInstanceAndShow(tipsStr, title)
    SetPositionScreenCenter(tipdlg:GetWindow())
end

function ShengSiZhanDlg:MessageBoxCancel(args)
    if CEGUI.toWindowEventArgs(args).handled ~= 1 then
	    gGetMessageManager():CloseCurrentShowMessageBox()
    end   
end
function ShengSiZhanDlg:MessageBoxOk(args)
    if CEGUI.toWindowEventArgs(args).handled ~= 1 then
	    gGetMessageManager():CloseCurrentShowMessageBox()
    end  

    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local nNeedMoney = self.costmoney
    local nUserMoney = roleItemManager:GetPackMoney()
    if nUserMoney >= nNeedMoney then
	    local p = require "protodef.fire.pb.battle.livedie.cinvitationlivediebattleok":new()
        p.objectid = self.targetID
        p.selecttype = self.fType
        require "manager.luaprotocolmanager".getInstance():send(p)        
        self:DestroyDialog() 
    else
        local nMoneyType = fire.pb.game.MoneyType.MoneyType_SilverCoin
		local nShowNeed = nNeedMoney - nUserMoney
		LogInfo("nMoneyType="..nMoneyType)
		CurrencyManager.handleCurrencyNotEnough(nMoneyType, nShowNeed)
    end
         
end
function ShengSiZhanDlg:process(id,name,stype,costmoney)
    self.targetID = id
    self.fType = stype
    self.costmoney = costmoney
    local strbuilder = StringBuilder.new()
    strbuilder:Set("parameter1", tostring(name))
    strbuilder:Set("parameter2", tostring(costmoney))
    gGetMessageManager():AddMessageBox("",
    strbuilder:GetString(MHSD_UTILS.get_msgtipstring(162070)),
    ShengSiZhanDlg.MessageBoxOk,
    self,
    ShengSiZhanDlg.MessageBoxCancel,
    self,
    eMsgType_Normal,
    60000,
    0,
    0,
    nil,
    MHSD_UTILS.get_resstring(2037),
    MHSD_UTILS.get_resstring(2038)
    )
    strbuilder:delete()
end
function ShengSiZhanDlg:OnEditActive(args)
    if self.inputBox:isInputFocus() then
	    self.placeHolder:setVisible(false)
    else        
        local stt = self.inputBox:getText()
        local len = string.len(stt)
        if string.len(self.inputBox:getText()) == 0 then
	        self.placeHolder:setVisible(true)
        end
    end
end
function ShengSiZhanDlg:OnEditNumChange()
    local stt = self.inputBox:getText()
    local len = string.len(stt)
    if string.len(self.inputBox:getText()) > 0 then
	    self.sureBtn:setEnabled(true)
    else
		self.sureBtn:setEnabled(false)
    end
end

function ShengSiZhanDlg:handleCANCELClicked(args)  
    self.DestroyDialog()
end

local p = require "protodef.fire.pb.battle.livedie.sinvitationlivediebattle"
function p:process()
    local dlg = ShengSiZhanDlg.getInstanceNotCreate()
    dlg:process(self.objectid,self.objectname,self.selecttype,self.costmoney)
end

local p = require "protodef.fire.pb.battle.livedie.sinvitationlivediebattleok"
function p:process()
    local function ClickYes(self, args)
        gGetMessageManager():CloseCurrentShowMessageBox()
        local req = require"protodef.fire.pb.battle.livedie.cacceptinvitationlivediebattle".Create()
        req.sourceid = self.sourceid
        req.acceptresult = 1
        LuaProtocolManager.getInstance():send(req)
    end

    local function ClickNo(self, args)
        if CEGUI.toWindowEventArgs(args).handled ~= 1 then
            gGetMessageManager():CloseCurrentShowMessageBox()
        end
        local req = require"protodef.fire.pb.battle.livedie.cacceptinvitationlivediebattle".Create()
        req.sourceid = self.sourceid
        req.acceptresult = 0
        LuaProtocolManager.getInstance():send(req)
    end

    local sid = 162071
    if self.selecttype == 1 then
        sid = 162082
    end
    local strbuilder = StringBuilder.new()
    strbuilder:Set("parameter1", tostring(self.sourcename))
    gGetMessageManager():AddMessageBox("",
    strbuilder:GetString(MHSD_UTILS.get_msgtipstring(sid)),
    ClickYes,
    self,
    ClickNo,
    self,
    eMsgType_Normal,
    300000,
    0,
    0,
    nil,
    MHSD_UTILS.get_resstring(2037),
    MHSD_UTILS.get_resstring(2038)
    )
    strbuilder:delete()
end

local p = require "protodef.fire.pb.battle.livedie.sacceptinvitationlivediebattle"
function p:process()
    --Ѱ·��ȥ
    TaskHelper.gotoNpc(161525)
end
return ShengSiZhanDlg
