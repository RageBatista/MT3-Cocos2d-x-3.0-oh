------------------------------------------------------------------
-- 任务管理器（从C++转Lua）
------------------------------------------------------------------

require "manager.notificationcenter"
require "manager.npcservicemanager"
require "logic.task.taskhelper"

require "protodef.rpcgen.fire.pb.mission.trackedmission"
require "protodef.rpcgen.fire.pb.mission.missioninfo"
require "protodef.rpcgen.fire.pb.circletask.activequestdata"
require"protodef.rpcgen.fire.pb.mission.missionstatus"
require "protodef.rpcgen.fire.pb.circletask.specialqueststate"
require "protodef.rpcgen.fire.pb.mission.missionexetypes"
require "protodef.rpcgen.fire.pb.mission.npcexecutetasktypes"
require "protodef.rpcgen.fire.pb.mission.missionfintypes"
require "protodef.rpcgen.fire.pb.circletask.refreshdatatype"

local msnStatus = MissionStatus:new()
local spcQuestState = SpecialQuestState:new()
local msnExeTypes = MissionExeTypes:new()
local neTaskTypes = NpcExecuteTaskTypes:new()
local msnFinTypes = MissionFinTypes:new()
local rfhDataType = RefreshDataType:new()

--enum enumQuestType
--{
--	eDailyQuest = 800000,//日常任务
--	eActivity = 600000,	//活动
--	eOtherQuest = 500000,//其他任务	
--	eEctypeQuest = 400000,//副本任务	
--	eDummyBranchQuest = 300000,//仿分支任务，任务结构是剧情任务的结构，但是现实在日常任务节点里
--	eBranchQuest = 200000,//剧情分支任务	
--	eScenarioQuest = 100000,//剧情任务
--	eNULL
--};

--enum enumTZTaskMsgID
--{
--	eTZFindNpc = 140060,//找人
--	eTZFindItem = 140070,//寻物
--	eTZFindPet = 140080,//寻宠物
--	eTZFight = 140090,//战斗
--};

--enum eLevelBonusType
--{
--	eLevelBonusNull,
--	eLevelBonus30	= 1,
--	eLevelBonus40	= 2,
--	eLevelBonus50	= 3,
--	eLevelBonus60	= 4,
--};

function GetQuestStateName(state)
	if state == spcQuestState.FAIL then
		return MHSD_UTILS.get_resstring(1244)
	elseif state == spcQuestState.UNDONE then
		return MHSD_UTILS.get_resstring(1245)
	elseif state == spcQuestState.DONE then
		return MHSD_UTILS.get_resstring(1246)
	else
		return ""
	end
end

------------------------------------------------------------------

stQuestInfo = {}
stQuestInfo.__index = stQuestInfo

function stQuestInfo.new()
    local ret = {}
    setmetatable(ret, stQuestInfo)
	ret:init()
    return ret
end

function stQuestInfo:init()
	self.questid        = 0     -- 任务id
	self.queststate     = 0     -- 任务状态
	self.name           = ""    -- 任务名称
	self.sourcenpckey   = 0     -- 源npc的key
	self.dstnpckey      = 0     -- 目的npc的key
	self.dstnpcid       = 0     -- 目的npc的id
	self.dstmapid       = 0     -- 目的地图id
	self.dstx           = 0     -- 目的坐标x
	self.dsty           = 0     -- 目的坐标y
end

------------------------------------------------------------------

stSpecialQuest = {}
stSpecialQuest.__index = stSpecialQuest

function stSpecialQuest.new()
    local ret = {}
    setmetatable(ret, stSpecialQuest)
	ret:init()
    return ret
end

function stSpecialQuest:init()
	self.questid        = 0     -- 任务id
	self.queststate     = 0     -- 任务状态
	self.round          = 0     -- 当前任务的环数
	self.sumnum         = 0
	self.questtype      = 0     -- 任务类型 （见 SpecialQuestType）
	self.dstmapid       = 0     -- 目的地图id
	self.dstnpckey      = 0     -- 目的npc的key
	self.dstnpcname     = ""    -- 目的npc名字
	self.dstnpcid       = 0     -- 目的npc的id
	self.dstitemid      = 0     -- 目的道具的id">
	self.dstitemnum     = 0     -- 目的道具的数量
	self.dstitemid2     = 0     -- 目的道具2
	self.dstitemidnum2  = 0     -- 目的道具2的数量
	self.dstx           = 0     -- 目的坐标x
	self.dsty           = 0     -- 目的坐标y
	self.validtime      = 0     -- 任务截止效期
	self.selfname       = ""    -- 任务名称
	self.islogin        = 0
