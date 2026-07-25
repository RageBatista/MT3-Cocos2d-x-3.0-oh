require "logic.npc.npcdialog"
require "logic.npc.npcscenespeakdialog"

NpcServiceManager = {}

eMissionIconNull = 0 --没有任务
eMissionIconAcceptalbe = 1 --可接任务
eMissionIconNoComplete = 2 --接取任务，未完成
eMissionIconComplete = 3 --可交任务状态


eCommon = 0 --普通npc提示框
eKeju = 1 --智慧试炼考试
eCommitQuest = 2 --提交剧情任务
eFinishQuest = 3 --提交任务后的对话
eAnswerScenarioQuestion = 4 --剧情任务答题
eScenarioBranch = 5 --剧情分支任务
eSelectPrentice = 6 
eConfirmPassBook = 7 
eQuestionnaire	= 8 --调查问卷
eSceneNpcTalk = 9 --景物NPC对话框 纯客户端的
eTreatNpcTalk	= 10 

NpcServiceManager.eNpcServiceType = 
{   
    jingyingfuben = 460,
    gonghuiqiuzhu =100309,
    shijieqiuzhu = 100310,
    pvp1v = 910002,
    pvp3v = 910012,
    shiguangzhixue =100400,
    pvp5v = 910022,

}

--点击服务后处理 return 0 ==传给c发消息
function NpcServiceManager.DispatchHandler(npckey, serviceid)
	local nCSendSercive = 0
	local nCNotSendService = 1
	local nNpcKey = npckey
	local nServiceId = serviceid

	if serviceid == 2058 then
		require "protodef.fire.pb.item.cgetpackinfo";
		local p = CGetPackInfo.Create();
		p.packid = fire.pb.item.BagTypes.DEPOT
		p.npcid = npckey
		LuaProtocolManager.getInstance():send(p)
		local dlg = require "logic.item.depot":getInstance()
		dlg.m_npckey = npckey
		dlg:SetVisible(false)
		return 0
	--//=====================================================
	--//=====================================================
	--点击职业提交
	elseif NpcServiceManager.IsSchoolCommit(serviceid)==true then
        NpcServiceManager.SendNpcService(npckey, serviceid)
		return nCNotSendService
	--//=====================================================
	elseif fire.pb.npc.NpcServices.CATCH_IT_QUERY == serviceid then --//zhuo gui chaxun --11023
        NpcServiceManager.SendNpcService(npckey, serviceid)
		return nCNotSendService 
	--//=====================================================
	elseif  NpcServiceManager.isBianjiezudui(nServiceId) ==true then
		NpcServiceManager.HandleService_CATCH_IT_BJ(nNpcKey,nServiceId)
		return nCNotSendService
	--//=====================================================
	elseif  NpcServiceManager.isJumpMap(nServiceId) ==true then
		NpcServiceManager.HandleService_JumpMap(nNpcKey,nServiceId)
		return nCNotSendService
	---------------------------------------------------------
	--购买药品、物品、装备
	elseif fire.pb.npc.NpcServices.BUY_MEDICINE == serviceid
	    or fire.pb.npc.NpcServices.BUY_GOODS == serviceid
		or fire.pb.npc.NpcServices.BUY_EQUIP == serviceid then
		
		NpcDialog.handleWindowShut()
		NpcServiceManager.ReceiveServiceId_openNpcShop(nNpcKey)
		
		return nCNotSendService
		
	---------------------------------------------------------
	--购买宠物
	elseif fire.pb.npc.NpcServices.BUY_PET == serviceid then
		NpcDialog.handleWindowShut()
		
		NpcServiceManager.ReceiveServiceId_openPetShop(nNpcKey)
		return nCNotSendService
		
	---------------------------------------------------------
	--打开商会
	elseif fire.pb.npc.NpcServices.OPEN_SHANGHUI == serviceid then
		NpcDialog.handleWindowShut()
		NpcServiceManager.ReceiveServiceId_openShangHui(nNpcKey)
		--require("logic.shop.shoplabel").showCommerce()
		return nCNotSendService
	elseif serviceid == fire.pb.npc.NpcServices.PET_STORE then
		petstoragedlg.npckey = npckey
        local p = require("protodef.fire.pb.pet.cgetpetcolumninfo"):new()
        p.columnid = 2
        p.npckey = npckey
	    LuaProtocolManager:send(p)
	--//========================================================
	elseif serviceid ==  NpcServiceManager.eNpcServiceType.jingyingfuben then
		NpcDialog.handleWindowShut()
		local fubendlg = require("logic.fuben.fubenlabel").getInstanceAndShow()
		return nCNotSendService
    ------------------------------------------------------------
    elseif nServiceId == NpcServiceManager.eNpcServiceType.gonghuiqiuzhu  then --gong hui qiu zhu
        NpcServiceManager.handleService_gonghuiqiuzhu(nServiceId)
        NpcDialog.handleWindowShut()
        return nCNotSendService
    ------------------------------------------------------------
    elseif nServiceId == NpcServiceManager.eNpcServiceType.shijieqiuzhu then --shi jie qiu zhu
        NpcServiceManager.handleService_shijieqiuzhu(nServiceId)
        NpcDialog.handleWindowShut()
        return nCNotSendService
    ------------------------------------------------------------
	elseif nServiceId == NpcServiceManager.eNpcServiceType.shiguangzhixue then --时光之穴
		NpcDialog.handleWindowShut()
		local p = require "protodef.fire.pb.mission.cgetlinestate":new()
		require "manager.luaprotocolmanager":send(p)
        return nCNotSendService
    ------------------------------------------------------------
    elseif nServiceId == NpcServiceManager.eNpcServiceType.pvp1v then --1v1 pvp
        NpcDialog.handleWindowShut()
        require("logic.jingji.jingjidialog").getInstanceAndShow()
        return nCNotSendService
    ------------------------------------------------------------
    
    elseif nServiceId == NpcServiceManager.eNpcServiceType.pvp3v then --3v3 pvp
        NpcDialog.handleWindowShut()
        require("logic.jingji.jingjidialog3").getInstanceAndShow()
        return nCNotSendService

    ------------------------------------------------------------
    elseif nServiceId == NpcServiceManager.eNpcServiceType.pvp5v then --55 pvp
        NpcDialog.handleWindowShut()
        require("logic.jingji.jingjidialog5").getInstanceAndShow()
        return nCNotSendService
    ------------------------------------------------------------
    elseif nServiceId == 100703 then 
        NpcDialog.handleWindowShut()
        
        local taskNpcDialog = require("logic.task.tasknpcdialog").getInstanceAndShow()
	    taskNpcDialog:RefreshNpcDialog_commitpet(nNpcKey,nServiceId)
        return nCNotSendService
    ------------------------------------------------------------
	elseif nServiceId == 910105 then
		local p = require "protodef.fire.pb.battle.livedie.cacceptlivediebattle":new()
		require "manager.luaprotocolmanager":send(p)
        return nCNotSendService
    ------------------------------------------------------------
    elseif NpcServiceManager.isServiceToSeeBattle(nServiceId)==true then
        local nTaskId = NpcServiceManager.getSeeBattleTaskIdWithServiceId(nServiceId)
        if nTaskId ~= -1 then
            local beginbattle = require "protodef.fire.pb.mission.cactivemissionaibattle":new()
            beginbattle.missionid = nTaskId
            beginbattle.npckey = nNpcKey
            beginbattle.activetype = 1 --1=see battle
            require "manager.luaprotocolmanager":send(beginbattle)
        end
        NpcDialog.handleWindowShut()
        return nCNotSendService
    ------------------------------------------------------------
    elseif nServiceId == 910106 then -- 兑换神兽
        NpcDialog.handleWindowShut()
        require("logic.pet.shenshoucommon").DuiHuan(nNpcKey)
        return nCNotSendService
    --------------------------------------------------------------
    elseif nServiceId == 910107 then -- 提升神兽能力
        NpcDialog.handleWindowShut()
        require("logic.pet.shenshoucommon").Increase(nNpcKey)
        return nCNotSendService
    ------------------------------------------------------------
    elseif nServiceId == 910111 then -- 重置神兽
        NpcDialog.handleWindowShut()
        require("logic.pet.shenshoucommon").Reset(nNpcKey)
        return nCNotSendService
    ------------------------------------------------------------
    elseif nServiceId == 910112 then -- 查看神兽
        NpcDialog.handleWindowShut()
        require("logic.pet.shenshoucommon").Show(nNpcKey)
        return nCNotSendService
    ------------------------------------------------------------
	elseif nServiceId == 910102 then --应战生死战
		NpcDialog.handleWindowShut()
		local p = require "protodef.fire.pb.battle.livedie.cacceptlivediebattlefirst":new()
		require "manager.luaprotocolmanager":send(p)
        return nCNotSendService
    ------------------------------------------------------------
    elseif nServiceId == 910215 then -- 熊猫人BOSS战观战
        NpcDialog.handleWindowShut()
            local req = require "protodef.fire.pb.npc.cnpctiaozhan".Create()
            req.npckey = nServiceId
            req.serviceid = 0
            LuaProtocolManager.getInstance():send(req)
        return nCNotSendService
    ------------------------------------------------------------
    elseif nServiceId == 100018 then
       local taskManager = require("logic.task.taskmanager").getInstance()
        --local nCurDay = taskManager:getServerOpenCurDay()
        --if nCurDay <= 7 then
        --    taskManager:showTip(nCurDay)
        --    NpcDialog.handleWindowShut()
        --    return nCNotSendService
        --end
       

       local bNeedToNpc =  taskManager:isAnyeNeedToGotoNpc()
       if bNeedToNpc then
            require("logic.task.taskmanager").getInstance():saveAnyeGotoTime()
       end

       local renwuListDlg = require("logic.task.renwulistdialog").getInstanceNotCreate()
       if renwuListDlg then
            if renwuListDlg:isHaveAnyeTrack()==false then
                renwuListDlg:addAnyeTrack()
            else
                require("logic.task.renwulistdialog").refreshAnyeTrack()
            end
       end
     ------------------------------------------------------------
     elseif nServiceId == 910031 then   --打开公会战排行界面
        NpcDialog.handleWindowShut()
		local familyfight = require("logic.family.familyfightrank").getInstanceAndShow()
        local p = require "protodef.fire.pb.clan.fight.cgetclanfightlist":new()
        --当前时间
	    local time = StringCover.getTimeStruct(gGetServerTime() / 1000)
        --计算星期
	    local curWeekDay = time.tm_wday
	    if curWeekDay <= 2 then
		    p.which = 0    
        else
            p.which = 1    
	    end
        p.whichweek = -1
		require "manager.luaprotocolmanager":send(p)
		return nCNotSendService
     elseif nServiceId == 910030 then  --参加公会战
        NpcDialog.handleWindowShut()
        --发送参加公会战协议
        NpcServiceManager.SendNpcService(npckey, nServiceId)
        --gGetNetConnection():send(fire.pb.mission.CReqGoto(2200, 100, 99));
        return nCNotSendService
    elseif nServiceId == fire.pb.npc.NpcServices.END_INST_NPC_BATTLE then
        local function ClickYes(self, args)
            gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
            local req = require "protodef.fire.pb.npc.cnpcservice".Create()
            req.npckey = npckey
            req.serviceid = nServiceId
            LuaProtocolManager.getInstance():send(req)
            return nCNotSendService
        end
        local function ClickNo(self, args)
            if CEGUI.toWindowEventArgs(args).handled ~= 1 then
                gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
            end
            return nCNotSendService
        end
        gGetMessageManager():AddConfirmBox(eConfirmNormal, MHSD_UTILS.get_msgtipstring(166137), ClickYes, 
        self, ClickNo, self,0,0,nil,MHSD_UTILS.get_resstring(2035),MHSD_UTILS.get_resstring(2036))
        NpcDialog.handleWindowShut()
        return nCNotSendService
	------------------------------------------------------------
    elseif nServiceId == 910301 then   --转职界面
		ZhuanZhiDlg.getInstanceAndShow()
		return nCNotSendService
	------------------------------------------------------------
    elseif nServiceId == 910302 then   --转换武器
	        require "logic.workshop.weaponswitch".getInstanceAndShow()
		return nCNotSendService
	elseif nServiceId + 100000 == 400000 then--
		XiLianDlg.getInstanceAndShow()
		return nCNotSendService
	elseif nServiceId + 111111 == 444444 then--
		LogInfo("=========");
		AdvancedEquipDlg.getInstanceAndShow()
		return nCNotSendService
	elseif nServiceId == 388888 then   --装备点化
			AttunementDlg.getInstanceAndShow()
		return nCNotSendService
	------------------------------------------------------------
    elseif nServiceId == 910303 then   --转换宝石
		-- if LeftChangeGemTimes == 0 then
		-- 	GetCTipsManager():AddMessageTipById(174016)
		-- else
		-- end
        ZhuanZhiBaoShi.getInstanceAndShow()
		return nCNotSendService
	elseif nServiceId == 999733 then   --装备附魔
	        require "logic.workshop.superronglian".getInstanceAndShow()
		return nCNotSendService
    elseif nServiceId == 999734 then   --装备附魔
        debugrequire "logic.workshop.zhuangbeifumo".getInstanceAndShow()

		return nCNotSendService
    elseif nServiceId == 130016 then   --福利兑换
        debugrequire "logic.libaoduihuan.libaoduihuanha".getInstanceAndShow()

		return nCNotSendService				
    elseif nServiceId == 999726 then   --经验兑换
        if  gGetDataManager():GetMainCharacterLevel() < 160 then
            GetCTipsManager():AddMessageTipById(191227)
            return
        end
        require "protodef.fire.pb.item.cexpchangeitem";
	    local cexpchangeitem = CExpChangeItem.Create();
	    LuaProtocolManager.getInstance():send(cexpchangeitem);
		return nCNotSendService
    end
    local bOpenUIService = NpcServiceManager.isOpenUIService(nServiceId)
    if bOpenUIService == true then
        NpcDialog.handleWindowShut()
        NpcServiceManager.openUIWithService(nServiceId)
        return nCNotSendService
    end
	return nCSendSercive --0 c send service
