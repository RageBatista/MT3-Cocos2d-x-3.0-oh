
require "utils.mhsdutils"

Taskhelperchat = {}

Taskhelperchat.EChatType =
{	
	receive = 1,
	npc = 2,
	commit = 3,
}


function Taskhelperchat.GetChatStringWithTableId(nTaskDetailId,nChatType)
	local repeatCfg =  BeanConfigManager.getInstance():GetTableByName("circletask.crepeattask"):getRecorder(nTaskDetailId)
	if repeatCfg then
		local nChatId  = -1
		if nChatType==Taskhelperchat.EChatType.receive then
			nChatId = repeatCfg.nacceptchatid
		elseif  nChatType==Taskhelperchat.EChatType.npc then
			nChatId = repeatCfg.nnpcchatid
		elseif  nChatType==Taskhelperchat.EChatType.commit then
			nChatId = repeatCfg.ncommitchatid
		end
		local chatCfg = BeanConfigManager.getInstance():GetTableByName("circletask.crepeattaskchat"):getRecorder(nChatId)
		if chatCfg and chatCfg.id ~= -1 then
			local strChat = chatCfg.strmsg;
			return strChat
		end
	end
	return ""
end

--职业接任务完成任务对话
function Taskhelperchat.GetChatString_receive(nTaskDetailId,nChatType,nTargetNpcId,nMapId,nItemId)
	local strChat= ""
	local strNpcName = ""
	local strTargetNpcName = ""
	local strMapName = ""
	local strItemName = ""
	local strPetName = ""
	strChat = Taskhelperchat.GetChatStringWithTableId(nTaskDetailId,nChatType)
	LogInfo("Taskhelperchat.GetChatString=strChat="..strChat)
	--//=====================================
	--target npc name
	--local nTargetNpcId = pQuest.dstnpcid
	local npcCfg = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(nTargetNpcId)
	if npcCfg then
		strTargetNpcName = npcCfg.name
	end
	--//=====================================
	--local nMapId = pQuest.dstmapid
	local mapCfg = BeanConfigManager.getInstance():GetTableByName("map.cmapconfig"):getRecorder(nMapId)
	if mapCfg then
		strMapName = mapCfg.mapName
	end
	--//=====================================
	--local nItemId = pQuest.dstitemid
	local itemattr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	--local strItemName = ""
	if itemattr then
		strItemName = itemattr.name
	end
	--//=====================================
	local nPetId = nItemId
	local petAttrCfg = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(nPetId)
	if  petAttrCfg then
		strPetName = petAttrCfg.name
	end
	--//=====================================
	local sb = StringBuilder.new()
	sb:Set("NPCName", strTargetNpcName);
	sb:Set("MapName", strMapName)
	sb:Set("ItemName", strItemName)
	sb:Set("PetName",strPetName )
	--[[
	local eTaskDetailType = TaskHelper.GetSpecialQuestType2(nTaskDetailId)
	if eTaskDetailType==fire.pb.circletask.CircTaskClass.CircTask_Mail then
		sb:Set("NPCName", strTargetNpcName);
	elseif eTaskDetailType==fire.pb.circletask.CircTaskClass.CircTask_ItemUse then
		sb:Set("MapName", strMapName)
	elseif eTaskDetailType==fire.pb.circletask.CircTaskClass.CircTask_ItemCollect then
		sb:Set("ItemName", strItemName)
		sb:Set("MapName", strMapName)
	elseif eTaskDetailType==fire.pb.circletask.CircTaskClass.CircTask_ItemFind then
		sb:Set("ItemName", strItemName)
	elseif eTaskDetailType==fire.pb.circletask.CircTaskClass.CircTask_PetCatch then
		sb:Set("MapName", strMapName)
		sb:Set("PetName",strPetName ) --//
	elseif eTaskDetailType==fire.pb.circletask.CircTaskClass.CircTask_Patrol then
		sb:Set("MapName", strMapName)
	end
	--]]
	local strShow = sb:GetString(strChat)
	sb:delete()
	return strShow
end



function Taskhelperchat.ReceivedSpecialTaskResult_CircTask_School(pQuest)
end


function Taskhelperchat.ReceivedSpecialTaskResult_CircTask_Catch(pQuest)
end

