
require "logic.task.taskhelpergoto"
require "logic.task.taskhelperchat"
require "logic.task.taskhelperscenario" 
require "logic.task.taskhelpernpc" 

require "logic.task.taskhelpertable" 




TaskHelper = {}
TaskHelper.nRiChangId = 1
TaskHelper.nHuodongId = 2
TaskHelper.nMainTaskId = 3
TaskHelper.nFenZhiId = 4
TaskHelper.nJuBaoId = 5
TaskHelper.nLeaveTaskId = 6
TaskHelper.nAnyeFollow = 7

TaskHelper.nPingDingAnBangServiceId = 100002
--//传说buff
TaskHelper.ITEM_FIND_LEGEND_BUFF = 507023

TaskHelper.nPingTaskDetailId = 1050001
TaskHelper.nActiveMenpai_acceptTask = 701001
TaskHelper.nActiveMenpai_Task = 701002

TaskHelper.nAnyeTaskTypeId = 2000000

TaskHelper.eRepeatTaskId=
{
    kaogu = 1040000,
    richangfuben=1030000,
    yingxiongshilian=1050000

}

function TaskHelper.GetItemIdInCurTask(nNpcKey)
   
	LogInfo("TaskHelper.GetItemIdInCurTask(nNpcKey)="..nNpcKey)
	local pNpc = gGetScene():FindNpcByID(nNpcKey)
	if not pNpc then	
		LogInfo("not pNpc")	
		return -1
	end
	local nNpcId = pNpc:GetNpcBaseID()
	LogInfo("nNpcId="..nNpcId)
	local vTaskIdInNpc = {}
	require("logic.task.taskhelpernpc").GetTaskIdInNpc(nNpcId,vTaskIdInNpc)
	local nNum = #vTaskIdInNpc
	if nNum==0 then
		return -1
	end
	local nLastTaskTypeId = GetMainCharacter():GetGotoTargetPosType()
	if nLastTaskTypeId==0 then
		return -1
	end
	local bHaveLastTask = false
	for nIndex=1,nNum do
		local nTaskId = vTaskIdInNpc[nIndex]
		if nTaskId==nLastTaskTypeId then
			bHaveLastTask = true
		end
	end
	if bHaveLastTask==false then
		return -1
	end
	
    local nItemId = -1
	local nNeedItemNum = 0
	local pQuest = GetTaskManager():GetSpecialQuest(nLastTaskTypeId)
	if  pQuest then
		nItemId = pQuest.dstitemid
        nNeedItemNum = pQuest.dstitemnum
	    return nItemId,nNeedItemNum
	end

    local anyeTaskData = require("logic.task.taskmanager").getInstance():getOneTaskDataWithTaskId(nLastTaskTypeId)
    if anyeTaskData then
        nItemId = anyeTaskData.dstitemid
        nNeedItemNum = anyeTaskData.dstitemnum
	    return nItemId,nNeedItemNum
    end

	return nItemId,nNeedItemNum
	
end


function TaskHelper.GetPindDingAnBangTaskId()
	local nServiceId = TaskHelper.nPingDingAnBangServiceId
	local serviceTaskTable = BeanConfigManager.getInstance():GetTableByName("npc.cnpcservicemapping"):getRecorder(nServiceId)
	if not serviceTaskTable then
		return 0
	end
	
	local nTaskTypeId = serviceTaskTable.param1 --1050000
	return nTaskTypeId
end

function TaskHelper.IsPingTaskOpenInLevel()
	local nTaskDetailId = TaskHelper.nPingTaskDetailId
	return TaskHelper.IsTaskOpenInLevel(nTaskDetailId)
end


function TaskHelper.IsTaskOpenInLevel(nTaskDetailId)
    
    local dataManager = gGetDataManager()
    if not dataManager then
        return false
    end

	local repeatTable = Taskhelpertable.GetRepeatTaskData(nTaskDetailId)
	if not repeatTable then
		return false
	end
	local nUserLevel = gGetDataManager():GetMainCharacterLevel()
	local nMinLv = repeatTable.levelmin
	if nUserLevel<nMinLv then
		return false
	end
	
	return true
end

function TaskHelper.SendIsHavePingDingAnBangTask(nparam)

	LogInfo("TaskHelper.SendIsHavePingDingAnBangTask()")
	local nTaskTypeId = TaskHelper.GetPindDingAnBangTaskId()
	local p = require "protodef.fire.pb.circletask.cquerycircletaskstate":new()
	p.questid = nTaskTypeId
	require "manager.luaprotocolmanager":send(p)
    
end



function TaskHelper.RefreshNpcState(nNpcKey,nNpcId)
end

function TaskHelper.GetNpcStateByID( nNpcKey,nNpcId)
	
	local nResult = Taskhelpernpc.GetNpcStateByID(nNpcKey,nNpcId)
	return nResult
end

function TaskHelper.IsHavePingDingAnBangTask()
	
	local nServiceId = TaskHelper.nPingDingAnBangServiceId
	local serviceTaskTable = BeanConfigManager.getInstance():GetTableByName("npc.cnpcservicemapping"):getRecorder(nServiceId)
	if not serviceTaskTable then
		return false
	end
	
	local nTaskTypeId = serviceTaskTable.param1 --1050000
	local pQuest = GetTaskManager():GetSpecialQuest(nTaskTypeId)
	if not pQuest then
		return false
	end
	return true
	
end


function TaskHelper.AcceptPingDingAnBangTask()
	local nNpcKey = 0
	local nServiceId = TaskHelper.nPingDingAnBangServiceId
    require "manager.npcservicemanager".SendNpcService(nNpcKey, nServiceId)
end