end

------------------------------------------------------------------

stLevelBonusInfo = {}
stLevelBonusInfo.__index = stLevelBonusInfo

function stLevelBonusInfo.new()
    local ret = {}
    setmetatable(ret, stLevelBonusInfo)
	ret:init()
    return ret
end

function stLevelBonusInfo:init()
	self.taskid             = 0     -- 任务id
	self.bfinish            = false -- 是否完成
	self.num                = 0     -- 任务计数
	self.alreadyplayeffect  = false -- 客户端自己记的，第一次数据刷新，或者是完成的时候，才弹特效
end

------------------------------------------------------------------

-- 等级红利奖励领取状况
stBonusRewardInfo = {}
stBonusRewardInfo.__index = stBonusRewardInfo

function stBonusRewardInfo.new()
    local ret = {}
    setmetatable(ret, stBonusRewardInfo)
	ret:init()
    return ret
end

function stBonusRewardInfo:init()
	self._type      = 0
	self.drawstate  = 0 --0代表不可领取，1代表可领取，2代表已领取
end

------------------------------------------------------------------

TaskManager_CToLua = {}
TaskManager_CToLua.__index = TaskManager_CToLua

local _instance

function GetTaskManager()
    return _instance
end

function TaskManager_CToLua.newInstance()
    if not _instance then
        _instance = TaskManager_CToLua:new()
    end
    return _instance
end

function TaskManager_CToLua.removeInstance()
    if _instance then
        _instance = nil
    end
end

function TaskManager_CToLua:new()
    local self = {}
    setmetatable(self, TaskManager_CToLua)

    self.EventUpdateLastQuest = LuaEvent.new()
    self.m_TaskTraceStateChangeNotifySet = LuaEvent.new()
    self.m_vSpecialQuest = {}
    self.m_vScenarioQuest = {}
    self.m_vReceiveQuestList = {}
    self.m_vAcceptableQuestList = {}
    self.m_mTraceQuests = {}
    self.m_mQuestTimes = {}
    self.m_iLastSelectTaskid = 0
    self.m_iClearQuestTime = 0
    self.m_bRequestBonusInfo = false
    self.m_bAllBonusFinish = false
    self.m_iBonusRefreshTaskID = 0
    self.m_bIsTaskTraceDlgVisible = true        
    self.m_luafunctions = {}

    return self
end

function TaskManager_CToLua:FireTaskTraceStateChange(questid)
    self.m_TaskTraceStateChangeNotifySet:Bingo(questid)
end

function TaskManager_CToLua:InsertTaskTraceStateChangeNotify(iHandler)
    return self.m_TaskTraceStateChangeNotifySet:InsertScriptFunctor(iHandler)
end

function TaskManager_CToLua:RemoveTaskTraceStateChangeNotify(iHandler)
    return self.m_TaskTraceStateChangeNotifySet:RemoveScriptFunctor(iHandler)
end

-- repeat task
function TaskManager_CToLua:AddSpecialQuest(quest)
    table.insert(self.m_vSpecialQuest, quest)

	local nMonsterId = GetSchoolMasterID()
	self:ReceivedSpecialTaskResult(quest.questid, nMonsterId)

	self:RemoveAcceptQuest(quest.questid)
end

function TaskManager_CToLua:RemoveSpecialQuest(questid)
    for index, quest in pairs(self.m_vSpecialQuest) do
		if quest.questid == questid then
			self:RemoveQuestFromTraceList(questid)
			self.m_vSpecialQuest[index] = nil
			break
	    end
	end
end

function TaskManager_CToLua:AddScenarioQuest(quest)
	table.insert(self.m_vScenarioQuest, quest)

	if (not gGetScene():IsFirstEnterMap()) and self:GetMainScenarioQuestId() == quest.missionid then
        Renwulistdialog.getSingletonDialog()
	end
end

function TaskManager_CToLua:RemoveScenarioQuest(questid)
    for index, quest in pairs(self.m_vScenarioQuest) do
		if quest.missionid == questid then
			TaskHelper.RemoveScenarioQuest(questid)
			self:RemoveQuestFromTraceList(questid)
			self.m_vScenarioQuest[index] = nil
			break
	    end
	end
end

