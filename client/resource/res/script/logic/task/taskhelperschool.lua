
Taskhelperschool = {}

--[[

	if nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_Mail or
		 nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ItemUse or 
         nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ItemCollect or  
		 nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_Patrol or 
		 nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ItemFind or
		 nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_PetCatch then
		
	end
--]]


function Taskhelperschool.GoToSchoolTask(nTaskTypeId)
	LogInfo("Taskhelperschool.GoToSchoolTask(nTaskTypeId)")
	local pQuest = GetTaskManager():GetSpecialQuest(nTaskTypeId)
	if not pQuest then
		return 
	end
	local nTaskDetailId = pQuest.questtype
	local nNpcId = require("logic.task.taskhelpernpc").GetRepeatTaskNpcId(nTaskTypeId) -- pQuest.dstnpcid
	local nRandX = 0
	local nRandY = 0
	local repeatCfg = BeanConfigManager.getInstance():GetTableByName("circletask.crepeattask"):getRecorder(nTaskDetailId)
	if repeatCfg.nflytype==1 then --初始点
	elseif repeatCfg.nflytype==2 then --地图随机点 
		nRandX = pQuest.dstx
		nRandY = pQuest.dsty
	end
	local flyWalkData = {}
	Taskhelpergoto.GetInitedFlyWalkData(flyWalkData)
	--//-======================================
		flyWalkData.nTaskTypeId = nTaskTypeId
		flyWalkData.nNpcId = nNpcId
		flyWalkData.nRandX = nRandX
		flyWalkData.nRandY = nRandY
	--//-======================================
	Taskhelpergoto.FlyOrWalkTo(flyWalkData)
end


return Taskhelperschool
