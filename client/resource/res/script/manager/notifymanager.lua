NotifyManager = {}

function NotifyManager.EventLevelChange(level)
    local levelF = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(309).value)
    if level == levelF then
        local creqchargerefundsinfo = require "protodef.fire.pb.fushi.creqchargerefundsinfo".Create()
        LuaProtocolManager.getInstance():send(creqchargerefundsinfo)
    end
    require("logic.xingongnengkaiqi.xingongnengopendlg").CheckNewFeatureByLevel()

    local guidemanager = require "logic.guide.guidemanager".getInstanceNotCreate()

    if guidemanager then
        guidemanager:HasHongdian()
        if LogoInfoDialog.getInstanceNotCreate() then
		    LogoInfoDialog.getInstanceNotCreate():RefreshBtnZhiyin()
	    end 
    end
end

function NotifyManager.HandleGotoFunction(npcid)
	if npcid == 61 then
		if GetTaskManager() then
			local quests = GetTaskManager():GetAcceptableQuestListForLua()
			LogInsane("size="..quests:size())
			local hasQuest = false
			for i = 0, quests:size() - 1 do
				local taskid = quests[i]
				LogInsane("questid="..quests[i])
				local tasktype = GetTaskManager():GetTaskType(taskid)
				if tasktype ~= 0 and tasktype ~= 1 then
					hasQuest = true
					break
				end
			end
			if hasQuest then
				require "logic.task.taskdialog".OpenAcceptQuest()
			else
                local p = require("protodef.fire.pb.mission.activelist.crefreshactivitylistfinishtimes"):new()
	            LuaProtocolManager:send(p)
			end
		end
	elseif npcid == 62 then
--		local quests = GetTaskManager():GetScenarioQuestListForLua()
--		local taskid = 0
--		for i = 0, quests:size() - 1 do
--			local questinfo = quests[i]
--			LogInsane("questid="..questinfo.questid)
--			local cfg = GameTable.mission.GetCFamousTaskTableInstance():getRecorder( questinfo.missionid)
--			if cfg and cfg.id ~= -1 then
--				taskid = questinfo.missionid
--				break
--			end
--		end
	end
	
end


function NotifyManager.SendOpenFactionProtocol()
--	local p = require "protodef.fire.pb.clan.copenclan":new()
--	require "manager.luaprotocolmanager":send(p)
    local p1 = require "protodef.fire.pb.clan.crefreshroleclan":new()
	require "manager.luaprotocolmanager".getInstance():send(p1)
end

return NotifyManager
