
Taskhelperformat = {}


	
function Taskhelperformat.SetSbFormat_CircTask_KillMonster(pQuest,sb)
	local nNpcId = pQuest.dstnpcid
	local nMapId = pQuest.dstmapid
	local strNpcName = pQuest.dstnpcname
	local nTargetNpcId = pQuest.dstitemid
	local nTargetNum = pQuest.dstitemnum
	local nCurKillNum = pQuest.dstx
	
	--local npcConfig = GameTable.npc.GetCNPCConfigTableInstance():getRecorder(nNpcId)
	sb:Set("NPCName",strNpcName)
	local mapcongig = BeanConfigManager.getInstance():GetTableByName("map.cmapconfig"):getRecorder(nMapId)
	sb:Set("MapName",mapcongig.mapName)
	
	sb:Set("Number",tostring(nCurKillNum))
	sb:Set("Number1",tostring(nTargetNum))
	
end


function Taskhelperformat.SetSbFormat_CircTask_ChallengeNpc(pQuest,sb)
	print("Taskhelperformat.SetSbFormat_CircTask_ChallengeNpc(pQuest,sb)")
	local nNpcId = pQuest.dstnpcid
	local nMapId = pQuest.dstmapid
	--local strNpcName = pQuest.dstnpcname
	local nTargetNpcId = pQuest.dstitemid
	--local nTargetNum = pQuest.dstitemnum
	--local nCurKillNum = pQuest.dstx
	
	local npcConfig = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(nNpcId)
    if npcConfig then
	    local strNpcName = npcConfig.name
	    sb:Set("NPCName",strNpcName)
    end
	local mapcongig = BeanConfigManager.getInstance():GetTableByName("map.cmapconfig"):getRecorder(nMapId)
    if mapcongig then
	    sb:Set("MapName",mapcongig.mapName)
    end
	
	--sb:Set("Number",tostring(nCurKillNum))
	--sb:Set("Number1",tostring(nTargetNum))
	
end

--require("logic.task.taskhelperformat").SetSbFormat_CircTask_normal(pQuest,sb)

function Taskhelperformat.SetSbFormat_CircTask_normal(pQuest,sb)
	local nNpcId = pQuest.dstnpcid
	local nMapId = pQuest.dstmapid
	local strNpcName = pQuest.dstnpcname
	--local nTargetNpcId = pQuest.dstitemid
	--local nTargetNum = pQuest.dstitemnum
	--local nCurKillNum = pQuest.dstx
	local nItemId = pQuest.dstitemid
	--//====================================
	local mapcongig = BeanConfigManager.getInstance():GetTableByName("map.cmapconfig"):getRecorder(nMapId)
    if mapcongig then
	    sb:Set("MapName",mapcongig.mapName)
    end
	--//====================================
	if not strNpcName then
		local npcConfig = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(nNpcId)
        if npcConfig then
		    strNpcName = npcConfig.name
        end
	end
	sb:Set("NPCName",strNpcName)
	--//====================================
	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if itemAttrCfg then
	    sb:Set("ItemName", itemAttrCfg.name)
    end
	--//====================================
	
	
	--sb:Set("Number",tostring(nCurKillNum))
	--sb:Set("Number1",tostring(nTargetNum))
	
end

return Taskhelperformat
