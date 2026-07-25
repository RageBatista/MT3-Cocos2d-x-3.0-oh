require "protodef.rpcgen.fire.pb.mission.missioninfo"


require "protodef.rpcgen.fire.pb.circletask.specialqueststate"
local spcQuestState = SpecialQuestState:new()


Taskhelperprotocol = {}


function Taskhelperprotocol.srenxingcircletask_process(srenxingcircletask)
	LogInfo("Taskhelperprotocol.srenxingcircletask_process(srenxingcircletask)")
	
	local nServiceId = srenxingcircletask.serviceid
	local nTaskTypeId = srenxingcircletask.questid
	local nCount = srenxingcircletask.renxingtimes
	
	LogInfo("Taskhelperprotocol=nServiceId="..nServiceId)
	LogInfo("Taskhelperprotocol=nTaskTypeId="..nTaskTypeId)
	LogInfo("Taskhelperprotocol=nCount="..nCount)
	
	
	local nNpcKey = srenxingcircletask.npckey 
	--LogInfo("Taskhelperprotocol=nNpcKey="..nNpcKey)
	 
	local taskNpcDialog = require("logic.task.tasknpcdialog").getInstanceAndShow()
	taskNpcDialog:RefreshNpcDialog(nNpcKey,nServiceId,nCount)
	
	
end




function Taskhelperprotocol.squerycircletaskstate_process(squerycircletaskstate)
	LogInfo("Taskhelperprotocol.squerycircletaskstate_process(squerycircletaskstate)")
	local TaskHelper = require "logic.task.taskhelper"
	local nTaskTypeId = squerycircletaskstate.questid
	local nTaskState = squerycircletaskstate.state
	LogInfo("nTaskState="..nTaskState)

	local nPingId = TaskHelper.GetPindDingAnBangTaskId()
	if nPingId==nTaskTypeId then
		
		local bEnable = true
		local bVisible = false
		if spcQuestState.DONE==nTaskState then
            require"logic.huodong.huodongmanager".getInstance().m_HeroTrial = 2
			bVisible = false
			bEnable = false
		elseif spcQuestState.UNDONE==nTaskState then
            require"logic.huodong.huodongmanager".getInstance().m_HeroTrial = 1
			bVisible = false
			bEnable = false
		elseif spcQuestState.RECYCLE==nTaskState then
            require"logic.huodong.huodongmanager".getInstance().m_HeroTrial = 0
			bVisible = true
			bEnable = true
		end
		local bOpenInLevel = TaskHelper.IsPingTaskOpenInLevel()
		if bOpenInLevel==false then
			bVisible = false
			bEnable = true
		end
		require("logic.task.taskmanager").getInstance():setPingRedVisible(bVisible)
		
		local logodlg = require("logic.logo.logoinfodlg").getInstanceNotCreate()
		if logodlg then
			logodlg:RefreshAllBtn()
		end
		--[[local mapChoseDlg = require("logic.mapchose.mapchosedlg").getInstanceNotCreate()
		if mapChoseDlg then
			require "logic.mapchose.mapchosedlg".SetRedVisible(bVisible)
			mapChoseDlg:SetPingDingAnBangBtn(bEnable)
		end]]--
		
	end
end


--[[
TaskHelper.eTaskTypeGroup=
{
	eScenario =1, --//剧情任务
	eRepeatTask=2, --//循环任务
	eFubenTask=3,--副本任务类型
}

--]]


function Taskhelperprotocol.ShowCommitItemDialog_repeat(nNpcKey,nTaskTypeId)
	local pQuest = GetTaskManager():GetSpecialQuest(nTaskTypeId)
	if pQuest then
		local nTaskDetailId = pQuest.questtype
		local nTaskDetailType = TaskHelper.GetSpecialQuestType2(nTaskDetailId)
		if nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ItemFind then 
			local nItemId = pQuest.dstitemid
			local vItemKey = {}
			Taskhelperprotocol.GetItemKeyWithTableIdUseToItemTable(nItemId,vItemKey)
			local commitItemDlg = require "logic.task.taskcommititemdialog".getInstance()
			commitItemDlg:SetCommitItemId(vItemKey,nNpcKey,2,nTaskTypeId)--1 main 2=school
		elseif nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_PetCatch then
			local nPetId = pQuest.dstitemid
			local vPetKey = {}
			Taskhelperprotocol.GetHavePetWithIdUseToItemTable(nPetId,vPetKey)
			local commitItemDlg = require "logic.task.taskcommitpetdialog".getInstance()
			commitItemDlg:SetCommitItemId(vPetKey,nNpcKey,nTaskTypeId)
		end
	end