function TaskManager_CToLua:AddActiveQuest(questdata)
	local pActiveQuest = self:GetReceiveQuest(questdata.questid)
	if not pActiveQuest then
		table.insert(self.m_vReceiveQuestList, questdata)
		self:AddNewQuestToTraceList(questdata.questid)
		self:AddQuestReceiveTimes(questdata.questid)
        
        if not self.m_mQuestTimes[questdata.questid] then
			self:RemoveAcceptQuest(questdata.questid)
	    end
	else
		local npckey = 0
		local npcbaseid = 0
		if pActiveQuest.dstnpcid ~= questdata.dstnpcid or pActiveQuest.dstnpckey ~=  questdata.dstnpckey then
			npckey = pActiveQuest.dstnpckey
			npcbaseid = pActiveQuest.dstnpcid
	    end
		pActiveQuest.questid = questdata.questid
		pActiveQuest.queststate = questdata.queststate
		pActiveQuest.dstnpckey = questdata.dstnpckey
		pActiveQuest.dstnpcid = questdata.dstnpcid
		pActiveQuest.dstmapid = questdata.dstmapid
		pActiveQuest.dstx = questdata.dstx
		pActiveQuest.dsty = questdata.dsty
		pActiveQuest.dstitemid = questdata.dstitemid
		pActiveQuest.sumnum = questdata.sumnum
		pActiveQuest.npcname = questdata.npcname
		pActiveQuest.rewardexp = questdata.rewardexp
		pActiveQuest.rewardmoney = questdata.rewardmoney
		pActiveQuest.rewardsmoney = questdata.rewardsmoney
		pActiveQuest.rewarditems = questdata.rewarditems
		if npckey ~= 0 or npcbaseid ~= 0 then
			self:RefreshNpcState(npckey, npcbaseid)
	    end
	end
	self.EventUpdateLastQuest:Bingo(questdata.questid)
	self:RefreshNpcState(questdata.dstnpckey, questdata.dstnpcid)
end

function TaskManager_CToLua:RemoveReceiveQuest(questid)
    for index, quest in pairs(self.m_vReceiveQuestList) do
		if quest.questid == questid then
			self:RemoveQuestFromTraceList(questid)
			self.m_vReceiveQuestList[index] = nil
			break
	    end
	end
end

function TaskManager_CToLua:AddAcceptableQuest(acceptlists)
	self:clearAcceptList()
    for _, nTaskId in pairs(acceptlists) do
		table.insert(self.m_vAcceptableQuestList, nTaskId)
	end
	Renwudialog.UpdateAcceptableTaskList()

    for index, taskid in pairs(self.m_vAcceptableQuestList) do
		local destnpcid = GetAcceptableTaskId(taskid)
		self:RefreshNpcState(0, destnpcid)
	end
end

function TaskManager_CToLua:AddOneQuestToAcceptable(accept_quest)
	table.insert(self.m_vAcceptableQuestList, accept_quest)
end

function TaskManager_CToLua:RemoveAcceptQuest(questid)
    for index, taskid in pairs(self.m_vAcceptableQuestList) do
		if taskid == questid then
			self.m_vAcceptableQuestList[index] = nil
			local destnpcid = GetAcceptableTaskId(questid)
			self:RefreshNpcState(0, destnpcid)
            if self.m_luafunctions["Renwudialog.RemoveAcceptableQuest"] then
                self.m_luafunctions["Renwudialog.RemoveAcceptableQuest"](questid)
            end
			break
	    end
	end
end

function TaskManager_CToLua:RegisterLuaTaskDlgFunction(handler, functionName)
    self.m_luafunctions[functionName] = handler
end

function TaskManager_CToLua:AddQuestReceiveTimes(questid)
    if self.m_mQuestTimes[questid] then
		self.m_mQuestTimes[questid] = self.m_mQuestTimes[questid] + 1
	end
end

function TaskManager_CToLua:SetClearQuestTime(time)
    self.m_iClearQuestTime = time
end

function TaskManager_CToLua:GetClearQuestTime()
    return self.m_iClearQuestTime
end

function TaskManager_CToLua:AddQuestToTraceList(questid, time)
	self.m_mTraceQuests[questid] = time
end

function TaskManager_CToLua:AddNewQuestToTraceList(questid)
    if not self.m_mTraceQuests[questid] then
		local data = TrackedMission:new()
		data.acceptdate = gGetServerTime()
		self.m_mTraceQuests[questid] = data
		self:FireTaskTraceStateChange(questid)
	end
