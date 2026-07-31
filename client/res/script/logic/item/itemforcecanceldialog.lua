
require "logic.dialog"

Itemforcecanceldialog = {}
setmetatable(Itemforcecanceldialog, Dialog)
Itemforcecanceldialog.__index = Itemforcecanceldialog

local _instance = nil

function Itemforcecanceldialog.getInstanceAndShow()
	if not _instance then
		_instance = Itemforcecanceldialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function Itemforcecanceldialog.DestroyDialog()
    if _instance then
        _instance:OnClose()
        _instance = nil
    end
end

function Itemforcecanceldialog:clearData()
    
end

function Itemforcecanceldialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, Itemforcecanceldialog)
    self:clearData()
	return self
end

function Itemforcecanceldialog:OnClose()
    Dialog.OnClose(self)
end

function Itemforcecanceldialog:OnCreate()
    Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.btnConfirm =  CEGUI.toPushButton(winMgr:getWindow("anquansuoqiangzhiquxiao/btn"))
    self.btnConfirm:subscribeEvent("MouseClick", Itemforcecanceldialog.clickConfirm, self)

    self.btnClose =  CEGUI.toPushButton(winMgr:getWindow("anquansuoqiangzhiquxiao/guanbi"))
    self.btnClose:subscribeEvent("MouseClick", Itemforcecanceldialog.clickClose, self)

    self.labelStartTime = winMgr:getWindow("anquansuoqiangzhiquxiao/text22")
    self.labelEndTime = winMgr:getWindow("anquansuoqiangzhiquxiao/text23")

    local itemManager = require("logic.item.roleitemmanager").getInstance()
    --itemManager.m_nForceDelPsdBeginTime
    --itemManager.m_nForceDelPsdEndTime

    local strBeginTime = self:getStringTime(itemManager.m_nForceDelPsdBeginTime/1000)
    local strEndTime = self:getStringTime(itemManager.m_nForceDelPsdEndTime/1000)
    self.labelStartTime:setText(strBeginTime)
    self.labelEndTime:setText(strEndTime)

end

function Itemforcecanceldialog:getStringTime(nSecond)
    local time = StringCover.getTimeStruct(nSecond)
    local nYear = time.tm_year + 1900
	local nMonth = time.tm_mon + 1
	local nDay = time.tm_mday
    local nHour = time.tm_hour
    local nMinute = time.tm_min
    local nSecond = time.tm_sec


    local strTime = nYear.."-"
    strTime = strTime..nMonth.."-"
    strTime = strTime..nDay.." "
    strTime = strTime..nHour..":"
    strTime = strTime..nMinute..":"
    strTime = strTime..nSecond
    return strTime

end

function Itemforcecanceldialog:clickClose(args)
    Itemforcecanceldialog.DestroyDialog()
end

function Itemforcecanceldialog:clickConfirm(args)
    local p =  require("protodef.fire.pb.ccancelforcedelpassword"):new()
    LuaProtocolManager:send(p)

    Itemforcecanceldialog.DestroyDialog()
end

function Itemforcecanceldialog:GetLayoutFileName()
	return "anquansuoqiangzhiquxiao.layout"
end

return Itemforcecanceldialog