end

function NpcServiceManager.getSeeBattleTaskIdWithServiceId(nServiceId)
    local npcDlg =  NpcDialog.getInstanceNotCreate()
    if not npcDlg then
        return -1
    end
    for k,nTaskId in pairs(npcDlg.m_vquestid) do
         local taskTable = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(nTaskId)
         if taskTable and taskTable.BattleVideo==nServiceId then
            return nTaskId
         end
    end
    return -1
end


--[[
Administrator:
0:空服务
1:接循环任务，参数为循环任务类型id。
2:提交循环任务，参数为循环任务类型id。
3:查询循任务次数，参数为循环任务类型id。
4:便捷组队，参数为便捷组队信息表ID
5:循环任务进入战斗服务，参数为循环任务类型id
6：合成道具，填物品合成表里合成ID
7：任性一下类型
9：挑战NPC的服务类型
10：副本进入的服务类型（服务参数1填写副本ID）
11:弹出界面服务(后面参数跟界面顺序表id就好了)
12：战斗录像类型
--]]
function NpcServiceManager.isServiceToSeeBattle(nServiceId)

    local serviceTaskTable = BeanConfigManager.getInstance():GetTableByName("npc.cnpcservicemapping"):getRecorder(nServiceId)
    if serviceTaskTable == nil then
        return false
    end

    if serviceTaskTable.type == 12 then
        return true
    end
    return false