end

function TaskManager_CToLua:RemoveQuestFromTraceList(questid)
    if self.m_mTraceQuests[questid] then
		self.m_mTraceQuests[questid] = nil
		self:FireTaskTraceStateChange(questid)
	end
end

function TaskManager_CToLua:IsQuestInTraceList(questid)
    if self.m_mTraceQuests[questid] then
		return true
	end
	return false
end

function TaskManager_CToLua:GetQuestTraceTime(questid)
    if self.m_mTraceQuests[questid] then
		return self.m_mTraceQuests[questid].acceptdate
	end
	return 0
end

function TaskManager_CToLua:RefreshQuestState(questid, queststate)
	local pSpecialquest = self:GetSpecialQuest(questid)
	if pSpecialquest then
		self:RefreshSpecialQuestState(pSpecialquest, questid,queststate)
		self.EventUpdateLastQuest:Bingo(questid)
		return
	end

	local pActiveQuest = self:GetReceiveQuest(questid)
	if pActiveQuest then
		self:RefreshReceiveQuestState(pActiveQuest, questid,queststate)
		self.EventUpdateLastQuest:Bingo(questid)
		return
	end
	self:RefreshScenarioQuestState(questid,queststate)
	self.EventUpdateLastQuest:Bingo(questid)
end

function TaskManager_CToLua:RefreshSpecialQuestState(pSpecialQuest, questid, state)
	if not pSpecialQuest then
		return
	end

	local npckey = pSpecialQuest.dstnpckey
	local npcbaseid = pSpecialQuest.dstnpcid
	local questtype = pSpecialQuest.questtype
	pSpecialQuest.queststate = state

	if state == spcQuestState.SUCCESS then
		gGetGameUIManager():PlayScreenEffect(10215)
        if gGetTaskOnOffEffectManager() then
            gGetTaskOnOffEffectManager():playOffEffect()
	    end
		local npcidOld = npcbaseid
		self:CommitSpecialTaskResult(pSpecialQuest.questid, npcidOld)
		self:RemoveSpecialQuest(pSpecialQuest.questid)
	elseif state == spcQuestState.DONE then
		local nTaskTypeId = pSpecialQuest.questid
		local npcidOld = npcbaseid
		self:DoneSpecialTaskResult(nTaskTypeId, npcidOld)
	elseif state == spcQuestState.ABANDONED then
		self:RemoveSpecialQuest(pSpecialQuest.questid)
	elseif state == spcQuestState.RECYCLE then
		self:RemoveSpecialQuest(pSpecialQuest.questid)
	else
		local strSpecialQuestName = GetNewSpecialQuestName(pSpecialQuest.questid)
		pSpecialQuest.name = strSpecialQuestName
	end

	self:RefreshNpcState(npckey, npcbaseid)
end

function TaskManager_CToLua:RefreshReceiveQuestState(pQuest, questid, state)
	if not pQuest then
		return
	end

	local npckey = pQuest.dstnpckey
	local npcbaseid = pQuest.dstnpcid
	local sumnum =pQuest.sumnum
	local npcbaseid2 = pQuest.dstx
	local npcbaseid3 = pQuest.dsty

	pQuest.queststate = state
	if state == spcQuestState.SUCCESS then
		gGetGameUIManager():PlayScreenEffect(10215)
		
        if gGetTaskOnOffEffectManager() then
            gGetTaskOnOffEffectManager():playOffEffect()
        end
		self:RemoveReceiveQuest(pQuest.questid)
	elseif state == spcQuestState.FAIL then

	elseif state == spcQuestState.ABANDONED then
		self:RemoveReceiveQuest(pQuest.questid)
	elseif state == spcQuestState.RECYCLE then
		self:RemoveReceiveQuest(pQuest.questid)
	elseif state == spcQuestState.DONE then

	elseif state == spcQuestState.INSTANCE_ABANDONED then
		return
	end
	self:RefreshNpcState(npckey, npcbaseid)
end

function TaskManager_CToLua:RefreshScenarioQuestState(questid, state)
	local questinfo = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(questid)
	local pQuest = self:GetScenarioQuest(questid)
	if (not pQuest) and state == msnStatus.COMMITED then
		self:ScenarioQuestCommitedEnd(questid)
		self:RemoveAcceptQuest(questid)
	elseif not pQuest then
		return
	else
		pQuest.missionstatus = state
		if state == msnStatus.COMMITED then
			self:RemoveScenarioQuest(questid)
            
            if gGetTaskOnOffEffectManager() then
                gGetTaskOnOffEffectManager():playOffEffect()
	        end
			self:ScenarioQuestCommitedEnd(questid)
		elseif state == msnStatus.ABANDON then
			self:RemoveScenarioQuest(questid)
	    end
		self:RefreshNpcState(0, questinfo.ActiveInfoNpcID)
		self:RefreshTaskShowNpc(questid)
	end