function TaskHelper.GetCatchItTaskTypeId()
    local tt = BeanConfigManager.getInstance():GetTableByName("circletask.crepeattask")
    local ids = tt:getAllID()
    local num = tt:getSize()
    for i = 1, num do
		local nTaskTypeIdInTable = ids[i]
		local record = BeanConfigManager.getInstance():GetTableByName("circletask.crepeattask"):getRecorder(nTaskTypeIdInTable)
        if record.etasktype== fire.pb.circletask.CircTaskClass.CircTask_CatchIt then
			return record.eactivetype
        end
    end
	return -1
end


function TaskHelper.GetRepeatTaskMaxCount(nTaskDetailId)
	
	local repeatTable = BeanConfigManager.getInstance():GetTableByName("circletask.crepeattask"):getRecorder(nTaskDetailId)
    if not repeatTable then
        return -1
    end
	local nTaskTypeId = repeatTable.eactivetype
	
	local vcId = BeanConfigManager.getInstance():GetTableByName("circletask.cschooltask"):getAllID()
    local level = GetMainCharacter():GetLevel()
    for i = 1, #vcId do
		local nTaskTypeIdInTable = vcId[i]
		local record = BeanConfigManager.getInstance():GetTableByName("circletask.cschooltask"):getRecorder(nTaskTypeIdInTable)
        if nTaskTypeId==record.type  

			then
            local nMaxNum = record.maxnum
            return nMaxNum
        end
    end
	return -1
end


function TaskHelper.SetSbFormat_repeatTaskAll(pQuest,sb)
	local nTaskDetailId = pQuest.questtype
	local nTaskDetailType = TaskHelper.GetSpecialQuestType2(nTaskDetailId) 
		--//==========================================
		-- 职业送信
		if nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_Mail then
			TaskHelper.SetSbFormat_CircTask_Mail(pQuest,sb)
		--//==========================================
		-- 职业制作打造符
		elseif nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ItemUse then 
			TaskHelper.SetSbFormat_CircTask_ItemUse(pQuest,sb)
		--//==========================================
		--//职业收集物品 打怪寻物
        elseif nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ItemCollect then  
			TaskHelper.SetSbFormat_CircTask_ItemCollect(pQuest,sb)
		--//==========================================
		-- 职业巡逻
		elseif nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_Patrol then 
			TaskHelper.SetSbFormat_CircTask_Patrol(pQuest,sb)
		--//==========================================
		--//职业-买道具
		elseif nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ItemFind then
			TaskHelper.SetSbFormat_CircTask_ItemFind(pQuest,sb)
		--//==========================================
		--//职业-捕获宠物
		elseif nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_PetCatch then
			TaskHelper.SetSbFormat_CircTask_PetCatch(pQuest,sb)
		--//==========================================
			
		elseif nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_CatchIt then 
			TaskHelper.SetSbFormat_CircTask_Catch(pQuest,sb)
		--//==========================================
		--//shi lian
		elseif nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_KillMonster then
			--TaskHelper.SetSbFormat_CircTask_KillMonster(pQuest,sb)
			require("logic.task.taskhelperformat").SetSbFormat_CircTask_KillMonster(pQuest,sb)
		--//==========================================
		elseif fire.pb.circletask.CircTaskClass.CircTask_ChallengeNpc == nTaskDetailType then
			require("logic.task.taskhelperformat").SetSbFormat_CircTask_ChallengeNpc(pQuest,sb)
		--//==========================================
		else
			require("logic.task.taskhelperformat").SetSbFormat_CircTask_normal(pQuest,sb)
		end
end

function TaskHelper.SetSbFormat_CircTask_KillMonster(pQuest,sb)
	--require("logic.task.taskhelperformat").SetSbFormat_CircTask_KillMonster(pQuest,sb)
end

function TaskHelper.SetSbFormat_Active_Menpai(pQuest, sb) 
    local nNpcId = pQuest.dstnpcid
	local npcConfig = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(nNpcId)
    if npcConfig then
        sb:Set("NPCName",npcConfig.name)
	    local mapcongig = BeanConfigManager.getInstance():GetTableByName("map.cmapconfig"):getRecorder(npcConfig.mapid)
	    sb:Set("MapName",mapcongig.mapName)
	    sb:SetNum("mapid",npcConfig.mapid)
	    sb:SetNum("xPos",npcConfig.xPos)
	    sb:SetNum("yPos",npcConfig.yPos)
	    sb:SetNum("npcid",pQuest.dstnpcid)
    end
end
	
--职业送信
function TaskHelper.SetSbFormat_CircTask_Mail(pQuest,sb)
	local nNpcId = pQuest.dstnpcid
	local npcConfig = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(nNpcId)
    if npcConfig then
	    sb:Set("NPCName",npcConfig.name)
	    local mapcongig = BeanConfigManager.getInstance():GetTableByName("map.cmapconfig"):getRecorder(npcConfig.mapid)
	    sb:Set("MapName",mapcongig.mapName)
	    --sb:SetNum("xjPos",mapcongig.xjPos)
	    --sb:SetNum("yjPos",mapcongig.yjPos)
	    sb:SetNum("mapid",npcConfig.mapid)
	    sb:SetNum("xPos",npcConfig.xPos)
	    sb:SetNum("yPos",npcConfig.yPos)
	    sb:SetNum("npcid",pQuest.dstnpcid)
    end
end