function Taskhelperchat.ReceivedSpecialTaskResult_inAccept(pQuest)

end

function Taskhelperchat.GetSayNpcIdInReceive(nTaskDetailId)
	local repeatTable = BeanConfigManager.getInstance():GetTableByName("circletask.crepeattask"):getRecorder(nTaskDetailId)
	if not repeatTable then
        return -1
    end
	local nNpcId = repeatTable.nacceptnpcid
	if nNpcId == 1 then --1=school monster
		nNpcId = require("logic.task.taskhelper").GetSchoolMonsterId()
	end
	return nNpcId
end

function Taskhelperchat.IsHaveChatId(nTaskDetailId,nChatType)
	local repeatCfg = BeanConfigManager.getInstance():GetTableByName("circletask.crepeattask"):getRecorder(nTaskDetailId)
	
	local nChatId  = -1
		if nChatType==Taskhelperchat.EChatType.receive then
			nChatId = repeatCfg.nacceptchatid
		elseif  nChatType==Taskhelperchat.EChatType.npc then
			nChatId = repeatCfg.nnpcchatid
		elseif  nChatType==Taskhelperchat.EChatType.commit then
			nChatId = repeatCfg.ncommitchatid
		end
		local chatCfg = BeanConfigManager.getInstance():GetTableByName("circletask.crepeattaskchat"):getRecorder(nChatId)
		if chatCfg and chatCfg.id ~= -1 then
			return true
		end
		return false
end

function Taskhelperchat.ShowReceiveRepeatTaskSay(pQuest,nSayNpcId)
	if not pQuest then
		return
	end
	--//重新登陆后不显示对话 2=npc accept
	if pQuest.islogin ~= 2 then
		LogInfo("pQuest.islogin ~= 2  no show chat")
		return 
	end
	local nTaskTypeId = pQuest.questid
	if pQuest.round ~= 1 then
		return
	end
	local nTaskDetailId = pQuest.questtype
	local nTargetNpcId = pQuest.dstnpcid
	local nMapId = pQuest.dstmapid
	local nItemId = pQuest.dstitemid
	local nChatType = Taskhelperchat.EChatType.receive
	
	local bHaveChatId = Taskhelperchat.IsHaveChatId(nTaskDetailId,nChatType)
	if not bHaveChatId then
		return
	end
	
	local strChat = Taskhelperchat.GetChatString_receive(nTaskDetailId,nChatType,nTargetNpcId,nMapId,nItemId)
	local Tasknpcchatdialog = require "logic.task.tasknpcchatdialog".getInstance()
	LogInfo(" Taskhelperchat.nSayNpcId="..nSayNpcId)
	Tasknpcchatdialog:ShowNpcChat(nSayNpcId,strChat)

end


function Taskhelperchat.ReceivedSpecialTaskResult_chat(pQuest)
	local nTaskDetailId = pQuest.questtype
	local nTaskDetailType = TaskHelper.GetSpecialQuestType2(nTaskDetailId)
	
	local nSayNpcId = Taskhelperchat.GetSayNpcIdInReceive(nTaskDetailId)
	
	local npcCfg = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(nSayNpcId)
	if not npcCfg then
		return 
	end
	Taskhelperchat.ShowReceiveRepeatTaskSay(pQuest,nSayNpcId)
	
end

--[[
<variable name="nautodo" type="int" fromCol="是否自动寻路" />
			<variable name="nautonextlun" type="int" fromCol="自动领取下一轮" />
			<variable name="nlunendmsgid" type="int" fromCol="不自动领取确定提示" />
			
--]]


function Taskhelperchat.IsAutoDoRepeatTask(nTaskTypeId)
	local vcId = BeanConfigManager.getInstance():GetTableByName("circletask.cschooltask"):getAllID()
    local level = GetMainCharacter():GetLevel()
    for i = 1, #vcId do
		local nTaskTypeIdInTable = vcId[i]
		local record = BeanConfigManager.getInstance():GetTableByName("circletask.cschooltask"):getRecorder(nTaskTypeIdInTable)
        if nTaskTypeId==record.type  then
			return record.nautodo
        end
    end
	return 0
end

