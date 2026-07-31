Taskhelpertable = {}

Taskhelpertable.eFubenTaskType = 
{
	eNpcMissionBattle = 1, --//zhandou
	eAnswer =2, --//dati
	eCommitItem =3, --ti jiao wu pin
}

function Taskhelpertable.GetSchoolNeedNum(nTaskTypeId)
	
	local pQuest = GetTaskManager():GetSpecialQuest(nTaskTypeId)
	if pQuest then
		local nTaskDetailId = pQuest.questtype
		local repeatCfg = BeanConfigManager.getInstance():GetTableByName("circletask.crepeattask"):getRecorder(nTaskDetailId)
        if not repeatCfg then
            return
        end
		local nGroupId = repeatCfg.ngroupid
		local nTaskDetailType = require("logic.task.taskhelper").GetSpecialQuestType2(nTaskDetailId)
		if nTaskDetailType== fire.pb.circletask.CircTaskClass.CircTask_ItemFind then 
			local nBuyItemTableId = Taskhelpertable.GetSchoolTaskBuyItemTableId(nGroupId)
			local buyItemCfg = BeanConfigManager.getInstance():GetTableByName("circletask.ccirctaskitemfind"):getRecorder(nBuyItemTableId)
			local nNeedItemNum = buyItemCfg.itemnum
			return nNeedItemNum
		elseif nTaskDetailType== fire.pb.circletask.CircTaskClass.CircTask_PetCatch then
			local nBuyPetTableId = Taskhelpertable.GetSchoolTaskBuyPetTableId(nGroupId)
			local buyPetCfg = BeanConfigManager.getInstance():GetTableByName("circletask.ccirctaskpetcatch"):getRecorder(nBuyPetTableId)
			local nNeedItemNum = buyPetCfg.itemnum
			return nNeedItemNum
		end
	end
	return 0

end

--职业购买物品 物品的数量
function Taskhelpertable.GetSchoolTaskBuyItemTableId(nGroupId)
	local nSchoolId =  gGetDataManager():GetMainCharacterSchoolID()
	local vcId = BeanConfigManager.getInstance():GetTableByName("circletask.ccirctaskitemfind"):getAllID()
    local nCurLevel = GetMainCharacter():GetLevel()
    for i = 1, #vcId do
		local record = BeanConfigManager.getInstance():GetTableByName("circletask.ccirctaskitemfind"):getRecorder(vcId[i])
        if record.levelmax >= nCurLevel and 
		record.levelmin <= nCurLevel and
		(nSchoolId == record.school or record.school==0) and
		nGroupId==record.ctgroup then
            return record.id
        end
    end
	return -1
end

--职业购买宠物 物品的数量
function Taskhelpertable.GetSchoolTaskBuyPetTableId(nGroupId)
	local nSchoolId =  gGetDataManager():GetMainCharacterSchoolID()
	local vcId =  BeanConfigManager.getInstance():GetTableByName("circletask.ccirctaskpetcatch"):getAllID()
    local nCurLevel = GetMainCharacter():GetLevel()
    for i = 1, #vcId do
		local record = BeanConfigManager.getInstance():GetTableByName("circletask.ccirctaskpetcatch"):getRecorder(vcId[i])
        if record.levelmax >= nCurLevel and 
		record.levelmin <= nCurLevel  and
		(nSchoolId == record.school or record.school==0) and
		nGroupId==record.ctgroup then
            return record.id
        end
    end
	return -1
end


function Taskhelpertable.GetRepeatTaskData(nTaskDetailId)
	--[[
	and
			record.levelmax >= level and
			record.levelmin <= level then
            local nMaxNum = record.maxnum
            return nMaxNum
	--]]
	
	local repeatTable = BeanConfigManager.getInstance():GetTableByName("circletask.crepeattask"):getRecorder(nTaskDetailId)
	local nTaskTypeId = repeatTable.eactivetype
	local nGroupId = repeatTable.ngroupid
	
	local vcId =BeanConfigManager.getInstance():GetTableByName("circletask.cschooltask"):getAllID()
    --local level = GetMainCharacter():GetLevel()
    for i = 1, #vcId do
		local nTaskTypeIdInTable = vcId[i]
		local record = BeanConfigManager.getInstance():GetTableByName("circletask.cschooltask"):getRecorder(nTaskTypeIdInTable)
        if nTaskTypeId==record.type and nGroupId==record.levelgroup then --levelgroup todo
			return record
        end
    end
	return nil
end


function Taskhelpertable.GetTaskOpenInLevel(nTaskDetailId)
	local repeatTable = Taskhelpertable.GetRepeatTaskData(nTaskDetailId)
	if not repeatTable then
		return -1
	end
	--local nUserLevel = gGetDataManager():GetMainCharacterLevel()
	local nMinLv = repeatTable.levelmin
	return nMinLv
end

function Taskhelpertable.GetQuality(nSchoolId,nGroupId,nCurlevel)
	
	local vcId =  BeanConfigManager.getInstance():GetTableByName("circletask.ccirctaskitemfind"):getAllID()
    for i = 1, #vcId do
		local nTableId = vcId[i]
		local findItemTable = BeanConfigManager.getInstance():GetTableByName("circletask.ccirctaskitemfind"):getRecorder(nTableId)
        if nCurlevel >= findItemTable.levelmin and
			nCurlevel <= findItemTable.levelmax and
			(nSchoolId == findItemTable.school or findItemTable.school==0) and
			nGroupId == findItemTable.ctgroup 
			
		then
			local nQuality = findItemTable.nqualitya/1000 * nCurlevel
			nQuality = nQuality+0.5
			nQuality = math.floor(nQuality)
			nQuality = nQuality + findItemTable.nqualityb
			return nQuality
			
        end
    end
	
	return -1
end


function Taskhelpertable.getNeedDoublePoint(nTaskTypeId)
	local repeatAllTable = Taskhelpertable.GetRepeatAllTaskTableFirst(nTaskTypeId)
	if not repeatAllTable then
		return -1
	end
	return repeatAllTable.doublepoint
end



function Taskhelpertable.GetRepeatAllTaskTableFirst(nTaskTypeId)
	LogInfo(" Taskhelpertable.GetRepeatAllTaskTableFirst(nTaskTypeId)="..nTaskTypeId)
	local vcId = BeanConfigManager.getInstance():GetTableByName("circletask.cschooltask"):getAllID()
    local nCurLevel = GetMainCharacter():GetLevel()
    for i = 1, #vcId do
		local nTableId = vcId[i]
		local record = BeanConfigManager.getInstance():GetTableByName("circletask.cschooltask"):getRecorder(nTableId)
        if nTaskTypeId==record.type  then
			return record
        end
    end
	return nil
end

function Taskhelpertable.GetSchoolTaskUseItemTableId(nGroupId)
	local nSchoolId =  gGetDataManager():GetMainCharacterSchoolID()
	local vcId = BeanConfigManager.getInstance():GetTableByName("circletask.cschooluseitem"):getAllID()
    local nCurLevel = GetMainCharacter():GetLevel()
    for i = 1, #vcId do
		local taskUseItemCfg = BeanConfigManager.getInstance():GetTableByName("circletask.cschooluseitem"):getRecorder(vcId[i])
        if nGroupId == taskUseItemCfg.nuseitemgroup and
		nCurLevel >= taskUseItemCfg.nlvmin and
		nCurLevel <= taskUseItemCfg.nlvmax and
		(taskUseItemCfg.nschoolid==nSchoolId or taskUseItemCfg.nschoolid==0)
		then
            return taskUseItemCfg.id
        end
    end
	return -1
end









return Taskhelpertable