end


function NpcServiceManager.SendNpcService(npckey, serviceid)
    if require "logic.bingfengwangzuo.bingfengwangzuomanager":isInBingfeng() then    
        if require("logic.worldmap.worldmapdlg").GetSingleton()then
            return    --冰封王座打开世界地图，禁止自动找Npc战斗
        end 
    end
    local req = require "protodef.fire.pb.npc.cnpcservice".Create()
    req.npckey = npckey
    req.serviceid = serviceid
    LuaProtocolManager.getInstance():send(req)
    NpcDialog.handleWindowShut()
end


function NpcServiceManager.openUIWithService(nServiceId)
    local serviceTaskTable = BeanConfigManager.getInstance():GetTableByName("npc.cnpcservicemapping"):getRecorder(nServiceId)
    if serviceTaskTable == nil then
        return 
    end
    if serviceTaskTable.type ~= 11 then
        return 
    end
    local nUIId = serviceTaskTable.param1
    
    require("logic.openui").OpenUI(nUIId)
end


function NpcServiceManager.isOpenUIService(nServiceId)
    local serviceTaskTable = BeanConfigManager.getInstance():GetTableByName("npc.cnpcservicemapping"):getRecorder(nServiceId)
    if serviceTaskTable == nil then
        return false
    end

    if serviceTaskTable.type == 11 then 
        return true
    end
    return false
end

function NpcServiceManager.getCurJuqingTaskId()
    local npcDlg =  NpcDialog.getInstanceNotCreate()
    if not npcDlg then
        return -1
    end
    for k,nTaskId in pairs(npcDlg.m_vquestid) do
         local taskTable = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(nTaskId)
         if taskTable  then
            return nTaskId
         end
    end
    return -1
end