function Taskhelperchat.GetRepeatTaskTable(nTaskTypeId)
	local vcId = BeanConfigManager.getInstance():GetTableByName("circletask.cschooltask"):getAllID()
    local level = GetMainCharacter():GetLevel()
    for i = 1, #vcId do
		local nTaskTypeIdInTable = vcId[i]
		local record = BeanConfigManager.getInstance():GetTableByName("circletask.cschooltask"):getRecorder(nTaskTypeIdInTable)
        if nTaskTypeId==record.type  then
			return record
        end
    end
	return nil
end

function Taskhelperchat.ReceivedSpecialTaskResult_autoDo(pQuest)
	LogInfo("Taskhelperchat.ReceivedSpecialTaskResult_autoDo(pQuest)")
	if pQuest.islogin ==1 then
		return 
	end
	local nTaskTypeId = pQuest.questid
	LogInfo("nTaskTypeId"..nTaskTypeId)
	
	local nRound = pQuest.round
	local nTaskDetailId = pQuest.questtype
	local nTaskDetailType = require "logic.task.taskhelper".GetSpecialQuestType2(nTaskDetailId)
	
	--//=================================
	local nAutoDo =  Taskhelperchat.IsAutoDoRepeatTask(nTaskTypeId)
	if nAutoDo ~= 1 then
		return 
	end
	--//=================================
	if GetTeamManager() and GetTeamManager():CanIMove()==false then
		return
	end
	
    if nTaskTypeId==TaskHelper.eRepeatTaskId.richangfuben and nRound == 1 then
        return
    end
		
	--//================================
	--Tasktimermanager.eTimerType.repeatCount =1,
	--repeatEver =2,
	local timerData = {}
    require("logic.task.tasktimermanager").getInstance():getTimerDataInit(timerData)
	--//=======================================
	timerData.nId = Tasktimermanager.eTimerId.delayRepeatTask
	timerData.eType = Tasktimermanager.eTimerType.repeatCount
	timerData.nDurTime = 1
	timerData.nDurTimeDt =0
	timerData.repeatCount = 1
	timerData.repeatCountDt =0
	timerData.functionName = Taskhelperchat.timerCallBack
	timerData.nParam1 = nTaskTypeId
	--//=======================================
	require("logic.task.tasktimermanager").getInstance():addTimer(timerData)
	
end

function Taskhelperchat.timerCallBack(nTaskTypeId)
	LogInfo("Taskhelperchat.timerCallBack(nTaskTypeId)="..nTaskTypeId)
	require "logic.task.taskhelper".OnClickCellGoto(nTaskTypeId)
end

function Taskhelperchat.DelayToDoRepeatTaskskhelper(nTaskTypeId)
	LogInfo("Tachat.DelayToDoRepeatTaskskhelper(nTaskTypeId)"..nTaskTypeId)
	--require "logic.task.taskhelper".OnClickCellGoto(nTaskTypeId)
end

function Taskhelperchat.ReceivedSpecialTaskResult_refreshUI(pQuest)
	LogInfo("Taskhelperchat.ReceivedSpecialTaskResult_refreshUI(pQuest)")
	local nTaskTypeId = pQuest.questid
	local nTaskDetailId = pQuest.questtype
	local nPingTaskId = require "logic.task.taskhelper".nPingTaskDetailId 
	if nTaskDetailId==nPingTaskId then
		require("logic.task.taskmanager").getInstance():setPingRedVisible(false)
        require("logic.huodong.huodongmanager").getInstance().m_HeroTrial = 0
	end
	
	
end


--//收到任务后对话 nSayNpcId unuse
function Taskhelperchat.ReceivedSpecialTaskResult(nNewTaskIdType,nSayNpcId)
	LogInfo("Taskhelperchat.ReceivedSpecialTaskResult()"..nNewTaskIdType)
	
	local TaskHelper = require "logic.task.taskhelper"
	local pQuest = GetTaskManager():GetSpecialQuest(nNewTaskIdType)
	if pQuest==nil then
		return
	end
	Taskhelperchat.ReceivedSpecialTaskResult_chat(pQuest)
	Taskhelperchat.ReceivedSpecialTaskResult_autoDo(pQuest)
	Taskhelperchat.ReceivedSpecialTaskResult_refreshUI(pQuest)
	Taskhelperchat.ReceivedRepeatTaskResult_eventDoublePoint(pQuest)
	
