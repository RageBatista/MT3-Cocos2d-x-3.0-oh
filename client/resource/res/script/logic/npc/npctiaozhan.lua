require "logic.dialog"

Npctiaozhan = {}
setmetatable(Npctiaozhan, Dialog)
Npctiaozhan.__index = Npctiaozhan

local _instance
function Npctiaozhan.getInstance(petkey)
	if not _instance then
		_instance = Npctiaozhan:new()
		_instance:OnCreate(petkey)
	end
	return _instance
end

function Npctiaozhan.getInstanceAndShow()
	if not _instance then
		_instance = Npctiaozhan:new()
		_instance:OnCreate(petkey)
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function Npctiaozhan.getInstanceNotCreate()
	return _instance
end

function Npctiaozhan.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function Npctiaozhan.ToggleOpenClose()
	if not _instance then
		_instance = Npctiaozhan:new()
		_instance:OnCreate(petkey)
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function Npctiaozhan.getInstanceOrNot()
    return _instance
end

function Npctiaozhan.GetLayoutFileName()
	return "messageboxfuwu2.layout"
end

function Npctiaozhan:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Npctiaozhan)
	return self
end

function Npctiaozhan:OnCreate(petkey)
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	itemkey1=petkey

    self.m_tiaozhan1 = CEGUI.toPushButton(winMgr:getWindow("messageboxfuwu/tiaozhan1"))
	self.m_tiaozhan2 = CEGUI.toPushButton(winMgr:getWindow("messageboxfuwu/tiaozhan2"))
    self.m_tiaozhan3 = CEGUI.toPushButton(winMgr:getWindow("messageboxfuwu/tiaozhan3"))
    self.m_tiaozhan4 = CEGUI.toPushButton(winMgr:getWindow("messageboxfuwu/tiaozhan4"))
	self.m_tiaozhan5 = CEGUI.toPushButton(winMgr:getWindow("messageboxfuwu/tiaozhan5"))
	self.m_tiaozhan6 = CEGUI.toPushButton(winMgr:getWindow("messageboxfuwu/tiaozhan6"))
	self.m_tiaozhan7 = CEGUI.toPushButton(winMgr:getWindow("messageboxfuwu/tiaozhan7"))
	self.gonglue = CEGUI.toPushButton(winMgr:getWindow("messageboxfuwu/gonglue"))
	self.zudui = CEGUI.toPushButton(winMgr:getWindow("messageboxfuwu/zudui"))
	self.tishi = CEGUI.toPushButton(winMgr:getWindow("messageboxfuwu/tishi"))
	self.tishi1 = CEGUI.toPushButton(winMgr:getWindow("messageboxfuwu/tishi1"))
	self.m_btnguanbi = CEGUI.toPushButton(winMgr:getWindow("messageboxfuwu/guanbi"))
	
    self.m_tiaozhan1:subscribeEvent("Clicked", Npctiaozhan.tiaozhan1, self)
    self.m_tiaozhan2:subscribeEvent("Clicked", Npctiaozhan.tiaozhan2, self) 
	self.m_tiaozhan3:subscribeEvent("Clicked", Npctiaozhan.tiaozhan3, self) 
    self.m_tiaozhan4:subscribeEvent("Clicked", Npctiaozhan.tiaozhan4, self)
	self.m_tiaozhan5:subscribeEvent("Clicked", Npctiaozhan.tiaozhan5, self)
	self.m_tiaozhan6:subscribeEvent("Clicked", Npctiaozhan.tiaozhan6, self)
	self.m_tiaozhan7:subscribeEvent("Clicked", Npctiaozhan.tiaozhan7, self)
	self.gonglue:subscribeEvent("Clicked", Npctiaozhan.gonglue, self)
	self.zudui:subscribeEvent("Clicked", Npctiaozhan.zudui, self)
	self.tishi:subscribeEvent("Clicked", Npctiaozhan.tishi, self)
	self.tishi1:subscribeEvent("Clicked", Npctiaozhan.tishi1, self)
	self.m_btnguanbi:subscribeEvent("Clicked", Npctiaozhan.handguanbi, self)
    Npctiaozhan:DefineNpcData(petkey)
    local p = require("protodef.fire.pb.npc.cnpctiaozhansl"):new()
    LuaProtocolManager:send(p)
end

function Npctiaozhan:handguanbi(e)
	Npctiaozhan.DestroyDialog();
end

function Npctiaozhan:refreshList(tz1,tz2,tz3,tz4,tz5,tz6,tz7)
text11 =tz1
text12 =tz2
text13 =tz3
text14 =tz4
text15 =tz5
text16 =tz6
text17 =tz7
	local winMgr2 = CEGUI.WindowManager:getSingleton()
    self.m_pCishu = winMgr2:getWindow("messageboxfuwu/text12")
	if self.m_npcBaseId == 171202 then
    local text1 = text11 .. "/" .. text16
    self.m_pCishu:setText(text1)
	end
	if self.m_npcBaseId == 171206 then
    local text2 = text12 .. "/" .. text16
    self.m_pCishu:setText(text2)
	end
	if self.m_npcBaseId == 171210 then
    local text3 = text13 .. "/" .. text16
    self.m_pCishu:setText(text3)
	end
	if self.m_npcBaseId == 171214 then
    local text4 = text14 .. "/" .. text16
    self.m_pCishu:setText(text4)
	end
	if self.m_npcBaseId == 171218 then
    local text5 = text15 .. "/" .. text16
    self.m_pCishu:setText(text5)
	end