function NpcServiceManager.sendChatInChannel(nServiceId,nChannel)

   local nLeaderId =  gGetDataManager():GetMainCharacterID()
   if not GetTeamManager():IsOnTeam()  then
      GetTeamManager():RequestCreateTeam()
   else
        local pMember =  GetTeamManager():GetTeamLeader()
        if pMember then
            nLeaderId = pMember.id
        end
   end

    local strJoinTeam = require "utils.mhsdutils".get_resstring(11306)

    local sb = StringBuilder:new()
	sb:Set("leaderid", tostring(nLeaderId))
	strJoinTeam = sb:GetString(strJoinTeam)
	sb:delete()

    local inputChannel = nChannel
    local strChatContent = strJoinTeam --160227
    local strPureText = strJoinTeam
    
    print("____strChatContent: " .. strChatContent)
    print("____strPureText: " .. strPureText)

    local taskID = NpcServiceManager.getCurJuqingTaskId() --GetTaskManager():GetMainScenarioQuestId() 
    if taskID==-1 then  
        return
    end
    local taskTable = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(taskID)
    if not taskTable then  
        return
    end
    local strName = taskTable.MissionName

    local nppcExcuteType = require "protodef.rpcgen.fire.pb.mission.npcexecutetasktypes":new()
    if taskTable.MissionType == nppcExcuteType.START_BATTLE or 
       taskTable.MissionType == nppcExcuteType.GIVE_ITEM then
       --strName = taskTable.BattlePreString
    end

	local roleID = gGetDataManager():GetMainCharacterID()

    local nType = 8
	--<P t="[[主线]部落的大酋长]" roleid="2056193" type="8" key="180130" baseid="0" shopid="0" counter="1" bind="0" loseefftime="0" TextColor="FF00FF00"></P>

    --strName = strName.."<T t="
    strName = "["..strName.."]"
    strName = "<P t=\""..strName.."\" "
    strName = strName.."roleid=\""..tostring(roleID).."\" "
    strName = strName.."type=\""..tostring(nType).."\" "
    strName = strName.."key=\""..tostring(taskID).."\" "

    strName = strName.."baseid=\""..tostring(1).."\" "
    strName = strName.."shopid=\""..tostring(0).."\" "
    strName = strName.."counter=\""..tostring(1).."\" "
    strName = strName.."bind=\""..tostring(0).."\" "
    strName = strName.."loseefftime=\""..tostring(0).."\" "
	strName = strName.."TaskType=\"".."zhuxian".."\" "
    strName = strName.."TextColor=\"".."FF00FF00".."\""

    strName = strName.."></P>"

    --strName = "["..strName.."]"

    strChatContent = strName..strChatContent

    local chatCmd = require "protodef.fire.pb.talk.ctranschatmessage2serv".Create()
	chatCmd.messagetype = inputChannel
	chatCmd.message = strChatContent
	chatCmd.checkshiedmessage = strPureText
	chatCmd.funtype = 4
	chatCmd.taskid = taskID
	LuaProtocolManager.getInstance():send(chatCmd)

    local chatDlg =  CChatOutputDialog.getInstanceNotCreate()
    if chatDlg then
           chatDlg:ToShow()
           chatDlg:ChangeOutChannel(nChannel)
           chatDlg:refreshChannelSel(nChannel)
    else
        chatDlg = CChatOutputDialog:GetSingletonDialogAndShowIt() 
        chatDlg:ChangeOutChannel(nChannel)
        chatDlg:refreshChannelSel(nChannel)
    end
    
end

function NpcServiceManager.handleService_gonghuiqiuzhu(nServiceId) 
    local taskManager = require("logic.task.taskmanager").getInstance()
    if taskManager.fFactionHelpCd > 0 then
        
        local nFactionHelpCd = taskManager.fFactionHelpCd/1000
        nFactionHelpCd = math.floor(nFactionHelpCd)
        if nFactionHelpCd ==0 then
            nFactionHelpCd = 1
        end
        --160238
        local strWaitzi =   require("utils.mhsdutils").get_msgtipstring(160238)
        local sb = StringBuilder.new()
        sb:Set("parameter1",tostring(nFactionHelpCd))
        strWaitzi = sb:GetString(strWaitzi)
        sb:delete()
        
        GetCTipsManager():AddMessageTip(strWaitzi)
        return 
    end
    taskManager:startFactionHelpCd()

    local nChannel = 4
    NpcServiceManager.sendChatInChannel(nServiceId,nChannel)
end

function NpcServiceManager.handleService_shijieqiuzhu(nServiceId)
    local strChannel = GameTable.common.GetCCommonTableInstance():getRecorder(274).value
    local nChannel = tonumber(strChannel)
    NpcServiceManager.sendChatInChannel(nServiceId,nChannel)
end

function NpcServiceManager.HandleService_CATCH_IT_BJ(nNpcKey,nServiceId)
	local serviceTaskTable = BeanConfigManager.getInstance():GetTableByName("npc.cnpcservicemapping"):getRecorder(nServiceId)
	local nParam = serviceTaskTable.param1 

	if GetTeamManager():IsOnTeam() then
		local settingdlg = require("logic.team.teamsettingdlg").getInstance()
        if settingdlg then
            settingdlg:selecteActById(nParam)
        end
	else
		local teamdlg = require('logic.team.teammatchdlg').getInstanceAndShow()
		if teamdlg then
			teamdlg:selecteActById(nParam)
		end
		
	end
	NpcDialog.handleWindowShut()
end

function NpcServiceManager.HandleService_JumpMap(nNpcKey,nServiceId)
	local serviceTaskTable = BeanConfigManager.getInstance():GetTableByName("npc.cnpcservicemapping"):getRecorder(nServiceId)
	local nMapID = serviceTaskTable.param1 

    local  mapRecord = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(nMapID)
	
	if mapRecord == nil then	
		return true;
	end

	if mapRecord.maptype == 1 or mapRecord.maptype == 2  then
	
		local randX = mapRecord.bottomx - mapRecord.topx
		randX = mapRecord.topx + math.random(0, randX)

		local randY = mapRecord.bottomy - mapRecord.topy
		randY = mapRecord.topy + math.random(0, randY)
		gGetNetConnection():send(fire.pb.mission.CReqGoto(nMapID, randX, randY));
    end
	NpcDialog.handleWindowShut()
end
function NpcServiceManager.HandleService_CATCH_IT_QUERY(nNpcKey,nServiceId)
end



function NpcServiceManager.HandleNoCompleteScenarioQuest(npcId, questID, npcBaseId)
    local questinfo = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(questID)
    local nppcExcuteType = require "protodef.rpcgen.fire.pb.mission.npcexecutetasktypes":new()

    if questinfo.MissionType == nppcExcuteType.GIVE_MONEY then
        local commitquest = require "protodef.fire.pb.mission.ccommitmission":new()
        commitquest.missionid = questID
        commitquest.npckey = npcId
        LuaProtocolManager.getInstance():send(commitquest)
    elseif questinfo.MissionType == nppcExcuteType.GIVE_ITEM then
        local tip = MHSD_UTILS.get_msgtipstring(140638)
        local itemattr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(questinfo.ActiveInfoTargetID)
        if itemattr then
            local sb = StringBuilder:new()
            sb:Set("parameter1", itemattr.name)
            local strMsg = sb:GetString(tip)
            sb:delete()
            NpcDialog.getInstance():AddTipsMessage(npcId, npcBaseId, strMsg)
        end
    else
        local strMsg = MHSD_UTILS.get_msgtipstring(141714)
        NpcDialog.getInstance():AddTipsMessage(npcId, npcBaseId, strMsg)
    end
