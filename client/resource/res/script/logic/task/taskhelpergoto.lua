Taskhelpergoto = {}

function Taskhelpergoto.GetRandPosInMap(nMapId)
	local nPosX
	local nPosY
	local mapSize = {}
	--Nuclear.GetEngine():GetWorld():GetMapSize(mapSize)
	--GameScene::IsMoveBlock new bind
	
	return nPosX,nPosY
end

function Taskhelpergoto.OnClickCellGoto_doRepeatTask(nTaskTypeId)
	
end



function Taskhelpergoto.OnClickCellGoto_killMonster(nTaskTypeId)
	
	LogInfo("TaskHelper.OnClickCellGoto_killMonster(nTaskTypeId)")
	local pQuest = GetTaskManager():GetSpecialQuest(nTaskTypeId)
	if not pQuest then
		--local nTaskDetailId = pQuest.questtype
		return
	end
	local nMapId = 	require("logic.mapchose.hookmanger").getInstance():GetLevelMapID() --pQuest.dstmapid
	local nTaskDetailId = pQuest.questtype
	local nRandX = 0
	local nRandY = 0
	--//-======================================
	local nCurMapId = gGetScene():GetMapID()
	LogInfo("Taskhelpergoto.OnClickCellGoto_killMonster(nTaskTypeId)nCurMapId="..nCurMapId)
	LogInfo("Taskhelpergoto.OnClickCellGoto_killMonster(nTaskTypeId)nMapId="..nMapId)
 
	--//-======================================
			
	local flyWalkData = {}
	Taskhelpergoto.GetInitedFlyWalkData(flyWalkData)
	--//-======================================
	flyWalkData.nMapId = nMapId
	--flyWalkData.nNpcId = nNpcId
	flyWalkData.nRandX = nRandX
	flyWalkData.nRandY = nRandY
	flyWalkData.bXunLuo = 1
	flyWalkData.nTargetPosX = nRandX
	flyWalkData.nTargetPosY = nRandY
	--//-======================================
	Taskhelpergoto.FlyOrWalkTo(flyWalkData)
	return true
end


function Taskhelpergoto.GotoTaskNpc(nTaskTypeId)
	local acceptCfg = BeanConfigManager.getInstance():GetTableByName("mission.cacceptabletask"):getRecorder(nTaskTypeId)
	if acceptCfg.id ==-1 then
		return
	end
	local nNpcId = acceptCfg.destnpcid

    require("logic.task.taskhelper").gotoNpc(nNpcId)
    
end

function Taskhelpergoto.OnClickCellGoto_eCatchIt(nTaskTypeId)
	LogInfo("Taskhelpergoto.OnClickCellGoto_eCatchIt"..nTaskTypeId)
	local pQuest = GetTaskManager():GetSpecialQuest(nTaskTypeId)
	if pQuest then
		local nMapId = pQuest.dstmapid
		local nNpcKey = pQuest.dstnpckey
		local nNpcId = pQuest.dstnpcid
		local nTargetPosX = pQuest.dstx
		local nTargetPosY = pQuest.dsty
		
		local flyWalkData = {}
		Taskhelpergoto.GetInitedFlyWalkData(flyWalkData)
		--//==============================
		flyWalkData.nMapId = nMapId
		flyWalkData.nNpcKey = nNpcKey
		flyWalkData.nNpcId = nNpcId
		flyWalkData.nTargetPosX = nTargetPosX
		flyWalkData.nTargetPosY = nTargetPosY
		--//==============================
		Taskhelpergoto.FlyOrWalkTo(flyWalkData)
	end
	return true
end

function Taskhelpergoto.gotoAcceptTask_eCatchIt(nTaskTypeId)
	local acceptCfg = BeanConfigManager.getInstance():GetTableByName("mission.cacceptabletask"):getRecorder(nTaskTypeId)
	if acceptCfg.id ==-1 then
		return
	end
	local nNpcId = acceptCfg.destnpcid

	local npcCfg = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(nNpcId)
	if not npcCfg then
		return
	end
	local nRandX = npcCfg.xPos
	local nRandY = npcCfg.yPos - 1

	local flyWalkData = {}
	Taskhelpergoto.GetInitedFlyWalkData(flyWalkData)
	--//==============================
	flyWalkData.nRandX = nRandX
	flyWalkData.nRandY = nRandY

	flyWalkData.nNpcId = nNpcId
	--//==============================
	Taskhelpergoto.FlyOrWalkTo(flyWalkData)
