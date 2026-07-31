require "logic.dialog"

ShowTaskDetail = {m_NeedRequestRoleInfo = false}
setmetatable(ShowTaskDetail, Dialog)
ShowTaskDetail.__index = ShowTaskDetail

local _instance
function ShowTaskDetail.getInstance()
	if not _instance then
		_instance = ShowTaskDetail:new()
		_instance:OnCreate()
	end
	return _instance
end

function ShowTaskDetail.getInstanceAndShow()
	if not _instance then
		_instance = ShowTaskDetail:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ShowTaskDetail.getInstanceNotCreate()
	return _instance
end

function ShowTaskDetail.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ShowTaskDetail.ToggleOpenClose()
	if not _instance then
		_instance = ShowTaskDetail:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ShowTaskDetail.GetLayoutFileName()
	return "insetrenwudialog.layout"
end

function ShowTaskDetail:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ShowTaskDetail)
	return self
end

function ShowTaskDetail:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.winMgr = winMgr

    self.name = CEGUI.toRichEditbox(self.winMgr:getWindow("insetrenwudialog/name"))
	self.name:setReadOnly(true)
	self.name:SetBackGroundEnable(false)
	self.name:SetLineSpace(4.0)
	
	self.jianjie = CEGUI.toRichEditbox(self.winMgr:getWindow("insetrenwudialog/jianjie"))
	self.jianjie:setReadOnly(true)
	self.jianjie:SetBackGroundEnable(false)
	self.jianjie:SetLineSpace(4.0)
	
	self.descript = CEGUI.toRichEditbox(self.winMgr:getWindow("insetrenwudialog/text/shuoming"))
	self.descript:setReadOnly(true)
	self.descript:SetBackGroundEnable(false)
	self.descript:SetLineSpace(4.0)

	self.questid = 0
	self.roleid = 0
