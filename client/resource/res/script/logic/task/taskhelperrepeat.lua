
Taskhelperrepeat = {}



	
--[[

enum {
		CircTask_Mail = 1, // 送信
		CircTask_ItemUse = 2, // 道具制造
		CircTask_ItemCollect = 3, // 道具收集
		CircTask_ItemFind = 4, // 寻找道具
		CircTask_PetCatch = 5, // 捕获宠物
		CircTask_Patrol = 6, // 巡逻
		CircTask_CatchIt = 7, // 捉鬼
		CircTask_KillMonster = 8, // 杀怪计数
		CircTask_ChallengeNpc = 9, // 挑战npc
	};
	

	if nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_Mail or
		 nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ItemUse or 
         nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ItemCollect or  
		 nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_Patrol or 
		 nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ItemFind or
		 nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_PetCatch then
		
	end
--]]


function Taskhelperrepeat.GoToRepeatTask(nTaskTypeId)
	local pQuest = GetTaskManager():GetSpecialQuest(nTaskTypeId)
	if not pQuest then
		return 
	end
	local nTaskDetailId = pQuest.questtype
	local nNpcId = Taskhelperschool.GetSchoolTaskNpcId(nTaskTypeId) -- pQuest.dstnpcid
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
	flyWalkData.nTaskTypeId = nTaskTypeId --nTaskTypeId
		flyWalkData.nNpcId = nNpcId
		flyWalkData.nRandX = nRandX
		flyWalkData.nRandY = nRandY
	--//-======================================
	Taskhelpergoto.FlyOrWalkTo(flyWalkData)
end
--[[

	if nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_Mail or
		 nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ItemUse or 
         nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ItemCollect or  
		 nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_Patrol or 
		 nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ItemFind or
		 nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_PetCatch then
		return true
	end
	
--]]

function Taskhelperrepeat.IsRepeatTaskHaveBuff(nTaskTypeId)
	LogInfo("Taskhelperrepeat.IsRepeatTaskHaveBuff(nTaskTypeId)")
	local pQuest = GetTaskManager():GetSpecialQuest(nTaskTypeId)
	if not pQuest then
		return false
	end
	local nTaskDetailId = pQuest.questtype
	local nTaskDetailType = TaskHelper.GetSpecialQuestType2(nTaskDetailId)
	if nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ItemFind and 
		pQuest.dstitemidnum2 > 0 --//have buff
	then
		
		local nChuanShuoBuffId = require("logic.task.taskhelper").ITEM_FIND_LEGEND_BUFF
		local buffManager = require("manager.buffmanager").getInstance()
		local buffData = buffManager:getBuffDataWithId(nChuanShuoBuffId)
		if not buffData then
			LogInfo("Taskhelperrepeat.IsRepeatTaskHaveBuff=not buffData=return false")
			return false
		end
		return true
		
	end
	return false
	
end

--[[
	self.time = 0
	self.count = 0
	self.tipargs = {}
--]]

--[[

--1237 %d年%d月%d日 
--1238 %d时%d分%d秒
--1239 %d分%d秒
--1240 %d小时%d分钟
--1241 %d分钟
--1242 %d小时


11031	类型:
11032	功能:
11033	要求:
11034	生效时间:
11035	过期时间:
11036	道具已过期
11037	镶嵌:
11038	功效:
11039	品质:
11040	坐标:
11041	等级:
11042	摆摊出售
11043	赠送
11044	丢弃

--]]

function Taskhelperrepeat.GetTimeStringWithSecond(nSecond)
	local nMin = math.floor( nSecond /60)
	local strLeftTime = require("utils.mhsdutils").get_resstring(1241)
	strLeftTime = string.format(strLeftTime,nMin)
	return strLeftTime
	--local curTime = string.format("%04d-%02d-%02d %02d:%02d:%02d", year, month, day, hour, minute, second)
end