--//买宠物
function TaskHelper.SetSbFormat_CircTask_PetCatch(pQuest,sb)
	local nTaskDetailId = pQuest.questtype
	
	
	local nPetId = pQuest.dstitemid
	local nPetNum =  pQuest.dstitemnum
	
	
	local nHaveAllPetNum = TaskHelper.getHavePetNumWithInBattle(nPetId) -- #vPetKey
	local petAttrCfg = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(nPetId)
	local nNeedItemNum =  pQuest.dstitemnum --buyPetCfg.itemnum
	local nHaveItemNum = nHaveAllPetNum
    if petAttrCfg then
	    sb:Set("PetName", petAttrCfg.name)
    end
	sb:SetNum("Number2", nHaveItemNum)
	sb:SetNum("Number3", nNeedItemNum) --总个数
end

function TaskHelper.getHavePetNumWithInBattle(nPetId)
	local vItemKeyAll = {}
	require("logic.task.taskhelperprotocol").GetHavePetWithIdUseToItemTable(nPetId,vItemKeyAll)
	
	local nPeiKeyInBattle = gGetDataManager():GetBattlePetID()

	local vItemKey = {}
	for k,nPetKey in pairs(vItemKeyAll) do 
		if nPetKey ~= nPeiKeyInBattle then
			vItemKey[#vItemKey +1] = nPetKey
		end
	end
	local nNum = #vItemKey
	return nNum
end

--职业巡逻
function TaskHelper.SetSbFormat_CircTask_Patrol(pQuest,sb)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local nItemId = pQuest.dstitemid
	local nMapId = pQuest.dstmapid
	local mapCfg = BeanConfigManager.getInstance():GetTableByName("map.cmapconfig"):getRecorder(nMapId)
    local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)

	local nHaveItemNum = roleItemManager:GetItemNumByBaseID(nItemId)
	--sb:SetNum("npcid",pQuest.dstnpcid)
	sb:Set("MapName",mapCfg.mapName)
    if itemAttrCfg then
	    sb:Set("ItemName", itemAttrCfg.name)
    end
	sb:SetNum("Number2", nHaveItemNum)
	
end

--职业购买物品
function TaskHelper.SetSbFormat_CircTask_ItemFind(pQuest,sb)
	
	LogInfo("TaskHelper.SetSbFormat_CircTask_ItemFind(pQuest,sb)")
	local nItemId = pQuest.dstitemid
	local nTaskDetailId = pQuest.questtype
	
	local nNeedItemNum = pQuest.dstitemnum
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	--local nHaveItemNum = require("logic.item.roleitemmanager").getInstance():GetItemNumByBaseID(nItemId)
     local nHaveItemNum  = require("logic.task.taskhelperprotocol").getItemNumForTask(nItemId)
	
    local nCurlevel = GetMainCharacter():GetLevel()
    local repeatTable = BeanConfigManager.getInstance():GetTableByName("circletask.crepeattask"):getRecorder(nTaskDetailId)
	if repeatTable.id ==-1 then
		return 
	end
	local nSchoolId =  gGetDataManager():GetMainCharacterSchoolID()
	local nGroupId = repeatTable.ngroupid
    local nQuality = require("logic.task.taskhelpertable").GetQuality(nSchoolId,nGroupId,nCurlevel)

	--sb:SetNum("npcid",pQuest.dstnpcid)
    if itemAttrCfg then
	    sb:Set("ItemName", itemAttrCfg.name)
    end
	sb:SetNum("Number2", nHaveItemNum)
	sb:SetNum("Number3", nNeedItemNum) --总个数
	sb:SetNum("Number4", nQuality)
	
	LogInfo("TaskHelper.SetSbFormat_CircTask_ItemFind=nItemId="..nItemId)
end

--职业打怪收集物品
function TaskHelper.SetSbFormat_CircTask_ItemCollect(pQuest,sb)
	local nTaskDetailId = pQuest.questtype
	local repeatCfg = BeanConfigManager.getInstance():GetTableByName("circletask.crepeattask"):getRecorder(nTaskDetailId)
	local nGroupId = repeatCfg.ngroupid
	local nCollectItemTableId = TaskHelper.GetSchoolTaskBattleToCollectItemTableId(nGroupId)
	local collectItemCfg = BeanConfigManager.getInstance():GetTableByName("circletask.ccirctaskitemcollect"):getRecorder(nCollectItemTableId)
	local nNeedItemNum = collectItemCfg.itemnum 
	local nMapId = pQuest.dstmapid
	local nCollectItemId = collectItemCfg.itemid 
    local mapcongig = BeanConfigManager.getInstance():GetTableByName("map.cmapconfig"):getRecorder(nMapId)
    sb:Set("MapName",mapcongig.mapName)
    --sb:Set("petname",mapcongig.mapName)
	--local nHaveItemNum = 
    local itemattr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nCollectItemId)
    if itemattr then
        sb:Set("ItemName", itemattr.name)
    end
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local nHaveItemNum = roleItemManager:GetItemNumByBaseID(nCollectItemId)
    sb:SetNum("Number2", nHaveItemNum)
	sb:SetNum("Number3", nNeedItemNum) --总个数
    sb:SetNum("mapid",nMapId)
	
end

--职业使用物品
function TaskHelper.SetSbFormat_CircTask_ItemUse(pQuest,sb)
	local nTaskId = pQuest.questtype
	local nMapId = pQuest.dstmapid 
	local mapcongig = BeanConfigManager.getInstance():GetTableByName("map.cmapconfig"):getRecorder(nMapId)
	sb:Set("MapName",mapcongig.mapName)
end


