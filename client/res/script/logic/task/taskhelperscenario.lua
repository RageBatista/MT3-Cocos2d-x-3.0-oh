Taskhelperscenario = {}

--[[
enum {
		NPC_TALK = 10, // 点击npc，与npc对话
		GIVE_MONEY = 11, // 给予金钱
		GIVE_ITEM = 12, // 给予道具
		GIVE_PET = 13, // 给予宠物
		ANSWER_QUESTION = 17, // 答题
		START_BATTLE = 40, // 开始战斗
	};
--]]
--//给ｎｐｃ物品完成任务
--//scenario task 
Taskhelperscenario.MissionType =
{	
	npcTalk=10,
	commitItemToNpc = 12,
	useItem =22,
	battleItem=32,
	battleCount=34,
	battleKillMonster = 35, --kill monster
	patrol = 60, --xunluo
    xuexijineng = 80,
    
    chuanequip = 90, 
    continueLevelup = 58
}



function Taskhelperscenario.RefreshLastTask(nTaskTypeId)
	--LogInfo("Taskhelperscenario.RefreshLastTask="..nTaskTypeId)
	local missCfg = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(nTaskTypeId)
	if missCfg.id==-1 then
		return bCHandleFlag
	end
	if missCfg.MissionType==Taskhelperscenario.MissionType.useItem then
	elseif missCfg.MissionType==Taskhelperscenario.MissionType.patrol or 
		Taskhelperscenario.MissionType.battleItem==missCfg.MissionType or 
		Taskhelperscenario.MissionType.battleCount==missCfg.MissionType or 
		Taskhelperscenario.MissionType.battleKillMonster==missCfg.MissionType
	then
		Taskhelperscenario.RefreshLastTask_patrol(nTaskTypeId)
	end
end

--[[
enum {
		ABANDON = -2, // 放弃
		UNACCEPT = -1,
		COMMITED = 1, // 已提交
		FAILED = 2, // 任务执行失败 
		FINISHED = 3, // 完成
		PROCESSING = 4, // 进行中
	};
--]]
function Taskhelperscenario.RefreshLastTask_patrol(nTaskTypeId)
	--LogInfo("Taskhelperscenario.RefreshLastTask_patrol="..nTaskTypeId)
	local pScenarioQuest = GetTaskManager():GetScenarioQuest(nTaskTypeId)
	if pScenarioQuest then
		local nQuestState = pScenarioQuest.missionstatus
		if nQuestState ==1 then 
			
			GetMainCharacter():StopPacingMove()
		end
	end
end

--require "logic.task.taskhelpergoto".GotoTaskNpc(nTaskTypeId)
function Taskhelperscenario.OnClickCellGoto_Scenario(nTaskTypeId)
	local missCfg = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(nTaskTypeId)
	if missCfg.id==-1 then
		return false
	end
	--LogInfo(" missCfg="..missCfg.MissionType)
   -- missCfg.MissionType  = 90 --wangbin test

   -- missCfg.MissionType = Taskhelperscenario.MissionType.xuexijineng --wangbin 

	if missCfg.MissionType==Taskhelperscenario.MissionType.useItem then
		Taskhelperscenario.OnClickCellGoto_Scenario_useItem(nTaskTypeId)
		
	elseif missCfg.MissionType==Taskhelperscenario.MissionType.patrol then
		Taskhelperscenario.OnClickCellGoto_Scenario_patrol(nTaskTypeId)
		
    -----------------------------
    elseif Taskhelperscenario.MissionType.xuexijineng == missCfg.MissionType then
        --local Openui = require("logic.openui")
        --Openui.OpenUI(Openui.eUIId.menpaijineng_19)
        require("logic.skill.skilllable").getInstance():ShowOnly(1)    
    ---------------------------------------------------------------------------
    elseif Taskhelperscenario.MissionType.continueLevelup == missCfg.MissionType then
        local msg = require "utils.mhsdutils".get_msgtipstring(193425)
	    GetCTipsManager():AddMessageTip(msg)
        if missCfg.nopuitype == 1 then
            require("logic.openui").OpenUI(missCfg.nuiid)
            return true
        end
    ---------------------------------------------------------------------------
    elseif Taskhelperscenario.MissionType.chuanequip == missCfg.MissionType then
        Taskhelperscenario.chuanzhuangbei(nTaskTypeId)
	else
       
        if missCfg.nopuitype == 1 then
            require("logic.openui").OpenUI(missCfg.nuiid)
            return true
        end
		Taskhelperscenario.OnClickCellGoto_ScenarioAll(nTaskTypeId)
		
	end
	return true