end


function Npctiaozhan:DefineNpcData(npcId)
	local winMgr1 = CEGUI.WindowManager:getSingleton()
    self.m_pNpcIcon = winMgr1:getWindow("messageboxfuwu/icon")
    self.m_pNpcName = winMgr1:getWindow("messageboxfuwu/name")
    self.m_pNpcName1 = winMgr1:getWindow("messageboxfuwu/text111")
    local npc = gGetScene():FindNpcByID(npcId)

    if npc then
        self.m_npcBaseId = npc:GetNpcBaseID()
    else
        npc = gGetScene():FindNpcByBaseID(self.m_npcBaseId)
    end

    if npc == nil then return false end
    local npcConfig = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(self.m_npcBaseId)
	local mapRecord23 = npcConfig.minimapquery
    self.m_pNpcName:setText(mapRecord23)
    self.m_pNpcName1:setText(npc:GetName())
    local Shape = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(npc:GetShapeID())
    local iconPath = gGetIconManager():GetImagePathByID(Shape.headID)

    if iconPath:c_str() == CEGUI.PropertyHelper:imageToString(gGetIconManager():getDefaultIcon()) then
        iconPath = gGetIconManager():GetImagePathByID(BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(gGetDataManager():GetMainCharacterShape()).headID)
    end

    self.m_pNpcIcon:setProperty("Image", iconPath:c_str())
    return true
end

function Npctiaozhan:tiaozhan1(e)
    local npc = gGetScene():FindNpcByID(itemkey1)
            local req = require "protodef.fire.pb.npc.cnpctiaozhan".Create()
            req.npckey = npc:GetNpcBaseID()
            req.serviceid = 1
            LuaProtocolManager.getInstance():send(req)
    if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
	
end
function Npctiaozhan:tiaozhan2(e)
    local npc = gGetScene():FindNpcByID(itemkey1)
            local req = require "protodef.fire.pb.npc.cnpctiaozhan".Create()
            req.npckey = npc:GetNpcBaseID()
            req.serviceid = 2
            LuaProtocolManager.getInstance():send(req)
    if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
	
end
function Npctiaozhan:tiaozhan3(e)
    local npc = gGetScene():FindNpcByID(itemkey1)
            local req = require "protodef.fire.pb.npc.cnpctiaozhan".Create()
            req.npckey = npc:GetNpcBaseID()
            req.serviceid = 3
            LuaProtocolManager.getInstance():send(req)
    if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
	
end
function Npctiaozhan:tiaozhan4(e)
    local npc = gGetScene():FindNpcByID(itemkey1)
            local req = require "protodef.fire.pb.npc.cnpctiaozhan".Create()
            req.npckey = npc:GetNpcBaseID()
            req.serviceid = 4
            LuaProtocolManager.getInstance():send(req)
    if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
	
end
function Npctiaozhan:tiaozhan5(e)
    local npc = gGetScene():FindNpcByID(itemkey1)
            local req = require "protodef.fire.pb.npc.cnpctiaozhan".Create()
            req.npckey = npc:GetNpcBaseID()
            req.serviceid = 5
            LuaProtocolManager.getInstance():send(req)
    if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
	
end
function Npctiaozhan:tiaozhan6(e)
    local npc = gGetScene():FindNpcByID(itemkey1)
            local req = require "protodef.fire.pb.npc.cnpctiaozhan".Create()
            req.npckey = npc:GetNpcBaseID()
            req.serviceid = 6
            LuaProtocolManager.getInstance():send(req)
    if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
	
end
function Npctiaozhan:tiaozhan7(e)
    local npc = gGetScene():FindNpcByID(itemkey1)
            local req = require "protodef.fire.pb.npc.cnpctiaozhan".Create()
            req.npckey = npc:GetNpcBaseID()
            req.serviceid = 7
            LuaProtocolManager.getInstance():send(req)
    if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
	
end
function Npctiaozhan:gonglue(e)
    local title = MHSD_UTILS.get_resstring(11923)
    local strAllString = MHSD_UTILS.get_resstring(11924)
    local tips1 = require "logic.workshop.tips1"
    tips1.getInstanceAndShow(strAllString, title)
end
function Npctiaozhan:zudui(e)
    require('logic.team.teammatchdlg').getInstanceAndShow()
    if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end
function Npctiaozhan:tishi(e)
    local title = MHSD_UTILS.get_resstring(11922)
    local strAllString = MHSD_UTILS.get_resstring(11674)
    local tips1 = require "logic.workshop.tips1"
    tips1.getInstanceAndShow(strAllString, title)
end
function Npctiaozhan:tishi1(e)
    local text1 = text11 .. "/" .. text16
    local text2 = text12 .. "/" .. text16
    local text3 = text13 .. "/" .. text16
    local text4 = text14 .. "/" .. text16
    local text5 = text15 .. "/" .. text16
    local text6 = text17
    local tips1 = require "logic.npc.tips3"
    Tips3.getInstanceAndShow(text1,text2,text3,text4,text5,text6)
end

return Npctiaozhan