function TaskHelper.SetSbFormat_CircTask_Catch(pQuest,sb)
	
	
	local nNpcId = pQuest.dstnpcid
	local nMapId = pQuest.dstmapid
	local strNpcName = pQuest.dstnpcname
	local nTargetNpcId = pQuest.dstitemid
	local nTargetNum = pQuest.dstitemnum
	local nCurKillNum = pQuest.dstnpcid
	
	--local npcConfig = GameTable.npc.GetCNPCConfigTableInstance():getRecorder(nNpcId)
	
	
	sb:Set("NPCName",strNpcName)
	local mapcongig = BeanConfigManager.getInstance():GetTableByName("map.cmapconfig"):getRecorder(nMapId)
	sb:Set("MapName",mapcongig.mapName)
	
	--local nNpcId = pQuest.dstnpcid
	local npcConfig = BeanConfigManager.getInstance():GetTableByName("map.cmapconfig"):getRecorder(nNpcId)
	if strNpcName==nil then
		sb:Set("NPCName",npcConfig.name)
	end
	
end
--//============================================
--//============================================
--//============================================


--职业使用物品
function TaskHelper.GetSchoolTaskUseItemTableId(nGroupId)
	local nSchoolId =  gGetDataManager():GetMainCharacterSchoolID()
	local vcId = BeanConfigManager.getInstance():GetTableByName("circletask.cschooluseitem"):getAllID()
    local nCurLevel = GetMainCharacter():GetLevel()
    for i = 1, #vcId do
		local taskUseItemCfg = BeanConfigManager.getInstance():GetTableByName("circletask.cschooluseitem"):getRecorder(vcId[i])
        if nGroupId == taskUseItemCfg.nuseitemgroup and
		
		 (taskUseItemCfg.nschoolid==nSchoolId or taskUseItemCfg.nschoolid==0)
		then
            return taskUseItemCfg.id
        end
    end
	return -1
end

--职业打怪收集物品 物品的数量
function TaskHelper.GetSchoolTaskBattleToCollectItemTableId(nGroupId)
	local nSchoolId =  gGetDataManager():GetMainCharacterSchoolID()
	local vcId = BeanConfigManager.getInstance():GetTableByName("circletask.ccirctaskitemcollect"):getAllID()
    local nCurLevel = GetMainCharacter():GetLevel()
    for i = 1, #vcId do
    local record = BeanConfigManager.getInstance():GetTableByName("circletask.ccirctaskitemcollect"):getRecorder(vcId[i])
        if record.levelmax >= nCurLevel and
		 record.levelmin <= nCurLevel and
		(nSchoolId == record.school or  record.school==0) and
		nGroupId==record.ctgroup then
            return record.id
        end
    end
	return -1
end

--//============================================
--//============================================
--//============================================

--//取任务名字title
function TaskHelper.GetSpecialTrackName(nQuestId)
	local repeatCfg = BeanConfigManager.getInstance():GetTableByName("circletask.crepeattask"):getRecorder(nQuestId)
	if repeatCfg then
		local strTrackName = repeatCfg.strtasktitletrack
		return strTrackName
	end
	return ""
end

--//取任务内容
function TaskHelper.GetSpecialTrackContent(nQuestId)
	local repeatCfg = BeanConfigManager.getInstance():GetTableByName("circletask.crepeattask"):getRecorder(nQuestId)
	if repeatCfg then
		local strTrackContent =  repeatCfg.strtaskdestrack
		return strTrackContent
	end
	return ""
end

function TaskHelper.GetSpecialQuestTypeWithNum(nQuestId)
	local nResult = math.floor(nQuestId/10000)
	nResult = nResult % 100
	return nResult
end

--//取任务的详细类型
function TaskHelper.GetSpecialQuestType2(nQuestId)
	local repeatCfg = BeanConfigManager.getInstance():GetTableByName("circletask.crepeattask"):getRecorder(nQuestId)
	if repeatCfg then
		return repeatCfg.etasktype
	end
	return -1
end


--//收到任务后对话
function TaskHelper.ReceivedSpecialTaskResult(nTaskTyepId,nOldNpcId)
	Taskhelperchat.ReceivedSpecialTaskResult(nTaskTyepId,nOldNpcId)

end

--//完成循环任务后对话
function TaskHelper.DoneSpecialTaskResult(nTaskTyepId,nOldNpcId)
	Taskhelperchat.DoneSpecialTaskResult(nTaskTyepId,nOldNpcId)
end

--//commit special task
function TaskHelper.CommitSpecialTaskResult(nTaskTyepId,nOldNpcId)
	Taskhelperchat.CommitSpecialTaskResult(nTaskTyepId,nOldNpcId)
end

function TaskHelper.GetSchoolMonsterId()
	local nSchoolId = gGetDataManager():GetMainCharacterSchoolID()
	LogInfo("TaskHelper.GetSchoolMonsterId()=nSchoolId="..nSchoolId)
	local schoolRecord = BeanConfigManager.getInstance():GetTableByName("role.schoolmasterskillinfo"):getRecorder(nSchoolId)
	if schoolRecord == nil then
		return -1
	end
	local nSchoolMonsterId = schoolRecord.masterid
	return nSchoolMonsterId
end
--//============================================
--//============================================
--//============================================


TaskHelper.eTaskTypeGroup=
{
	eScenario =1, --//剧情任务
	eRepeatTask=2, --//循环任务
    eActiveTask=3, --活动任务类型
    eAnyeTask=4 --马戏团任务

}

TaskHelper.eTaskTypeScenario=
{
	eMainTask =1, --//主线
	eBranchTask =2, --//支线
}


function TaskHelper.GetTaskTypeGroup(nTaskTypeId)
	local nResult = math.floor( nTaskTypeId /1000000) --7位
	if nResult == 1 then --//循环任务
		return TaskHelper.eTaskTypeGroup.eRepeatTask
    elseif nResult == 2 then
        return TaskHelper.eTaskTypeGroup.eAnyeTask
	end

    if math.floor( nTaskTypeId /100000) == 7 then --6位活动 暂时公会（门-派）闯关
        return TaskHelper.eTaskTypeGroup.eActiveTask  --活动任务类型
    end

	local scenarioTable = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(nTaskTypeId)
	if scenarioTable.id==-1 then
		return -1
	end
	return TaskHelper.eTaskTypeGroup.eScenario