end

--unuse
function Taskhelpergoto.AcceptTaskGoto_eCatchIt()
	--[[
	local TaskHelper = require "logic.task.taskhelper"
	local nTaskTypeId = TaskHelper.GetCatchItTaskTypeId()
	Taskhelpergoto.GotoTaskNpc(nTaskTypeId)
	--]]
end

function Taskhelpergoto.AcceptTaskGoto_eBranchTask(nTaskTypeId)
	Taskhelpergoto.GotoTaskNpc(nTaskTypeId)
end

function Taskhelpergoto.OnClickGoToChanllengeActiveNPC(nTaskTypeId)
    local pQuest = GetTaskManager():GetReceiveQuest(nTaskTypeId)
    if pQuest then
		local nMapId = pQuest.dstmapid
		local nNpcKey = pQuest.dstnpckey
		local nNpcId = pQuest.dstnpcid
		
		local flyWalkData = {}
		Taskhelpergoto.GetInitedFlyWalkData(flyWalkData)
		flyWalkData.nMapId = nMapId
		flyWalkData.nNpcKey = nNpcKey
		flyWalkData.nNpcId = nNpcId
		Taskhelpergoto.FlyOrWalkTo(flyWalkData)
	end
	return true
end

function Taskhelpergoto.OnClickCellGoto_CircTask_ChallengeNpc(nTaskTypeId)
	LogInfo("Taskhelpergoto.OnClickCellGoto_CircTask_ChallengeNpc"..nTaskTypeId)
	local pQuest = GetTaskManager():GetSpecialQuest(nTaskTypeId)
	if pQuest then
		local nMapId = pQuest.dstmapid
		local nNpcKey = pQuest.dstnpckey --no key
		local nNpcId = pQuest.dstnpcid
		--local nTargetPosX = pQuest.dstx
		--local nTargetPosY = pQuest.dsty
		
		local flyWalkData = {}
		Taskhelpergoto.GetInitedFlyWalkData(flyWalkData)
		--//==============================
		flyWalkData.nMapId = nMapId
		flyWalkData.nNpcKey = nNpcKey
		flyWalkData.nNpcId = nNpcId
		--flyWalkData.nTargetPosX = nTargetPosX
		--flyWalkData.nTargetPosY = nTargetPosY
		--//==============================
		Taskhelpergoto.FlyOrWalkTo(flyWalkData)
	end
	return true
end

function Taskhelpergoto.OnClickCellGoto_CircTask_normal(nTaskTypeId)
	LogInfo("Taskhelpergoto.OnClickCellGoto_normal"..nTaskTypeId)
	local pQuest = GetTaskManager():GetSpecialQuest(nTaskTypeId)
	if pQuest then
		local nMapId = pQuest.dstmapid
		local nNpcKey = pQuest.dstnpckey
		local nNpcId = pQuest.dstnpcid
		local nTargetPosX = pQuest.dstx
		local nTargetPosY = pQuest.dsty
		
		local flyWalkData = {}
		Taskhelpergoto.GetInitedFlyWalkData(flyWalkData)
		--//==============================
		flyWalkData.nMapId = nMapId
		flyWalkData.nNpcKey = nNpcKey
		flyWalkData.nNpcId = nNpcId
		flyWalkData.nTargetPosX = nTargetPosX
		flyWalkData.nTargetPosY = nTargetPosY
		--//==============================
		Taskhelpergoto.FlyOrWalkTo(flyWalkData)
	end
	return true
end
	