end


function Taskhelperscenario.getEquipKeyInBag(nItemToItemId)
    --local vCommitItemId = {}
    --vCommitItemId[#vCommitItemId + 1] = nItemId
   local nItemKey = require("logic.workshop.workshophelper").GetItemKeyWithTableId(nItemToItemId) 
   if nItemKey ~= -1 then
         return nItemKey,nItemToItemId
   end

	local toItemTable = BeanConfigManager.getInstance():GetTableByName("item.citemtoitem"):getRecorder(nItemToItemId)
    if toItemTable and toItemTable.id ~= -1 then
        local vcItemId = toItemTable.itemsid
        for nIndex=0,vcItemId:size()-1 do
            local nItemIdInTo = vcItemId[nIndex]
            nItemKey = require("logic.workshop.workshophelper").GetItemKeyWithTableId(nItemIdInTo) 
            if nItemKey ~= -1 then
                return nItemKey,nItemIdInTo
            end
        end
    end
    return -1
end

function Taskhelperscenario.chuanzhuangbei(nTaskTypeId)
    local TaskHelper = require "logic.task.taskhelper"
	local missCfg = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(nTaskTypeId)
	if missCfg.id==-1 then
		return 
	end
	
	local nItemToItemId = missCfg.ActiveInfoUseItemID
    --nItemToItemId = 100 --wangbin test
    local nItemKey,nItemId =  Taskhelperscenario.getEquipKeyInBag(nItemToItemId) --require("logic.workshop.workshophelper").GetItemKeyWithTableId(nItemId) 
    if nItemKey == -1 then
        return
    end
    --nItemId = 41600 
    local Taskuseitemdialog = require "logic.task.taskuseitemdialog"
    local nType = Taskuseitemdialog.eUseType.chuanzhuangbei

	local useItemDlg = require "logic.task.taskuseitemdialog".getInstance()
	useItemDlg:SetUseItemId(nItemId,nItemKey,nType)
	
	GetMainCharacter():SetGotoTargetPosType(0)
	GetMainCharacter():SetGotoTargetPos(0,0)

end

function Taskhelperscenario.OnClickCellGoto_ScenarioAll(nTaskTypeId)
	--LogInfo(" Taskhelperscenario.OnClickCellGoto_ScenarioAll(nTaskTypeId)"..nTaskTypeId)

	local missCfg = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(nTaskTypeId)
	if missCfg.id==-1 then
		LogInfo("error=nTaskTypeId="..nTaskTypeId)
		return false
	end
	local nMapId = missCfg.ActiveInfoMapID
	local nNpcId = missCfg.ActiveInfoNpcID

	local nRandX,nRandY = TaskHelper.GetRandPosWithMapId(nMapId)

	local nTargetPosX=0
	local nTargetPosY=0
	
	local npcCfg = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(nNpcId)
	if npcCfg then
		--LogInfo("Taskhelperscenario.OnClickCellGoto_ScenarioAll(nTaskTypeId)= npcCfg.xPos=".. npcCfg.xPos.." npcCfg.yPos"..npcCfg.yPos)
		nTargetPosX = npcCfg.xPos
		nTargetPosY = npcCfg.yPos
		
	else
		nTargetPosX,nTargetPosY = Taskhelperscenario.GetTargetRandXYWithTaskId(nTaskTypeId)
		--LogInfo("Taskhelperscenario.OnClickCellGoto_ScenarioAll(nTaskTypeId)= nTargetPosX=".. nTargetPosX.."nTargetPosY"..nTargetPosY)

	end
	--battleItem=32,
	--battleCount=34,
    local nIsAutoBattle = 0
	if 	Taskhelperscenario.MissionType.battleItem == missCfg.MissionType or 
		Taskhelperscenario.MissionType.battleCount == missCfg.MissionType or 
		Taskhelperscenario.MissionType.battleKillMonster == missCfg.MissionType
	then
        nIsAutoBattle = 1
	end
	local Taskhelpergoto = require "logic.task.taskhelpergoto"
	local flyWalkData = {}
	Taskhelpergoto.GetInitedFlyWalkData(flyWalkData)
	--//==============================
	flyWalkData.nMapId = nMapId
	flyWalkData.nNpcId = nNpcId
	flyWalkData.nRandX = nRandX
	flyWalkData.nRandY = nRandY
    flyWalkData.bXunLuo = nIsAutoBattle
	flyWalkData.nTargetPosX = nTargetPosX
	flyWalkData.nTargetPosY = nTargetPosY
    flyWalkData.nTaskTypeId = nTaskTypeId
	--//==============================
	Taskhelpergoto.FlyOrWalkTo(flyWalkData)	


end

function Taskhelperscenario.GetTargetRandXYWithTaskId(nTaskTypeId)
	--LogInfo("Taskhelperscenario.GetTargetRandXYWithTaskId(nTaskTypeId)")
	local missCfg = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(nTaskTypeId)
	if missCfg.id==-1 then
		return 0
	end
	
	local nWidth = missCfg.ActiveInfoRightPos - missCfg.ActiveInfoLeftPos
	nWidth = nWidth - 1
	if nWidth < 0 then
		nWidth = 0
	end
	local nRandWidth = math.random(0,nWidth)
	local nTargetPosX = missCfg.ActiveInfoLeftPos + nRandWidth
	
	
	--//========================================
	--local nTargetPosY = missCfg.ActiveInfoBottomPos - missCfg.ActiveInfoTopPos
	local nHeight = missCfg.ActiveInfoBottomPos - missCfg.ActiveInfoTopPos
	nHeight = nHeight -1
	if nHeight <0 then
		nHeight =0
	end
	local nRandHeight = math.random(0,nHeight)
	local nTargetPosY = missCfg.ActiveInfoTopPos + nRandHeight
	--LogInfo("missCfg.ActiveInfoLeftPos="..missCfg.ActiveInfoLeftPos)
	--LogInfo("missCfg.ActiveInfoRightPos="..missCfg.ActiveInfoRightPos)
	--LogInfo("missCfg.ActiveInfoTopPos="..missCfg.ActiveInfoTopPos)
	--LogInfo("missCfg.ActiveInfoBottomPos="..missCfg.ActiveInfoBottomPos)
	--LogInfo("Taskhelperscenario.GetTargetRandXYWithTaskId(nTaskTypeId)= nTargetPosX="..nTargetPosX.."nTargetPosY"..nTargetPosY)

	if  nTargetPosX < missCfg.ActiveInfoLeftPos or
		nTargetPosX >= missCfg.ActiveInfoRightPos or
		nTargetPosY < missCfg.ActiveInfoTopPos or
		nTargetPosY >= missCfg.ActiveInfoBottomPos 
		
	 then
		--LogInfo("error=rand")
	end
	return nTargetPosX,nTargetPosY
end


function Taskhelperscenario.isTaskItem(nItemId)
	
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return false
	end
	local nItemType = itemAttrCfg.itemtypeid
	local nFirstType = require "utils.mhsdutils".GetItemFirstType(nItemType) 

	if nFirstType==eItemType_TASKITEM then
		return true
	end
	return false
end

function Taskhelperscenario.OnClickCellGoto_Scenario_useItem(nTaskTypeId)
	--LogInfo("Taskhelperscenario.OnClickCellGoto_Scenario_useItem(nTaskTypeId)="..nTaskTypeId)
	local TaskHelper = require "logic.task.taskhelper"
	local missCfg = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(nTaskTypeId)
	if missCfg.id==-1 then
		--LogInfo("Taskhelperscenario.OnClickCellGoto_Scenario_useItem="..nTaskTypeId)
		return 
	end
	
	--normal item
	local nItemId = missCfg.ActiveInfoUseItemID
	local bTaskItem = Taskhelperscenario.isTaskItem(nItemId)
	if not bTaskItem then
		--Taskhelperscenario.HandleVisitPos_scenaro(nTaskTypeId)
		local useItemDlg = require "logic.task.taskuseitemdialog".getInstance()
		--local nItemId = missCfg.ActiveInfoUseItemID
        local Taskuseitemdialog = require "logic.task.taskuseitemdialog"
        local nType = Taskuseitemdialog.eUseType.taskUseItem
        local nItemKey = 0
		useItemDlg:SetUseItemId(nItemId,nItemKey,nType)
	
		GetMainCharacter():SetGotoTargetPosType(0)
		GetMainCharacter():SetGotoTargetPos(0,0)
		return
	end
	
	
	--//============================================
	--if in area push use card
	local bCanShow =  Taskhelperscenario.canShowUseItemCard(nTaskTypeId)
	if bCanShow then
		Taskhelperscenario.HandleVisitPos_scenaro(nTaskTypeId)	
		return
	end
	--//============================================
	
	--[[
	local nTargetPosX = missCfg.ActiveInfoRightPos - missCfg.ActiveInfoLeftPos
	nTargetPosX = missCfg.ActiveInfoLeftPos + math.random(0, nTargetPosX)
	local nTargetPosY = missCfg.ActiveInfoBottomPos - missCfg.ActiveInfoTopPos
	nTargetPosY = missCfg.ActiveInfoTopPos + math.random(0, nTargetPosY)
	--]]
	local nTargetPosX,nTargetPosY = Taskhelperscenario.GetTargetRandXYWithTaskId(nTaskTypeId)
	
	local nMapId = missCfg.ActiveInfoMapID
	local nRandX,nRandY = TaskHelper.GetRandPosWithMapId(nMapId)
	--GetMainCharacter():SetGotoTargetPos(nTargetPosX,nTargetPosY) --SetGotoTargetPos
	--GetMainCharacter():SetGotoTargetPosType(nTaskTypeId)
	
	local Taskhelpergoto = require "logic.task.taskhelpergoto"
	local flyWalkData = {}
	Taskhelpergoto.GetInitedFlyWalkData(flyWalkData)
	--//==============================
	flyWalkData.nTaskTypeId = nTaskTypeId
	flyWalkData.nMapId = nMapId
	flyWalkData.nTargetPosX = nTargetPosX
	flyWalkData.nTargetPosY = nTargetPosY
	--//==============================
	Taskhelpergoto.FlyOrWalkTo(flyWalkData)	
		
		
end

function Taskhelperscenario.HandleVisitPos_scenaro(nTaskTypeId)
	--LogInfo("Taskhelperscenario.HandleVisitPos_scenaro(nTaskTypeId)="..nTaskTypeId)
	local missCfg = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(nTaskTypeId)
	if missCfg.id==-1 then
		--LogInfo(" error= Taskhelperscenario.HandleVisitPos_scenaro(nTaskTypeId)"..nTaskTypeId)
		return 
	end
	--if missCfg.MissionType~=Taskhelperscenario.MissionType.useItem then
		
	--end
	local bInArea = Taskhelperscenario.IsMainRoleInTaskArea(nTaskTypeId)
	if bInArea==false then
		--LogInfo(" error=Taskhelperscenario.IsMainRoleInTaskArea")
		return
	end
    local Taskuseitemdialog = require "logic.task.taskuseitemdialog"
	local useItemDlg = require "logic.task.taskuseitemdialog".getInstance()
	local nItemId = missCfg.ActiveInfoUseItemID
    local nItemkey = 0
    local nType = Taskuseitemdialog.eUseType.taskUseItem
	useItemDlg:SetUseItemId(nItemId,nItemkey,nType)
	
	GetMainCharacter():SetGotoTargetPosType(0)
	GetMainCharacter():SetGotoTargetPos(0,0)
end

function Taskhelperscenario.canShowUseItemCard(nTaskTypeId)
	--LogInfo("Taskhelperscenario.canShowUseItemCard()")
	local bInArea = Taskhelperscenario.IsMainRoleInTaskArea(nTaskTypeId)
	if bInArea==false then
		--LogInfo(" error=Taskhelperscenario.IsMainRoleInTaskArea")
		return false
	end
	local bHave = Taskhelperscenario.isHaveTaskItem(nTaskTypeId)
	if bHave == false then
		return false
	end
	return true
end

function Taskhelperscenario.isHaveTaskItem(nTaskTypeId)
	local missCfg = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(nTaskTypeId)
	if missCfg.id==-1 then
		return 
	end
	local nItemId = missCfg.ActiveInfoUseItemID
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local nItemNum = roleItemManager:GetItemNumByBaseID(nItemId,fire.pb.item.BagTypes.QUEST)
	if nItemNum==0 then
		--LogInfo(" error=Taskhelperscenario.IsMainRoleInTaskArea=noitem")
		--GetCTipsManager():AddMessageTip("error=Taskhelperscenario.IsMainRoleInTaskArea=no have=nItemId="..nItemId)
		return false
	end
	return true
end

function Taskhelperscenario.IsMainRoleInTaskArea(nTaskTypeId)
	--LogInfo("Taskhelperscenario.IsMainRoleInTaskArea(nTaskTypeId)="..nTaskTypeId)
	local missCfg = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(nTaskTypeId)
	if missCfg.id==-1 then
		return 
	end
	local nItemId = missCfg.ActiveInfoUseItemID
	
	local taskItemCfg = BeanConfigManager.getInstance():GetTableByName("item.ctaskrelative"):getRecorder(nItemId)
	if not taskItemCfg then
		--LogInfo(" error=Taskhelperscenario.IsMainRoleInTaskArea=nitemId="..nItemId)
		return false
	end
	local nUseMapId = taskItemCfg.usemap
	--nUseMapId = 0 
	if nUseMapId==0 then
		--LogInfo("Taskhelperscenario.IsMainRoleInTaskArea(nTaskTypeId)=nUseMapId="..nUseMapId)
		return true --any map
	end
	local nCurMapId = gGetScene():GetMapID()
	if nCurMapId~=nUseMapId then
		--LogInfo(" error=Taskhelperscenario.IsMainRoleInTaskArea=mapid")
		return false
	end
	
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local nItemNum = roleItemManager:GetItemNumByBaseID(nItemId,fire.pb.item.BagTypes.QUEST)
	if nItemNum==0 then
		--LogInfo(" error=Taskhelperscenario.IsMainRoleInTaskArea=noitem")
		GetCTipsManager():AddMessageTip("error=Taskhelperscenario.IsMainRoleInTaskArea=no have=nItemId="..nItemId)
		return false
	end
	
	local loc = GetMainCharacter():GetLogicLocation();
	local nTileX = math.floor(loc.x / 16)
	local nTileY = math.floor(loc.y / 16)
	if  nTileX>=missCfg.ActiveInfoLeftPos and
		nTileX<=missCfg.ActiveInfoRightPos and
		nTileY>=missCfg.ActiveInfoTopPos and
		nTileY<=missCfg.ActiveInfoBottomPos then
		
		--LogInfo(" Taskhelperscenario.IsMainRoleInTaskArea=ok")
		return true
	end
	
	--LogInfo(" error=Taskhelperscenario.IsMainRoleInTaskArea=rect")
	--LogInfo("nTileX="..nTileX)
	--LogInfo("nTileY="..nTileY)
	--LogInfo("missCfg.ActiveInfoLeftPos="..missCfg.ActiveInfoLeftPos)
	--LogInfo("missCfg.ActiveInfoRightPos="..missCfg.ActiveInfoRightPos)
	--LogInfo("missCfg.ActiveInfoTopPos="..missCfg.ActiveInfoTopPos)
	--LogInfo("missCfg.ActiveInfoBottomPos="..missCfg.ActiveInfoBottomPos)
	
	return false
end

function Taskhelperscenario.OnClickCellGoto_Scenario_patrol(nTaskTypeId)
	--LogInfo("Taskhelperscenario.OnClickCellGoto_Scenario_patrol(nTaskTypeId)="..nTaskTypeId)
	local missCfg = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(nTaskTypeId)
	if missCfg.id==-1 then
		return 
	end
	local nMapId = missCfg.ActiveInfoMapID
	local nRandX,nRandY = TaskHelper.GetRandPosWithMapId(nMapId)
	
	local nTargetPosX,nTargetPosY = Taskhelperscenario.GetTargetRandXYWithTaskId(nTaskTypeId)
	nRandX = nTargetPosX
	nRandY = nTargetPosY
	
	--//-======================================
	
	local Taskhelpergoto = require "logic.task.taskhelpergoto"
	local flyWalkData = {}
		Taskhelpergoto.GetInitedFlyWalkData(flyWalkData)
		--//==============================
		flyWalkData.nMapId = nMapId
		flyWalkData.nRandX = nRandX
		flyWalkData.nRandY = nRandY
		flyWalkData.bXunLuo = 1
		--flyWalkData.nXunLuoState = 1
		flyWalkData.nTargetPosX = nTargetPosX
		flyWalkData.nTargetPosY = nTargetPosY
		--//==============================
	Taskhelpergoto.FlyOrWalkTo(flyWalkData)	
end

function Taskhelperscenario.HandleCompleteScenarioQuest_GIVE_ITEM(nTaskTypeId,nNpcKey)
	
	local mainMissCfg = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(nTaskTypeId)
	if mainMissCfg.id == -1 then
		return false
	end
	local nItemId = mainMissCfg.ActiveInfoTargetID

	local commitItemDlg = require "logic.task.taskcommititemdialog".getInstance()
	local nCommitType = 1
	commitItemDlg:SetCommitItemId_scenario(nItemId,nNpcKey,nCommitType,nTaskTypeId) --//1 mainmiss 2=school
	
	return true
end

function Taskhelperscenario.showSelItemToCommitTask(vcItemId,vcItemNum,nTaskTypeId,nNpcKey)
	local vItemId = {}
	local vItemNum = {}
	for nIndex=1,vcItemId:size() do
		vItemId[#vItemId + 1] = vcItemId[nIndex-1]
	end
	for nIndex=1,vcItemNum:size() do
		vItemNum[#vItemNum + 1] = vcItemNum[nIndex-1]
	end
	local chooseDlg = require  "logic.chosepetdialog".getInstance() --debugrequire
	local mainMissCfg = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(nTaskTypeId)
	if mainMissCfg.RewardType==1 then --//item
		chooseDlg:SetSelectItemId(vItemId,vItemNum,nTaskTypeId,nNpcKey)
	elseif  mainMissCfg.RewardType==2 then --//pet
		chooseDlg:SetSelectPetId(vItemId,vItemNum,nTaskTypeId,nNpcKey)
	end
end

return Taskhelperscenario
