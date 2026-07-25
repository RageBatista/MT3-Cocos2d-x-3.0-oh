

local srenxingcircletask = require "protodef.fire.pb.circletask.srenxingcircletask"
function srenxingcircletask:process()
	require "logic.task.taskhelperprotocol".srenxingcircletask_process(self)
end

local squerycircletaskstate = require "protodef.fire.pb.circletask.squerycircletaskstate"
function squerycircletaskstate:process()
	--require "logic.task"
	require "logic.task.taskhelperprotocol".squerycircletaskstate_process(self)
end


local srefreshspecialqueststate = require "protodef.fire.pb.circletask.srefreshspecialqueststate"
function srefreshspecialqueststate:process()
	require ("logic.task.taskhelperprotocol").srefreshspecialqueststate_process(self)
end  

local srefreshquestdata = require "protodef.fire.pb.circletask.srefreshquestdata"
function srefreshquestdata:process()
	require ("logic.task.taskhelperprotocol").srefreshquestdata_process(self)
end

local srefreshanyedata = require "protodef.fire.pb.circletask.anye.srefreshanyedata"
function srefreshanyedata:process()
	local taskmanager = require("logic.task.taskmanager").getInstance()
    taskmanager.nAnyeTimes = self.times
    taskmanager.nRenxingNum = self.renxins
    taskmanager.nAnyeRewardExp = self.awardexp
    taskmanager.nAnyeRewardSliver = self.awardsilver
    taskmanager.nAnyeRewardGold = self.swardgold
    taskmanager.nnAnyetonpcshijian = self.jointime
    taskmanager.m_nAnyeFollowIndex = self.legendpos + 1
    --require("logic.task.renwulistdialog").refreshAnyeTrack()


    local renwuListDlg = require("logic.task.renwulistdialog").getInstanceNotCreate()
   -- local taskManager = require("logic.task.taskmanager").getInstance()
    local bNeedToNpc =  taskmanager:isAnyeNeedToGotoNpc()
    if bNeedToNpc==false then
       if renwuListDlg then
            if renwuListDlg:isHaveAnyeTrack()==false then
                renwuListDlg:addAnyeTrack()
            else
                require("logic.task.renwulistdialog").refreshAnyeTrack()
            end
       end   
    else
        if renwuListDlg then
            if renwuListDlg:isHaveAnyeTrack()==true then
                renwuListDlg:removeAnyeTrack()
            end
        end
        local taskDlg = require("logic.task.taskdialog").getInstanceNotCreate()
        if taskDlg then
             taskDlg:removeAnyeTaskItem()
        end
    end


    if table.getn(self.anyetasks) ==8 then
        taskmanager.vAnyeTask = {}
        for k,oneTaskData in pairs(self.anyetasks) do
            taskmanager:insertAnyeTask(oneTaskData)
        end

        local dlg = require("logic.anye.anyemaxituandialog").getInstanceNotCreate()
        if dlg then
              dlg:refreshAllCell(true)
        else
              --require("logic.anye.anyemaxituandialog").getInstanceAndShow()
        end        
    else
        local bSuccess = false
        for k,oneTaskData in pairs(self.anyetasks) do
            taskmanager:updateAnyeTask(oneTaskData)
        end
        local dlg = require("logic.anye.anyemaxituandialog").getInstanceNotCreate()
        if dlg then
            dlg:refreshAllCell()
        else
            taskmanager:checkShowAnyeDlgWithCurIndex()
        end
    end

    local strValue = GameTable.common.GetCCommonTableInstance():getRecorder(311).value
    local nAllHuan = tonumber(strValue)

    if nAllHuan==taskmanager.nAnyeTimes then
        local dlg = require("logic.anye.anyemaxituandialog").getInstanceNotCreate()
        if dlg then
            require("logic.anye.anyemaxituandialog").DestroyDialog()
            GetCTipsManager():AddMessageTipById(166112)
        end
        require("logic.task.taskmanager").getInstance().nAnyeCurSelIndex = -1
        local renwuListDlg = require("logic.task.renwulistdialog").getInstanceNotCreate()
        if renwuListDlg then
            renwuListDlg:removeAnyeFollow()
        end
        local taskdialog = require("logic.task.taskdialog").getInstanceNotCreate()
        if taskdialog then
            taskdialog:RemoveAnyeFollowItem()
        end
        return
    end

    local renwuListDlg = require("logic.task.renwulistdialog").getInstanceNotCreate()

    if renwuListDlg then
        --当前的在传说任务，如果是超出0~7（显示范围）外的值，代表当前没有传说任务
        if self.legendpos >=0 and self.legendpos <= 7 then
            --刷新或者新建任务追踪
            renwuListDlg:addOrRefreshAnyeFollow()
        else    
            --删除任务追踪
            renwuListDlg:removeAnyeFollow()

        end
    end
    local taskdialog = require("logic.task.taskdialog").getInstanceNotCreate()
    if taskdialog then
        taskdialog:RemoveAnyeFollowItem()
    end
end

local slengendanyetask = require "protodef.fire.pb.circletask.anye.slengendanyetask"
function slengendanyetask:process()
    GetCTipsManager():AddMessageTipById(166118)
    Anyemaxituandialog.DestroyDialog()
    local data = gGetDataManager():GetMainCharacterData()
	local level = data:GetValue(1230)
    local mapId = 0
    local indexIDs = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getAllID()
	for _, v in pairs(indexIDs) do
		local mapconfig = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(v)
		local minLevel = mapconfig.LevelLimitMin
		local maxlevel = mapconfig.LevelLimitMax
		if  level < maxlevel and level > minLevel or level == maxlevel or level == minLevel then
			mapId = mapconfig.id
		end
	end
    local mapRecord = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(mapId)
	if mapRecord then
		local randX = mapRecord.bottomx - mapRecord.topx
		randX = mapRecord.topx + math.random(0, randX)

		local randY = mapRecord.bottomy - mapRecord.topy
		randY = mapRecord.topy + math.random(0, randY)

		local nTargetPosX = randX
		local nTargetPosY = randY
		
		local flyWalkData = {}
		Taskhelpergoto.GetInitedFlyWalkData(flyWalkData)
		flyWalkData.nMapId = mapId
		--flyWalkData.nNpcId = nNpcId
		flyWalkData.nRandX = randX
		flyWalkData.nRandY = randY
		flyWalkData.bXunLuo = 1
		flyWalkData.nTargetPosX = nTargetPosX
		flyWalkData.nTargetPosY = nTargetPosY
		Taskhelpergoto.FlyOrWalkTo(flyWalkData)
	end
    
end