end


function Taskhelperchat.ReceivedRepeatTaskResult_eventDoublePoint(pQuest)
	
	LogInfo("Taskhelperchat.ReceivedRepeatTaskResult_eventDoublePoint(pQuest)")
	local nTaskTypeId = pQuest.questid
	local nTaskDetailId = pQuest.questtype

    require "protodef.rpcgen.fire.pb.circletask.specialqueststate"
    local spcQuestState = SpecialQuestState:new()
    if pQuest.queststate == spcQuestState.ABANDONED then
        return
    end


	local nNeedDoublePoint = require("logic.task.taskhelpertable").getNeedDoublePoint(nTaskTypeId)
	
	if nNeedDoublePoint <= 0 then
		return
	end
	
	local list = require("logic.mapchose.hookmanger").getInstance():GetHookData()
	if list == nil or #list == 0 then
		return
	end
	--self.m_nCanDoublePtr = list[1]
	--self.m_nGotDoublePtr = list[2]
    local nCanGetDouble = 0

    if #list >= 1 then
        nCanGetDouble = list[1]
    end

    if nCanGetDouble <= 0 then
        return
    end
	
	local nUserDoublePoint = 0
    if #list >= 2 then
        nUserDoublePoint = list[2]
    end
     
	if nUserDoublePoint >= nNeedDoublePoint then
		return
	end
	local bHave = require("logic.task.taskmanager").getInstance():isRepeatTaskHaveShowGetDoublePoint(nTaskTypeId)
	
	if bHave then
		return 
	end

	Taskhelperchat.showGetDoublePoint(nTaskTypeId)
	
end


function Taskhelperchat.showGetDoublePoint(nTaskTypeId)
	LogInfo("Taskhelperchat.showGetDoublePoint()")
	local nTipMsgId = 160059 
	local strMsg =  MHSD_UTILS.get_msgtipstring(nTipMsgId)  --MHSD_UTILS.get_resstring(nTipMsgId)
	local msgManager = gGetMessageManager()

    Taskhelperchat.nTaskTypeId_doublePoint = nTaskTypeId
		
	gGetMessageManager():AddConfirmBox(eConfirmNormal,
		strMsg,
		Taskhelperchat.clickConfirmBoxOk,
	  	Taskhelperchat,
	  	Taskhelperchat.clickConfirmBoxCancel,
	  	Taskhelperchat)
end


function Taskhelperchat.clickConfirmBoxOk()
	local msgManager = gGetMessageManager()
	local nTaskTypeId = Taskhelperchat.nTaskTypeId_doublePoint
		
	gGetMessageManager():CloseCurrentShowMessageBox()
	gGetMessageManager():CloseConfirmBox(eConfirmNormal,false)
	
	--CAdviceDbPoint
	--[[
	local p = require "protodef.fire.pb.circletask.cadvicedbpoint":new()
	p.result = 1
	require "manager.luaprotocolmanager":send(p)
	--]]
	
	local p = require "protodef.fire.pb.hook.cgetdpoint":new()
	require "manager.luaprotocolmanager":send(p)
end

function Taskhelperchat.clickConfirmBoxCancel()
	
	local msgManager = gGetMessageManager()
	local nTaskTypeId = Taskhelperchat.nTaskTypeId_doublePoint
	
	gGetMessageManager():CloseCurrentShowMessageBox()
	gGetMessageManager():CloseConfirmBox(eConfirmNormal,false)
	
	local taskManager = require("logic.task.taskmanager").getInstance()
	
	table.insert(taskManager.vHaveShowGetBoublePoint,nTaskTypeId)
	

	--for k,nTaskId in pairs(self.vHaveShowGetBoublePoint) do 
		
	--end
	--[[
	local p = require "protodef.fire.pb.circletask.cadvicedbpoint":new()
	p.result = 0
	require "manager.luaprotocolmanager":send(p)
	--]]
end