end

function TaskHelper.GetTaskTypeScenario(nTaskTypeId)
	local scenarioTable = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(nTaskTypeId)
	if scenarioTable.id==-1 then
		return -1
	end
	--//0==6位id
	local nResult = math.floor(nTaskTypeId /100000) --//6位
	if nResult==1 then
		--//主线任务
		return TaskHelper.eTaskTypeScenario.eMainTask
	elseif nTaskTypeId >= 200000  and nTaskTypeId < 999999 then
		 --//支线任务
		return TaskHelper.eTaskTypeScenario.eBranchTask
	end
	return -1
end

function TaskHelper.isMainTask(nTaskTypeId)
    --local TaskHelper = require("logic.task.taskhelper")
	local nGroupTaskType = TaskHelper.GetTaskTypeGroup(nTaskTypeId)
	if nGroupTaskType==TaskHelper.eTaskTypeGroup.eScenario then
         local scenarioType = TaskHelper.GetTaskTypeScenario(nTaskTypeId)
         if scenarioType == TaskHelper.eTaskTypeScenario.eMainTask then
            return 1
         end
	end
    return 0
end

function TaskHelper.GetMainScenarioQuestId()
    local scenarioquests = GetTaskManager():GetScenarioQuestListForLua()
	local scenarioquestnum = scenarioquests:size()
	for i = 0, scenarioquestnum - 1 do
		local scenarioquest = scenarioquests[i]
        local nTaskId = scenarioquest.missionid
        local bMainTask = TaskHelper.isMainTask(nTaskId)
        if bMainTask==1 then
            return nTaskId
        end
    end
    return 0
end


function TaskHelper.GetTaskTypeInAll(nTaskTypeId)
end

function TaskHelper.isAnyeTaskId(nTaskTypeId)
    local anyeTable = BeanConfigManager.getInstance():GetTableByName("circletask.canyemaxituanconf"):getRecorder(nTaskTypeId)
    if anyeTable then
        return true
    end
    return false
end

--//============================================
--//点击追踪按钮 return false --no to c
function TaskHelper.OnClickCellGoto(nTaskTypeId)
	
    if nTaskTypeId==TaskHelper.nAnyeTaskTypeId then
        require("logic.anye.anyemaxituandialog").getInstanceAndShow()
        return
    end
    --是不是暗夜马戏团任务追踪
    
    local bAnyeTask = require("logic.task.taskhelper").isAnyeTaskId(nTaskTypeId)

    if bAnyeTask then
        local taskmanager = require("logic.task.taskmanager").getInstance()
        local taskDataStatus =  taskmanager.vAnyeTask[taskmanager.m_nAnyeFollowIndex].legend
        if taskDataStatus == 3 then
            GetCTipsManager():AddMessageTipById(166119)
            require("logic.anye.anyemaxituandialog").getInstanceAndShow()
            return
        elseif taskDataStatus == 4 then
            GetCTipsManager():AddMessageTipById(166120)
            require("logic.anye.anyemaxituandialog").getInstanceAndShow()
            return
        end
    	local data = gGetDataManager():GetMainCharacterData()
	    local level = data:GetValue(1230)
        local mapId = 0
        local indexIDs = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getAllID()
	    for _, v in pairs(indexIDs) do
		    local mapconfig = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(v)
		    local minLevel = mapconfig.LevelLimitMin
		    local maxlevel = mapconfig.LevelLimitMax
		    if  level < maxlevel and level > minLevel or level == maxlevel or level == minLevel then
			    mapId = mapconfig.id
		    end
	    end
        local mapRecord = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(mapId)
	    if mapRecord then
		    local randX = mapRecord.bottomx - mapRecord.topx
		    randX = mapRecord.topx + math.random(0, randX)

		    local randY = mapRecord.bottomy - mapRecord.topy
		    randY = mapRecord.topy + math.random(0, randY)

		    local nTargetPosX = randX
		    local nTargetPosY = randY
		
		    local flyWalkData = {}
		    Taskhelpergoto.GetInitedFlyWalkData(flyWalkData)
		    flyWalkData.nMapId = mapId
		    --flyWalkData.nNpcId = nNpcId
		    flyWalkData.nRandX = randX
		    flyWalkData.nRandY = randY
		    flyWalkData.bXunLuo = 1
		    flyWalkData.nTargetPosX = nTargetPosX
		    flyWalkData.nTargetPosY = nTargetPosY
		    Taskhelpergoto.FlyOrWalkTo(flyWalkData)
	    end
    end

    if nTaskTypeId ==TaskHelper.eRepeatTaskId.yingxiongshilian then