end


function Taskhelperprotocol.GetHavePetWithIdUseToItemTable(nPetId,vPetKey)

    local vCommitItemId = {}
    vCommitItemId[#vCommitItemId + 1] = nPetId

	local toItemTable = BeanConfigManager.getInstance():GetTableByName("item.citemtoitem"):getRecorder(nPetId)
    if toItemTable and toItemTable.id ~= -1 then
        local vcItemId = toItemTable.itemsid
        for nIndex=0,vcItemId:size()-1 do
            local nItemIdInTo = vcItemId[nIndex]
            vCommitItemId[#vCommitItemId + 1] = nItemIdInTo
        end
    end
    ----------------------------------------------
    local nPetNum = MainPetDataManager.getInstance():GetPetNum()
	for nIndex = 1,nPetNum do
		local pPet = MainPetDataManager.getInstance():getPet(nIndex)
        local nPetIdInMy = pPet.baseid

        local bCanCommit = Taskhelperprotocol.isItemIdInToItemTable(nPetIdInMy,vCommitItemId)

		if bCanCommit== true then
			local nPetKey = pPet.key
			vPetKey[#vPetKey +1] = nPetKey
		end
	end

end

function Taskhelperprotocol.getItemNumForTask(nItemId)
    local vCommitItemId = {}
    vCommitItemId[#vCommitItemId + 1] = nItemId

	local toItemTable = BeanConfigManager.getInstance():GetTableByName("item.citemtoitem"):getRecorder(nItemId)
    if toItemTable and toItemTable.id ~= -1 then
        local vcItemId = toItemTable.itemsid
        for nIndex=0,vcItemId:size()-1 do
            local nItemIdInTo = vcItemId[nIndex]
            vCommitItemId[#vCommitItemId + 1] = nItemIdInTo
        end
    end

    local nNumAll = 0

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    for nIndex=1,#vCommitItemId do
        local nItemIdInTo = vCommitItemId[nIndex] 
         local nNum = roleItemManager:GetItemNumByBaseID(nItemIdInTo)
         nNumAll = nNumAll + nNum
    end
    return nNumAll
end

--//取所有相同物品的key
function Taskhelperprotocol.GetItemKeyWithTableIdUseToItemTable(nItemId,vItemKey)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()

    local vCommitItemId = {}
    vCommitItemId[#vCommitItemId + 1] = nItemId

	local toItemTable = BeanConfigManager.getInstance():GetTableByName("item.citemtoitem"):getRecorder(nItemId)
    if toItemTable and toItemTable.id ~= -1 then
        local vcItemId = toItemTable.itemsid
        for nIndex=0,vcItemId:size()-1 do
            local nItemIdInTo = vcItemId[nIndex]
            vCommitItemId[#vCommitItemId + 1] = nItemIdInTo
        end
    end

    --------------------------------------------
	local vItemKeyAll = roleItemManager:GetItemKeyListByBag(fire.pb.item.BagTypes.BAG)
	for i = 0, vItemKeyAll:size() - 1 do
		local nItemKey = vItemKeyAll[i]
		local pRoleItem = roleItemManager:FindItemByBagAndThisID(nItemKey, fire.pb.item.BagTypes.BAG)
		if pRoleItem then
			local nTableId = pRoleItem:GetObjectID()
            local bCanCommit = Taskhelperprotocol.isItemIdInToItemTable(nTableId,vCommitItemId)

			if bCanCommit == true then
				vItemKey[#vItemKey + 1] = nItemKey
			end
		end
	end
end

function Taskhelperprotocol.isItemIdInToItemTable(nItemId,vToItemId)
    for nIndex=1,#vToItemId do
        if nItemId == vToItemId[nIndex] then
            return true
        end
    end
    return false
end

function Taskhelperprotocol.ssubmit2npc_process_gonghuifuben(protocol)
    LogInfo("Taskhelperprotocol.ShowCommitItemDialog_fuben(protocol)")
    local nNpcKey = protocol.npckey
	local nTaskTypeId = protocol.questid


    local nItemId = -1
    if #protocol.availableids > 0 then
        nItemId = protocol.availableids[1]
    end
    local nCommitNum = protocol.availablepos

	local vItemKey = {}
	Taskhelperprotocol.GetItemKeyWithTableIdUseToItemTable(nItemId,vItemKey)

    if #vItemKey == 0 then
        --如果没有该图品提示错误信息
        local msg = MHSD_UTILS.get_msgtipstring(160148)
	    GetCTipsManager():AddMessageTip(msg)
        return
    end
	
	local Taskcommititemdialog = require "logic.task.taskcommititemdialog" 
	local commitItemDlg = Taskcommititemdialog.getInstance()
	local eType = Taskcommititemdialog.eCommitType.eFuben
	commitItemDlg:SetCommitItemId(vItemKey,nNpcKey,eType,nTaskTypeId,nCommitNum)--1 main 2=school


	
end


function Taskhelperprotocol.ssubmit2npc_process(protocol)	
    
    local nNpcKey = protocol.npckey
	local nTaskTypeId = protocol.questid
    local submitType = protocol.submittype

    if submitType == 22 then --工会副本提交物品
        Taskhelperprotocol.ssubmit2npc_process_gonghuifuben(protocol)
        return
    end

	LogInfo("Taskhelperprotocol.ShowCommitItemDialog(nNpcKey,nTaskTypeId)="..nTaskTypeId)
	
	local TaskHelper = require("logic.task.taskhelper")
	local nGroupTaskType = TaskHelper.GetTaskTypeGroup(nTaskTypeId)
	if nGroupTaskType==TaskHelper.eTaskTypeGroup.eScenario  then
		
	elseif nGroupTaskType==TaskHelper.eTaskTypeGroup.eRepeatTask then
		Taskhelperprotocol.ShowCommitItemDialog_repeat(nNpcKey,nTaskTypeId)
	
	end

end 


--[[
self.service = 0
	self.title = "" 

--]]
function Taskhelperprotocol.ssendnpcservice_process(protocol)
    local nServiceId = protocol.service
    local strTitle = protocol.title
    local nNpcKey = protocol.npckey

    NpcDialog.handleWindowShut()

    local taskNpcDialog = require("logic.task.tasknpcdialog").getInstanceAndShow()
	--taskNpcDialog:RefreshNpcDialog(nNpcKey,nServiceId,nCount)
    taskNpcDialog:RefreshNpcDialog_commititem(nNpcKey,nServiceId,strTitle)
    --RefreshNpcDialog_commititem
end

function Taskhelperprotocol.swaitrolltime_process(protocol)
    local nMsgId = protocol.messageid
    local function callback()
    end
    local function clickYes(callBackObj,args)
        if CEGUI.toWindowEventArgs(args).handled ~= 1 then
	    	gGetMessageManager():CloseCurrentShowMessageBox()
        end
    end
    local nRightTick = 0
    gGetMessageManager():AddMessageBox("",
    require "utils.mhsdutils".get_msgtipstring(nMsgId),
    callback,
    Taskhelperprotocol,
    clickYes,
    Taskhelperprotocol,
    eMsgType_Normal,
    10000,
    0,
    0,
    nil,
    MHSD_UTILS.get_resstring(2037),
    MHSD_UTILS.get_resstring(2037),
    nRightTick,
    eConfirmOK)
end 

--self.teamleadername = "" 
function Taskhelperprotocol.saskintoinstance_process(protocol)
    local nMsgId = protocol.msgid
    local strTitle = protocol.teamleadername
    local nRewardCount = protocol.awardtimes
    local nStep = protocol.step
    local fubenType = protocol.insttype
    local data = {}
    data.name = protocol.teamleadername
    data.leaveTime = protocol.awardtimes
    data.insttype = protocol.insttype
    data.tlstep = protocol.tlstep
    data.mystep = protocol.mystep
    data.allstep = protocol.allstep
    data.steplist = {}
    data.steplist = protocol.steplist
    data.autoenter = protocol.autoenter
    local dlg = require "logic.fuben.fubenEnterDlg".getInstanceAndShow()
    dlg:initConnectedData(data)
--    --队长号召进入副本$parameter1$,您的奖励次数还剩余$parameter2$次,是否同意进入?。 有奖励次数时
--    -------------------------------------------------
--    local sb = StringBuilder:new()
--    local strMsg =  require "utils.mhsdutils".get_msgtipstring(nMsgId)

--    sb:Set("parameter1", strTitle)
--    if nRewardCount>0 then
--        sb:Set("parameter2", tostring(nRewardCount))
--    end
--	strMsg = sb:GetString(strMsg)
--	sb:delete()



--    if gGetMessageManager() then
--        gGetMessageManager():CloseCurrentShowMessageBox()
--    end
--    -----------------------------------------
--   local function clickYes(callBackObj,args)
--        LogInfo("Taskhelperprotocol.clickYes(args)")
--        if CEGUI.toWindowEventArgs(args).handled ~= 1 then
--	    	gGetMessageManager():CloseCurrentShowMessageBox()
--        end
--          local bAgree = true
--         Taskhelperprotocol.clickConfirmBox_saskintoinstance(bAgree, fubenType)
--    end
--    -----------------------------------------
--local function clickNo(callBackObj,args)
--     LogInfo("Taskhelperprotocol.clickNo(args)")
--    if CEGUI.toWindowEventArgs(args).handled ~= 1 then --user click  1=timeout
--		gGetMessageManager():CloseCurrentShowMessageBox()

--        local bAgree = false
--        Taskhelperprotocol.clickConfirmBox_saskintoinstance(bAgree, fubenType)
--        return
--    end
--      local bAgree = false
--      Taskhelperprotocol.clickConfirmBox_saskintoinstance(bAgree, fubenType)

--end
--    local nRightTick = 0
-------------------------------------------
--    local strTitle = ""
--    local strContent = strMsg
--    gGetMessageManager():AddMessageBox(strTitle,
--    strContent,
--    clickYes,
--    Taskhelperprotocol,
--    clickNo,
--    Taskhelperprotocol,
--    eMsgType_Normal,
--    20000,
--    0,
--    0,
--    nil,
--    MHSD_UTILS.get_resstring(996),
--    MHSD_UTILS.get_resstring(997),
--    nRightTick)


end



function Taskhelperprotocol.testBox()

------------------
local function clickYes(callBackObj,args)
   LogInfo("Taskhelperprotocol.clickYes(args)")
   if CEGUI.toWindowEventArgs(args).handled ~= 1 then
		gGetMessageManager():CloseCurrentShowMessageBox()
  end
end
-------------------
local function clickNo(callBackObj,args)
     LogInfo("Taskhelperprotocol.clickNo(args)")
    if CEGUI.toWindowEventArgs(args).handled ~= 1 then --user click 1=timeout
		gGetMessageManager():CloseCurrentShowMessageBox()
       
    end
end
-------------------

    local strTitle = "test"
    local strContent = "content"
    gGetMessageManager():AddMessageBox(strTitle,
    strContent,
    clickYes,
    Taskhelperprotocol,
    clickNo,
    Taskhelperprotocol,
    eMsgType_Normal,
    10000,
    0,
    0,
    nil,
    MHSD_UTILS.get_resstring(996),
    MHSD_UTILS.get_resstring(997))
end



function Taskhelperprotocol.clickConfirmBox_saskintoinstance(bAgree, fubenType)
    local nAgree = 0
    if bAgree==true then
        nAgree = 1
    end
	local p = require "protodef.fire.pb.mission.caskintoinstance":new()
    p.answer = nAgree --1表示同意, 0表示不同意
    p.insttype = fubenType
	require "manager.luaprotocolmanager":send(p)
end


function Taskhelperprotocol.strackedmissions_process(protocol)
    if not GetTaskManager() then
        return
    end
    GetTaskManager():clearTraceList()
    for nTaskId,traceQuest in pairs(protocol.trackedmissions) do
        Taskhelperprotocol.addTraceToList(nTaskId,traceQuest)
    end
    require("logic.task.renwulistdialog").InitTaskList()
end

function Taskhelperprotocol.addTraceToList(nTaskId,traceQuest)
    local bHave = false
    local pSpecialQuest = GetTaskManager():GetSpecialQuest(nTaskId)
	if  pSpecialQuest then
		bHave = true
	end
	local activequest = GetTaskManager():GetReceiveQuest(nTaskId)
    if  activequest then
        bHave = true
	end
	local pScenarioQuest = GetTaskManager():GetScenarioQuest(nTaskId)
	if  pScenarioQuest then
        bHave = true
    end

    if not bHave then
        return
    end
    local oneTrace = require "protodef.rpcgen.fire.pb.mission.trackedmission":new()
    oneTrace.acceptdate = traceQuest.acceptdate
    GetTaskManager():AddQuestToTraceList(nTaskId,oneTrace)
end

--
--[[
function Taskhelperprotocol.srefreshspecialquest_process(protocol)
     if not GetTaskManager() then
        return
    end
    local nTaskId = protocol.questid
    local nTaskState = protocol.queststate
    local quest = GetTaskManager():GetSpecialQuest(nTaskId)
    if quest==nil then
        if nTaskState==spcQuestState.SUCCESS then
            return
        end
        local quest1 = stSpecialQuest:new(); --wangbin todo
		quest1.questid = protocol.questid;
        
		quest1.questtype = protocol.questtype;
		quest1.queststate = protocol.queststate;
		quest1.round = protocol.round;
		quest1.sumnum = protocol.sumnum;
		quest1.dstmapid = protocol.dstmapid;
		quest1.dstnpckey = protocol.dstnpckey;
		quest1.dstnpcname = protocol.dstnpcname;
		quest1.dstnpcid = protocol.dstnpcid;
		quest1.dstitemid = protocol.dstitemid;
		quest1.dstx = protocol.dstx;
		quest1.dsty = protocol.dsty;
		quest1.dstitemnum = protocol.dstitemnum;
		quest1.dstitemid2 = protocol.dstitemid2;
		quest1.dstitemidnum2 = protocol.dstitemidnum2;
		quest1.validtime = protocol.validtime;
		quest1.islogin = protocol.islogin;
        local repeatTable = GameTable.circletask.GetCRepeatTaskTableInstance():getRecorder(protocol.questtype)
		quest1.name = repeatTable.strtypename
        
        GetTaskManager():AddSpecialQuest(quest1);
		GetTaskManager():AddNewQuestToTraceList(protocol.questid);
    else
        local npckeyOld = quest.dstnpckey;
		local npcidOld = quest.dstnpcid;
		local nTaskIdOld =quest.questtype;
		if protocol.questtype == 0  then
			GetTaskManager():RemoveSpecialQuest(protocol.questid);
		else
			quest.queststate = queststate; --wangbin todo ?
			quest.round = round;
			quest.sumnum = sumnum;
			quest.dstmapid = dstmapid;
			quest.dstnpckey = dstnpckey;
			quest.dstnpcname = dstnpcname;
			quest.dstnpcid = dstnpcid;
			quest.dstitemid = dstitemid;
			quest.dstx = dstx;
			quest.dsty = dsty;
			quest.dstitemnum = dstitemnum;
			quest.dstitemid2 = dstitemid2;
			quest.dstitemidnum2 = dstitemidnum2;
			quest.validtime = validtime;
			quest.islogin = islogin;
            local repeatTable = GameTable.circletask.GetCRepeatTaskTableInstance():getRecorder(protocol.questtype)
			quest.name = repeatTable.strtypename
			if quest.questtype ~= protocol.questtype then
				quest.questtype = protocol.questtype;
				GetTaskManager():AddNewQuestToTraceList(protocol.questid);
            end
		end
		if npckeyOld ~= protocol.dstnpckey or npcidOld ~= protocol.dstnpcid then
			GetTaskManager():RefreshNpcState(npckeyOld, npcidOld);
		end

    end
    GetTaskManager():EventUpdateLastQuestFire(protocol.questid);
	GetTaskManager():RefreshNpcState(protocol.dstnpckey, protocol.dstnpcid);
end
--]]

function  Taskhelperprotocol.srefreshspecialqueststate_process(protocol)
    if not GetTaskManager() then
        return
    end
    GetTaskManager():RefreshQuestState(protocol.questid,protocol.state);

	-- 完成日常副本，发 GameCenter 成就得分
	if protocol.questid == TaskHelper.eRepeatTaskId.richangfuben then
		require "protodef.rpcgen.fire.pb.circletask.specialqueststate"
		if protocol.state == SpecialQuestState.SUCCESS or protocol.state == SpecialQuestState.DONE then
			if GameCenter:GetInstance() then
                  local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
                  if manager then
                      if manager.m_isPointCardServer then
                           GameCenter:GetInstance():sendAchievementScore(GameCenterAchievementId_DK.DK_DailyInstance, 1);
                      else
                            GameCenter:GetInstance():sendAchievementScore(GameCenterAchievementId.DailyInstance, 1);
                      end
                  end
			end
		end
	end
end


function Taskhelperprotocol.protocolToScenarioQuestInfo(taskInfo,taskData)
    taskInfo.missionid = taskData.missionid
	taskInfo.missionstatus =taskData.missionstatus
	taskInfo.missionvalue = taskData.missionvalue
	taskInfo.missionround = taskData.missionround
	taskInfo.dstnpckey = taskData.dstnpckey
end


function Taskhelperprotocol.sacceptmission_process(protocol)

    local TaskHelper = require("logic.task.taskhelper")
    if not GetTaskManager() then
        return
    end
    local nTaskId = protocol.missioninfo.missionid
    local pScenario = GetTaskManager():GetScenarioQuest(nTaskId)
    if pScenario then
        return
    end
   
    local taskInfo = MissionInfo:new()
    local taskData = protocol.missioninfo
    Taskhelperprotocol.protocolToScenarioQuestInfo(taskInfo,taskData) 
    GetTaskManager():AddScenarioQuest(taskInfo); 

    require("logic.task.taskhelper").AddScenarioQuest(nTaskId)
    GetTaskManager():RemoveAcceptQuest(nTaskId)
    local taskTable = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(nTaskId)
    GetTaskManager():RefreshNpcState(protocol.missioninfo.dstnpckey,taskTable.ActiveInfoNpcID);
    GetTaskManager():RefreshTaskShowNpc(nTaskId);
    GetTaskManager():AddNewQuestToTraceList(nTaskId);
	GetTaskManager():EventUpdateLastQuestFire(nTaskId);

    if taskTable.AutoDo ==1 then --//1=autodo
        local renwulistDlg =  require("logic.task.renwulistdialog").getSingleton()
        if renwulistDlg then
             renwulistDlg:OnQuestBtnClickedIMP(nTaskId)
        end
       
	end
    if taskTable.CruiseId > 0 and protocol.missioninfo.missionvalue == 0 then
		GetMainCharacter():StartAutoMove(taskTable.CruiseId);
	end
	
end

function Taskhelperprotocol.srefreshmissionstate_process(protocol)
    if not GetTaskManager() then
        return
    end
    GetTaskManager():RefreshQuestState(protocol.missionid,protocol.missionstatus);
    Taskhelperprotocol.checkSendTaskEndForCG(protocol.missionid,protocol.missionstatus)
end

function Taskhelperprotocol.checkSendTaskEndForCG(nTaskId,nTaskState)
      local MissionStatus = require"protodef.rpcgen.fire.pb.mission.missionstatus":new()
       if nTaskState== MissionStatus.COMMITED then 
	     local questinfo = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(nTaskId)
         if questinfo.ScenarioInfoFinishConversationList:size() > 0 then
            return
         end
         if questinfo then
            if questinfo.ScenarioInfoAnimationID >0 or questinfo.RewardMapJumpType > 0 then
                
                  local taskEnd = require "protodef.fire.pb.mission.cmissiondialogend":new()
                 taskEnd.missionid = nTaskId
                 require "manager.luaprotocolmanager":send(taskEnd)
            end
         end
	end

end

function Taskhelperprotocol.srefreshmissionvalue_process(protocol)
    if not GetTaskManager() then
        return
    end
    local nTaskId = protocol.missionid
    
    local pScenarioQuest = GetTaskManager():GetScenarioQuest(nTaskId)
    if  not pScenarioQuest then
        return 
    end
    pScenarioQuest.missionvalue = protocol.missionidvalue
    pScenarioQuest.missionround = protocol.missionidround

   GetTaskManager():EventUpdateLastQuestFire(protocol.missionid);
  
end

function  Taskhelperprotocol.srefreshquestdata_process_special(protocol)
     if not GetTaskManager() then
        return
    end
    local questid =protocol.questid
    local quest = GetTaskManager():GetSpecialQuest(questid);
    if not quest then
        return
    end
		
    local RefreshDataType = require("protodef.rpcgen.fire.pb.circletask.refreshdatatype"):new()
	local oldnpcid = 0;
	for nType,llValue in pairs(protocol.datas) do
		if nType==RefreshDataType.STATE then
			local state = llValue;
			GetTaskManager():RefreshSpecialQuestState(quest, questid, state);
			if  state == spcQuestState.SUCCESS or
			    state == spcQuestState.ABANDONED or
			    state == spcQuestState.RECYCLE then
					
			    GetTaskManager():EventUpdateLastQuestFire(questid);
				return;
            end
		elseif nType == RefreshDataType.DEST_NPD_ID then
				oldnpcid = quest.dstnpcid;
        end
		GetTaskManager():refreshSpecialTaskValue(questid, nType, llValue);
	
    end
	if oldnpcid ~= 0 then
		GetTaskManager():RefreshNpcState(0,oldnpcid);
    end
	GetTaskManager():RefreshNpcState(quest.dstnpckey,quest.dstnpcid);
    RefreshDataType = nil
		
end

function Taskhelperprotocol.srefreshquestdata_process_active(protocol)
    if not GetTaskManager() then
        return
    end
    local questid =protocol.questid
    local pActiveQuest = GetTaskManager():GetReceiveQuest(questid);
    if not pActiveQuest then
        return
    end
    local RefreshDataType = require("protodef.rpcgen.fire.pb.circletask.refreshdatatype"):new()
	local oldnpcid = 0;
	for  nType,llValue in pairs(protocol.datas) do
		if nType == RefreshDataType.STATE then
			local state = llValue;
			GetTaskManager():RefreshReceiveQuestState(pActiveQuest, questid, state);
			if  state == spcQuestState.SUCCESS or
				state == spcQuestState.ABANDONED or
				state == spcQuestState.RECYCLE then
					GetTaskManager():EventUpdateLastQuestFire(questid);
					return;
             end
		elseif nType == RefreshDataType.DEST_NPD_ID then
			oldnpcid = pActiveQuest.dstnpcid;
        end

		GetTaskManager():refreshActiveTaskValue(questid, nType, llValue);
	end
	if oldnpcid ~= 0 then
		GetTaskManager():RefreshNpcState(0,oldnpcid);
    end
	GetTaskManager():RefreshNpcState(pActiveQuest.dstnpckey,pActiveQuest.dstnpcid);	
    RefreshDataType = nil	
		
end
function Taskhelperprotocol.srefreshquestdata_process(protocol)
     if not GetTaskManager() then
        return
    end
    Taskhelperprotocol.srefreshquestdata_process_special(protocol)
    Taskhelperprotocol.srefreshquestdata_process_active(protocol)
    GetTaskManager():EventUpdateLastQuestFire(protocol.questid);
end

function Taskhelperprotocol.sreqmissioncanaccept_process(protocol)
    if not GetTaskManager() then
        return
    end
    GetTaskManager():clearAcceptList()
    for k,nTaskId in pairs(protocol.missions) do
        GetTaskManager():AddOneQuestToAcceptable(nTaskId)

        local acceptCfg = BeanConfigManager.getInstance():GetTableByName("mission.cacceptabletask"):getRecorder(nTaskId)
		GetTaskManager():RefreshNpcState(0,acceptCfg.destnpcid);
    end
    
    require("logic.task.taskdialog").UpdateAcceptList()
	
end

function  Taskhelperprotocol.snpcfollowstart_process(protocol)
    if not gGetDataManager() then
        return
    end
    gGetDataManager():RemoveFollowNpc(protocol.npcid);
    gGetDataManager():AddFollowNpc(protocol.npcid);
end

function Taskhelperprotocol.snpcfollowend_process(protocol)
     if not gGetDataManager() then
        return
    end
    gGetDataManager():RemoveFollowNpc(protocol.npcid);
end

function Taskhelperprotocol.cdefineteam( answer )
	local p = require "protodef.fire.pb.mission.cdefineteam":new()
    p.answer = answer --1表示同意, 0表示不同意
	require "manager.luaprotocolmanager":send(p)
end

function Taskhelperprotocol.sdefineteam_process(protocol)
    local sb = StringBuilder:new()
    local strMsg =  require "utils.mhsdutils".get_msgtipstring(166059)
    local info = BeanConfigManager.getInstance():GetTableByName("mission.CShiGuangZhiXueConfig"):getRecorder(protocol.instid - 100)
    sb:Set("parameter1", info.name)
    sb:Set("parameter2", tostring(protocol.tlstep).."/5")
    sb:Set("parameter3", tostring(protocol.mystep).."/5")
	strMsg = sb:GetString(strMsg)
	sb:delete()


    if gGetMessageManager() then
        gGetMessageManager():CloseCurrentShowMessageBox()
    end
    -----------------------------------------
   local function clickYes(callBackObj,args)
        if CEGUI.toWindowEventArgs(args).handled ~= 1 then
	    	gGetMessageManager():CloseCurrentShowMessageBox()
            local iAgree = 1
            Taskhelperprotocol.cdefineteam(iAgree)
        end
    end
    -----------------------------------------
local function clickNo(callBackObj,args)
    if CEGUI.toWindowEventArgs(args).handled ~= 1 then --user click  1=timeout
		gGetMessageManager():CloseCurrentShowMessageBox()
        local iAgree = 0
        Taskhelperprotocol.cdefineteam(iAgree)
        return
    end
end
    local nRightTick = 0
-----------------------------------------
    local strTitle = ""
    local strContent = strMsg
    gGetMessageManager():AddMessageBox(strTitle,
    strContent,
    clickYes,
    Taskhelperprotocol,
    clickNo,
    Taskhelperprotocol,
    eMsgType_Normal,
    20000,
    0,
    0,
    nil,
    MHSD_UTILS.get_resstring(996),
    MHSD_UTILS.get_resstring(997),
    nRightTick)
end

function Taskhelperprotocol.sdropinstance_process(protocol)
    local sb = StringBuilder:new()
    local strMsg =  require "utils.mhsdutils".get_msgtipstring(protocol.messageid)
    sb:Set("parameter1", protocol.landname)
	strMsg = sb:GetString(strMsg)
	sb:delete()
    local function ClickYes(args)
        local p = require "protodef.fire.pb.mission.cdropinstance":new()
	    require "manager.luaprotocolmanager":send(p)
        gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
    end
----    if gGetMessageManager() then
----        gGetMessageManager():CloseCurrentShowMessageBox()
----    end
    gGetMessageManager():AddConfirmBox(eConfirmNormal, strMsg, ClickYes, 0, MessageManager.HandleDefaultCancelEvent, MessageManager)
end

return Taskhelperprotocol