--//================================================
--//================================================
--//================================================
--//================================================
--//================================================
function Taskhelperchat.DoneSpecialTaskResult_CircTask_Mail(pQuest,nOldNpcId)
	local nTaskDetailId = pQuest.questtype
	local nChatType = Taskhelperchat.EChatType.npc
	local strChat = Taskhelperchat.GetChatStringWithTableId(nTaskDetailId,nChatType)
	local Tasknpcchatdialog = require "logic.task.tasknpcchatdialog".getInstance()
	Tasknpcchatdialog:ShowNpcChat(nOldNpcId,strChat)
end

function Taskhelperchat.DoneSpecialTaskResult_CircTask_ItemCollect(pQuest,nOldNpcId)
	GetMainCharacter():StopPacingMove()
end

function Taskhelperchat.DoneSpecialTaskResult_CircTask_Patrol(pQuest,nOldNpcId)
	GetMainCharacter():StopPacingMove()
	GetMainCharacter():RemoveAutoWalkingEffect()
end

function Taskhelperchat.DoneSpecialTaskResult_CircTask_KillMonster(pQuest,nOldNpcId)
    if pQuest.questid == 1050000 then return end  --英雄试炼任务后不会停止巡逻
	GetMainCharacter():StopPacingMove()
end

function Taskhelperchat.DoneSpecialTaskResult_CircTask_ItemFind(pQuest,nOldNpcId)
	GetMainCharacter():StopPacingMove()
end

--//完成循环任务后
function Taskhelperchat.DoneSpecialTaskResult(nTaskTypeId,nOldNpcId)
	local TaskHelper = require "logic.task.taskhelper"
	local pQuest = GetTaskManager():GetSpecialQuest(nTaskTypeId)
	if pQuest==nil then
		return
	end
	local nTaskDetailId = pQuest.questtype
	local eTaskDetailType = TaskHelper.GetSpecialQuestType2(nTaskDetailId)
	if eTaskDetailType==fire.pb.circletask.CircTaskClass.CircTask_Mail then
		Taskhelperchat.DoneSpecialTaskResult_CircTask_Mail(pQuest,nOldNpcId)
	elseif eTaskDetailType==fire.pb.circletask.CircTaskClass.CircTask_ItemCollect then
		Taskhelperchat.DoneSpecialTaskResult_CircTask_ItemCollect(pQuest,nOldNpcId)
	elseif eTaskDetailType==fire.pb.circletask.CircTaskClass.CircTask_Patrol then
		Taskhelperchat.DoneSpecialTaskResult_CircTask_Patrol(pQuest,nOldNpcId)
	elseif eTaskDetailType==fire.pb.circletask.CircTaskClass.CircTask_CatchIt then
	elseif eTaskDetailType==fire.pb.circletask.CircTaskClass.CircTask_KillMonster  then
		Taskhelperchat.DoneSpecialTaskResult_CircTask_KillMonster(pQuest,nOldNpcId)
    elseif eTaskDetailType==fire.pb.circletask.CircTaskClass.CircTask_ItemFind then
        Taskhelperchat.DoneSpecialTaskResult_CircTask_ItemFind(pQuest,nOldNpcId)
	end

    Taskhelperchat.DoneSpecialTaskResult_refreshUI(pQuest)

end

 function Taskhelperchat.DoneSpecialTaskResult_refreshUI(pQuest)
    local TaskHelper = require "logic.task.taskhelper"
	--local pQuest = GetTaskManager():GetSpecialQuest(nTaskTypeId)
	if pQuest==nil then
		return
	end
	local nTaskDetailId = pQuest.questtype
	local eTaskDetailType = TaskHelper.GetSpecialQuestType2(nTaskDetailId)
	if eTaskDetailType==fire.pb.circletask.CircTaskClass.CircTask_ItemFind then
        require("logic.task.taskmanager").getInstance():repeatTaskDoneCall()
        
    elseif eTaskDetailType==fire.pb.circletask.CircTaskClass.CircTask_PetCatch then
	    require("logic.task.taskmanager").getInstance():repeatTaskDoneCall()

	end

 end


--//================================================
--//================================================
--//================================================


