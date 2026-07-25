require "protodef.rpcgen.fire.pb.circletask.specialqueststate"
local spcQuestState = SpecialQuestState:new()

Taskhelpernpc = {}

function Taskhelpernpc.GetNpcStateByID( nNpcKey,nNpcId)
		
	 
	--active task
	--//==============================================
	local quests = GetTaskManager():GetReceiveQuestListForLua()
	local questnum = quests:size()
	for i = 0, questnum - 1 do
		local pQuest = quests[i]
		local nTaskTypeId = pQuest.questid
		local nDstNpcId = pQuest.dstnpcid
		
		local fubenTable = BeanConfigManager.getInstance():GetTableByName("circletask.cfubentask"):getRecorder(nTaskTypeId)
		if fubenTable and fubenTable.id ~= -1 then
			
			
			if nDstNpcId == nNpcId and 
			fubenTable.nfubentasktype == require("logic.task.taskhelpertable").eFubenTaskType.eNpcMissionBattle then -- 1=zhandou
				return eNpcMissionBattle
			end
		end
	end
	
	--//==============================================
	--LogInfo("Taskhelpernpc.GetNpcStateByID( nNpcKey,nNpcId)=nNpcKey="..nNpcKey.."=nNpcId="..nNpcId)
	local specialquests = GetTaskManager():GetSpecailQuestForLua()
	local specialquestnum = specialquests:size()
	for i = 0, specialquestnum - 1 do
		local pQuest = specialquests[i]
		if pQuest.questid ~= 0 then
			local nTaskDetailId = pQuest.questtype
			local nTaskDetailType = require "logic.task.taskhelper".GetSpecialQuestType2(nTaskDetailId)
			if nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_CatchIt or 
                nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ChallengeNpc
             then --CircTask_Catch
				if (pQuest.dstnpckey==nNpcKey and pQuest.dstnpckey~=0)  or
                    (pQuest.dstnpckey==0 and pQuest.dstnpcid==nNpcId )
                then
					LogInfo("CircTask_CatchIt=eNpcMissionBattle")
					return eNpcMissionBattle
				end
			end
		
		end
	end
	--//scenario task show npc
	--//===================================================
	
	local scenarioquests = GetTaskManager():GetScenarioQuestListForLua()
	local scenarioquestnum = scenarioquests:size()
	for nIndexScenario = 0, scenarioquestnum - 1 do
		local scenarioquest = scenarioquests[nIndexScenario]
		local nTaskTypeId = scenarioquest.missionid
		local questinfo = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(nTaskTypeId)
		if questinfo.id ~= -1 then
			
			local bHave = Taskhelpernpc.IsHaveTaskShowNpcId(nTaskTypeId,nNpcId)
			if bHave then
				return eNpcMissionDisplay
			end
			
		end	
	end
	
	--//===================================================

    local taskManager = require("logic.task.taskmanager").getInstance()
    local bNeedToNpc =  taskManager:isAnyeNeedToGotoNpc()
    if bNeedToNpc then
        return -1
    end

    --local taskManager = require("logic.task.taskmanager").getInstance()
    for nIndex,anyeTaskData in pairs( taskManager.vAnyeTask) do
        local nTaskDetailType = anyeTaskData.kind
        if  nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_CatchIt  or 
             nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ChallengeNpc
        then
            if anyeTaskData.state ~= spcQuestState.SUCCESS then
                local nNpcId_anye = anyeTaskData.dstnpcid
                
                 if  nNpcId_anye==nNpcId then
					return eNpcMissionBattle
			    end
            end
        end
    end
	
	return -1
end

function Taskhelpernpc.IsHaveTaskShowNpcId(nTaskTypeId,nNpcId)
	local questinfo = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(nTaskTypeId)
	if questinfo.id == -1 then
		return false
	end
	local nNum = questinfo.vTaskShowNpc:size()
	for nIndex=0,nNum-1 do
		local nShowNpcId = questinfo.vTaskShowNpc[nIndex]
		if nNpcId==nShowNpcId then
			return true
		end
	end
	return false
end

function Taskhelpernpc.checkShowScenarTaskNpc(nTaskTypeId)
	--Taskhelpernpc.setScenarTaskNpcVisible(nTaskTypeId,true)
end

function Taskhelpernpc.setScenarTaskNpcVisible(nTaskTypeId,bVisible)
	local questinfo = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(nTaskTypeId)
	if questinfo.id ~= -1 then
			--local nTaskTypeId = scenarioquest.questid
		local nNum = questinfo.vTaskShowNpc:size()
		for nIndex=0,nNum-1 do
			local nNpcId = questinfo.vTaskShowNpc[nIndex]
			local pNpc =  gGetScene():FindNpcByBaseID(nNpcId)
			if pNpc then
				pNpc:SetVisible(bVisible)
				--LogInfo("pNpc:SetVisible(bVisible)=nNpcId="..nNpcId)
			end
		end
	end	