--        require "logic.huodong.huodongdlg".getInstanceAndShow()
--        local p = require("protodef.fire.pb.mission.activelist.crefreshactivitylistfinishtimes"):new()
--	    LuaProtocolManager:send(p)
        local str = MHSD_UTILS.get_msgtipstring(166128)
	    GetCTipsManager():AddMessageTip(str)
        return
    end

	local taskManager = require("logic.task.taskmanager").getInstance()
    if GetTeamManager() and GetTeamManager():CanIMove()==false then
        local strDuiyuanmomovezi = require("utils.mhsdutils").get_msgtipstring(141206)
		GetCTipsManager():AddMessageTip(strDuiyuanmomovezi)
		return
	end
	local nGroupTaskType = TaskHelper.GetTaskTypeGroup(nTaskTypeId)
	--//剧情
	if nGroupTaskType==TaskHelper.eTaskTypeGroup.eScenario  then
		 Taskhelperscenario.OnClickCellGoto_Scenario(nTaskTypeId)
	--//循环
	elseif nGroupTaskType==TaskHelper.eTaskTypeGroup.eRepeatTask then
		local pQuest = GetTaskManager():GetSpecialQuest(nTaskTypeId)
		if not pQuest then
			return false
		end
		local nTaskDetailId = pQuest.questtype
		local nTaskDetailType = TaskHelper.GetSpecialQuestType2(nTaskDetailId)
		
		if nTaskDetailType==fire.pb.circletask.CircTaskClass.CircTask_Mail then --送信
			TaskHelper.GoToSchoolTaskSendMail(nTaskTypeId)
				
		elseif nTaskDetailType==fire.pb.circletask.CircTaskClass.CircTask_ItemUse then--使用物品
			require("logic.task.taskhelpergoto").GoToSchoolTaskPosUseItem(nTaskTypeId)
				
		elseif nTaskDetailType==fire.pb.circletask.CircTaskClass.CircTask_ItemCollect then --打怪寻物
			TaskHelper.GoToSchoolTaskBattleToGetItem(nTaskTypeId)
				
		elseif nTaskDetailType==fire.pb.circletask.CircTaskClass.CircTask_Patrol then --巡逻
			TaskHelper.GoToSchoolTaskBattleToPatrol(nTaskTypeId)
			
		elseif nTaskDetailType== fire.pb.circletask.CircTaskClass.CircTask_ItemFind then --购买物品
			TaskHelper.GoToSchoolTaskBuyItem(nTaskTypeId)
				
		elseif nTaskDetailType== fire.pb.circletask.CircTaskClass.CircTask_PetCatch then --购买宠物
			TaskHelper.GoToSchoolTaskBuyPet(nTaskTypeId)
		
		elseif fire.pb.circletask.CircTaskClass.CircTask_CatchIt == nTaskDetailType   then
			require("logic.task.taskhelpergoto").OnClickCellGoto_eCatchIt(nTaskTypeId)
			
		elseif fire.pb.circletask.CircTaskClass.CircTask_KillMonster  == nTaskDetailType then
			require("logic.task.taskhelpergoto").OnClickCellGoto_killMonster(nTaskTypeId)
			
		elseif fire.pb.circletask.CircTaskClass.CircTask_ChallengeNpc == nTaskDetailType  then
			require("logic.task.taskhelpergoto").OnClickCellGoto_CircTask_ChallengeNpc(nTaskTypeId)
			
		else
			require("logic.task.taskhelpergoto").OnClickCellGoto_CircTask_normal(nTaskTypeId)
		end
	elseif nGroupTaskType==TaskHelper.eTaskTypeGroup.eActiveTask then --men pai chuang guan
        require("logic.task.taskhelpergoto").OnClickGoToChanllengeActiveNPC(nTaskTypeId)
	end
	
	return true
end

function TaskHelper.OnClickCellGoto_killMonster(nTaskTypeId)
	
end



function TaskHelper.GoToSchoolTaskSendMail(nQuestTypeId)
	local pQuest = GetTaskManager():GetSpecialQuest(nQuestTypeId)
	if pQuest then
		local nTaskDetailId = pQuest.questtype
		local repeatCfg = BeanConfigManager.getInstance():GetTableByName("circletask.crepeattask"):getRecorder(nTaskDetailId)
		local nNpcId = pQuest.dstnpcid
				
		local flyWalkData = {}
		Taskhelpergoto.GetInitedFlyWalkData(flyWalkData)
		--//-======================================
		flyWalkData.nNpcId = nNpcId
		local nRandX =0
		local nRandY = 0
		if repeatCfg.nflytype==1 then 
			
		elseif repeatCfg.nflytype==2 then 
			nRandX = pQuest.dstx
			nRandY = pQuest.dsty
		end
		flyWalkData.nRandX = nRandX
		flyWalkData.nRandY = nRandY
		--//-======================================
		Taskhelpergoto.FlyOrWalkTo(flyWalkData)
		
	end
end


function TaskHelper.GetRandPosWithMapId(nMapId)
	local mapRecord=BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(nMapId)
	if mapRecord then
            local randX=mapRecord.bottomx-mapRecord.topx
            randX = mapRecord.topx+math.random(randX)-1 
            local randY=mapRecord.bottomy-mapRecord.topy
            randY=mapRecord.topy+math.random(randY)-1
			return randX,randY
	end
	
	local mapCfg = BeanConfigManager.getInstance():GetTableByName("map.cmapconfig"):getRecorder(nMapId)
	if mapCfg then
		local nPosX = mapCfg.xjPos
		local nPosY =  mapCfg.yjPos
		return nPosX,nPosY
	end
	return 0,0
	
end


function TaskHelper.GoToSchoolTaskBuyPet(nQuestTypeId)
	require "logic.task.taskhelperschool".GoToSchoolTask(nQuestTypeId)
end


function TaskHelper.GoToSchoolTaskBuyItem(nQuestTypeId)
	require "logic.task.taskhelperschool".GoToSchoolTask(nQuestTypeId)
end


function TaskHelper.GoToSchoolTaskBattleToPatrol(nTaskTypeId)
	TaskHelper.gotoRepeatTaskAutoBattle(nTaskTypeId)
end

