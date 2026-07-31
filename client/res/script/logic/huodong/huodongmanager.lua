HuoDongManager = {}
HuoDongManager.__index = HuoDongManager

------------------- public: -----------------------------------
--活动数据      wjf
---- singleton /////////////////////////////////////////------
local _instance;

HuoDongManager.ActivityID_Dati = 1
HuoDongManager.ActivityID_Keju = 2
HuoDongManager.ActivityID_GonghuiFB = 3

HuoDongManager.ActivityID_Pvp1 = 4
HuoDongManager.ActivityID_Pvp3 = 5
HuoDongManager.ActivityID_Pvp5 = 6
HuoDongManager.ActivityID_kejukaoshisystem =7
HuoDongManager.ActivityID_winnercall=8
HuoDongManager.ActivityID_FamilyFight = 9

local ActivityID_Count=  9

function HuoDongManager.getInstance()
	LogInfo("enter get activitymanager instance")
	if not _instance then
		_instance = HuoDongManager:new()
	end
	
	return _instance
end

function HuoDongManager.getInstanceNotCreate()
	return _instance
end

function HuoDongManager.Destroy()
	if _instance then
		_instance = nil
	end
end



function HuoDongManager:new()
	local self = {}
	setmetatable(self, HuoDongManager)
	
    --活跃度 等等
	self.m_activities = {}
    --当前活跃度
	self.m_activevalue = 0
    --礼包
	self.m_chests = {}
    --推荐
	self.m_recommend = 0

    self.m_closeids = {}
    --特殊的一种活动数据
    self.m_activityinfos = {}
	
	self.hasHongdianAll = false

    self.m_HeroTrial = 0

    self.m_boxuezhe = false

    self.m_bingfengwangzuoFinish = false

    self.m_PushTime = {}

    for i = 1,ActivityID_Count do
        self.m_PushTime[i] = 0
    end

    self.m_day = 0

    local time = StringCover.getTimeStruct(gGetServerTime() / 1000)
    self.m_day = time.tm_mday

    self.m_RedpackDis = {}
    local tableName = ""
    if IsPointCardServer() then
        tableName = "mission.cactivitynewpay"
    else
        tableName = "mission.cactivitynew"
    end
    local tableAllId = BeanConfigManager.getInstance():GetTableByName(tableName):getAllID()
    for _, v in pairs(tableAllId) do
		local actScheculed = BeanConfigManager.getInstance():GetTableByName(tableName):getRecorder(v)
        if actScheculed.linkredpackdis == 1 then
            self.m_RedpackDis[v] = 0
        end
    end

    --请求协议初始化数据
    local p = require("protodef.fire.pb.mission.activelist.crefreshactivitylistfinishtimes"):new()
	LuaProtocolManager:send(p)
	return self
end
function HuoDongManager.SendList()
    local p = require("protodef.fire.pb.mission.activelist.crefreshactivitylistfinishtimes"):new()
	LuaProtocolManager:send(p)
end
function HuoDongManager:SendPush(index)
    self.m_PushTime[index] = 15 * 60 * 1000
end
function HuoDongManager:CanPush(index)
    if self.m_PushTime[index] <= 0 then
        self:SendPush(index)
        return true
    else 
        return false
    end
end
function HuoDongManager:OpenPush()
    for i,v in pairs(self.m_PushTime) do
        if v > 0 then
            self.m_PushTime[i] = 0
        end
    end
    for i,v in pairs(self.m_RedpackDis) do
        self.m_RedpackDis[i] = 0
    end
end
function HuoDongManager:Update(delta)
    local time = StringCover.getTimeStruct(gGetServerTime() / 1000)
    if self.m_day ~= time.tm_mday then
        self:OpenPush()
        self.m_day = time.tm_mday
    end
    for i,v in pairs(self.m_PushTime) do
        if v > 0 then
            self.m_PushTime[i] = v - delta
        end
    end
end
function HuoDongManager:getHasActivity()
    local logoDlg = LogoInfoDialog.getInstanceNotCreate()
	if logoDlg then
		logoDlg:RefreshBtnHuodong()
	end 

    local dlg = require "logic.battle.zhandouanniu".getInstanceNotCreate()
    if dlg then
        dlg:refreshHuodongBtn()
    end