function Taskhelperchat.CommitSpecialTaskResult_CircTask_ItemFind(pQuest,nSayNpcId)
	local nTaskDetailId = pQuest.questtype
	local nChatType = Taskhelperchat.EChatType.commit
	local strChat = Taskhelperchat.GetChatStringWithTableId(nTaskDetailId,nChatType)
	local Tasknpcchatdialog = require "logic.task.tasknpcchatdialog".getInstance()
	Tasknpcchatdialog:ShowNpcChat(nSayNpcId,strChat)
end

function Taskhelperchat.CommitSpecialTaskResult_CircTask_PetCatch(pQuest,nSayNpcId)
	local nTaskDetailId = pQuest.questtype
	local nChatType = Taskhelperchat.EChatType.commit
	local strChat = Taskhelperchat.GetChatStringWithTableId(nTaskDetailId,nChatType)
	local Tasknpcchatdialog = require "logic.task.tasknpcchatdialog".getInstance()
	Tasknpcchatdialog:ShowNpcChat(nSayNpcId,strChat)
end




function Taskhelperchat.CheckForContinueDone_CircTask_Catch(nTaskTypeId)
	LogInfo("Taskhelperchat.CheckForContinueDone_CircTask_Catch(nTaskTypeId)"..nTaskTypeId)
	local repeatTypeTable = Taskhelperchat.GetRepeatTaskTable(nTaskTypeId)
	
	if repeatTypeTable==nil then
		return
	end
	local nTipMsgId = repeatTypeTable.nlunendmsgid
	
	local bLeader = GetMainCharacter():IsTeamLeader()
	if not bLeader then
		return
	end
	
	LogInfo("Taskhelperchat.CheckForContinueDone_CircTask_Catch(nTaskTypeId)")
	local pQuest = GetTaskManager():GetSpecialQuest(nTaskTypeId)
	if pQuest==nil then
		return
	end

	local nTaskDetailId = pQuest.questtype
	local nMaxNum  = require "logic.task.taskhelper".GetRepeatTaskMaxCount(nTaskDetailId)
	local nRound = pQuest.round
	local nSumnum = pQuest.sumnum
	local nEndFlag = pQuest.dstitemnum
	if nRound>=nMaxNum and nEndFlag==1 then 
		local strMsg =  MHSD_UTILS.get_msgtipstring(nTipMsgId)  --MHSD_UTILS.get_resstring(nTipMsgId)
		local msgManager = gGetMessageManager()
		Taskhelperchat.nTaskDetailId_continue = nTaskDetailId
		
		gGetMessageManager():AddConfirmBox(eConfirmNormal,
		strMsg,
		Taskhelperchat.ClickConfirmContinueDone_CircTask_Catch,
	  	Taskhelperchat,
	  	MessageManager.HandleDefaultCancelEvent,
	  	MessageManager)
	end
end


function Taskhelperchat.ClickConfirmContinueDone_CircTask_Catch()
	
	LogInfo("Taskhelperchat.ClickConfirmContinueDone_CircTask_Catch()")
	local msgManager = gGetMessageManager()
	local nTaskDetailId = Taskhelperchat.nTaskDetailId_continue
	
	gGetMessageManager():CloseCurrentShowMessageBox()
	gGetMessageManager():CloseConfirmBox(eConfirmNormal,false)
	
	local repeatCfg =  BeanConfigManager.getInstance():GetTableByName("circletask.crepeattask"):getRecorder(nTaskDetailId)
	if repeatCfg == nil then
		return
	end
	local nTaskTypeId = repeatCfg.eactivetype
	
	require "logic.task.taskhelpergoto".gotoAcceptTask_eCatchIt(nTaskTypeId)
	-- Taskhelpergoto.gotoAcceptTask_eCatchIt(nTaskTypeId)
	
end