function TaskHelper.gotoRepeatTaskAutoBattle(nQuestTypeId)
	local pQuest = GetTaskManager():GetSpecialQuest(nQuestTypeId)
	if pQuest then
		local nMapId = pQuest.dstmapid
		
		local nRandX = 0
		local nRandY = 0
		local nTaskDetailId = pQuest.questtype
		local repeatCfg = BeanConfigManager.getInstance():GetTableByName("circletask.crepeattask"):getRecorder(nTaskDetailId)
		if repeatCfg.nflytype==1 then --初始点
			nRandX,nRandY = TaskHelper.GetRandPosWithMapId(nMapId)
		elseif repeatCfg.nflytype==2 then --地图随机点 
			nRandX = pQuest.dstx
			nRandY = pQuest.dsty
		end
			
		--//=======================================
		local nCurMapId = gGetScene():GetMapID()
		--//=======================================
		local nTargetPosX = nRandX
		local nTargetPosY = nRandY
		--//=======================================
		
		local flyWalkData = {}
		Taskhelpergoto.GetInitedFlyWalkData(flyWalkData)
		--//-======================================
		flyWalkData.nMapId = nMapId
		--flyWalkData.nNpcId = nNpcId
		flyWalkData.nRandX = nRandX
		flyWalkData.nRandY = nRandY
		flyWalkData.bXunLuo = 1
		flyWalkData.nTargetPosX = nTargetPosX
		flyWalkData.nTargetPosY = nTargetPosY
		--//-======================================
		Taskhelpergoto.FlyOrWalkTo(flyWalkData)
	end
end

--//职业打怪寻物
function TaskHelper.GoToSchoolTaskBattleToGetItem(nTaskTypeId)
	TaskHelper.gotoRepeatTaskAutoBattle(nTaskTypeId)
end


--使用物品检测区域 use for repeat task
function TaskHelper.IsMainRoleInTaskArea(nTaskTypeId)
	
	local pQuest = GetTaskManager():GetSpecialQuest(nTaskTypeId)
	if not pQuest then
		return false
	end
	local nTaskDetailId = pQuest.questtype
	local nItemId = pQuest.dstitemid
	LogInfo("TaskHelper.IsMainRoleInTaskArea(nTaskTypeId)=nItemId"..nItemId)
	
	local repeatCfg = BeanConfigManager.getInstance():GetTableByName("circletask.crepeattask"):getRecorder(nTaskDetailId)
	if repeatCfg.id==-1 then
		return
	end
	local nCurMapId = gGetScene():GetMapID()
	
	local nXPos =  pQuest.dstx 
	local nYPos =  pQuest.dsty 
	local nMapId = pQuest.dstmapid 
    local nDis = GetMainCharacter():GetDistanceWithPos(nXPos,nYPos)
	
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local nItemNum = roleItemManager:GetItemNumByBaseID(nItemId,fire.pb.item.BagTypes.QUEST)
	if nItemNum==0 then
		LogInfo("error=TaskHelper.IsMainRoleInTaskArea(nTaskTypeId)=nItemNum=0")
		return false
	end
	
	if nDis <= 5 then --nMapId==nCurMapId
		return true
	end
	return false
end



function TaskHelper.isInTaskArea(nItemId)
    local nJuqingTaskId = -1
    local bInArea = true
    local scenarioquests = GetTaskManager():GetScenarioQuestListForLua()
	local scenarioquestnum = scenarioquests:size()
	for i = 0, scenarioquestnum - 1 do
		local scenarioquest = scenarioquests[i]
		local questTable = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(scenarioquest.missionid)
		if questTable then
			if questTable.ActiveInfoUseItemID == nItemId then
                nJuqingTaskId = questTable.id
                break
            end
		end	
	end
    if nJuqingTaskId ~= -1 then
        bInArea = Taskhelperscenario.IsMainRoleInTaskArea(nJuqingTaskId)
    end
    return bInArea
end


function TaskHelper.HandleVisitPos_eSchool(nTaskTypeId)
	local pQuest = GetTaskManager():GetSpecialQuest(nTaskTypeId)
	if pQuest then
		local nTaskDetailId = pQuest.questtype
		local nTaskDetailType = TaskHelper.GetSpecialQuestType2(nTaskDetailId)
		if nTaskDetailType== fire.pb.circletask.CircTaskClass.CircTask_ItemUse then 
		
			local bInArea = TaskHelper.IsMainRoleInTaskArea(nTaskTypeId)
			if bInArea==false then
				return
			end
			local useItemDlg = require "logic.task.taskuseitemdialog".getInstance()
			local nItemId =pQuest.dstitemid
			
		    useItemDlg:SetUseItemId(nItemId)
			GetMainCharacter():SetGotoTargetPosType(0)
			GetMainCharacter():SetGotoTargetPos(0,0)
		end
	end
end


--//角色停止移动后回调
function TaskHelper.HandleVisitPos(nTaskTypeId)
	local nGroupTaskType = TaskHelper.GetTaskTypeGroup(nTaskTypeId)
	if nGroupTaskType==TaskHelper.eTaskTypeGroup.eScenario  then
		Taskhelperscenario.HandleVisitPos_scenaro(nTaskTypeId)
	elseif nGroupTaskType==TaskHelper.eTaskTypeGroup.eRepeatTask then
		TaskHelper.HandleVisitPos_eSchool(nTaskTypeId)
	end
end

--//职业上交物品
function TaskHelper.ssubmit2npc_process(protocol)

	require("logic.task.taskhelperprotocol").ssubmit2npc_process(protocol)
end

--[[
TaskHelper.eTaskTypeGroup=
{
	eScenario =1, --//剧情任务
	eRepeatTask=2, --//循环任务
	eFubenTask=3,--副本任务类型
}

--]]