end
function ShowTaskDetail:ShowTaskAnye(anyeTaskData)
    
    local nLevel =  anyeTaskData.nLevel 
    local nSchoolId = anyeTaskData.nSchool
    local nTaskId = anyeTaskData.id
    local anyeTable = BeanConfigManager.getInstance():GetTableByName("circletask.canyemaxituanconf"):getRecorder(nTaskId)
	if not anyeTable  then
		return 
	end
    local strTaskName = anyeTable.strtaskname
    local strTaskDesc = anyeTable.strtaskdesc
    local strTitleDesc = anyeTable.titledes
    local nGroupId = anyeTable.group

    local nQuality = require("logic.task.taskhelpertable").GetQuality(nSchoolId,nGroupId,nLevel)
    anyeTaskData.nQuality = nQuality

    local sb = StringBuilder:new()
    require("logic.task.taskmanager").getInstance():getTaskInfoCorrectSb(anyeTaskData,sb)
    strTaskDesc = sb:GetString(strTaskDesc)
    require("logic.task.taskmanager").getInstance():getTaskInfoCorrectSb(anyeTaskData,sb)
    strTitleDesc = sb:GetString(strTitleDesc)
    sb:delete()

    self.name:Clear()
	self.name:AppendText(CEGUI.String(strTaskName), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FF50321A")))
	self.name:Refresh()
	self.name:getVertScrollbar():setScrollPosition(0)

	self.jianjie:Clear()
	self.jianjie:AppendParseText(CEGUI.String(strTitleDesc))
	self.jianjie:Refresh()
	self.jianjie:getVertScrollbar():setScrollPosition(0)

	self.descript:Clear()
	self.descript:AppendParseText(CEGUI.String(strTaskDesc))
	self.descript:Refresh()
	self.descript:getVertScrollbar():setScrollPosition(0)

end

function ShowTaskDetail:ShowTask_specialtask(pSpecialQuest, questid, baseid,nRoleLevel,nJobId)
    local pQuest
	if pSpecialQuest ~= 0 then
		pQuest = pSpecialQuest
	else
		pQuest = GetTaskManager():GetSpecialQuest(questid)
	end
    if not pQuest then
        return
    end

    local nTaskDetailId = pQuest.questtype
	local nTaskDetailType = require("logic.task.taskhelper").GetSpecialQuestType2(nTaskDetailId) 

    local repeatCfg = BeanConfigManager.getInstance():GetTableByName("circletask.crepeattask"):getRecorder(nTaskDetailId)
        if not repeatCfg then
            return
        end
	local nGroupId = repeatCfg.ngroupid

    local nMaxNum = require("logic.task.taskhelper").GetRepeatTaskMaxCount(nTaskDetailId)

    local oneTaskData = {}
    oneTaskData.id = questid
    oneTaskData.kind = nTaskDetailType
    oneTaskData.dstnpcid = pQuest.dstnpcid
    oneTaskData.dstitemid = pQuest.dstitemid
    oneTaskData.dstitemnum = pQuest.dstitemnum
    oneTaskData.dstmapid = pQuest.dstmapid
    oneTaskData.nPetId = pQuest.dstitemid

    oneTaskData.nNumber = pQuest.round
    oneTaskData.nNumber1 = nMaxNum

    local nQuality = require("logic.task.taskhelpertable").GetQuality(nJobId,nGroupId,nRoleLevel)
    oneTaskData.nQuality = nQuality

    local sb = StringBuilder:new()
    require("logic.task.taskmanager").getInstance():getTaskInfoCorrectSbForAll(oneTaskData,sb)
    

	local questinfo = BeanConfigManager.getInstance():GetTableByName("circletask.crepeattask"):getRecorder(nTaskDetailId)
    if not questinfo then
        return
    end
	local strTaskName =  sb:GetString(questinfo.strtaskname)
	local strJianjie = sb:GetString(questinfo.strtasktitle)
	local strDescript =  sb:GetString(questinfo.strtaskdes)

    sb:delete()

			self.name:Clear()
			self.name:AppendText(CEGUI.String(""..strTaskName), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FF50321A")))
			self.name:Refresh()
			self.name:getVertScrollbar():setScrollPosition(0)

			self.jianjie:Clear()
			self.jianjie:AppendParseText(CEGUI.String(strJianjie))
			self.jianjie:Refresh()
			self.jianjie:getVertScrollbar():setScrollPosition(0)

			self.descript:Clear()
			self.descript:AppendParseText(CEGUI.String(strDescript))
			self.descript:Refresh()
			self.descript:getVertScrollbar():setScrollPosition(0)

end
--require("logic.task.showtaskdetail").ShowTask(quest, key, baseID,nRoleLevel,nJobId)
function ShowTaskDetail.ShowTask(pSpecialQuest, questid, baseid, nRoleLevel, nJobId, nnRoleId)
	ShowTaskDetail.getInstanceAndShow()

	local pTaskDetail = ShowTaskDetail.getInstanceNotCreate()
    if not pTaskDetail then
        return
    end
	
	local namebox = pTaskDetail.name
	local jianjiebox = pTaskDetail.jianjie
	local descriptbox = pTaskDetail.descript
	
	local sb = StringBuilder:new()

	if baseid == 2 then --special quest
        pTaskDetail:ShowTask_specialtask(pSpecialQuest, questid, baseid,nRoleLevel,nJobId)
	else --1= juqing task
		local pScenarioQuest = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(questid)
		if pScenarioQuest then
			
            if nnRoleId==gGetDataManager():GetMainCharacterID() then
                local questinfo = GetTaskManager():GetScenarioQuest(questid)
			    if questinfo then
				    sb:SetNum("number", questinfo.missionvalue)
                end
            else
                 sb:SetNum("number", 0)
            end

			sb:Set("NAME",gGetDataManager():GetMainCharacterName())

			local strTaskName = pScenarioQuest.MissionName
			local strJianjie = pScenarioQuest.TaskInfoPurposeListA
			local strDescript = pScenarioQuest.TaskInfoDescriptionListA

			namebox:Clear()
			namebox:AppendText(CEGUI.String(""..strTaskName), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FF50321A")))
			namebox:Refresh()
			namebox:getVertScrollbar():setScrollPosition(0)

				jianjiebox:Clear()
				jianjiebox:AppendParseText(CEGUI.String(sb:GetString(strJianjie)))
				jianjiebox:Refresh()
				jianjiebox:getVertScrollbar():setScrollPosition(0)

				descriptbox:Clear()
				descriptbox:AppendParseText(CEGUI.String(sb:GetString(strDescript)))
				descriptbox:Refresh()
				descriptbox:getVertScrollbar():setScrollPosition(0)

		end
	end

	sb:delete()



end


return ShowTaskDetail