function Taskhelperrepeat.GetRepeatTaskBuffString(nTaskTypeId)
	LogInfo("Taskhelperrepeat.GetRepeatTaskBuffString(nTaskTypeId)")
	local strResult = ""
	local pQuest = GetTaskManager():GetSpecialQuest(nTaskTypeId)
	if not pQuest then
		return strResult
	end
	local nTaskDetailId = pQuest.questtype
	local nTaskDetailType = TaskHelper.GetSpecialQuestType2(nTaskDetailId)
	
	if nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ItemFind then
		local nChuanShuoBuffId = require("logic.task.taskhelper").ITEM_FIND_LEGEND_BUFF
		local buffManager = require("manager.buffmanager").getInstance()
		local buffData = buffManager:getBuffDataWithId(nChuanShuoBuffId)
		if not buffData then
			return strResult
		end
		local nTimeEnd = buffData.time
		LogInfo("Taskhelperrepeat.=nTimeEnd="..nTimeEnd)
		local nLeftSecond  = nTimeEnd --math.floor( nTimeEnd /1000)
		
		--<T t="在" c="ff6b4226"></T><T t="$MapName$" c="ff00ff00"></T><T t="击杀怪物有概率获得任务物品，剩余时间为" c="ff6b4226"></T><T t="$time$" c="ff6b4226"></T>
		
		local nMapId = require("logic.mapchose.hookmanger").getInstance():GetLevelMapID()
		LogInfo("nMapId="..nMapId)
		local mapCfg = BeanConfigManager.getInstance():GetTableByName("map.cmapconfig"):getRecorder(nMapId)
		local strMapName = mapCfg.mapName
		
		local strTime = Taskhelperrepeat.GetTimeStringWithSecond(nLeftSecond)
		
		
		
		local strBuff = require("utils.mhsdutils").get_resstring(11202)   --11202
		local sb = StringBuilder.new()
		sb:Set("MapName", strMapName)
		sb:Set("time", strTime)
		local strContent = sb:GetString(strBuff)
		sb:delete()
		
		--//===============
		--//===============
		
		strResult = strContent
		LogInfo("Taskhelperrepeat=strResult="..strResult)
		return strResult
		
	end
	return strResult
end

--[[
function Taskhelperrepeat.GetTaskTypeWithBuffId(nBuffId)
	LogInfo("Taskhelperrepeat.GetTaskTypeWithBuffId(nBuffId)")
	local nChuanShuoBuffId = require("logic.task.taskhelper").ITEM_FIND_LEGEND_BUFF
	
	if nBuffId == nChuanShuoBuffId then
		return fire.pb.circletask.CircTaskClass.CircTask_ItemFind
	end
	return -1
end
--]]

function Taskhelperrepeat.RefreshTaskBuffChuanShuo(nBuffId)
	LogInfo("Taskhelperrepeat.RefreshTaskBuffChuanShuo(nBuffId)")
	local tracingDlg = require("logic.task.renwulistdialog").getSingleton()
	if not tracingDlg then
		return 
	end
	
	for nIndex = 1, #tracingDlg.m_mapCells do
		local unitCell = tracingDlg.m_mapCells[nIndex]		
		local nCellId = unitCell.id
		local pQuest = GetTaskManager():GetSpecialQuest(nCellId)
		if pQuest then
			local nTaskDetailId = pQuest.questtype
			local nTaskDetailType = TaskHelper.GetSpecialQuestType2(nTaskDetailId)
			local nTaskTypeId = pQuest.questid
			if nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ItemFind then
				tracingDlg:RefreshCellContentForBuffWithId(nTaskTypeId)
			end			
		end
	end
	
end

function Taskhelperrepeat.addBuff(addedbuffs)
	LogInfo("Taskhelperrepeat.addBuff(addedbuffs)")
	local nChuanShuoBuffId = require("logic.task.taskhelper").ITEM_FIND_LEGEND_BUFF
	
	for nBuffId,v in pairs(addedbuffs) do 
		LogInfo("buffid="..nBuffId)
		if nBuffId==nChuanShuoBuffId then
			
			local taskManager = require("logic.task.taskmanager").getInstance()
			taskManager:addBuff(nBuffId)
		end
	end
end

function Taskhelperrepeat.deleteBuff(deletedBuffs)
	LogInfo("Taskhelperrepeat.deleteBuff(deletedBuffs)")
	local nChuanShuoBuffId = require("logic.task.taskhelper").ITEM_FIND_LEGEND_BUFF
	
	for k,nBuffId in pairs(deletedBuffs) do 
		LogInfo("buffid="..nBuffId)
		if nBuffId==nChuanShuoBuffId then
			
			local taskManager = require("logic.task.taskmanager").getInstance()
			taskManager:deleteBuff(nBuffId)
		end
	end
end
	
return Taskhelperrepeat