--//取所有相同物品的key
function TaskHelper.GetItemKeyWithTableId(nItemId,vItemKey)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local vItemKeyAll = roleItemManager:GetItemKeyListByBag(fire.pb.item.BagTypes.BAG)
	for i = 0, vItemKeyAll:size() - 1 do
		local nItemKey = vItemKeyAll[i]
		local pRoleItem = roleItemManager:FindItemByBagAndThisID(nItemKey, fire.pb.item.BagTypes.BAG)
		if pRoleItem then
			local nTableId = pRoleItem:GetObjectID()
			if nTableId == nItemId then
				vItemKey[#vItemKey + 1] = nItemKey
			end
		end
	end
end

--取拥有的所有宠物key
function TaskHelper.GetHavePetWithId(nPetId,vPetKey)
	local nPetNum = MainPetDataManager.getInstance():GetPetNum()
	for nIndex = 1,nPetNum do
		local pPet = MainPetDataManager.getInstance():getPet(nIndex)
		if nPetId==pPet.baseid then
			local nPetKey = pPet.key
			vPetKey[#vPetKey +1] = nPetKey
		end
	end
end

function TaskHelper.GetPos(nIndex,nRowCount,nOriginX,nOriginY,nItemCellW,nItemCellH,nSpaceX,nSpaceY)
	local nIndexX = nIndex % nRowCount
	local nIndexY = math.floor(nIndex/nRowCount)
	local nPosX = nOriginX + (nItemCellW + nSpaceX) * nIndexX
	local nPosY = nOriginY + (nItemCellH + nSpaceY) * nIndexY
	return nPosX,nPosY
end


function TaskHelper.SetChildNoCutTouch(pane)
	local nChildcount = pane:getChildCount()
	for i = 0, nChildcount - 1 do
		local child = pane:getChildAtIdx(i)
		child:setMousePassThroughEnabled(true)
	end
end



--use for task dialog ui
function TaskHelper.GetTaskShowTypeWithId(nTaskTypeId)
	--剧情6位 100101，2 3，431203 
	--循环任务1010000 --7位
    if nTaskTypeId == TaskHelper.nActiveMenpai_acceptTask or nTaskTypeId == TaskHelper.nActiveMenpai_Task then
        return TaskHelper.nRiChangId
    end

	local nResult = math.floor( nTaskTypeId /1000000) --7位
	if nResult == 1 then --循环任务
		return TaskHelper.nRiChangId --//日常任务 常规任务
    elseif nResult == 2 then  
        return  TaskHelper.nAnyeFollow --anye type
	end
	--//============================
    if nTaskTypeId >= 100000  and nTaskTypeId < 199999 then --100000
        return  TaskHelper.nMainTaskId --//主线任务 
    elseif nTaskTypeId >= 510000  and nTaskTypeId < 519999 then
        return TaskHelper.nLeaveTaskId --	突破任务
    elseif nTaskTypeId > 600000  and nTaskTypeId < 600999 then
        return TaskHelper.nJuBaoId --支线 菊爆大队任务
    elseif nTaskTypeId >= 200000  and nTaskTypeId < 999999 then --200000
        return TaskHelper.nFenZhiId --//支线任务
    else
        
    end
    
	return -1
end

--//renwu geng xin shi call
function TaskHelper.RefreshLastTask(nTaskTypeId)
	LogInfo("TaskHelper.RefreshLastTask="..nTaskTypeId)
	
	local nGroupTaskType = TaskHelper.GetTaskTypeGroup(nTaskTypeId)
	if nGroupTaskType==TaskHelper.eTaskTypeGroup.eScenario  then
		Taskhelperscenario.RefreshLastTask(nTaskTypeId)
	elseif nGroupTaskType==TaskHelper.eTaskTypeGroup.eRepeatTask then
	
	end
 
end

function TaskHelper.gotoSchoolMonster()
	local nNpcId =  TaskHelper.GetSchoolMonsterId()
	
	local flyWalkData = {}
	Taskhelpergoto.GetInitedFlyWalkData(flyWalkData)
	--//-======================================
	flyWalkData.nNpcId = nNpcId
	--//-======================================
	Taskhelpergoto.FlyOrWalkTo(flyWalkData)
end

function TaskHelper.gotoNpc(nNpcId)
	local flyWalkData = {}

    --如果在战斗中发出提示
    if  GetBattleManager():IsInBattle()== true  then
        GetChatManager():AddTipsMsg(131451)
    end
	Taskhelpergoto.GetInitedFlyWalkData(flyWalkData)
	--//-======================================
	flyWalkData.nNpcId = nNpcId
	--//-======================================
	Taskhelpergoto.FlyOrWalkTo(flyWalkData)

end
	
function TaskHelper.ClickAcceptTask(nTaskTypeId)
	require ("logic.task.taskhelpergoto").GotoTaskNpc(nTaskTypeId)
end


function TaskHelper.AddScenarioQuest(nTaskTypeId)
	require("logic.task.taskhelpernpc").checkShowScenarTaskNpc(nTaskTypeId)
end

function TaskHelper.RemoveScenarioQuest(nTaskTypeId)
	require("logic.task.taskhelpernpc").checkHideScenarTaskNpc(nTaskTypeId)
end

function TaskHelper.isInGonghui()
    local datamanager = require "logic.faction.factiondatamanager"
    local bIn = datamanager:IsHasFaction()
    return bIn
end

function TaskHelper.isRichangfubenTargetNpc(nNpcId)
    local nTaskTypeId =  TaskHelper.eRepeatTaskId.richangfuben  --=1030000,
    local pQuest = GetTaskManager():GetSpecialQuest(nTaskTypeId)
	if not pQuest then
		return false
	end
	local nTaskNpcId = pQuest.dstnpcid
    if nTaskNpcId == nNpcId then
        return true
    end
    return false
end


return TaskHelper