--//点击后职业使用物品
function Taskhelpergoto.GoToSchoolTaskPosUseItem(nQuestTypeId)
	local pQuest = GetTaskManager():GetSpecialQuest(nQuestTypeId)
	if not pQuest then
		return
	end
	local nTaskDetailId = pQuest.questtype
	local repeatCfg = BeanConfigManager.getInstance():GetTableByName("circletask.crepeattask"):getRecorder(nTaskDetailId)
	if repeatCfg.id==-1 then
		return
	end
	
	
	local nTargetPosX = pQuest.dstx --schoolUseItemCfg.nposx
	local nTargetPosY = pQuest.dsty --schoolUseItemCfg.nposy
	local nMapId = pQuest.dstmapid --schoolUseItemCfg.nmapid
	
	local nRandX = 0 --pQuest.dstx
	local nRandY = 0 --pQuest.dsty
	LogInfo("TaskHelper.GoToSchoolTaskPosUseItem=.nQuestTypeId="..nQuestTypeId)
	LogInfo("TaskHelper.GoToSchoolTaskPosUseItem=repeatCfg.nflytype="..repeatCfg.nflytype)
	--if repeatCfg.nflytype==1 then --初始点
	nRandX,nRandY = TaskHelper.GetRandPosWithMapId(nMapId)
	--elseif repeatCfg.nflytype==2 then --地图随机点 
		--nRandX = pQuest.dstx
		--nRandY = pQuest.dsty
	--end
	
	local flyWalkData = {}
		Taskhelpergoto.GetInitedFlyWalkData(flyWalkData)
		--//-======================================
		flyWalkData.nTaskTypeId = nQuestTypeId
		flyWalkData.nMapId = nMapId
		flyWalkData.nRandX = nRandX
		flyWalkData.nRandY = nRandY
		flyWalkData.nTargetPosX = nTargetPosX
		flyWalkData.nTargetPosY = nTargetPosY
		--//-======================================
	Taskhelpergoto.FlyOrWalkTo(flyWalkData)


end


function Taskhelpergoto.flyToNpc(nNpcId)
	local flyWalkData = {}
	Taskhelpergoto.GetInitedFlyWalkData(flyWalkData)
	local npcCfg = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(nNpcId)
	if not npcCfg then
		return
	end	
	--local nTargetPosX = npcCfg.xPos
	--local nTargetPosY = npcCfg.yPos
	local nRandX = npcCfg.xPos
	local nRandY = npcCfg.yPos
	--//==============================
	flyWalkData.nNpcId = nNpcId
	flyWalkData.nRandX = nRandX
	flyWalkData.nRandY = nRandY
	--//==============================
	Taskhelpergoto.FlyOrWalkTo(flyWalkData)
end

function Taskhelpergoto.flyToNpcForHuoDong(nNpcId)
	local flyWalkData = {}
	Taskhelpergoto.GetInitedFlyWalkData(flyWalkData)
	local npcCfg = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(nNpcId)
	if not npcCfg then
		return
	end	
	--local nTargetPosX = npcCfg.xPos
	--local nTargetPosY = npcCfg.yPos
	local nRandX = npcCfg.xPos
	local nRandY = npcCfg.yPos
	--//==============================
	flyWalkData.nNpcId = nNpcId
	flyWalkData.nRandX = nRandX
	flyWalkData.nRandY = nRandY
	--//==============================
	Taskhelpergoto.FlyOrWalkToForHuoDong(flyWalkData)
end



--//=============================================
--//=============================================
--//=========================================
function Taskhelpergoto.GetInitedFlyWalkData(flyWalkData)
	--flyWalkData.nFlyType=0
	flyWalkData.nMapId=0
	flyWalkData.nNpcKey=0
	flyWalkData.nNpcId=0
	flyWalkData.bXunLuo=0
	flyWalkData.nRandX=0
	flyWalkData.nRandY=0
	flyWalkData.nTargetPosX=0
	flyWalkData.nTargetPosY=0
	flyWalkData.nTaskTypeId =0
	flyWalkData.nXunLuoState = 0