end


function NpcServiceManager.ParseCommitScenarioQuest(npcId, questid, queststate, npcBaseId)
    if NpcDialog.isShow() then
        NpcDialog.handleWindowShut()
    end

    if queststate == eMissionIconNoComplete then
        NpcServiceManager.HandleNoCompleteScenarioQuest(npcId, questid, npcBaseId)
    elseif queststate == eMissionIconComplete then
        NpcSceneSpeakDialog.m_eFunction = eCommitQuest
        if not NpcSceneSpeakDialog.getInstanceAndShow(npcId, npcBaseId, questid):npcSpeakStart() then
            NpcServiceManager.HandleCompleteScenarioQuest(npcId, questid)
        end
    end
end

function NpcServiceManager.HandleCompleteScenarioQuest(npcid, questid)
    local mainMissCfg = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(questid)
    if mainMissCfg.RewardOption == 2 then
        
        require("logic.npc.npcscenespeakdialog").DestroyDialog()
        NpcDialog.handleWindowShut()
        local vcItemId = mainMissCfg.RewardItemIDList
        local vcItemIdNum = mainMissCfg.RewardItemNumList

        require "logic.task.taskhelperscenario".showSelItemToCommitTask(vcItemId, vcItemIdNum, questid, npcid)
        return
    end

    local nTaskType = mainMissCfg.MissionType
    if nTaskType == Taskhelperscenario.MissionType.commitItemToNpc then
         require("logic.npc.npcscenespeakdialog").DestroyDialog()
         if require "logic.task.taskhelperscenario".HandleCompleteScenarioQuest_GIVE_ITEM(questid, npcid) then
            NpcDialog.handleWindowShut()
            return
         end
    end

    local nppcExcuteType = require "protodef.rpcgen.fire.pb.mission.npcexecutetasktypes":new()
    local readTimeType = require "protodef.rpcgen.fire.pb.mission.readtimetype":new()

    local questinfo = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(questid)
	if questinfo.MissionType == nppcExcuteType.NPC_TALK then
		if questinfo.ProcessBarTime > 0 then
			CReadTimeProgressBarDlg:GetSingletonDialogAndShowIt():Start(questinfo.ProcessBarText, readTimeType.END_TALK_QUEST, questinfo.ProcessBarTime, npcid, questid)
		else
            local commitquest = require "protodef.fire.pb.mission.ccommitmission":new()
			commitquest.missionid = questid
			commitquest.npckey = npcid
			LuaProtocolManager.getInstance():send(commitquest)
        end
        NpcSceneSpeakDialog.handleWindowShut()
        NpcDialog.handleWindowShut()
	elseif questinfo.MissionType == nppcExcuteType.START_BATTLE then
        local msgType = eConfirmNormal
        if gGetDataManager():IsHpEightyPercentFull() then
            if questinfo.ProcessBarTime > 0 then
                CReadTimeProgressBarDlg:GetSingletonDialogAndShowIt():Start(questinfo.ProcessBarText, readTimeType.BEGIN_BATTLE_QUEST, questinfo.ProcessBarTime, npcid, questid)
            else
                 local beginbattle = require "protodef.fire.pb.mission.cactivemissionaibattle":new()
                 beginbattle.missionid = questid
                 beginbattle.npckey = npcid
                 require "manager.luaprotocolmanager":send(beginbattle)
            end 
        else
            local function confirm()
                if msgType then 
                    if questinfo.ProcessBarTime > 0 then
                    else
                         local beginbattle = require "protodef.fire.pb.mission.cactivemissionaibattle":new()
                         beginbattle.missionid = questid
                         beginbattle.npckey = npcid
                         require "manager.luaprotocolmanager":send(beginbattle)
                    end
                    gGetMessageManager():CloseConfirmBox(msgType, false)
                    msgType = nil
                end
            end

            local strMsg = MHSD_UTILS.get_msgtipstring(142596)
            
            gGetMessageManager():AddConfirmBox(msgType, strMsg, confirm, 0, MessageManager.HandleDefaultCancelEvent,MessageManager)
        end

        NpcSceneSpeakDialog.handleWindowShut()
        NpcDialog.handleWindowShut()
    elseif questinfo.MissionType == nppcExcuteType.GIVE_ITEM or questinfo.MissionType == nppcExcuteType.GIVE_PET or questinfo.MissionType == nppcExcuteType.GIVE_MONEY then
            local commitquest = require "protodef.fire.pb.mission.ccommitmission":new()
            commitquest.missionid = questid
            commitquest.npckey = npcid
            LuaProtocolManager.getInstance():send(commitquest)

            NpcSceneSpeakDialog.handleWindowShut()
            NpcDialog.handleWindowShut()
    else
        if questinfo.ProcessBarTime > 0 then
            CReadTimeProgressBarDlg:GetSingletonDialogAndShowIt():Start(questinfo.ProcessBarText, questid, questinfo.ProcessBarTime, npcid)
		else
            local commitquest = require "protodef.fire.pb.mission.ccommitmission":new()
            commitquest.missionid = questid
            commitquest.npckey = npcid
            LuaProtocolManager.getInstance():send(commitquest)
        end
        NpcSceneSpeakDialog.handleWindowShut()
        NpcDialog.handleWindowShut()
    end
end