end

function TaskManager_CToLua:RefreshNpcState(npckey, npcbaseid)
	local state = self:GetNpcStateByID(npckey, npcbaseid)
	if gGetScene() then
		local pNpc = nil
		if npckey > 0 then
			pNpc = gGetScene():FindNpcByID(npckey)
			if not pNpc then
				pNpc = gGetScene():FindNpcByBaseID(npcbaseid)
	        end
		else
			pNpc = gGetScene():FindNpcByBaseID(npcbaseid)
	    end

		if pNpc then
			pNpc:SetQuestState(state, false)
	    end
	end
	TaskHelper.RefreshNpcState(npckey, npcbaseid)
end

function TaskManager_CToLua:RefreshScenarioDisplayNpcState(npcbaseid)
	if not gGetScene() then
		return
	end
	local state = self:GetNpcStateByID(0, npcbaseid)
    gGetScene():RefreshScenarioDisplayNpcState(npcbaseid, state)
end

function TaskManager_CToLua:GetSpecialQuest(questid)
    for index, quest in pairs(self.m_vSpecialQuest) do
		if quest.questid == questid then
			return quest
	    end
	end
	return nil
end

function TaskManager_CToLua:GetScenarioQuest(questid)
    for index, quest in pairs(self.m_vScenarioQuest) do
		if quest.missionid == questid then
			return quest
	    end
	end
	return nil
end

function TaskManager_CToLua:GetReceiveQuest(questid)
    for index, quest in pairs(self.m_vReceiveQuestList) do
		if quest.questid == questid then
			return quest
	    end
	end
	return nil
end

function TaskManager_CToLua:IsMasterStrokeQuest(questid)
	local bMain = TaskHelper.isMainTask(questid)
	return bMain > 0 and true or false
end

function TaskManager_CToLua:GetSpecailQuestForLua()
    local quests = { _size = 0 }
    function quests:size()
        return self._size
    end
    function quests:push_back(quest)
        self[self._size] = quest
        self._size = self._size + 1
    end

    for index, quest in pairs(self.m_vSpecialQuest) do
        quests:push_back(quest)
	end

    return quests
end

function TaskManager_CToLua:GetScenarioQuestListForLua()
    local quests = { _size = 0 }
    function quests:size()
        return self._size
    end
    function quests:push_back(quest)
        self[self._size] = quest
        self._size = self._size + 1
    end

    for index, quest in pairs(self.m_vScenarioQuest) do
        quests:push_back(quest)
	end

    return quests
end

function TaskManager_CToLua:GetReceiveQuestListForLua()
    local quests = { _size = 0 }
    function quests:size()
        return self._size
    end
    function quests:push_back(quest)
        self[self._size] = quest
        self._size = self._size + 1
    end

    for index, quest in pairs(self.m_vReceiveQuestList) do
        quests:push_back(quest)
        --SDLOG_INSANE(L"get active questid=%d", it->questid)
	end

    return quests
end

function TaskManager_CToLua:GetAcceptableQuestListForLua() 
    local quests = { _size = 0 }
    function quests:size()
        return self._size
    end
    function quests:push_back(quest)
        self[self._size] = quest
        self._size = self._size + 1
    end

    for index, taskid in pairs(self.m_vAcceptableQuestList) do
        quests:push_back(taskid)
	end

    return quests
end

function TaskManager_CToLua:GetSpecialQuestList()
    return self.m_vSpecialQuest
end

function TaskManager_CToLua:GetScenarioQuestList()
    return self.m_vScenarioQuest
end

function TaskManager_CToLua:GetReceiveQuestList()
    return self.m_vReceiveQuestList
end

function TaskManager_CToLua:GetAcceptableQuestList()
    return self.m_vAcceptableQuestList
end