end
--//
--//if no mapId then get mapId from npcId
--//if no nTargetPosX get nTargetPosX from npcId
--//if no mapRandX get it from MapId
function Taskhelpergoto.FlyOrWalkTo(flyWalkData)
	if gGetScene()  then
		gGetScene():EnableJumpMapForAutoBattle(false);
	end

	local nMapId = flyWalkData.nMapId
	local nNpcKey = flyWalkData.nNpcKey
	local nNpcId = flyWalkData.nNpcId
	local bXunLuo = flyWalkData.bXunLuo
	local nRandX = flyWalkData.nRandX
	local nRandY = flyWalkData.nRandY
	local nTargetPosX = flyWalkData.nTargetPosX
	local nTargetPosY = flyWalkData.nTargetPosY
	local nTaskTypeId = flyWalkData.nTaskTypeId
	local nXunLuoState = flyWalkData.nXunLuoState
	
	LogInfo("Taskhelpergoto.FlyOrWalkTo(flyWalkData)=nMapId="..nMapId)
	LogInfo("Taskhelpergoto.FlyOrWalkTo(flyWalkData)=nTargetPosX="..nTargetPosX.."y="..nTargetPosY)
	
	--//=============================================
	GetMainCharacter():SetGotoTargetPosType(nTaskTypeId)
    GetMainCharacter():SetGotoTargetPos(0,0)
	
	if nMapId==0 then
		local npcCfg = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(nNpcId)
		if npcCfg then
			nMapId = npcCfg.mapid
		end
	end
	
	--//=============================================
	if nTargetPosX==0 and nTargetPosY==0 then
		
		local npcCfg = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(nNpcId)
		if npcCfg then
			nTargetPosX = npcCfg.xPos
			nTargetPosY = npcCfg.yPos
			LogInfo("Taskhelpergoto.FlyOrWalkTo(flyWalkData)=npcCfg.xPos="..npcCfg.xPos.."y="..npcCfg.yPos)
		end
	end
	--//=============================================	
	if nRandX==0 and nRandY==0 then
		nRandX,nRandY = TaskHelper.GetRandPosWithMapId(nMapId)
	end
	--//=============================================
	
	local nCurMapId = gGetScene():GetMapID()
	if nMapId==nCurMapId then
		if bXunLuo==1 then
			GetMainCharacter():SetRandomPacing()
        else
			GetMainCharacter():SetGotoTargetPos(nTargetPosX,nTargetPosY)
			GetMainCharacter():WalkToPos(nTargetPosX,nTargetPosY,nNpcKey,nNpcId)
		end
	else
		if bXunLuo==1 then
			--GetMainCharacter():SetGotoTargetPos(0,0) --SetGotoTargetPos
			gGetScene():EnableJumpMapForAutoBattle(true)
		end
		
		GetMainCharacter():FlyToPos(nMapId, nRandX, nRandY, nNpcId,nNpcKey,false,nTargetPosX,nTargetPosY)
	end
	
end

function Taskhelpergoto.FlyOrWalkToForHuoDong(flyWalkData)
	if gGetScene()  then
		gGetScene():EnableJumpMapForAutoBattle(false);
	end

	local nMapId = flyWalkData.nMapId
	local nNpcKey = flyWalkData.nNpcKey
	local nNpcId = flyWalkData.nNpcId
	local bXunLuo = flyWalkData.bXunLuo
	local nRandX = flyWalkData.nRandX
	local nRandY = flyWalkData.nRandY
	local nTargetPosX = flyWalkData.nTargetPosX
	local nTargetPosY = flyWalkData.nTargetPosY
	local nTaskTypeId = flyWalkData.nTaskTypeId
	local nXunLuoState = flyWalkData.nXunLuoState
	
	LogInfo("Taskhelpergoto.FlyOrWalkTo(flyWalkData)=nMapId="..nMapId)
	LogInfo("Taskhelpergoto.FlyOrWalkTo(flyWalkData)=nTargetPosX="..nTargetPosX.."y="..nTargetPosY)
	
	--//=============================================
	GetMainCharacter():SetGotoTargetPosType(nTaskTypeId)
    GetMainCharacter():SetGotoTargetPos(0,0)
	
	if nMapId==0 then
		local npcCfg = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(nNpcId)
		if npcCfg then
			nMapId = npcCfg.mapid
		end
	end
	
	--//=============================================
	if nTargetPosX==0 and nTargetPosY==0 then
		
		local npcCfg = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(nNpcId)
		if npcCfg then
			nTargetPosX = npcCfg.xPos
			nTargetPosY = npcCfg.yPos
			LogInfo("Taskhelpergoto.FlyOrWalkTo(flyWalkData)=npcCfg.xPos="..npcCfg.xPos.."y="..npcCfg.yPos)
		end
	end
	--//=============================================	
	if nRandX==0 and nRandY==0 then
		nRandX,nRandY = TaskHelper.GetRandPosWithMapId(nMapId)
	end
	--//=============================================
	
	local nCurMapId = gGetScene():GetMapID()
	if nMapId==nCurMapId then
		if bXunLuo==1 then
			GetMainCharacter():SetRandomPacing()
        else
			GetMainCharacter():FlyToPos(nMapId, nRandX, nRandY, nNpcId,nNpcKey,false,nTargetPosX,nTargetPosY, true)
		end
	else
		if bXunLuo==1 then
			--GetMainCharacter():SetGotoTargetPos(0,0) --SetGotoTargetPos
			gGetScene():EnableJumpMapForAutoBattle(true)
		end
		
		GetMainCharacter():FlyToPos(nMapId, nRandX, nRandY, nNpcId,nNpcKey,false,nTargetPosX,nTargetPosY)
	end
	
end



return Taskhelpergoto