--[[
function Taskhelperchat.ClickCancelContinueDone_CircTask_Catch()
	gGetMessageManager():CloseCurrentShowMessageBox()
	gGetMessageManager():CloseConfirmBox(eConfirmNormal,false)
end
--]]
--//================================================
function Taskhelperchat.CommitSpecialTaskResult(nTaskTypeId,nOldNpcId)
	local TaskHelper = require "logic.task.taskhelper"
	local pQuest = GetTaskManager():GetSpecialQuest(nTaskTypeId)
	if pQuest==nil then
		return
	end
	
	local nTaskDetailId = pQuest.questtype
	local eTaskDetailType = TaskHelper.GetSpecialQuestType2(nTaskDetailId)
	
	--local nSayNpcId = TaskHelper.GetSchoolMonsterId()
    local nSayNpcId = Taskhelperchat.GetSayNpcIdInReceive(nTaskDetailId)

	LogInfo("nSayNpcId="..nSayNpcId)
		
	if eTaskDetailType==fire.pb.circletask.CircTaskClass.CircTask_ItemFind then
		Taskhelperchat.CommitSpecialTaskResult_CircTask_ItemFind(pQuest,nSayNpcId)
	elseif eTaskDetailType==fire.pb.circletask.CircTaskClass.CircTask_PetCatch then
		Taskhelperchat.CommitSpecialTaskResult_CircTask_PetCatch(pQuest,nSayNpcId)
	end
	
	Taskhelperchat.CommitSpecialTaskResult_checkShowTip(nTaskTypeId)
	Taskhelperchat.CommitSpecialTaskResult_checkShowTip_gaojiang(nTaskTypeId)
	
end

function Taskhelperchat.CommitSpecialTaskResult_checkShowTip_gaojiang(nTaskTypeId)
	LogInfo("Taskhelperchat.CommitSpecialTaskResult_checkShowTip_gaojiang(nTaskTypeId)="..nTaskTypeId)
	local pQuest = GetTaskManager():GetSpecialQuest(nTaskTypeId)
	if not pQuest then
		return
	end
	
	local nTaskDetailId = pQuest.questtype
	local nSum = pQuest.sumnum
	local eTaskDetailType = TaskHelper.GetSpecialQuestType2(nTaskDetailId)
	
	local repeatAllTable = require("logic.task.taskhelpertable").GetRepeatAllTaskTableFirst(nTaskTypeId)
	if not repeatAllTable then
		LogInfo("error=not repeatAllTable=nTaskTypeId="..nTaskTypeId)
		return 
	end
	
	if repeatAllTable.ngaojianground <=0 then
		LogInfo("repeatAllTable.ngaojianground <=0 ")
		return
	end
	local nGaoJiangCount = repeatAllTable.ngaojianground
	nGaoJiangCount = nGaoJiangCount - 1
	
	LogInfo("nSum="..nSum)
	LogInfo("repeatAllTable.ngaojianground="..repeatAllTable.ngaojianground)
		
	if nSum ~= nGaoJiangCount then
		LogInfo("nSum ~= repeatAllTable.ngaojianground ")
		return
	end
	local nTipMsgId = repeatAllTable.ngaojiangmsgid
    if nTipMsgId <= 0 then
        return
    end
	local strMsg = MHSD_UTILS.get_resstring(nTipMsgId)
		 
	local msgManager = gGetMessageManager()
	msgManager.nTaskDetailId = nTaskDetailId
		
	gGetMessageManager():AddConfirmBox(eConfirmNormal,
		strMsg,
		Taskhelperchat.ClickConfirmContinueDone_flyToNpc,
	  	Taskhelperchat,
	  	MessageManager.HandleDefaultCancelEvent,
	  	MessageManager)
end

function Taskhelperchat.ClickConfirmContinueDone_flyToNpc()
	LogInfo("Taskhelperchat.ClickConfirmContinueDone_flyToNpc()")
	--local msgManager = gGetMessageManager()
	gGetMessageManager():CloseCurrentShowMessageBox()
	gGetMessageManager():CloseConfirmBox(eConfirmNormal,false)
end


	--[[
	local msgManager = gGetMessageManager()
	local nTaskDetailId = msgManager.nTaskDetailId
	local repeatTable =  GameTable.circletask.GetCRepeatTaskTableInstance():getRecorder(nTaskDetailId)
	if repeatTable.id == -1 then
		LogInfo("error=Taskhelperchat.ClickConfirmContinueDone_flyToNpc()"..nTaskDetailId)
		return
	end
	local nNpcId = repeatTable.nacceptnpcid
	if nNpcId == 1 then
		nNpcId = require("logic.task.taskhelper").GetSchoolMonsterId()
	end
	require("logic.task.taskhelpergoto").flyToNpc(nNpcId)
	--]]