function TaskManager_CToLua:GetTraceQuestListForLua() 
    local questids = { _size = 0 }
    function questids:size()
        return self._size
    end
    function questids:push_back(quest)
        self[self._size] = quest
        self._size = self._size + 1
    end

    local questdatas = { _size = 0 }
    function questdatas:size()
        return self._size
    end
    function questdatas:push_back(quest)
        self[self._size] = quest
        self._size = self._size + 1
    end

    for first, second in pairs(self.m_mTraceQuests) do
        questids:push_back(first)
        questdatas:push_back(second)
	end

    return questids, questdatas
end

function TaskManager_CToLua:GetTraceQuestList()
    return self.m_mTraceQuests
end

function TaskManager_CToLua:GetNpcStateByID(npckey, npcbaseid)
	local nResult = TaskHelper.GetNpcStateByID(npckey, npcbaseid)
	if nResult ~= -1 then
		return nResult
	end

	local queststate = 0

	-- scenario task 
    -------------------------------------------------------------
    for index, quest in pairs(self.m_vScenarioQuest) do
		local id = quest.missionid
		local questinfo = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(quest.missionid)
		if questinfo.ActiveInfoNpcID == npcbaseid then
			if math.floor(questinfo.MissionType / 10) == msnExeTypes.AIBATTLE then
				return eNpcMissionBattle
            end
			if self:IsMasterStrokeQuest(id) then
				return eNpcMissionMainQuest
            end
			if quest.missionstatus == msnStatus.FINISHED then
				return eNpcMissionCompleteQuest
            end
			if quest.missionstatus == msnStatus.PROCESSING then
				queststate = eNpcMissionInCompleteQuest
            end
        end
    end

	-- can accept task
    -------------------------------------------------------------
    for index, taskid in pairs(self.m_vAcceptableQuestList) do
		local destnpcid = GetAcceptableTaskId(taskid)
		if destnpcid == npcbaseid then
 			return eNpcMissionNewQuest
        end
    end

	-- repeat task
    -------------------------------------------------------------
    for index, quest in pairs(self.m_vSpecialQuest) do
		if (quest.dstnpckey ~= 0 and quest.dstnpckey == npckey) or
			(quest.dstnpckey == 0 and quest.dstnpcid == npcbaseid) then
			if quest.queststate == spcQuestState.DONE then
				return eNpcMissionCompleteQuest
			else
				return eNpcMissionInCompleteQuest
            end
        end
    end

	-- active task
    -------------------------------------------------------------
    for index, quest in pairs(self.m_vReceiveQuestList) do
		if (quest.dstnpckey == npckey and npckey ~= 0) or (quest.dstnpcid == npcbaseid and quest.dstnpckey == 0) then
			if quest.queststate == spcQuestState.DONE then
				return eNpcMissionCompleteQuest
			elseif quest.queststate == spcQuestState.UNDONE then
				queststate = eNpcMissionInCompleteQuest
			elseif quest.queststate == spcQuestState.INSTANCE_ABANDONED then
				queststate = eNpcMissionBattle
            end
        end
    end

	return queststate
end

function TaskManager_CToLua:GetQuestState(questid)
	local pScenarioQuest = self:GetScenarioQuest(questid)
	if pScenarioQuest then
		local questinfo = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(questid)
		if questinfo.MissionType == neTaskTypes.START_BATTLE or
			pScenarioQuest.missionstatus == msnStatus.FINISHED then
			return eMissionIconComplete
        end
		return eMissionIconNoComplete
    end
	local pSpecialQuest = self:GetSpecialQuest(questid)
	if pSpecialQuest then
		return pSpecialQuest.queststate == spcQuestState.DONE and eMissionIconComplete or eMissionIconNoComplete
    end
	return eMissionIconAcceptalbe
end

function TaskManager_CToLua:CheckAreaQuest()
	if gGetGameApplication() and gGetGameApplication():isShowProgressBar() then
		return
    end
    if GetBattleManager():IsInBattle() then
        return
    end
    
	local canIMove = TeamManager.CanIMove_cpp()
	if not canIMove then
        return
    end
    
    for index, quest in pairs(self.m_vScenarioQuest) do
		local questinfo = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(quest.missionid)
		if questinfo.MissionType % 10 == msnFinTypes.AREA and questinfo.ActiveInfoMapID == gGetScene():GetMapID() then
            local area = Nuclear.NuclearRect(questinfo.ActiveInfoLeftPos*16, questinfo.ActiveInfoTopPos*16,
                                 questinfo.ActiveInfoRightPos*16, questinfo.ActiveInfoBottomPos*16)
            local loc = GetMainCharacter():GetLogicLocation()
            if area:PtInRect(loc) then
				if questinfo.CruiseId > 0 then
					if GetMainCharacter():GetMoveState() == eMove_Fly then
						GetMainCharacter():StopAutoMove()
						return
	                end
	            end
				if questinfo.ProcessBarTime > 0 then
                    local readTimeType = require "protodef.rpcgen.fire.pb.mission.readtimetype":new()
					ReadTimeProgressDlg.Start(questinfo.ProcessBarText, readTimeType.END_AREA_QUEST, questinfo.ProcessBarTime * 1000, 0, questinfo.id)
				else
					local commitquest = require "protodef.fire.pb.mission.ccommitmission":new()
					commitquest.missionid = quest.missionid
					commitquest.npckey = 0
					LuaProtocolManager.getInstance():send(commitquest)
	            end
                return
	        end
	    end
	end