function NpcServiceManager.isNpcHaveCurJuqingTask(nNpcKey,scenarioquests)
    local servicesSize = require "utils.tableutil".tablelength(scenarioquests)
	if servicesSize == 0 then
        return false 
    end
    local nLastTaskTypeId = GetMainCharacter():GetGotoTargetPosType()

    local missCfg = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(nLastTaskTypeId)
	if not missCfg then
        return false 
    end
	
	local Taskhelperscenario = require "logic.task.taskhelperscenario"
	if missCfg.MissionType ~= Taskhelperscenario.MissionType.npcTalk then 
        return false 
    end
	
	if missCfg.ScenarioInfoNpcConversationList:size() ==0  then
		return false
	end

    for k,nTaskId in pairs(scenarioquests) do
        if nLastTaskTypeId == nTaskId then
            return true
        end
    end
    return false
end


--//接收到服务 一个服务时自动提交
--true=shownpcdialog
function NpcServiceManager.ReceiveServiceId(nNpcKey, services, scenarioquests, npcBaseid)
	local bOnlyChat = NpcServiceManager.IsScenarioTaskOnlyAndChatType(nNpcKey, services, scenarioquests)
	if bOnlyChat then --只有一个任务 并且是对话
        if require "utils.tableutil".tablelength(scenarioquests) == 0 then return true end
        local nState = GetTaskManager():GetQuestState(scenarioquests[1])
        NpcServiceManager.ParseCommitScenarioQuest(nNpcKey, scenarioquests[1], nState, npcBaseid)
		return false
	end
	
    --have only one service and auto done
	local bHaveOnlyOneSercive = NpcServiceManager.IsOnlyHaveOneService(services, scenarioquests)
	if bHaveOnlyOneSercive then
		local nFirstServiceId = NpcServiceManager.GetFirstServiceIdOnlyHaveService(services, scenarioquests)
		local bAutoCommit = NpcServiceManager.IsAutoCommitService(nFirstServiceId)
		if bAutoCommit then
            NpcServiceManager.SendNpcService(nNpcKey, nFirstServiceId)
			return  false
		end
	end

    --npc have ju qing task and click juqing task auto done
    if NpcServiceManager.isNpcHaveCurJuqingTask(nNpcKey,scenarioquests) == true then
        local nLastTaskTypeId = GetMainCharacter():GetGotoTargetPosType()
        local nState = GetTaskManager():GetQuestState(nLastTaskTypeId)
         NpcServiceManager.ParseCommitScenarioQuest(nNpcKey, nLastTaskTypeId, nState, npcBaseid)
         return  false
    end

	--循环任务 提交服务时自动提交，直接发服务
	local vRepeatTaskCommitServiceId = {}
	NpcServiceManager.getRepeatTaskServiceIdInNpc(vRepeatTaskCommitServiceId, services)
	
	if #vRepeatTaskCommitServiceId > 0 then
		local nLastTaskTypeId = GetMainCharacter():GetGotoTargetPosType()
		local nSendServiceId = NpcServiceManager.getCurClickServiceId(vRepeatTaskCommitServiceId, nLastTaskTypeId)
		
		if nSendServiceId ~= -1 then
            NpcServiceManager.SendNpcService(nNpcKey, nSendServiceId)
			return false
		end
	end
	
	--//商店npc
	local nOpenShopServiceId = NpcServiceManager.IsHaveOpenShopServiceId(services)
	if nOpenShopServiceId <= 0 then
		return true
	end

	--//npc有买物品任务
	local bHaveTaskItem = NpcServiceManager.IsHaveBuyTaskItem(nNpcKey)
	if not bHaveTaskItem then
		return true
	end

    --npc shop
	if fire.pb.npc.NpcServices.BUY_MEDICINE == nOpenShopServiceId
	    or fire.pb.npc.NpcServices.BUY_GOODS == nOpenShopServiceId
		or fire.pb.npc.NpcServices.BUY_EQUIP == nOpenShopServiceId then
		NpcServiceManager.ReceiveServiceId_openNpcShop(nNpcKey)
		return false
	end

	--shanghui
	if fire.pb.npc.NpcServices.OPEN_SHANGHUI == nOpenShopServiceId then
		NpcServiceManager.ReceiveServiceId_openShangHui(nNpcKey)
		return false
	end

	--pet shop
	if fire.pb.npc.NpcServices.BUY_PET == nOpenShopServiceId then
		NpcServiceManager.ReceiveServiceId_openPetShop(nNpcKey)
		return false
	end

    return true
end


function NpcServiceManager.getCurClickServiceId(vRepeatTaskCommitServiceId,nLastTaskTypeId)
	for k, nRepeatTaskServiceId in pairs(vRepeatTaskCommitServiceId) do 
		local nTableId = nRepeatTaskServiceId
		local record = BeanConfigManager.getInstance():GetTableByName("npc.cnpcservicemapping"):getRecorder(nTableId)
        if nLastTaskTypeId == record.param1  then
			return nTableId
        end
	end
	return -1
end