end
function HuoDongManager:getOpenActivity(id)
    --限时活动开启
    self.hasHongdianAll = true
    if self.m_RedpackDis[id] then
        self.m_RedpackDis[id] = 0
    end
    getHuodongDlg().HasOpenActicity()
    HuoDongManager:getInstance():getHasActivity()
    --答题
    local manager = require "logic.pointcardserver.pointcardservermanager".getInstance()
    if manager.m_isTodayNotFree then
        return
    end
    if id == 213 then
        if not self:CanPush(HuoDongManager.ActivityID_Dati) then
            return
        end
        local function ClickYes(self, args)
            --gGetMessageManager():CloseMessageBoxByType(eMsgType_Normal, false)
            gGetMessageManager():CloseCurrentShowMessageBox()
            local p = require("protodef.fire.pb.npc.crequestactivityanswerquestion"):new()
	        LuaProtocolManager:send(p)
        end
        local function ClickNo(self, args)
            if CEGUI.toWindowEventArgs(args).handled ~= 1 then
              --gGetMessageManager():CloseMessageBoxByType(eMsgType_Normal, false)
              gGetMessageManager():CloseCurrentShowMessageBox()
            end
            return
        end
		local data = gGetDataManager():GetMainCharacterData()
		local nLvl = data:GetValue(fire.pb.attr.AttrType.LEVEL)
        local tableName = ""
        if IsPointCardServer() then
            tableName = "mission.cactivitynewpay"
        else
            tableName = "mission.cactivitynew"
        end
        local record = BeanConfigManager.getInstance():GetTableByName(tableName):getRecorder(id)

        if nLvl >= record.level and nLvl <= record.maxlevel then
            local msg = MHSD_UTILS.get_msgtipstring(160474)
            gGetMessageManager():AddMessageBox("",msg,ClickYes,self,ClickNo,self,eMsgType_Normal,30000,0,0,nil,MHSD_UTILS.get_resstring(996),MHSD_UTILS.get_resstring(997))
        end
    --公会副本
    elseif id == 218 then
        if not self:CanPush(HuoDongManager.ActivityID_GonghuiFB) then
            return
        end
        local datamanager = require "logic.faction.factiondatamanager"
        if datamanager:IsHasFaction() then
            local function ClickYes(self, args)
                gGetMessageManager():CloseMessageBoxByType(eMsgType_Normal, false)
                TaskHelper.gotoNpc(161303)
            end
            local function ClickNo(self, args)
                if CEGUI.toWindowEventArgs(args).handled ~= 1 then
                  gGetMessageManager():CloseMessageBoxByType(eMsgType_Normal, false)
                end
                return
            end
		    local data = gGetDataManager():GetMainCharacterData()
		    local nLvl = data:GetValue(fire.pb.attr.AttrType.LEVEL)
            local tableName = ""
            if IsPointCardServer() then
                tableName = "mission.cactivitynewpay"
            else
                tableName = "mission.cactivitynew"
            end
            local record = BeanConfigManager.getInstance():GetTableByName(tableName):getRecorder(id)

            if nLvl >= record.level and nLvl <= record.maxlevel then
                local msg = MHSD_UTILS.get_msgtipstring(162034)
                gGetMessageManager():AddMessageBox("",msg,ClickYes,self,ClickNo,self,eMsgType_Normal,30000,0,0,nil,MHSD_UTILS.get_resstring(996),MHSD_UTILS.get_resstring(997))
            end
        end
    elseif  id == 281 then  --公会战
        if not self:CanPush(HuoDongManager.ActivityID_FamilyFight) then
            return
        end
        local datamanager = require "logic.faction.factiondatamanager"
        local factionlevel = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(411).value)
        if datamanager:IsHasFaction()  and datamanager.factionlevel >=factionlevel then
            local function ClickYes(self, args)
                gGetMessageManager():CloseMessageBoxByType(eMsgType_Normal, false)
                TaskHelper.gotoNpc(161531)
            end
            local function ClickNo(self, args)
                if CEGUI.toWindowEventArgs(args).handled ~= 1 then
                  gGetMessageManager():CloseMessageBoxByType(eMsgType_Normal, false)
                end
                return
            end
		    local data = gGetDataManager():GetMainCharacterData()
		    local nLvl = data:GetValue(fire.pb.attr.AttrType.LEVEL)
            local tableName = ""
            if IsPointCardServer() then
                tableName = "mission.cactivitynewpay"
            else
                tableName = "mission.cactivitynew"
            end
            local record = BeanConfigManager.getInstance():GetTableByName(tableName):getRecorder(id)

            if nLvl >= record.level and nLvl <= record.maxlevel then
                local msg = require("utils.mhsdutils").get_resstring(11607)
                gGetMessageManager():AddMessageBox("",msg,ClickYes,self,ClickNo,self,eMsgType_Normal,30000,0,0,nil,MHSD_UTILS.get_resstring(996),MHSD_UTILS.get_resstring(997))
            end
        end
    end
end
function HuoDongManager.HandleAnswerQuestionLinkClick(param1, param2, param3, param4)
	--答题 对应活动id
    local ntype = tonumber(param4)
	if ntype == 213 then
        require"logic.answerquestion.answerquestionhelp".ShowUI(param1, param2, param3, param4)
    --科举 对应活动id
    elseif ntype == 214 then
        require"logic.wisdomtrialdlg.wisdomrrialhelpdlg".ShowUI(param1, param2, param3, param4)
    --红包
    elseif ntype == 300 then
        require"logic.redpack.redpackmanager".GetRedPack(param1, param2, param3, param4)
    end
end
return HuoDongManager