end


function Taskhelpernpc.checkHideScenarTaskNpc(nTaskTypeId)
	Taskhelpernpc.setScenarTaskNpcVisible(nTaskTypeId,false)
end


function Taskhelpernpc.GetAnyeTaskNpcId(anyeTaskData)

    local nNpcId = anyeTaskData.dstnpcid
    local nTaskDetailType = anyeTaskData.kind
    local nItemId = anyeTaskData.dstitemid
    if fire.pb.circletask.CircTaskClass.CircTask_ItemFind==nTaskDetailType then
		local nItemId = anyeTaskData.dstitemid
		local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
		if itemAttrCfg then
			nNpcId = itemAttrCfg.npcid2
		else
		end
	end
	
	if nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_PetCatch then
		local nItemId = anyeTaskData.dstitemid
		local petAttrCfg = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(nItemId)
		if petAttrCfg then
			nNpcId = petAttrCfg.nshopnpcid
		end
	end
    return nNpcId
end

function Taskhelpernpc.GetRepeatTaskNpcId(nTaskTypeId)
	local pQuest = GetTaskManager():GetSpecialQuest(nTaskTypeId)
	if not pQuest then
		return -1
	end
	local nNpcId = pQuest.dstnpcid
	if pQuest.queststate == spcQuestState.DONE then
		return nNpcId
	end
	local nTaskDetailId = pQuest.questtype
	local nTaskDetailType = require("logic.task.taskhelper").GetSpecialQuestType2(nTaskDetailId)
	

	if fire.pb.circletask.CircTaskClass.CircTask_ItemFind==nTaskDetailType then
		local nItemId = pQuest.dstitemid
		local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
		if itemAttrCfg then
			nNpcId = itemAttrCfg.npcid2
		else
		end
	end
	
	if nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_PetCatch then
		local nItemId = pQuest.dstitemid
		local petAttrCfg = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(nItemId)
		if petAttrCfg then
			nNpcId = petAttrCfg.nshopnpcid
		end
	end
	return nNpcId
end