--[[
<variable name="nautodo" type="int" fromCol="是否自动寻路" />
<variable name="nautonextlun" type="int" fromCol="自动领取下一轮" />
<variable name="nlunendmsgid" type="int" fromCol="不自动领取确定提示" />		
--]]

function Taskhelperchat.CommitSpecialTaskResult_checkShowTip(nTaskTypeId)
	local repeatTypeTable = Taskhelperchat.GetRepeatTaskTable(nTaskTypeId)
	
	if repeatTypeTable==nil then
		return
	end
	if repeatTypeTable.nautonextlun ~=0 then
		return
	end
	local pQuest = GetTaskManager():GetSpecialQuest(nTaskTypeId)
	if pQuest==nil then
		return
	end
	
	local nTaskDetailId = pQuest.questtype
	local eTaskDetailType = require "logic.task.taskhelper".GetSpecialQuestType2(nTaskDetailId)
	if  fire.pb.circletask.CircTaskClass.CircTask_CatchIt==eTaskDetailType or 
        fire.pb.circletask.CircTaskClass.CircTask_ChallengeNpc==eTaskDetailType 
     then
		Taskhelperchat.CheckForContinueDone_CircTask_Catch(nTaskTypeId)
		return
	end
	
	local nTipMsgId = repeatTypeTable.nlunendmsgid

    if nTipMsgId <= 0 then
        return
    end

	--local nTaskDetailId = pQuest.questtype
	local nMaxNum  = require "logic.task.taskhelper".GetRepeatTaskMaxCount(nTaskDetailId)
	local nRound = pQuest.round
	--local nSumnum = pQuest.sumnum
	if nRound>=nMaxNum then 
		local strMsg = MHSD_UTILS.get_msgtipstring(nTipMsgId)
		 
		local msgManager = gGetMessageManager()
		msgManager.nTaskTypeId =nTaskTypeId
		
		gGetMessageManager():AddConfirmBox(eConfirmNormal,
		strMsg,
		Taskhelperchat.ClickConfirmContinueDone_defaultRepeatTask,
	  	Taskhelperchat,
	  	MessageManager.HandleDefaultCancelEvent,
	  	MessageManager)
	end

end

function Taskhelperchat.ClickConfirmContinueDone_defaultRepeatTask()
	LogInfo("Taskhelperchat.ClickConfirmContinueDone_defaultRepeatTask()")
	local msgManager = gGetMessageManager()
	local nTaskTypeId = msgManager.nTaskTypeId
	
	gGetMessageManager():CloseCurrentShowMessageBox()
	gGetMessageManager():CloseConfirmBox(eConfirmNormal,false)

	require "logic.task.taskhelpergoto".GotoTaskNpc(nTaskTypeId)
end


return Taskhelperchat


--[[
function Taskhelperchat.CheckForContinueDone_CircTask_School(nTaskTypeId)
	LogInfo("Taskhelperchat.CheckForContinueDone_CircTask_School(nTaskTypeId)")
	local pQuest = GetTaskManager():GetSpecialQuest(nTaskTypeId)
	if pQuest==nil then
		return
	end
	local nRound = pQuest.round
	local nSumnum = pQuest.sumnum
	
	local nTaskDetailId = pQuest.questtype
	local nMaxNum = require "logic.task.taskhelper".GetRepeatTaskMaxCount(nTaskDetailId)
	
	if nSumnum==nMaxNum then
		local strMsg = MHSD_UTILS.get_resstring(11024)
		gGetMessageManager():AddConfirmBox(eConfirmNormal,
		strMsg,
		Taskhelperchat.ClickConfirmContinueDoneSchoolTask,
	  	Taskhelperchat,
	  	MessageManager.HandleDefaultCancelEvent,
	  	MessageManager)
			
	end
		
end
--]]

--[[
function Taskhelperchat.ClickConfirmContinueDoneSchoolTask()
	gGetMessageManager():CloseCurrentShowMessageBox()
	gGetMessageManager():CloseConfirmBox(eConfirmNormal,false)
	local TaskHelper = require "logic.task.taskhelper"
	TaskHelper.gotoSchoolMonster()
end
--]]