end

function TaskManager_CToLua:FinishScenarioQuest(questinfo)
	local pNpc = gGetScene():FindNpcByBaseID(questinfo.ActiveInfoNpcID)
	if pNpc then
		pNpc:BeginLeaveScene()
	end
end

function TaskManager_CToLua:SetLastSelectedTask(taskid)
    self.m_iLastSelectTaskid = taskid
end

function TaskManager_CToLua:GetLastSelectedTask()
    return self.m_iLastSelectTaskid
end

function TaskManager_CToLua:GetCurTaskNum()
	return TableUtil.tablelength(self.m_vSpecialQuest) + TableUtil.tablelength(self.m_vScenarioQuest) + TableUtil.tablelength(self.m_vReceiveQuestList)
end

function TaskManager_CToLua:ReceivedSpecialTaskResult(nNewTaskIdType, nNpcId)
	TaskHelper.ReceivedSpecialTaskResult(nNewTaskIdType, nNpcId)
end

function TaskManager_CToLua:DoneSpecialTaskResult(nOldTaskId, nNpcId)
	TaskHelper.DoneSpecialTaskResult(nOldTaskId, nNpcId)
end

function TaskManager_CToLua:CommitSpecialTaskResult(nOldTaskId, nNpcIdOld)
	TaskHelper.CommitSpecialTaskResult(nOldTaskId, nNpcIdOld)
end

function TaskManager_CToLua:CommitScenarioQuest(nTaskId, nNpcKey, nOptionId)
	local commitquest = require "protodef.fire.pb.mission.ccommitmission":new()
	commitquest.missionid = nTaskId
	commitquest.npckey = nNpcKey
	commitquest.option = nOptionId
	LuaProtocolManager.getInstance():send(commitquest)
end

function TaskManager_CToLua:ScenarioQuestCommitedEnd(nTaskId)
	local questinfo = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(nTaskId)
	if questinfo.ScenarioInfoFinishConversationList:size() ~= 0 then
		NpcSceneSpeakDialog.finishShowTalk(nTaskId)
	elseif questinfo.NoteInfo ~= "" then
		gGetGameUIManager():AddMessageTip(questinfo.NoteInfo)
	else
		self:FinishScenarioQuest(questinfo)
	end

	XinGongNengOpenDLG.CheckOpenXingGongNengByTaskComplete(nTaskId)
end

function TaskManager_CToLua:RefreshTaskShowNpc(questid)
	local questinfo = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(questid)
	local pQuest = self:GetScenarioQuest(questid)
	if not pQuest then
		return
	end
	for i = 0, questinfo.vTaskShowNpc:size() - 1 do
		self:RefreshScenarioDisplayNpcState(questinfo.vTaskShowNpc[i])
	end
end

function TaskManager_CToLua:resetCurMainTaskNpcState()
	local nTaskId = self:GetMainScenarioQuestId()
	self:RefreshScenarioQuestState(nTaskId, msnStatus.ABANDON)
end

function TaskManager_CToLua:clearTraceList()
	self.m_mTraceQuests = {}
end

function TaskManager_CToLua:EventUpdateLastQuestFire(nTaskId)
	self.EventUpdateLastQuest:Bingo(nTaskId)
end

function TaskManager_CToLua:GetMainScenarioQuestId()
	local nTaskId = TaskHelper.GetMainScenarioQuestId()
	return nTaskId
end

function TaskManager_CToLua:RefreshScenarioQuestValue(questData)
	local quest = self:GetScenarioQuest(questData.missionid)
	if not quest then
		return
	end
	quest.missionvalue = questData.missionvalue
	quest.missionround = questData.missionround
	quest.missionstatus = questData.missionstatus
	quest.dstnpckey = questData.dstnpckey