function Taskhelpernpc.GetTaskIdInNpc(nNpcId,vTaskIdInNpc)
	LogInfo("Taskhelpernpc.GetTaskIdInNpc(nNpcId,vTaskIdInNpc)=nNpcId="..nNpcId)
	local specialquests = GetTaskManager():GetSpecailQuestForLua()
	local specialquestnum = specialquests:size()
	for i = 0, specialquestnum - 1 do
		local pQuest = specialquests[i]
		if pQuest.questid ~= 0 then
			local nTaskDetailId = pQuest.questtype
			local nTaskTypeId = pQuest.questid 
			local nNpcIdDst = Taskhelpernpc.GetRepeatTaskNpcId(nTaskTypeId) --pQuest.dstnpcid
			if nNpcId==nNpcIdDst then
				vTaskIdInNpc[#vTaskIdInNpc +1] = pQuest.questid
			end
			--local nTaskDetailType = require "logic.task.taskhelper".GetSpecialQuestType2(nTaskDetailId)		
		end
	end
    ----------------------
    local taskManager = require("logic.task.taskmanager").getInstance()
    --local nAllCellNum = (taskManager.vAnyeTask) 
    for nIndex,oneTaskData in pairs(taskManager.vAnyeTask) do
        local nNpcIdDst =  Taskhelpernpc.GetAnyeTaskNpcId(oneTaskData)
        if nNpcId==nNpcIdDst then
				vTaskIdInNpc[#vTaskIdInNpc +1] = oneTaskData.id
		end
    end


end


function Taskhelpernpc.getTaskIdInNpc(nNpcKey,vTaskIdInNpc)
	LogInfo("TaskHelper.getTaskIdInNpc(nNpcKey)="..nNpcKey)
	local pNpc = gGetScene():FindNpcByID(nNpcKey)
	if not pNpc then	
		LogInfo("not pNpc")	
		return -1
	end
	local nNpcId = pNpc:GetNpcBaseID()
	LogInfo("nNpcId="..nNpcId)
	--local vTaskIdInNpc = {}
	require("logic.task.taskhelpernpc").GetTaskIdInNpc(nNpcId,vTaskIdInNpc)
	
	--[[
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
	
	
	local pQuest = GetTaskManager():GetSpecialQuest(nLastTaskTypeId)
	if not pQuest then
		return -1
	end
	local nItemId = pQuest.dstitemid
	return nItemId
	--]]
end

function Taskhelpernpc.isHaveCurClickTaskId(nNpcKey)
	local nLastTaskTypeId = GetMainCharacter():GetGotoTargetPosType()
	if nLastTaskTypeId==0 then
		return false
	end
	local vTaskIdInNpc = {}
	Taskhelpernpc.getTaskIdInNpc(nNpcKey,vTaskIdInNpc)
	local nNum = #vTaskIdInNpc
	if nNum==0 then
		return false
	end
	
	for nIndex=1,nNum do
		local nTaskId = vTaskIdInNpc[nIndex]
		if nTaskId==nLastTaskTypeId then
			return true
		end
	end
	return false
	
end

--require("logic.task.taskhelpernpc")
--server add npc 
function Taskhelpernpc.AddSceneNpc(nNpcId,nNpcKey)
--[[
    LogInfo("Taskhelpernpc.AddSceneNpc(nNpcId,nNpcKey)="..nNpcId)
    --local pNpc =  gGetScene():FindNpcByBaseID(nNpcId)
    local pNpc =  gGetScene():FindNpcByID(nNpcKey)
	if pNpc then
		--pNpc:SetVisible(bVisible)
		
	end
    --]]
end


function Taskhelpernpc.sgeneralsummoncommand_process(protocol)
    local HuoDongManager = require"logic.huodong.huodongmanager"

    local nActType = 0
    local TraType = require("protodef.rpcgen.fire.pb.npc.transmittypes"):new()
    if  protocol.summontype ==TraType.kejukaoshisystem then
	    nActType = HuoDongManager.ActivityID_kejukaoshisystem
	elseif protocol.summontype ==TraType.winnercall then
		nActType = HuoDongManager.ActivityID_winnercall
    elseif protocol.summontype ==TraType.singlepvp then	
		nActType = HuoDongManager.ActivityID_Pvp1
	elseif protocol.summontype ==TraType.pvp3 then	
		nActType = HuoDongManager.ActivityID_Pvp3
    elseif  protocol.summontype ==TraType.pvp5 then
        nActType = HuoDongManager.ActivityID_Pvp5
	end
    TraType = nil
    local huodongmanager = require"logic.huodong.huodongmanager".getInstanceNotCreate()
    if huodongmanager then
        if not huodongmanager:CanPush(nActType) then
            return
        end
    end

    --------------------------------------------
    if not gGetMessageManager() then
		return;
	end
    if not gGetStateManager() then
        return
    end
    local eGameState = gGetStateManager():getGameState()
	if  eGameState == eGameStateLogin then
		return;
	end
    if GetBattleManager():IsInBattle() then
        local taskManager = require("logic.task.taskmanager").getInstance()
       
        local inviteData = require("protodef.fire.pb.npc.sgeneralsummoncommand"):new()
        inviteData.summontype = protocol.summontype
	    inviteData.roleid = protocol.roleid
	    inviteData.npckey = protocol.npckey
	    inviteData.mapid = protocol.mapid
	    inviteData.minimal = protocol.minimal

        table.insert(taskManager.vInvitePlayer,inviteData)
        return;
    end
    ------------
    local noneedopen = false;
	local describe;
	local title;
	local time = 30000;
	--eMsgType messagetype =  eMsgType_Normal;
    
    local TransmitTypes = require("protodef.rpcgen.fire.pb.npc.transmittypes"):new()
	if  protocol.summontype ==TransmitTypes.kejukaoshisystem then
			title = require("utils.mhsdutils").get_resstring(975)
			describe = require("utils.mhsdutils").get_resstring(976)
			time = 300000;
			--messagetype = eMsgType_Activity;
            local nNeedMoney = 1000 + (gGetDataManager():GetMainCharacterLevel() - 20)*200
	        local roleItemManager = require("logic.item.roleitemmanager").getInstance()
			if (gGetDataManager()
                and roleItemManager:GetPackMoney() < nNeedMoney) then
			
				noneedopen = true;
			end
	elseif protocol.summontype ==TransmitTypes.winnercall then
			title = require("utils.mhsdutils").get_resstring(977)
			describe = GameTable.message.GetCMessageTipTableInstance():getRecorder(140665).msg;
			time = GetNumberValueForStrKey("GUANJUNSHILIAN_ALERT_TIME");
			--messagetype = eMsgType_Activity;
    elseif protocol.summontype ==TransmitTypes.singlepvp then	
			title = require("utils.mhsdutils").get_resstring(11356)
			describe = GameTable.message.GetCMessageTipTableInstance():getRecorder(144293).msg;
			local strActiveName = require("utils.mhsdutils").get_resstring(11353)

            local sb = StringBuilder.new()
            sb:Set("parameter1", strActiveName);
            describe = sb:GetString(describe);
            sb:delete()
            time = 300000;	 
			--messagetype = eMsgType_Activity;
	elseif protocol.summontype ==TransmitTypes.pvp3 then	
			title = require("utils.mhsdutils").get_resstring(11357)
			describe = require("utils.mhsdutils").get_msgtipstring(144293)
			local strActiveName =require("utils.mhsdutils").get_resstring(11354)
            local sb = StringBuilder.new()
			sb:Set("parameter1", strActiveName);
			describe = sb:GetString(describe);
            sb:delete()
            time = 300000;	
			--messagetype = eMsgType_Activity;
    elseif  protocol.summontype ==TransmitTypes.pvp5 then
            title = require("utils.mhsdutils").get_resstring(11464) --5v5拉人
			describe = require("utils.mhsdutils").get_msgtipstring(144293) -- 
			local strActiveName =require("utils.mhsdutils").get_resstring(11465) --5v5竞技场
            local sb = StringBuilder.new()
			sb:Set("parameter1", strActiveName);
			describe = sb:GetString(describe);
            sb:delete()
            time = 300000;	
	end
    TransmitTypes = nil

    if noneedopen then
        return
    end
	--gGetMessageManager():CloseCurrentShowMessageBox();
    -----------------------------------------
    local function clickYes(callBackObj,args)
         Taskhelpernpc.HandleConfirmSummon()
    end
    -----------------------------------------
    local function clickNo(callBackObj,args)
         local nTimeOut = CEGUI.toWindowEventArgs(args).handled
        Taskhelpernpc.HandleRefuseSummon(nTimeOut)
    end
    -----------------------------------------
    local nRightTick = 0
    local strTitle = title
    local strContent = describe
    gGetMessageManager():AddMessageBox(strTitle,
    strContent,
    clickYes,
    Taskhelpernpc,
    clickNo,
    Taskhelpernpc,
    eMsgType_TeamSummon,
    time,
    protocol.summontype,
    protocol.npckey,
    nil,
    MHSD_UTILS.get_resstring(996),
    MHSD_UTILS.get_resstring(997),
    nRightTick)

    
end



--//确认拉人
function Taskhelpernpc.HandleConfirmSummon()
    if not gGetMessageManager() then
        return
    end
    local TransmitTypes = require("protodef.rpcgen.fire.pb.npc.transmittypes"):new()
    local summontype = gGetMessageManager():GetUserID()
    if summontype ==TransmitTypes.singlepvp then
        require("logic.task.taskhelper").gotoNpc(161518)
        gGetMessageManager():CloseCurrentShowMessageBox();
        return
    elseif summontype ==TransmitTypes.pvp3 then
        require("logic.task.taskhelper").gotoNpc(161519)
        gGetMessageManager():CloseCurrentShowMessageBox();
        return
    elseif summontype ==TransmitTypes.pvp5 then
        require("logic.task.taskhelper").gotoNpc(161520)
        gGetMessageManager():CloseCurrentShowMessageBox();
        return 
    end
    TransmitTypes = nil

    local p = require "protodef.fire.pb.npc.cgeneralsummoncommand":new()
    p.agree = 1 --1表示同意, 0表示不同意
    p.summontype = gGetMessageManager():GetUserID()
    p.npckey = gGetMessageManager():GetUserID2();
	require "manager.luaprotocolmanager":send(p)

    gGetMessageManager():CloseCurrentShowMessageBox();

    if GetMainCharacter() then
        GetMainCharacter():StopMove()
        GetMainCharacter():clearGoTo()
    end	
end

--//拒绝拉人
function  Taskhelpernpc.HandleRefuseSummon(nTimeOut)
     if not gGetMessageManager() then
        return
    end
	if nTimeOut ~= 1 then
	    
        local p = require "protodef.fire.pb.npc.cgeneralsummoncommand":new()
        p.agree = 0 --1表示同意, 0表示不同意
        p.summontype = gGetMessageManager():GetUserID()
        p.npckey = gGetMessageManager():GetUserID2();
	    require "manager.luaprotocolmanager":send(p)

        gGetMessageManager():CloseCurrentShowMessageBox();
	else --timeout=1
	    local p = require "protodef.fire.pb.npc.cgeneralsummoncommand":new()
        p.agree = 0 --1表示同意, 0表示不同意
        p.summontype = gGetMessageManager():GetAutoCloseMessageUserID()
        --p.npckey = gGetMessageManager():GetUserID2();
	    require "manager.luaprotocolmanager":send(p)
	end
	
end


return Taskhelpernpc