function NpcServiceManager.getRepeatTaskServiceIdInNpc(vRepeatTaskCommitServiceId, services)
	local nServiceNum = require "utils.tableutil".tablelength(services)

	if nServiceNum <= 0 then return end

	for _, v in pairs(services) do 
		local bSchoolCommit = NpcServiceManager.IsSchoolCommit(v)
		if bSchoolCommit then
			vRepeatTaskCommitServiceId[#vRepeatTaskCommitServiceId + 1] = v
		end
	end
end

function NpcServiceManager.IsOpenShopServiceId(nServiceId)
	if 	fire.pb.npc.NpcServices.BUY_MEDICINE == nServiceId or --
	    fire.pb.npc.NpcServices.BUY_GOODS == nServiceId or --物品
		fire.pb.npc.NpcServices.BUY_EQUIP == nServiceId or --装备
		fire.pb.npc.NpcServices.OPEN_SHANGHUI == nServiceId or --商会
		fire.pb.npc.NpcServices.BUY_PET == nServiceId --宠物
		then
		return true
	end
	return false
end


function NpcServiceManager.IsHaveOpenShopServiceId(services)
	local nServiceNum = require "utils.tableutil".tablelength(services)
	
	if nServiceNum <= 0 then
		return 0
	end
	
	for _, v in pairs(services) do 
		local bOpenShop = NpcServiceManager.IsOpenShopServiceId(v)
		if bOpenShop then
			return v
		end
	end
	return 0
end


function NpcServiceManager.ReceiveServiceId_openPetShop(nNpcKey)
    require("logic.tips.commontipdlg").DestroyDialog()

    local dlg = require("logic.shop.npcpetshop").getInstanceAndShow()
    local bQuickOpenItemId = require("logic.task.taskhelper").GetItemIdInCurTask(nNpcKey)
    local petAttrCfg = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(bQuickOpenItemId)
    if not petAttrCfg then
        return
    end
    dlg:selectGoodsByPetId(bQuickOpenItemId)

    local Taskmanager = require("logic.task.taskmanager")
    Taskmanager.getInstance():setTaskOpenShopType(Taskmanager.eOpenShopType.petshop)
end


function NpcServiceManager.ReceiveServiceId_openNpcShop(nNpcKey)
    require("logic.tips.commontipdlg").DestroyDialog()
	local dlg = require("logic.shop.npcshop").getInstanceAndShow()
	local shopType = require("logic.shop.shopmanager"):getShopTypeByNpcKey(nNpcKey)
	dlg:setShopType(shopType)
	
	local bQuickOpenItemId,nNeedItemNum = require("logic.task.taskhelper").GetItemIdInCurTask(nNpcKey)
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(bQuickOpenItemId)
	if not itemAttrCfg then
		return
	end
	dlg:selectGoodsByItemid(bQuickOpenItemId,nNeedItemNum)
    --------------------------------------------------
    local Taskmanager = require("logic.task.taskmanager")
    Taskmanager.getInstance():setTaskOpenShopType(Taskmanager.eOpenShopType.npcshop)
end

NpcServiceManager.eItemOpenShopType = 
{
	npcShop =1,
	shangHui=2,
	baiTan=3,
	shangCheng=4,
}

function NpcServiceManager.IsHaveBuyTaskItem(nNpcKey)
    local bQuickOpenItemId = require("logic.task.taskhelper").GetItemIdInCurTask(nNpcKey)
    if bQuickOpenItemId == -1 then
        return false
    end
    return true
end


function NpcServiceManager.ReceiveServiceId_openShangHui(nNpcKey)
	require("logic.tips.commontipdlg").DestroyDialog()
	local bQuickOpenItemId,nNeedItemNum = require("logic.task.taskhelper").GetItemIdInCurTask(nNpcKey)

	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(bQuickOpenItemId)
	if not itemAttrCfg then
		require("logic.shop.shoplabel").showCommerce()
		return
	end

	if NpcServiceManager.eItemOpenShopType.shangHui == itemAttrCfg.nshoptype then
        require("logic.shop.shoplabel").getInstance():showOnly(1)
		local commercedlg = require("logic.shop.commercedlg").getInstanceNotCreate()
		if commercedlg then
			commercedlg:selectGoodsByItemid(bQuickOpenItemId,nNeedItemNum)
		end
	elseif NpcServiceManager.eItemOpenShopType.baiTan == itemAttrCfg.nshoptype then
        if itemAttrCfg.special == 1 then  --特殊处理关于兽决的
            require("logic.shop.stalllabel").openStallToBuy()
            StallDlg.getInstance():openCatalog1ById(5)
        else
		    local stalldlg = require("logic.shop.stalllabel").openStallToBuy()
		    if stalldlg then
			    if stalldlg.buyArgs then
				    stalldlg.buyArgs:reset()
			    end
			    stalldlg:selectGoodsCatalogByItemid(bQuickOpenItemId)
		    end
        end

	elseif NpcServiceManager.eItemOpenShopType.shangCheng == itemAttrCfg.nshoptype then
		require("logic.shop.shoplabel").showMallShop()
		local mallshop = require("logic.shop.mallshop").getInstanceNotCreate()
		if mallshop then
			mallshop:selectGoodsByItemid(bQuickOpenItemId,nNeedItemNum)
		end
	end

     --------------------------------------------------
    if NpcServiceManager.eItemOpenShopType.shangHui == itemAttrCfg.nshoptype then
         local Taskmanager = require("logic.task.taskmanager")
        Taskmanager.getInstance():setTaskOpenShopType(Taskmanager.eOpenShopType.shanghui)
	elseif NpcServiceManager.eItemOpenShopType.baiTan == itemAttrCfg.nshoptype then 
		 local Taskmanager = require("logic.task.taskmanager")
        Taskmanager.getInstance():setTaskOpenShopType(Taskmanager.eOpenShopType.baitan)
	elseif NpcServiceManager.eItemOpenShopType.shangCheng == itemAttrCfg.nshoptype then
		 local Taskmanager = require("logic.task.taskmanager")
        Taskmanager.getInstance():setTaskOpenShopType(Taskmanager.eOpenShopType.shangcheng)
	end

end

--[[
function NpcServiceManager.getCurTaskBuyItemQuality(nNpcKey)
	
	local nTaskTypeId = GetMainCharacter():GetGotoTargetPosType()
	local bQuickOpenItemId = require("logic.task.taskhelper").GetItemIdInCurTask(nNpcKey)
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(bQuickOpenItemId)
	if not itemAttrCfg then
		return -1
	end
	
	local pQuest = GetTaskManager():GetSpecialQuest(nTaskTypeId)
	if not pQuest then
		return -1
	end
	local nTaskDetailId = pQuest.questtype
	local nQuality = require("logic.task.taskhelpertable").GetQuality(nTaskDetailId)
	LogInfo("getCurTaskBuyItemQuality"..nQuality)
	return nQuality
	
end
--]]
function NpcServiceManager:AskIfAcceptToMarry(leadername,level)
	--hjw  �ܾ����
	if gGetGameConfigManager():GetConfigValue("refusefriend") == 1 then
		return
	end
	local sb = StringBuilder:new()
	sb:Set("parameter1", leadername)
    local rolelv = ""..level
    if level>1000 then
        local zscs,t2 = math.modf(level/1000)
        rolelv = zscs..""..(level-zscs*1000)
    end
    sb:Set("parameter2", tostring(rolelv))
    local strTitle = MHSD_UTILS.get_resstring(11703)
    local strMsg = sb:GetString(MHSD_UTILS.get_resstring(11702))
    sb:delete()

	gGetMessageManager():AddMessageBox(strTitle, strMsg,
    NpcServiceManager.HandleAcceptToMarry, self,
    NpcServiceManager.HandleRefuseToMarry, self,
        eMsgType_Team, 20000, 0,
        0,nil,MHSD_UTILS.get_resstring(996),MHSD_UTILS.get_resstring(997))
end
function NpcServiceManager:HandleAcceptToMarry(e)--同意结婚
    local p = require("protodef.fire.pb.npc.crespondinvitetomarry"):new()
    p.agree = 1
    LuaProtocolManager:send(p)
	gGetMessageManager():CloseCurrentShowMessageBox()
	return true
end

function NpcServiceManager:HandleRefuseToMarry(e)--拒绝结婚
    local p = require("protodef.fire.pb.npc.crespondinvitetomarry"):new()
    p.agree = 0
    LuaProtocolManager:send(p)
	if e.handled ~= 1 then
		gGetMessageManager():CloseCurrentShowMessageBox()
    end
	return true
end

function NpcServiceManager.isNormalNpcSoundCanPlay(nNpcKey, services, quests)
    local nNormalNpcPlay = 1

    local bOnlyChatType = NpcServiceManager.IsScenarioTaskOnlyAndChatType(nNpcKey, services, quests)
    if bOnlyChatType == false then
        return nNormalNpcPlay
    end

    local nQuestNum = require "utils.tableutil".tablelength(quests)
    if nQuestNum == 0 then
        return nNormalNpcPlay
    end
    local nTaskId = questes[1]

    local missCfg = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(nTaskId)
	if missCfg.id==-1 then
        return nNormalNpcPlay
    end
    if missCfg.vNpcChatSound:size() > 0 then
        return 0
    end
    return nNormalNpcPlay

end

function NpcServiceManager.doScenarioTaskOnlyAndChatType(nNpcKey)

end

function NpcServiceManager.IsScenarioTaskOnlyAndChatType(nNpcKey, services, scenarioquests)
	local servicesSize = require "utils.tableutil".tablelength(services)
	if servicesSize >0 then
        return false 
    end

    local questSize = require "utils.tableutil".tablelength(scenarioquests)
	if questSize ~= 1 then
        return false 
    end
	
	local nScenarioTask = scenarioquests[1]
	local missCfg = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(nScenarioTask)
	if missCfg.id==-1 then
        return false 
    end
	
	local Taskhelperscenario = require "logic.task.taskhelperscenario"
	if missCfg.MissionType ~= Taskhelperscenario.MissionType.npcTalk then 
        return false 
    end
	
	if missCfg.ScenarioInfoNpcConversationList:size() ==0  then
		return false
	end
	if missCfg.ScenarioInfoNpcID:size() ==0  then
		return false
	end

	return true
end

function NpcServiceManager.IsSchoolCommit(nServiceId)
	if nServiceId>= fire.pb.npc.NpcServices.CIRCTASK_SCHOOL_SUBMIT1 and
		nServiceId<= fire.pb.npc.NpcServices.CIRCTASK_SCHOOL_SUBMIT6 then
		return true
	end
	if nServiceId >= 100022 and
	   nServiceId <= 100027 
	then
		return true
	end
	
	return false
end

function NpcServiceManager.IsOnlyHaveOneService(services, scenarioquests)
    local servicesSize = require "utils.tableutil".tablelength(services)
    local questSize = require "utils.tableutil".tablelength(scenarioquests)

	if 	servicesSize == 1 and questSize == 0 then
		return true
	end
	return false
end


function NpcServiceManager.GetFirstServiceIdOnlyHaveService(services, scenarioquests)
    local servicesSize = require "utils.tableutil".tablelength(services)
    local questSize = require "utils.tableutil".tablelength(scenarioquests)
	
	if 	questSize ==0 and servicesSize == 1 then
		return services[1]
	end
	return -1
end

function NpcServiceManager.GetSchoolCommitServiceId(vcServiceId)
	for nIndex=0,vcServiceId:size()-1 do
		local nServiceId = vcServiceId[nIndex]
		local bSchoolCommit = NpcServiceManager.IsSchoolCommit(nServiceId)
		if bSchoolCommit then
			return nServiceId
		end
	end
	return -1
end


function NpcServiceManager.IsAutoCommitService(nServiceId)
	local  serviceCfg = BeanConfigManager.getInstance():GetTableByName("npc.cnpcserverconfig"):getRecorder(nServiceId)
	if serviceCfg and serviceCfg.id ~= -1 then
		if serviceCfg.nautocommit == 1 then
			return true
		end
	end
	return false
end

--1 = accept repeat taskid
--2= commit repeat tsdk
--3=
--[[
Administrator:
0:空服务
1:接循环任务，参数为循环任务类型id。
2:提交循环任务，参数为循环任务类型id。
3:查询循任务次数，参数为循环任务类型id。
4:便捷组队，参数为便捷组队信息表ID
5:循环任务进入战斗服务，参数为循环任务类型id
6：合成道具，填物品合成表里合成ID
7：捉鬼以及考古任务的服务类型参数为循环任务类型
8：英雄试炼任务的服务类型
9：挑战NPC的服务类型
10：副本进入的服务类型（服务参数1填写副本ID）
11:弹出界面服务(后面参数跟界面顺序表id就好了)
12：战斗录像类型
13：突破任务，参数为突破任务ID
14:跳转地图
--]]
function NpcServiceManager.isBianjiezudui(nServiceId)
	local  tab = BeanConfigManager.getInstance():GetTableByName("npc.cnpcservicemapping")
    local serviceTaskTable = tab:getRecorder(nServiceId)
    
	if serviceTaskTable == nil then
		return false
	end
	if serviceTaskTable.type == 4 then
		return true
	end
	return false

end
function NpcServiceManager.isJumpMap(nServiceId)
	local  tab = BeanConfigManager.getInstance():GetTableByName("npc.cnpcservicemapping")
    local serviceTaskTable = tab:getRecorder(nServiceId)
    
	if serviceTaskTable == nil then
		return false
	end
	if serviceTaskTable.type == 14 then
		return true
	end
	return false

end

return NpcServiceManager