end

function TaskManager_CToLua:refreshSpecialTaskValue(questid, nType, llValue)
	local quest = self:GetSpecialQuest(questid)
	if not quest then
		return
	end

	if nType == rfhDataType.STATE then
		quest.queststate = math.floor(llValue)
	elseif nType == rfhDataType.DEST_NPD_KEY then
		quest.dstnpckey = math.floor(llValue)
	elseif nType == rfhDataType.DEST_NPD_ID then
		quest.dstnpcid = math.floor(llValue)
	elseif nType == rfhDataType.DEST_MAP_ID then
		quest.dstmapid = math.floor(llValue)
	elseif nType == rfhDataType.DEST_XPOS then
		quest.dstx = math.floor(llValue)
	elseif nType == rfhDataType.DEST_YPOS then
		quest.dsty = math.floor(llValue)
	elseif nType == rfhDataType.DEST_ITEM_ID then
		quest.dstitemid = math.floor(llValue)
	elseif nType == rfhDataType.DEST_ITEM1_NUM then
		quest.dstitemnum = math.floor(llValue)
	elseif nType == rfhDataType.DEST_ITEM2_ID then
		quest.dstitemid2 = math.floor(llValue)
	elseif nType == rfhDataType.DEST_ITEM2_NUM then
		quest.dstitemidnum2 = math.floor(llValue)
	elseif nType == rfhDataType.QUEST_TYPE then
		quest.questtype = math.floor(llValue)
	elseif nType == rfhDataType.SUMNUM then
		quest.sumnum = math.floor(llValue)
	end
end

function TaskManager_CToLua:refreshActiveTaskValue(questid, nType, llValue)
	local pActiveQuest = self:GetReceiveQuest(questid)
	if not pActiveQuest then
		return
	end

	if nType == rfhDataType.STATE then
		pActiveQuest.queststate = math.floor(llValue)
	elseif nType == rfhDataType.DEST_NPD_KEY then
		pActiveQuest.dstnpckey = math.floor(llValue)
	elseif nType == rfhDataType.DEST_NPD_ID then
		pActiveQuest.dstnpcid = math.floor(llValue)
	elseif nType == rfhDataType.DEST_MAP_ID then
		pActiveQuest.dstmapid = math.floor(llValue)
	elseif nType == rfhDataType.DEST_XPOS then
		pActiveQuest.dstx = math.floor(llValue)
	elseif nType == rfhDataType.DEST_YPOS then
		pActiveQuest.dsty = math.floor(llValue)
	elseif nType == rfhDataType.DEST_ITEM_ID then
		pActiveQuest.dstitemid = math.floor(llValue)
	elseif nType == rfhDataType.SUMNUM then
		pActiveQuest.sumnum = math.floor(llValue)
	end
end

function TaskManager_CToLua:clearAcceptList()
	self.m_vAcceptableQuestList = {}
end

function TaskManager_CToLua:GetQuestName(questid)
	local strSpecialQuestName = GetNewSpecialQuestName(questid)
	if strSpecialQuestName ~= "" then
		return strSpecialQuestName
	end
	local questinfo = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(questid)
	if questinfo.id ~= -1 then
		local name = questinfo.MissionName
		local firstpos = string.find(questinfo.MissionName, "$")
		if firstpos then
			name = string.sub(questinfo.MissionName, 0, firstpos - 1)
	    end
		if questinfo.AIInfoBattleLevel == "" then
			return name
		else
            return name .. questinfo.AIInfoBattleLevel
        end
	end
	return ""
end

function TaskManager_CToLua:GetLevelBonusRefreshTaskID()
    return self.m_iBonusRefreshTaskID
end

function TaskManager_CToLua:IsAlreadyRequestBonusInfo()
    return self.m_bRequestBonusInfo
end

function TaskManager_CToLua:SetAlreadyRequestBonusInfo()
    self.m_bRequestBonusInfo = true
end

function TaskManager_CToLua:IsBonusFinish()
    return self.m_bAllBonusFinish
end

function TaskManager_CToLua:GetIsTaskTraceDlgVisible()
    return self.m_bIsTaskTraceDlgVisible
end

function TaskManager_CToLua:SetIsTaskTraceDlgVisible(flag)
    self.m_bIsTaskTraceDlgVisible = flag
end

return TaskManager_CToLua
