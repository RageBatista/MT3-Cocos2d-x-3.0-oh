require "logic.dialog"
require "logic.fubenguidedialog"
require "logic.task.renwucell"
require "logic.task.teammemberunit"
require "utils.tableutil"
require "logic.task.taskhelper"

require "protodef.rpcgen.fire.pb.circletask.specialqueststate"
local spcQuestState = SpecialQuestState:new()

local SHOW_TASK = 0
local SHOW_TEAM = 1
local eFlyNull = 0
local eFlyFadeOut = 1
local eFlyFadeIn = 2
local eTaskFlyNull = 0
local eTeamFlyNull = 0
local eTeamFlyFadeOut = 1
local eTeamFlyFadeIn = 2

local function copyv2(v)
	local oneVector = CEGUI.UVector2()
	oneVector.x = v.x
	oneVector.y = v.y
	return oneVector
end


Renwulistdialog = {}
setmetatable(Renwulistdialog, Dialog)
Renwulistdialog.__index = Renwulistdialog
local _instance

local strTitleColor = "ffd729ea" 

function Renwulistdialog.getSingleton()
	return _instance
end

function Renwulistdialog.getInstanceNotCreate()
	return _instance
end


function Renwulistdialog.new()
	LogInsane("Renwulistdialog.new")
	local self = Dialog:new()
	setmetatable(self, Renwulistdialog)
    self:resetData()
	self:OnCreate()

	return self
end

function Renwulistdialog:resetData()
    self.m_fTaskElapsedTimeFadeout = 0
	self.m_eTeamFlyType = eTeamFlyNull
	
	self.m_fTeamElapsedTimeFadein = 0
	self.m_eFlyType = eFlyNull
	self.m_eTaskFlyType = eTaskFlyNull
    self.m_mapCells = {}
	self.m_vTeamMem = {}
	self.m_felapsedTimeFadeout = 0
	self.m_felapsedTimeFadein = 0
	self.cutPage = SHOW_TASK
	self.fUpdateBuffTime = 0
    self.m_eDialogType = {}
	self.m_bEscClose = false
	
    self.m_fTaskElapsedTimeFadein = 0
	self.m_fTeamElapsedTimeFadeout = 0

    self.nRefreshAnyeUICd = 1000
    self.nRefreshAnyeUICdDt =0
end

function Renwulistdialog.getSingletonDialog()
	if _instance == nil then
		_instance = Renwulistdialog.new()
	end
	return _instance
end

function Renwulistdialog.autoDoMainQuest()
	if _instance == nil then
		return
	end
	_instance:OnQuestBtnClickedIMP(GetTaskManager():GetMainScenarioQuestId())
end

function Renwulistdialog.ToggleOpenHide()
	if _instance == nil then
		_instance = Renwulistdialog.new()
	else
		local bVisible = _instance:IsVisible()
		if bVisible then
			_instance:OnClose()
		else
			_instance:SetVisible(true)
		end
	end
end

function Renwulistdialog:addButtonAnimation(button, animationName)
    local animationDef = CEGUI.AnimationManager:getSingleton():getAnimation(animationName)
    if animationDef then
        local animation = CEGUI.AnimationManager:getSingleton():instantiateAnimation(animationDef)
        animation:setTargetWindow(button)
        animation:setSpeed(0.7)
        button.animation = animation
        button:subscribeEvent("MouseButtonDown", function()
            animation:start()
        end, self)
    end
end

function Renwulistdialog:OnCreate()
	
	Dialog.OnCreate(self)
	self:GetWindow():setRiseOnClickEnabled(false)

    local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_hUpdateLastQuest = GetTaskManager().EventUpdateLastQuest:InsertScriptFunctor(Renwulistdialog.RefreshLastTask)
    GetTaskManager():InsertTaskTraceStateChangeNotify(Renwulistdialog.OnTaskTraceStateChangeNotify)

	self.m_pRenwuNode = CEGUI.toScrollablePane(winMgr:getWindow("renwulist_mtg/taskback"))
	local renwuContent = CEGUI.toScrolledContainer(self.m_pRenwuNode:getContentPane())
    if renwuContent then
         renwuContent:setMousePassThroughEnabled(true);
    end

    self.m_pNodeTeam = CEGUI.toScrollablePane(winMgr:getWindow("renwulist_mtg/teamback"));
    self.m_pNodeTeam:setMousePassThroughEnabled(true);
    local teamContent = CEGUI.toScrolledContainer(self.m_pNodeTeam:getContentPane())
    if teamContent then
        teamContent:setMousePassThroughEnabled(true);
    end
	self.m_pNodeTeam:setVisible(false);
  
    self.m_pBgStaShow = winMgr:getWindow("renwulist_mtg");
    self.m_pBgStaShow:setVisible(true);


	self.btnTask = CEGUI.toPushButton(winMgr:getWindow("renwulist_mtg/title/task"))
    self.btnTeam = CEGUI.toPushButton(winMgr:getWindow("renwulist_mtg/title/team"))
	self.btnTask:subscribeEvent("MouseClick", Renwulistdialog.clickTaskBtn, self)
	self.btnTeam:subscribeEvent("MouseClick", Renwulistdialog.clickTeamBtn, self)

    self.btnTask:SetMouseLeaveReleaseInput(false)
    self.btnTeam:SetMouseLeaveReleaseInput(false)

    self.btnTask:EnableClickAni(false)
    self.btnTeam:EnableClickAni(false)

    m_btnYingcang = CEGUI.toPushButton(winMgr:getWindow("renwulist_mtg/title/retract"))
--	self:addButtonAnimation(m_btnYingcang, "xstudyBtnPress")
	m_btnYingcang:subscribeEvent("Clicked", Renwulistdialog.clickYincangBtn, self)

    self.m_pHideStateBack = winMgr:getWindow("renwulist_mtg/main/simple") 
 --   self:addButtonAnimation(m_pHideStateBack, "xstudyBtnPress")	
    self.m_pHideStateBack:setVisible(false)
    self.m_pShowBtn = CEGUI.toPushButton(winMgr:getWindow("renwulist_mtg/main/simple/spread"))
    self.m_pShowBtn:subscribeEvent("Clicked", Renwulistdialog.clickXianshiBtn, self)
    
	self.nodeMainBg = winMgr:getWindow("renwulist_mtg/main");
	self.nodeMainBg:setMousePassThroughEnabled(true);
	self.nodeMainBg:SetDisplaySizeChangePosEnable(false);
	self.nodeMainBg:SetDisplaySizeEnable(false);
	self.nodeMainBg:subscribeEvent("Moved", Renwulistdialog.HandleMoveDialog, self)

	self.m_fMiniHeight = self.nodeMainBg:getPixelSize().height
	self.m_fMiniWidth =  self.nodeMainBg:getPixelSize().width
	self.m_fCurWidth = self.m_fMiniWidth;
	self.m_fMaxHeight = 250

    self.nodeMainBg:subscribeEvent("WindowUpdate", Renwulistdialog.HandleWindowUpdate, self)
    self.m_ShowStateBackInitPos = copyv2(self.m_pBgStaShow:getPosition())
    self.m_TaskBackInitPos = copyv2(self.m_pRenwuNode:getPosition())
    self.m_TeamBackInitPos = copyv2(self.m_pNodeTeam:getPosition())
    self.m_pRenwuNode:setVisible(true)
    
    self.m_pNodeTeam:subscribeEvent("Shown", Renwulistdialog.HandleTeamPaneShown, self)
    self:GetWindow():subscribeEvent("Shown", Renwulistdialog.HandleTeamPaneShown, self)
    
	self.m_pFubenBack = winMgr:getWindow("renwulist_mtg/fuben")
	self.m_pFubenBack:setVisible(false)
    if GetBattleManager() then
	    if GetBattleManager():IsInBattle() then
		    self:SetVisible(false)
	    end
    end

    self.m_bTeamBtnEnable = GetTeamManager():IsOnTeam()
	self.m_hItemNumChangeNotify = gGetRoleItemManager():InsertLuaItemNumChangeNotify(Renwulistdialog.onItemNumNotify)
	
	self.nodeTeamKong = winMgr:loadWindowLayout("teamkuaijiecell.layout", "")
	self.nodeTeamKong:setPosition(self.m_pNodeTeam:getPosition())
	self.nodeTeamKong:setVisible(false)
	winMgr:getWindow("teamkuaijiecell/zudui1"):subscribeEvent("Clicked", self.quickTeamClicked, self)
	winMgr:getWindow("teamkuaijiecell/zudui"):subscribeEvent("Clicked", self.handleCreateTeamClicked, self)
	winMgr:getWindow("renwulist_mtg"):addChildWindow(self.nodeTeamKong)
	
	self.teamApplyTipDot = winMgr:getWindow("renwulist_mtg/title/team/tipdot")
	self.teamApplyTipDot:setVisible(false)

    NotificationCenter.addObserver(Notifi_TeamApplicantChange, Renwulistdialog.handleEventTeamApplyChange)
    NotificationCenter.addObserver(Notifi_TeamListChange, Renwulistdialog.tryRefreshTeamInfo)
    NotificationCenter.addObserver(Notifi_TeamMemberDataRefresh, Renwulistdialog.tryRefreshTeamInfo)
	
	self:transformLeftRightBtnState(false, true)
	self:initTeamPipeiPanel()
	self.m_Fade = 0
end
function Renwulistdialog:addOrRefreshAnyeFollow()
    local taskmanager = require("logic.task.taskmanager").getInstance()
    
    local nStatus = self:getAnyeFollowStatus()
    if nStatus == 1 then
        self:addAnyeFollow()
    elseif nStatus == 2 then
        --self:removeAnyeFollow()
        --self:addAnyeFollow()
        Renwulistdialog.refreshAnyeFollow()
    elseif nStatus == 3 then
        self:removeAnyeFollow()
        self:addAnyeFollow()
    end
    self:RefreshCellYPosition()
    
end
function Renwulistdialog:getAnyeFollowStatus()
    local taskmanager = require("logic.task.taskmanager").getInstance()
    local taskid = 0
   
    for i = 1, #self.m_mapCells do
        local nTaskTypeId = self.m_mapCells[i].id
        local bAnyeTask = require("logic.task.taskhelper").isAnyeTaskId(nTaskTypeId)
		if bAnyeTask then
            taskid = self.m_mapCells[i].id
            break
		end
	end
    --没有任务
    if taskid == 0 then
        return 1
        --有相同任�?
    elseif taskid == taskmanager.vAnyeTask[taskmanager.m_nAnyeFollowIndex].id then
        return 2
    --有不同任�?
    elseif taskid ~= taskmanager.vAnyeTask[taskmanager.m_nAnyeFollowIndex].id then
        return 3
    end
end
function Renwulistdialog:removeAnyeFollow()
    local taskmanager = require("logic.task.taskmanager").getInstance()
   
    for i = 1, #self.m_mapCells do
        local nTaskTypeId = self.m_mapCells[i].id
        local bAnyeTask = require("logic.task.taskhelper").isAnyeTaskId(nTaskTypeId)

		if bAnyeTask then
			self:removeTaskCell(self.m_mapCells[i].id)
            return
		end
	end
end
function Renwulistdialog:addAnyeFollow()
    local TaskHelper = require("logic.task.taskhelper") 
    local taskmanager = require("logic.task.taskmanager").getInstance()
    local nTaskTypeId  = taskmanager.vAnyeTask[taskmanager.m_nAnyeFollowIndex].id
    local newUnit = self:getRenwuCell(nTaskTypeId)

    Renwulistdialog.refreshAnyeFollow()
    if newUnit then
        local nnTimeNow = gGetServerTime()
	    newUnit.nWeightOrder = nnTimeNow

        local oneTrace = require "protodef.rpcgen.fire.pb.mission.trackedmission":new()
        oneTrace.acceptdate = nnTimeNow
        GetTaskManager():AddQuestToTraceList(nTaskTypeId,oneTrace)
    end

    self:RefreshCellYPosition()

end
function Renwulistdialog:getMaxAndMinAnyeTableId()
    local anyeIdMax = 1
    local anyeIdMin = 1
    local indexIDs = BeanConfigManager.getInstance():GetTableByName("circletask.canyemaxituanconf"):getAllID()
    local first = true
    --给每一个道具设置坐标和属�?
	for _, v in pairs(indexIDs) do
        local anyeRecord = BeanConfigManager.getInstance():GetTableByName("circletask.canyemaxituanconf"):getRecorder(v)
        if first then
            anyeIdMax = anyeRecord.id
            anyeIdMin = anyeRecord.id
            first = false
        end
        if anyeRecord then
            if anyeRecord.id > anyeIdMax then
                anyeIdMax = anyeRecord.id
            end
            if anyeRecord.id < anyeIdMin then
                anyeIdMin = anyeRecord.id
            end
        end
    end
    return anyeIdMax,anyeIdMin
end

function Renwulistdialog:isHaveAnyeTrack()
    
    local TaskHelper = require("logic.task.taskhelper") 
    local nTaskTypeId  = TaskHelper.nAnyeTaskTypeId

    for i = 1, #self.m_mapCells do
		if self.m_mapCells[i].id == nTaskTypeId then
			return true
		end
	end
    return false
end

function Renwulistdialog:removeAnyeTrack()
    local TaskHelper = require("logic.task.taskhelper") 
    local nTaskTypeId  = TaskHelper.nAnyeTaskTypeId
    self:removeTaskCell(nTaskTypeId)
end

function Renwulistdialog:refreshAnyeTaskAndUpdateTime()

    local TaskHelper = require("logic.task.taskhelper") 
    local nTaskTypeId  = TaskHelper.nAnyeTaskTypeId
    local newUnit = nil 

    for i = 1, #self.m_mapCells do
		if self.m_mapCells[i].id == nTaskTypeId then
			newUnit = self.m_mapCells[i]
		end
	end


    Renwulistdialog.refreshAnyeTrack()

     if newUnit then
        local nnTimeNow = gGetServerTime()
	    newUnit.nWeightOrder = nnTimeNow

        local oneTrace = require "protodef.rpcgen.fire.pb.mission.trackedmission":new()
        oneTrace.acceptdate = nnTimeNow
        GetTaskManager():AddQuestToTraceList(nTaskTypeId,oneTrace)
    end

    self:RefreshCellYPosition()
end


function Renwulistdialog:addAnyeTrack()
    local TaskHelper = require("logic.task.taskhelper") 
    local nTaskTypeId  = TaskHelper.nAnyeTaskTypeId
    local newUnit = self:getRenwuCell(nTaskTypeId)

    Renwulistdialog.refreshAnyeTrack()

     if newUnit then
        local nnTimeNow = gGetServerTime()
	    newUnit.nWeightOrder = nnTimeNow

        local oneTrace = require "protodef.rpcgen.fire.pb.mission.trackedmission":new()
        oneTrace.acceptdate = nnTimeNow
        GetTaskManager():AddQuestToTraceList(nTaskTypeId,oneTrace)

    end

    self:RefreshCellYPosition()

end
function Renwulistdialog.refreshAnyeFollow()
    local taskmanager = require("logic.task.taskmanager").getInstance()
    local taskData = taskmanager.vAnyeTask[taskmanager.m_nAnyeFollowIndex]
    local taskDataTime = taskmanager.vAnyeTask[taskmanager.m_nAnyeFollowIndex].legendend
    local taskDataStatus =  taskmanager.vAnyeTask[taskmanager.m_nAnyeFollowIndex].legend
    local nTaskTypeId  = taskmanager.vAnyeTask[taskmanager.m_nAnyeFollowIndex].id
    local newUnit = _instance:getRenwuCell(nTaskTypeId)
    local anyeRecord = BeanConfigManager.getInstance():GetTableByName("circletask.canyemaxituanconf"):getRecorder(nTaskTypeId)
    newUnit.pTitle:setText(anyeRecord.followtitle)
    newUnit.pTitle:setProperty("TextColours", "FFFFFF33")
    local strTrackContent = ""
    if taskDataStatus == 2 then
        strTrackContent = anyeRecord.followdes
    elseif taskDataStatus == 3 then
        strTrackContent = anyeRecord.followdessuccess
    elseif taskDataStatus == 4 then
        strTrackContent = anyeRecord.followdesfail
    end
    local sb = StringBuilder.new()
    taskmanager:getTaskInfoCorrectSb(taskData,sb)
    if taskDataStatus == 2 then
	    local data = gGetDataManager():GetMainCharacterData()
	    local level = data:GetValue(1230)
        local mapName = ""
        local indexIDs = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getAllID()
	    for _, v in pairs(indexIDs) do
		    local mapconfig = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(v)
		    local minLevel = mapconfig.LevelLimitMin
		    local maxlevel = mapconfig.LevelLimitMax
		    if  level < maxlevel and level > minLevel or level == maxlevel or level == minLevel then
			    mapName = mapconfig.mapName
		    end
	    end
        sb:Set("mapName10",mapName)
        local serverTime = gGetServerTime()
        local disTime = taskDataTime - serverTime
        if disTime > 0 then
            local strTime = ""
            local min = math.floor((disTime / 1000) / 60)
            local strmin = ""
            if min < 10 then
                strmin = "0"..tostring(min)
            else
                strmin = tostring(min)
            end
    
            local sec = math.floor((disTime / 1000 -  min * 60))
            local strsec = ""
            if sec < 10 then
                strsec = "0"..tostring(sec)
            else
                strsec = tostring(sec)
            end
            sb:Set("time",strmin..":"..strsec)
        else
            sb:Set("time","00:00")
        end
        
    end
    strTrackContent = sb:GetString(strTrackContent)
    sb:delete()
    newUnit.pContent:Clear()
	newUnit.pContent:AppendParseText(CEGUI.String(strTrackContent))
    newUnit.pContent:Refresh()
    newUnit:ResetHeight()
    _instance:RefreshCellYPosition()
	
    
end
function Renwulistdialog.refreshAnyeFollowTime()
    local taskmanager = require("logic.task.taskmanager").getInstance()
    local taskData = taskmanager.vAnyeTask[taskmanager.m_nAnyeFollowIndex]
    local taskDataTime = taskmanager.vAnyeTask[taskmanager.m_nAnyeFollowIndex].legendend
    local taskDataStatus =  taskmanager.vAnyeTask[taskmanager.m_nAnyeFollowIndex].legend
    local nTaskTypeId  = taskmanager.vAnyeTask[taskmanager.m_nAnyeFollowIndex].id
    local newUnit = _instance:getRenwuCell(nTaskTypeId)
    local anyeRecord = BeanConfigManager.getInstance():GetTableByName("circletask.canyemaxituanconf"):getRecorder(nTaskTypeId)
    if not anyeRecord then
        return
    end
    newUnit.pTitle:setText(anyeRecord.followtitle)
    newUnit.pTitle:setProperty("TextColours", "FFFFFF33")
    local strTrackContent = anyeRecord.followdes
    if taskDataStatus == 2 then
        strTrackContent = anyeRecord.followdes
    elseif taskDataStatus == 3 then
        strTrackContent = anyeRecord.followdessuccess
    elseif taskDataStatus == 4 then
        strTrackContent = anyeRecord.followdesfail
    end
    local sb = StringBuilder.new()
    taskmanager:getTaskInfoCorrectSb(taskData,sb)
    if taskDataStatus == 2 then
	    local data = gGetDataManager():GetMainCharacterData()
	    local level = data:GetValue(1230)
        local mapName = ""
        local indexIDs = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getAllID()
	    for _, v in pairs(indexIDs) do
		    local mapconfig = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(v)
		    local minLevel = mapconfig.LevelLimitMin
		    local maxlevel = mapconfig.LevelLimitMax
		    if  level < maxlevel and level > minLevel or level == maxlevel or level == minLevel then
			    mapName = mapconfig.mapName
		    end
	    end
        sb:Set("mapName10",mapName)
        local serverTime = gGetServerTime()
        local disTime = taskDataTime - serverTime
        if disTime > 0 then
            local strTime = ""
            local min = math.floor((disTime / 1000) / 60)
            local strmin = ""
            if min < 10 then
                strmin = "0"..tostring(min)
            else
                strmin = tostring(min)
            end
    
            local sec = math.floor((disTime / 1000 -  min * 60))
            local strsec = ""
            if sec < 10 then
                strsec = "0"..tostring(sec)
            else
                strsec = tostring(sec)
            end
            sb:Set("time",strmin..":"..strsec)
        else
            sb:Set("time","00:00")
        end
        
    end
    strTrackContent = sb:GetString(strTrackContent)
    sb:delete()
    newUnit.pContent:Clear()
	newUnit.pContent:AppendParseText(CEGUI.String(strTrackContent))
    newUnit.pContent:Refresh()
    newUnit:ResetHeight()
end

function Renwulistdialog.refreshAnyeTrack()

    if not _instance then
        return
    end

    local bHave = _instance:isHaveAnyeTrack()
    if not bHave then
        return
    end
     local taskManager = require("logic.task.taskmanager").getInstance()

    local strValue = GameTable.common.GetCCommonTableInstance():getRecorder(311).value
    local nAllHuan = tonumber(strValue)

    local TaskHelper = require("logic.task.taskhelper") 
    local nTaskTypeId  = TaskHelper.nAnyeTaskTypeId

    
    if nAllHuan==taskManager.nAnyeTimes then
        _instance:removeTaskCell(nTaskTypeId)
        return
    end

    local nAllLun = nAllHuan/8
    local nCurHuan = taskManager.nAnyeTimes + 1
    local nCurLun  = math.floor((nCurHuan-1)/8) + 1
    local newUnit = _instance:getRenwuCell(nTaskTypeId)
    newUnit.pTitle:setProperty("TextColours", "FFFFFF33")
    local strTrackName = require("utils.mhsdutils").get_resstring(11500)
    local sb = StringBuilder.new()
    sb:Set("parameter1",tostring(nCurLun))
    sb:Set("parameter2",tostring(nAllLun))
    strTrackName = sb:GetString(strTrackName)
    sb:delete()
    newUnit.pTitle:setText(strTrackName)

	local strTrackContent =  require("utils.mhsdutils").get_resstring(11501)
    local sb2 = StringBuilder.new()
    sb2:Set("parameter1",tostring(nCurHuan))
    sb2:Set("parameter2",tostring(nAllHuan))
    strTrackContent = sb2:GetString(strTrackContent)
    sb2:delete()
	--//==========================================
    newUnit.pContent:Clear()
	newUnit.pContent:AppendParseText(CEGUI.String(strTrackContent))
    newUnit.pContent:Refresh()
    newUnit:ResetHeight()
    _instance:RefreshCellYPosition()
	
    
   

end

function Renwulistdialog:quickTeamClicked(args)
	require('logic.team.teammatchdlg').getInstanceAndShow()
end

-- 创建队伍
function Renwulistdialog:handleCreateTeamClicked(arg)
    GetTeamManager():RequestCreateTeam()
    local setting = GetTeamManager():GetTeamMatchInfo()
    if setting.targetid ~= 0 then
        local p = require('protodef.fire.pb.team.crequestsetteammatchinfo').Create()
        p.targetid = setting.targetid
        p.levelmin = setting.minlevel
        p.levelmax = setting.maxlevel
        LuaProtocolManager:send(p)
    end
end



function Renwulistdialog:showOnly(wnd)
	print("Renwulistdialog:showOnly(wnd)")
	self.m_pRenwuNode:setVisible( self.m_pRenwuNode == wnd )
	self.m_pNodeTeam:setVisible( self.m_pNodeTeam == wnd)
	self.tabPipeiNode.window:setVisible( self.tabPipeiNode.window == wnd )
	self.nodeTeamKong:setVisible( self.nodeTeamKong == wnd )
	self.m_pFubenBack:setVisible( self.m_pFubenBack == wnd )
	
	self:transformLeftRightBtnState(not (self.m_pRenwuNode == wnd or self.m_pFubenBack == wnd ), not (self.m_pNodeTeam == wnd or self.nodeTeamKong == wnd or self.tabPipeiNode.window == wnd))
end

function Renwulistdialog:initTeamPipeiPanel()
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.tabPipeiNode = {}
	self.tabPipeiNode.window = winMgr:loadWindowLayout("teampipeicell.layout", "")
	self.tabPipeiNode.window:setPosition(self.m_pNodeTeam:getPosition())
	self.tabPipeiNode.targetName = winMgr:getWindow("teampipeicell/xingdongmubiao")
	winMgr:getWindow("renwulist_mtg"):addChildWindow(self.tabPipeiNode.window)
	local btnStopPipei = winMgr:getWindow("teampipeicell/stopMatch")
	btnStopPipei:subscribeEvent("Clicked", Renwulistdialog.handleStopMatchClicked, self)
    NotificationCenter.addObserver(Notifi_TeamAutoMatchChange, Renwulistdialog.handleEventAutoMatchChange)
	self:refreshTeamPipeiPanel()
end

function Renwulistdialog:transformLeftRightBtnState( stateOne, stateTwo )
	
    local strTeam1 = "set:ccui1 image:newdwc2"
    local strTeam2 = "set:ccui1 image:newdwc1"
    local strTask1 = "set:ccui1 image:newrwc2"
    local strTask2 = "set:ccui1 image:newrwc1"

	if stateTwo then
		self.btnTeam:setProperty("NormalImage", strTeam2)
    	self.btnTeam:setProperty("PushedImage", strTeam1)
	else
		self.btnTeam:setProperty("NormalImage", strTeam1)
    	self.btnTeam:setProperty("PushedImage", strTeam2)
	end
    if stateOne then
		self.btnTask:setProperty("NormalImage", strTask2)
    	self.btnTask:setProperty("PushedImage",strTask1)
	else 
		self.btnTask:setProperty("NormalImage", strTask1)
    	self.btnTask:setProperty("PushedImage", strTask2)
	end
end

function Renwulistdialog:refreshTeamPipeiPanel()
    local bOnTeam = GetTeamManager():IsOnTeam()
    local bPipeizhong = GetTeamManager():IsMatching()
	if self.nShowType == SHOW_TEAM then
		if not bOnTeam then
			if bPipeizhong then
				self:showOnly(self.tabPipeiNode.window)
				local pipeiData = GetTeamManager():GetTeamMatchInfo()
				if pipeiData and pipeiData.targetid ~= 0 then
                    local nTabId = pipeiData.targetid
					local teamListTable = BeanConfigManager.getInstance():GetTableByName(CheckTableName("team.cteamlistinfo")):getRecorder(nTabId)
					self.tabPipeiNode.targetName:setText(teamListTable.target)
				else
					self.tabPipeiNode.targetName:setText(MHSD_UTILS.get_resstring(3148))
				end
			else
				self:showOnly(self.nodeTeamKong)
			end
		else
			self:showOnly(self.m_pNodeTeam)
		end
	else
		self:showOnly(self.m_pRenwuNode)
	end
end

function Renwulistdialog.handleEventAutoMatchChange()
	if _instance then
		_instance:refreshTeamPipeiPanel()
	end
end

function Renwulistdialog:handleStopMatchClicked(args)
	GetTeamManager():StopTeamMatch()
	if not GetTeamManager():IsOnTeam() then
		self:showOnly(self.nodeTeamKong)
	else
		self:showOnly(self.m_pNodeTeam)
	end
end

function Renwulistdialog.RefreshLastTask(nTaskTypeId)
	local self = _instance
	if self == nil then
		return
	end
	local nnRecTime = GetTaskManager():GetQuestTraceTime(nTaskTypeId)
	self:refreshAllTask(nTaskTypeId, nnRecTime)
end

function Renwulistdialog:count(taskid)
	local x = 0
	for i = 1, #self.m_mapCells do
		if self.m_mapCells[i].id == taskid then
			x = x + 1
		end
	end
	return x
end

--//add task  delete task
function Renwulistdialog.OnTaskTraceStateChangeNotify(questid)
	local self = _instance
	if self == nil then
		return
	end
	
	local bTrace = GetTaskManager():IsQuestInTraceList(questid)
	if not bTrace and self:count(questid) > 0 then
		self:removeTaskCell(questid)
	elseif bTrace and self:count(questid) == 0 then
		local tracetime = GetTaskManager():GetQuestTraceTime(questid)
		local quest = GetTaskManager():GetSpecialQuest(questid)
		if quest then
			self:addRepeatTask(quest, tracetime)
		else
			local quest = GetTaskManager():GetScenarioQuest(questid)
			if quest then
				self:AddScenarioQuestItem(quest, tracetime)
			else
				local pActiveQuest = GetTaskManager():GetReceiveQuest(questid)
				if pActiveQuest then
					self:addRenwuCell(pActiveQuest, tracetime)
				end
			end
		end
	end
	
	local nTaskTypeId = questid
	TaskHelper.RefreshLastTask(nTaskTypeId)
end

function Renwulistdialog.showFubenTaskPanel()
    if not _instance then
        return
    end
    _instance.nShowType = SHOW_TASK
    _instance:showOnly(_instance.m_pFubenBack)
 
end

function Renwulistdialog:ShowSmallTaskDialog()
    if self.m_bJingying == true then
        return 
    end

	if not	self.m_pRenwuNode:isVisible()  then
		self:transformLeftRightBtnState(false, true)
		self.nShowType = SHOW_TASK
		self.m_pNodeTeam:setVisible(false)
		self.tabPipeiNode.window:setVisible(false)
		self.nodeTeamKong:setVisible(false)
        self.m_pRenwuNode:setVisible(true)
	end
end

function Renwulistdialog:clickTaskBtn(e)
	self:transformLeftRightBtnState(false, true)
	self.nShowType = SHOW_TASK
	if self.m_pRenwuNode:isVisible() then
        if CChatOutputDialog.getInstanceNotCreate() then
            CChatOutputDialog.getInstanceNotCreate():OnClose()	
        end

		
		require "logic.task.tasklabel".Show(1)
		return
    end
	self.m_pNodeTeam:setVisible(false)
	self.tabPipeiNode.window:setVisible(false)
	self.nodeTeamKong:setVisible(false)
	if self.m_pRenwuNode:isVisible() or (self.m_bJingying and self.m_pFubenBack:isVisible()) or (self.bIsFu and self.m_pFubenBack:isVisible()) then
        if gGetDataManager():GetMainCharacterLevel() <= 10 then
            self.m_eTaskFlyType = eTaskFlyNull
			self.m_pFubenBack:setVisible(false)
        else
        end        
		require "logic.task.tasklabel".Show(1)
	else
        if self.m_bJingying or self.bIsFu then
			self:showOnly(self.m_pFubenBack)
		else
            self.m_pRenwuNode:setVisible(true)
        end
	end
	return true;
end


function Renwulistdialog:clickTeamBtn(e)
	self.m_pFubenBack:setVisible(false)
	
	self:transformLeftRightBtnState(true, false)
    self.m_eTaskFlyType = 0
    self.m_fTaskElapsedTimeFadein = -1
	if CChatOutputDialog.getInstanceNotCreate() then
            CChatOutputDialog.getInstanceNotCreate():OnClose()	
   end
	
	if self.nShowType == SHOW_TEAM then
		require('logic.team.teamdialognew').getInstanceAndShow()
	else
		self.nShowType = SHOW_TEAM
		if not GetTeamManager():IsOnTeam() then
			if GetTeamManager():IsMatching() then
				self:showOnly(self.tabPipeiNode.window)
			else
				self:showOnly(self.nodeTeamKong)
			end
			require('logic.team.teamdialognew').getInstanceAndShow()
		elseif self.m_bTeamBtnEnable then
			self.m_pRenwuNode:setVisible(false)
			self.m_pFubenBack:setVisible(false)
			if self.m_pNodeTeam:isVisible() then
				self.m_eTeamFlyType = eTeamFlyFadeOut
				self.m_fTeamElapsedTimeFadeout = 1/3
			else
				self:showOnly(self.m_pNodeTeam)
				self.m_eTeamFlyType = eTeamFlyFadeIn
				self.m_fTeamElapsedTimeFadein = 1/3
				self.tryRefreshTeamInfo()
			end
            if NewRoleGuideManager.getInstance():getCurGuideId() == 33180 then
                require('logic.team.teamdialognew').getInstanceAndShow()
            end
		end
	end
	return true;
end


function Renwulistdialog:clickYincangBtn(e)
	self.m_eFlyType= eFlyFadeOut
    self.m_felapsedTimeFadeout = 1/3
	self.m_Fade = 1
    return true
end
function Renwulistdialog:clickXianshiBtn(e)
	self.m_eFlyType= eFlyFadeIn
    self.m_felapsedTimeFadein = 1/3
    self.m_pHideStateBack:setVisible(false)
	self.nTypeFad = 0
    return true
end

function Renwulistdialog:HideAllDialogEx()
	if self.nTypeFad == 1 then
		return
	end
	if self.m_eFlyType == eFlyFadeOut then
		return
	end
	self.m_eFlyType= eFlyFadeOut
    self.m_felapsedTimeFadeout = 1 / 3
	self.nTypeFad = 2
end
function Renwulistdialog:ShowDialogEx()
	if self.nTypeFad ~= 2 then
		return		
	end
	self.m_eFlyType= eFlyFadeIn
    self.m_felapsedTimeFadein = 1 / 3
    self.m_pHideStateBack:setVisible(false)
	self.nTypeFad = 0
end

function Renwulistdialog:OnQuestBtnClickedIMP(taskid)
	for nIndex = 1, #self.m_mapCells do
		if self.m_mapCells[nIndex].id == taskid then
			self.m_mapCells[nIndex]:OnGoToClicked()
			break
		end
	end
end
function Renwulistdialog:HandleMoveDialog(e)
	local ptTopLeft= self.nodeMainBg:GetScreenPos();
	local ptRightBottm = CEGUI.Vector2()
	ptRightBottm.x = ptTopLeft.x+self.nodeMainBg:getPixelSize().width
	ptRightBottm.y = ptTopLeft.y+self.nodeMainBg:getPixelSize().height  --ptTopLeft.d_y+nodeMainBg:getPixelSize().height  --by ligeng
	local ScreenSize = CEGUI.System:getSingleton():getGUISheet():getPixelSize()
	local bChange = false
	if ptTopLeft.x > (ScreenSize.width-30) then
		ptTopLeft.x = ScreenSize.width-30
		bChange=true;
	end
	if ptTopLeft.y > (ScreenSize.height-30) then
		ptTopLeft.y = ScreenSize.height-30
		bChange = true
	end
	if ptTopLeft.y < 30 then
		ptTopLeft.y= 30
		bChange=true;
	end
	if ptTopLeft.x<0 then
		ptTopLeft.x=0;
		bChange=true;
	end
	if bChange then
		local newLeftTop = CEGUI.UVector2(
			CEGUI.UDim(1,ptTopLeft.x-ScreenSize.width),
			CEGUI.UDim(0, ptTopLeft.y))
		self.nodeMainBg:setPosition(newLeftTop)
	end
	return true;
end
function Renwulistdialog:HandleWindowUpdate(e)
	
	local args = CEGUI.toUpdateEventArgs(e)
    local m_eFlyType = self.m_eFlyType
    if m_eFlyType == eFlyFadeOut then
        local width = self.m_pBgStaShow:getPixelSize().width
        if self.m_felapsedTimeFadeout > 0 then
            self.m_felapsedTimeFadeout = self.m_felapsedTimeFadeout - args.d_timeSinceLastFrame
            self.m_pBgStaShow:setXPosition(CEGUI.UDim(0,width * (1/3-self.m_felapsedTimeFadeout)*3))
        else
            self.m_eFlyType = eFlyNull
            self.m_felapsedTimeFadeout = 0
            self.m_pBgStaShow:setPosition(self.m_ShowStateBackInitPos)
            self.m_pBgStaShow:setVisible(false)
            self.m_pHideStateBack:setVisible(true)
        end
        self.m_pBgStaShow:invalidate()
    end
    if m_eFlyType == eFlyFadeIn then
        local width = self.m_pBgStaShow:getPixelSize().width
        
        self.m_felapsedTimeFadein = self.m_felapsedTimeFadein - args.d_timeSinceLastFrame
        
        if self.m_felapsedTimeFadein > 0 then
           local curPosX = width*self.m_felapsedTimeFadein*3
           
            self.m_pBgStaShow:setXPosition(CEGUI.UDim(0,curPosX))
            self.m_pBgStaShow:setVisible(true)
        else
            self.m_eFlyType = eFlyNull
            self.m_felapsedTimeFadein = 0
            self.m_pBgStaShow:setPosition(self.m_ShowStateBackInitPos)
        end
        self.m_pBgStaShow:invalidate()
    end
    if self.m_eTeamFlyType == eTeamFlyFadeOut then
        local height = self.nodeMainBg:getPixelSize().height
        if self.m_fTeamElapsedTimeFadeout > 0 then
            self.m_fTeamElapsedTimeFadeout = self.m_fTeamElapsedTimeFadeout - args.d_timeSinceLastFrame
            self.m_pNodeTeam:setYPosition(self.m_TeamBackInitPos.y + 
            	CEGUI.UDim(0, -height*(1.0/3-self.m_fTeamElapsedTimeFadeout)*3));
        else
            self.m_eTeamFlyType = eTeamFlyNull
            self.m_fTeamElapsedTimeFadeout = 0
            self.m_pNodeTeam:setPosition(self.m_TeamBackInitPos)
            self.m_pNodeTeam:setVisible(false);
			self.tabPipeiNode.window:setVisible(false)
			self.nodeTeamKong:setVisible(false)
        end
        self.m_pNodeTeam:invalidate()
    end
    
    if self.m_eTeamFlyType == eTeamFlyFadeIn then
        local height = self.nodeMainBg:getPixelSize().height
        self.m_fTeamElapsedTimeFadein = self.m_fTeamElapsedTimeFadein - args.d_timeSinceLastFrame
        if self.m_fTeamElapsedTimeFadein > 0 then     
            self.m_pNodeTeam:setYPosition(self.m_TeamBackInitPos.y + 
            	CEGUI.UDim(0,-height*self.m_fTeamElapsedTimeFadein*3));
        else
            self.m_eTeamFlyType = eTeamFlyNull
            self.m_fTeamElapsedTimeFadein = 0
            self.m_pNodeTeam:setPosition(self.m_TeamBackInitPos)
        end
        self.m_pNodeTeam:invalidate()
    end
    return true
end

function Renwulistdialog:HandleTeamPaneShown(e)
	self.tryRefreshTeamInfo()
	return true
end


function Renwulistdialog.trySetVisibleFalse()
	if _instance == nil then 
		return
	end
	_instance:SetVisible(false)
    local dlg =  TeamMemberMenu.getInstanceNotCreate()
	if dlg and dlg:IsVisible() then
        dlg:SetVisible(false)
    end
end

function Renwulistdialog.trySetVisibleTrue()
	if _instance == nil then 
		return
	end
	_instance:SetVisible(true)
end

function Renwulistdialog:ClearTeamInfo()
	for nIndex = 1, TableUtil.tablelength(self.m_vTeamMem) do
		local item = self.m_vTeamMem[nIndex]
		self.m_pNodeTeam:removeChildWindow(item.pWnd)
		CEGUI.WindowManager:getSingleton():destroyWindow(item.pWnd)
		self.m_vTeamMem[nIndex] = nil
	end
end

function Renwulistdialog.tryRefreshTeamInfo()
	
	if _instance == nil or GetTeamManager() == nil then 
		return
	end
	local self = _instance
    local dlg =  TeamMemberMenu.getInstanceNotCreate()
	if dlg and dlg:IsVisible() then
        dlg:SetVisible(false)
    end

	self.m_bTeamBtnEnable = GetTeamManager():IsOnTeam()

    if not GetTeamManager():IsOnTeam() and self.nShowType == SHOW_TEAM then
		self:ClearTeamInfo()
		self:showOnly(self.nodeTeamKong)
		self.teamApplyTipDot:setVisible(false)
        return
    end 
    local list = GetTeamManager():GetMemberList()
    for nIndex = 1, #list do
    	if nIndex > 5 then
    		break
    	end
		
		local pTeamMem = self.m_vTeamMem[nIndex]
		if not pTeamMem then
			pTeamMem = TeamMemberUnit.new()
			self.m_pNodeTeam:addChildWindow(pTeamMem.pWnd);
			local height = pTeamMem.pWnd:getPixelSize().height
			pTeamMem.pWnd:setYPosition(CEGUI.UDim(0, (nIndex-1)*(height+1)))
			table.insert(self.m_vTeamMem, pTeamMem)
		end
		pTeamMem:init(list[nIndex].id, list[nIndex].HP, list[nIndex].MaxHP, list[nIndex].MP, list[nIndex].MaxMP, list[nIndex].level, list[nIndex].strName, list[nIndex].shapeID, list[nIndex].eSchool)

        if list[nIndex].eMemberState == eTeamMemberAbsent then
            pTeamMem.pMark:setProperty("Image", "set:ccui1 image:dwzlcell")
        elseif list[nIndex].eMemberState == eTeamMemberFallline then
            pTeamMem.pMark:setProperty("Image", "set:ccui1 image:dwlxcell")
		else
			pTeamMem.pMark:setProperty("Image", "")
        end

        if GetTeamManager():GetTeamLeader().id == list[nIndex].id then
            pTeamMem.pMark:setProperty("Image", "set:ccui1 image:tm")-----队长暂时不显示
        end
        
    end

	if #self.m_vTeamMem > #list then
		for nIndex=#list+1, #self.m_vTeamMem do
			local item = self.m_vTeamMem[nIndex]
			self.m_pNodeTeam:removeChildWindow(item.pWnd)
			CEGUI.WindowManager:getSingleton():destroyWindow(item.pWnd)
			self.m_vTeamMem[nIndex] = nil	
		end
	end
 
end

function Renwulistdialog.tryShowTeamPane()
	
	if _instance == nil then 
		return
	end
	local self = _instance
	
	self.m_pRenwuNode:setVisible(false)
	self.m_pFubenBack:setVisible(false)

	if not self.m_pNodeTeam:isVisible() then
		self:showOnly(self.m_pNodeTeam)
		self.nShowType = SHOW_TEAM
        self.m_eTeamFlyType = eTeamFlyNull  
	end
    self.tryRefreshTeamInfo()
end

function Renwulistdialog.InitTaskList()
	if _instance == nil then
		self = Renwulistdialog.getSingletonDialog()
    else
        self = _instance
	end
	self:ResetCellPane()
	local tracequestids, tracequests = GetTaskManager():GetTraceQuestListForLua()
	for i = 0, tracequestids:size() - 1 do
		local nTaskTypeId = tracequestids[i]
		local data = tracequests[i]
		local tracetime = data.acceptdate 
		
		self:refreshAllTask(nTaskTypeId,tracetime)	
	end
	if #self.m_mapCells == 0 then
	elseif not GetBattleManager():IsInBattle() and GetTaskManager():GetIsTaskTraceDlgVisible() then
		self:SetVisible(true)
	end
end


function Renwulistdialog:refreshAllTask(nTaskTypeId, nnReceiveTime)
	local pRepeatTask = GetTaskManager():GetSpecialQuest(nTaskTypeId)
	if pRepeatTask then
		self:refreshRepeatTask(pRepeatTask,nTaskTypeId,nnReceiveTime)
		return
	end

	local pActiveTask = GetTaskManager():GetReceiveQuest(nTaskTypeId)
	if pActiveTask then
		self:RefreshCommonQuestItem(pActiveTask,nTaskTypeId,nnReceiveTime)
		return
	end

	local pJuqingTask = GetTaskManager():GetScenarioQuest(nTaskTypeId)
	if pJuqingTask then
		self:RefreshScenarioQuestItem(pJuqingTask,nTaskTypeId,nnReceiveTime)
		return
	end

    self:removeTaskCell(nTaskTypeId)
end

function Renwulistdialog:removeTaskCell(questid)
	local find = false
	local length = TableUtil.tablelength(self.m_mapCells)
	local njIndex = -1
	for niIndex = 1, #self.m_mapCells do
		if self.m_mapCells[niIndex].id == questid then
			njIndex = niIndex
			break			
		end
	end
	if njIndex ~= -1 then
		local cell = self.m_mapCells[njIndex]
		self.m_pRenwuNode:removeChildWindow(cell.pBtn)
		CEGUI.WindowManager:getSingleton():destroyWindow(self.m_mapCells[njIndex].pBtn)
		table.remove(self.m_mapCells, njIndex)
		for niIndex = njIndex, #self.m_mapCells do
			self.m_mapCells[niIndex].pBtn:setXPosition(CEGUI.UDim(0,0))
		end
		self:RefreshCellYPosition()
	end
	
end

function Renwulistdialog.onItemNumNotify(bagid, itemkey, itembaseid)
	
end	

local function getActvitiQuestAimConfig(nTaskTypeId)
	return BeanConfigManager.getInstance():GetTableByName("circletask.cspecialquestconfig"):getRecorder(nTaskTypeId)
end

--//active task 
function Renwulistdialog:RefreshCommonQuestItem(quest,nTaskTypeId,tracetime)
	
	local questcell = nil
	for nIndex = 1, #self.m_mapCells do
		if self.m_mapCells[nIndex].id == nTaskTypeId then
			questcell = self.m_mapCells[nIndex]
			break
		end
	end
	if quest and questcell == nil then 
		self:addRenwuCell(quest,tracetime)
	elseif quest and questcell then
		if quest.queststatus == spcQuestState.FAIL then
			self:ShowFailQuestInfo(questcell)
		else
			local specailTable = getActvitiQuestAimConfig(nTaskTypeId)		
			self:addTaskActive(questcell, quest, specailTable)
		end
		self.m_pRenwuNode:invalidate()
	end
end

function Renwulistdialog:GetNewSpecialCfg(nQuestId)
	local repeatCfg = BeanConfigManager.getInstance():GetTableByName("circletask.crepeattask"):getRecorder(nQuestId)
	if  not repeatCfg or repeatCfg.id == -1 then
		return nil
	end
	return repeatCfg
end


function Renwulistdialog:GetQuestType2(nQuestId)
	local repeatCfg = BeanConfigManager.getInstance():GetTableByName("circletask.crepeattask"):getRecorder(nQuestId)
	if repeatCfg then
		return repeatCfg.etasktype
	end
	return -1
end


function Renwulistdialog:GetTrackName(nQuestId)
	local repeatCfg = BeanConfigManager.getInstance():GetTableByName("circletask.crepeattask"):getRecorder(nQuestId)
	if repeatCfg then
		local strTrackName = repeatCfg.strtasktitletrack
		return strTrackName
	end
	return ""
end


function Renwulistdialog:GetTrackContent(nQuestId)

	local repeatCfg = BeanConfigManager.getInstance():GetTableByName("circletask.crepeattask"):getRecorder(nQuestId)
	if repeatCfg then
		local strTrackContent =  repeatCfg.strtaskdestrack
		return strTrackContent
	end
	return ""
end


--active task
function Renwulistdialog:addRenwuCell(quest,tracetime)
	local nTaskTypeId = quest.questid
	local trackTable =	BeanConfigManager.getInstance():GetTableByName("circletask.cspecialquestconfig"):getRecorder(nTaskTypeId)
	if not trackTable or trackTable.id == -1 then
		return
	end
	local strTrackName = trackTable.tracname
	local newUnit = self:getRenwuCell(quest.questid)
	newUnit.pTitle:setText(strTrackName)
	newUnit.pTitle:setProperty("TextColours", "FFFFFF00") --fffff2df --FFFFFF33----任务追踪栏颜色-黄色
	if quest.queststate == spcQuestState.FAIL then
		self:ShowFailQuestInfo(newUnit, quest)
	else
		self:addTaskActive(newUnit, quest)
	end
end


function Renwulistdialog:addTaskActive(unit, pQuest)
	if pQuest == nil then
		return false
	end
	local nTaskTypeId = pQuest.questid
    local trackTable =	BeanConfigManager.getInstance():GetTableByName("circletask.cspecialquestconfig"):getRecorder(nTaskTypeId)
	if not trackTable or trackTable.id == -1 then
		return
	end
	local strTrackName = trackTable.tracname
	local strTrackContent = trackTable.tracdiscribe
	
	local sb = StringBuilder.new()
	local npcConfig = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(pQuest.dstnpcid)
	local mapconfig
	
	if pQuest.dstmapid == 0 and npcConfig then
		LogInsane("mapid="..npcConfig.mapid)
		mapconfig = BeanConfigManager.getInstance():GetTableByName("map.cmapconfig"):getRecorder(npcConfig.mapid)
		sb:SetNum("xPos", npcConfig.xPos)
		sb:SetNum("yPos", npcConfig.yPos)
		sb:SetNum("mapid", npcConfig.mapid)
	elseif pQuest.dstmapid > 0 then
		LogInsane("mapid="..pQuest.dstmapid)
		mapconfig = BeanConfigManager.getInstance():GetTableByName("map.cmapconfig"):getRecorder(pQuest.dstmapid)
		sb:SetNum("xPos", pQuest.dstx)
		sb:SetNum("yPos", pQuest.dsty)
		sb:SetNum("mapid", pQuest.dstmapid)
	else
		sb:SetNum("xPos",0)
		sb:SetNum("yPos", 0)
		sb:SetNum("mapid", 0)
	end
	
	sb:Set("MapName", mapconfig and mapconfig.mapName or "")
	sb:SetNum("mapid", pQuest.dstmapid)
    sb:SetNum("npcid", pQuest.dstnpcid)
	sb:SetNum("xjPos",  mapconfig and mapconfig.xjPos or 0)
	sb:SetNum("yjPos",  mapconfig and mapconfig.yjPos or 0)
	
	
	sb:SetNum("Number", pQuest.sumnum)
    sb:SetNum("DstX", pQuest.dstx)
	sb:SetNum("DstY", pQuest.dsty)
	sb:SetNum("Number1", pQuest.dstitemid)
	sb:SetNum("Number2", pQuest.sumnum)
	sb:SetNum("NpcKey", pQuest.dstnpckey)
	
	sb:SetNum("Number3", pQuest.rewardsmoney)
	
	if string.len(pQuest.npcname) == 0 then
		local npcInAll = BeanConfigManager.getInstance():GetTableByName("npc.cnpcinall"):getRecorder(pQuest.dstnpcid)
		sb:Set("NPCName", npcInAll.name)
	else
		sb:Set("NPCName", pQuest.npcname)
	end
	
	if not string.find(strTrackName, "%$Number", 0) then
		unit.pTitle:setText(sb:GetString(strTrackName))
	end
	unit.pContent:Clear()
	unit.pContent:AppendParseText(CEGUI.String(sb:GetString(strTrackContent)))
	unit.bFail = false
	unit.pContent:Refresh()
	unit:ResetHeight()
	self:RefreshCellYPosition()
	sb:delete()
	
	self:ShowSmallTaskDialog()
	return true
end

function Renwulistdialog:RefreshScenarioQuestItem(quest,taskid,tracetime)
	
	local questdata = nil
	for nIndex = 1, #self.m_mapCells do
		if self.m_mapCells[nIndex].id == taskid then
			questdata = self.m_mapCells[nIndex]
			break
		end
	end

	if quest and questdata == nil then 
		self:AddScenarioQuestItem(quest,tracetime)
	elseif quest and questdata then
		if quest.missionstatus == spcQuestState.FAIL then
			self:ShowFailQuestInfo(questdata)
		else
			local questinfo = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(taskid)
			self:addJuqingTask(questdata, questinfo)
		end
		self.m_pRenwuNode:invalidate();
	end
end


function Renwulistdialog:getTitleColor(nTaskId)
    local strColor = "FFFFFF00"
    local nType = require("logic.task.taskhelper").GetTaskShowTypeWithId(nTaskId)
    if nType == 3 then --//主线任务
        strColor = "FFFFFF00"
    else 
         strColor = "ffffff33"
    end
    return strColor
end

function Renwulistdialog:AddScenarioQuestItem(quest, tracetime)
    local nJuqingId = quest.missionid
	local questinfo = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(nJuqingId)
	if not questinfo or questinfo.id == -1 or CEGUI.String(questinfo.TaskInfoTraceListA):empty() then
		return
	end
	local name = questinfo.MissionName
	if string.match(name,"round",0) then
		local sb = StringBuilder.new()
		sb:SetNum("round", quest.round)
		name = sb:GetString(name)
		sb:delete()
	end
    local newUnit = self:getRenwuCell(nJuqingId)
    local strTitleColor = self:getTitleColor(nJuqingId)
    newUnit.pTitle:setProperty("TextColours",strTitleColor)
    newUnit.pTitle:setText(name)

	self:addJuqingTask(newUnit, questinfo)
end

function Renwulistdialog:addJuqingTask(unit, questinfo)
    if string.match(questinfo.TaskInfoTraceListA, "%$", 0) then
		local quest = GetTaskManager():GetScenarioQuest(questinfo.id);
		if quest then
			local sb = StringBuilder.new()
			sb:SetNum("number", quest.missionvalue);
	        unit.pContent:Clear();
	        local info = sb:GetString(questinfo.TaskInfoTraceListA)
	       
			unit.pContent:AppendParseText(CEGUI.String(info))
	    	unit.pContent:Refresh()
	    	unit:ResetHeight()
	    	unit.bFail = false
	    	self:RefreshCellYPosition()
			sb:delete()
		end
	else
	    unit.pContent:Clear()
		unit.pContent:AppendParseText(CEGUI.String(questinfo.TaskInfoTraceListA))
	    unit.pContent:Refresh()
	    unit:ResetHeight()
	    unit.bFail = false
	    self:RefreshCellYPosition()
    end
	
	self:ShowSmallTaskDialog()
	return true;
end


function Renwulistdialog:refreshRepeatTask(quest, nTaskId, tracetime)
	
	local questdata = nil
	for nIndex = 1, #self.m_mapCells do
		if self.m_mapCells[nIndex].id == nTaskId then
			questdata = self.m_mapCells[nIndex]
			break
		end
	end
	if quest and questdata == nil then
		self:addRepeatTask(quest,tracetime)	
	elseif quest and questdata then 
		local strTrackName = self:GetTrackName(quest.questtype)
		questdata.pTitle:setText(strTrackName)
		if quest.queststate == spcQuestState.FAIL then
			self:ShowFailQuestInfo(questdata)
		else
			self:AddSpecialQuestAim(questdata,quest)
		end
		self.m_pRenwuNode:invalidate()
	end
end

function Renwulistdialog:addRepeatTask(quest, tracetime)
	local nTaskId = quest.questtype
	local strTrackName = self:GetTrackName(nTaskId)
	if CEGUI.String(strTrackName):empty() then
		LogInfo(MHSD_UTILS.get_resstring(2300)..quest.questid)
	else
		LogInsane("Add questid="..quest.questid.." cell")
        local newUnit = self:getRenwuCell(quest.questid)
        newUnit.pTitle:setProperty("TextColours", "FFFFFF33")
   
		if quest.queststate == spcQuestState.FAIL then
			self:ShowFailQuestInfo(newUnit)
		else
			self:AddSpecialQuestAim(newUnit,quest)
		end
	end
end

local function getTaskIndex(taskid)
	local tt = BeanConfigManager.getInstance():GetTableByName("mission.ctasktrackingorder")
	local ids = tt:getAllID()
	for i=1,#ids do
		local k = ids[i]
		local v = tt:getRecorder(k)
		if taskid >= v.mintaskid and taskid <= v.maxtaskid then
			return v.priority
		end
	end
	return 9999999
	
end

function Renwulistdialog:getRenwuCell(taskid)
	for i = 1, #self.m_mapCells do
		if self.m_mapCells[i].id == taskid then
			return self.m_mapCells[i]
		end
	end
	local newUnit = require "logic.task.renwucell".new(taskid)
	self:AddCellToPane(taskid, newUnit)
	return newUnit
end

function Renwulistdialog:AddCellToPane(taskid, newUnit)
    local TaskHelper = require("logic.task.taskhelper")

	
    local HEIGHT = 1
    local bMainTask = TaskHelper.isMainTask(taskid)
    if bMainTask==1 then  
    	table.insert(self.m_mapCells, 1, newUnit)
    else
    	local curIdx = getTaskIndex(taskid)
    	local pos = #self.m_mapCells + 1
    	for i = 1, #self.m_mapCells do
    		local tIdx = getTaskIndex(self.m_mapCells[i].id)
    		if tIdx >= curIdx then
    			pos = i
    			break
    		end
    	end
    	table.insert(self.m_mapCells, pos, newUnit)
    end
    
    self.m_pRenwuNode:addChildWindow(newUnit.pBtn)

    newUnit.pBtn:setXPosition(CEGUI.UDim(0, 0))   

    local height=newUnit.pBtn:getPixelSize().height
    newUnit.pBtn:setYPosition(CEGUI.UDim(0,HEIGHT))
    self:RefreshCellYPosition()

end


function Renwulistdialog:sortCellAll()
     local strLevelMid = GameTable.common.GetCCommonTableInstance():getRecorder(269).value
     local nLevelMid = tonumber(strLevelMid)

     local nUserLevel = 1 
     if gGetDataManager() then
        nUserLevel = gGetDataManager():GetMainCharacterLevel()
     end

     local TaskHelper = require("logic.task.taskhelper")
     for nIndex = 1, #self.m_mapCells do
    	local cell = self.m_mapCells[nIndex]
        local nTaskTypeId = cell.id
       
        local n64TaskTime = GetTaskManager():GetQuestTraceTime(nTaskTypeId)
        if n64TaskTime~=0 then
            cell.nWeightOrder = n64TaskTime
        end
        
        local bMainTask = TaskHelper.isMainTask(nTaskTypeId)
        if bMainTask==1 and nUserLevel<nLevelMid then
            cell.nWeightOrder = n64TaskTime*3
        end

        --if  nTaskTypeId ==TaskHelper.eRepeatTaskId.yingxiongshilian then
        --    local nnTimeNow = gGetServerTime()
        --    cell.nWeightOrder = nnTimeNow*2 
        --end

    end


    table.sort(self.m_mapCells, function (v1, v2)
		local nOrderWeight1 = v1.nWeightOrder
		local nOrderWeight2 = v2.nWeightOrder
		return nOrderWeight1 > nOrderWeight2
	end)

    local nYingxiongshilianKey = 0
    for nIndex = 1, #self.m_mapCells do
    	local cell = self.m_mapCells[nIndex]
        local nTaskTypeId = cell.id
        if  nTaskTypeId ==TaskHelper.eRepeatTaskId.yingxiongshilian then
            nYingxiongshilianKey = nIndex
        end
    end

    if nYingxiongshilianKey ==0 then
        return
    end
    local nnYingxiongTime = gGetServerTime()
    local nPreIndex = 1
    if nUserLevel<nLevelMid then
        nPreIndex = 2
    else
        nPreIndex =1
    end
    if #self.m_mapCells >= nPreIndex then
          local cellSecond = self.m_mapCells[nPreIndex]
          local n64TaskTime = GetTaskManager():GetQuestTraceTime(cellSecond.id)
          if n64TaskTime then
                nnYingxiongTime = n64TaskTime - 1
          end
    end
    local oneTrace = require "protodef.rpcgen.fire.pb.mission.trackedmission":new()
    oneTrace.acceptdate = nnYingxiongTime
    GetTaskManager():AddQuestToTraceList(TaskHelper.eRepeatTaskId.yingxiongshilian,oneTrace)

    local cellYingxiong = self.m_mapCells[nYingxiongshilianKey]
    if not cellYingxiong  then
        return
    end
    cellYingxiong.nWeightOrder = nnYingxiongTime

    table.sort(self.m_mapCells, function (v1, v2)
		local nOrderWeight1 = v1.nWeightOrder
		local nOrderWeight2 = v2.nWeightOrder
		return nOrderWeight1 > nOrderWeight2
	end)

end

function Renwulistdialog:RefreshCellYPosition()
	LogInsane("Renwulistdialog:RefreshCellYPosition")
    self:sortCellAll()
    local HEIGHT = 1
    local height = 0
    for i = 1, #self.m_mapCells do
    
    	local cell = self.m_mapCells[i]
    	if cell then
    		LogInsane("height="..height..", i="..i)
	    	cell.pBtn:setPosition(CEGUI.UVector2(CEGUI.UDim(0,0), CEGUI.UDim(0, height)))
        	height = height + math.ceil(cell.pBtn:getPixelSize().height + HEIGHT)
	    else
	    	LogInsane("not pos ="..(i-1).."item")
    	end
    end
    
    self.m_pRenwuNode:getVertScrollbar():setScrollPosition(0)
end


function Renwulistdialog:ShowFailQuestInfo(unit, pQuest)
	if pQuest then
		local sb = StringBuilder.new()
		sb:SetNum("Number",pQuest.sumnum)
		sb:SetNum("Number1",pQuest.dstitemid)
		sb:SetNum("Number2",pQuest.sumnum)
		sb:SetNum("Number3",pQuest.rewardsmoney) 
		local strTrackName = self:GetTrackName(pQuest.questtype)
		if  CEGUI.String(strTrackName):empty() then
			sb:delete()
			return
		end
		if string.match(strTrackName, "$Number", 0) then
			unit.pTitle:setText(sb:GetString(strTrackName))
		end
		sb:delete()
	end
	local failconfig = BeanConfigManager.getInstance():GetTableByName("circletask.cspecialquestconfig"):getRecorder(1000)
	if not failconfig or failconfig.id == -1 or CEGUI.String(failconfig.tracname):empty() then
		return
	end
    
    unit.pContent:Clear()
    unit.pContent:AppendParseText(CEGUI.String(failconfig.tracdiscribe))
    unit.pContent:Refresh()
    unit.bFail = true
    unit:ResetHeight()
    self:RefreshCellYPosition()
	
end

function Renwulistdialog:RefreshBattleIconVisible(unitCell,pQuest)
	LogInfo("Renwulistdialog:RefreshBattleIconVisible(unitCell,pQuest)")
	if unitCell==nil then
		return
	end
	local nTaskDetailId = pQuest.questtype
	
	local bShow = self:IsRepeatTaskNeedToShowBattleIcon(nTaskDetailId)
	unitCell:SetBattleIconVisible(bShow)

end

function Renwulistdialog:IsRepeatTaskNeedToShowBattleIcon(nTaskDetailId)
	local nTaskDetailType = TaskHelper.GetSpecialQuestType2(nTaskDetailId) 
	if fire.pb.circletask.CircTaskClass.CircTask_CatchIt==nTaskDetailType or
		fire.pb.circletask.CircTaskClass.CircTask_Patrol==nTaskDetailType
	then
		return true
	end
	return false
end

function Renwulistdialog:AddSpecialQuestAim(unit, pQuest)
	if pQuest == nil then
		return false
	end
	self:RefreshBattleIconVisible(unit,pQuest)

	--//==========================================
	local nTaskDetailId = pQuest.questtype
	
	local sb = StringBuilder.new()
	local nRound = pQuest.round
	local nMaxNum = TaskHelper.GetRepeatTaskMaxCount(nTaskDetailId)
	sb:SetNum("Number", nRound)
	sb:SetNum("Number1", nMaxNum)
	--//==========================================
	LogInsane("Renwulistdialog:AddSpecialQuestAim pQuest.questid = "..pQuest.questid..", nTaskDetailId="..nTaskDetailId)
	
	TaskHelper.SetSbFormat_repeatTaskAll(pQuest,sb)
	
	--//==========================================
	local strTrackName = self:GetTrackName(nTaskDetailId)
	local strTrackContent = self:GetTrackContent(nTaskDetailId)
	unit.pTitle:setText(sb:GetString(strTrackName))
	--//==========================================
	local showstr = sb:GetString(strTrackContent)
	sb:delete()
	
    unit.pContent:Clear()
	unit.pContent:AppendParseText(CEGUI.String(showstr))
    unit.pContent:Refresh()
    unit.bFail = false
    unit:ResetHeight()
    self:RefreshCellYPosition()
	
	self:RefreshCellContentForBuff(unit,pQuest)
	
	self:ShowSmallTaskDialog()
	return true
end



function Renwulistdialog:ResetCellPane()
	self.m_pRenwuNode:cleanupNonAutoChildren()
	for i = 1, #self.m_mapCells do
		self.m_mapCells[i] = nil
	end
	self.m_mapCells = {}
	
end

function Renwulistdialog.GetLayoutFileName()
	return "renwulist_mtg.layout"
end

function Renwulistdialog.DestroyDialog()
	if _instance == nil then
--		_instance.m_btnYingcang.animation:stop()
--	_instance.m_pHideStateBack.animation:stop()
		return
	end
	local jingyingdlg = Jingyingfubendlg.getInstanceNotCreate()
	if _instance.m_bJingying and jingyingdlg then
		_instance.m_bJingying = nil
		local pWnd = jingyingdlg:GetWindow()
		_instance.m_pFubenBack:removeChildWindow(pWnd)
		CEGUI.System:getSingleton():getGUISheet():addChildWindow(pWnd)
		Jingyingfubendlg.DestroyDialog()
	--	pWnd:OnExit()
	end

	local fubenInstance = FubenGuideDialog:getInstanceNotCreate() 
	if _instance.bIsFu and fubenInstance then
		_instance.bIsFu = nil
		local pWnd = fubenInstance:GetWindow()
		_instance.m_pFubenBack:removeChildWindow(pWnd)
		CEGUI.System:getSingleton():getGUISheet():addChildWindow(pWnd)
		FubenGuideDialog.DestroyDialog()
	end

	local s = #_instance.m_vTeamMem
	for i = 1, s do
		table.remove(_instance.m_vTeamMem, i)
	end
	GetTaskManager().EventUpdateLastQuest:RemoveScriptFunctor(_instance.m_hUpdateLastQuest)
    GetTaskManager():RemoveTaskTraceStateChangeNotify(Renwulistdialog.OnTaskTraceStateChangeNotify)
	gGetRoleItemManager():RemoveLuaItemNumChangeNotify(_instance.m_hItemNumChangeNotify)

    NotificationCenter.removeObserver(Notifi_TeamAutoMatchChange, Renwulistdialog.handleEventAutoMatchChange)
    NotificationCenter.removeObserver(Notifi_TeamApplicantChange, Renwulistdialog.handleEventTeamApplyChange)
    NotificationCenter.removeObserver(Notifi_TeamListChange, Renwulistdialog.tryRefreshTeamInfo)
    NotificationCenter.removeObserver(Notifi_TeamMemberDataRefresh, Renwulistdialog.tryRefreshTeamInfo)
	
	
	_instance.pStateChange = nil
	if not _instance.m_bCloseIsHide then
		_instance:OnClose()
		_instance = nil
	else
		_instance:ToggleOpenClose()
	end
end

function Renwulistdialog.enterJingyingfuben()
	
	local jingyingfubendlg = Jingyingfubendlg.getInstanceNotCreate()
	if not _instance or not jingyingfubendlg then
		return
	end
	
    
	local pWnd = jingyingfubendlg:GetWindow()
	if pWnd then
        
		_instance.m_pFubenBack:addChildWindow(pWnd)
		pWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 0), CEGUI.UDim(0, 1)))
		_instance.m_bJingying = true
		require("logic.fuben.fubenmanager").getInstance():setInFuben(true)
		_instance.m_pRenwuNode:setVisible(false)
		if not _instance.m_pNodeTeam:isVisible() then
			--_instance.m_pFubenBack:setVisible(true)
			_instance:showOnly(_instance.m_pFubenBack)
			

		end
	end
end

function Renwulistdialog.enterFuben()
	LogInfo("ctasktracing dialog enter fuben")
	local fubenInstance = FubenGuideDialog.getInstanceNotCreate()
	if not _instance or not fubenInstance then
		return
	end
	local curMapid = gGetScene():GetMapInfo()
	if curMapid == 1401 then
		FubenGuideDialog:OnExit()
		return
	end
	local pWnd = FubenGuideDialog.getInstanceNotCreate():GetWindow() 
	if pWnd then
		_instance.m_pFubenBack:addChildWindow(pWnd)
		pWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 0), CEGUI.UDim(0, 1)))
		_instance.bIsFu = true
		_instance.m_pRenwuNode:setVisible(false)
		if not _instance.m_pNodeTeam:isVisible() then
			--_instance.m_pFubenBack:setVisible(true)
			_instance:showOnly(_instance.m_pFubenBack)
			LogInfo("Renwulistdialog:enterFuben()=self.m_pFubenBack:setVisible(true)")

		end
	end
end

function Renwulistdialog.outJingyingFuben()
	
	local jingyingdlg = Jingyingfubendlg.getInstanceNotCreate()
	if not _instance or (not jingyingdlg) or (not _instance.m_bJingying) then
		return
	end
	_instance.m_bJingying = nil
	require("logic.fuben.fubenmanager").getInstance():setInFuben(false)
	local pWnd = jingyingdlg:GetWindow()
	if pWnd then
		_instance.m_pFubenBack:removeChildWindow(pWnd)
		CEGUI.System:getSingleton():getGUISheet():addChildWindow(pWnd)
	end
	if not _instance.m_pNodeTeam:isVisible() and not _instance.nodeTeamKong:isVisible() then
		_instance.m_pRenwuNode:setVisible(true)
	end
end

function Renwulistdialog.exitFuben()
	
	local fubenInstance = FubenGuideDialog.getInstanceNotCreate()
	if not _instance or (not fubenInstance) or (not _instance.bIsFu) then
		return
	end
	_instance.bIsFu = nil
	local pWnd = FubenGuideDialog.getInstanceNotCreate():GetWindow() 
	if pWnd then
		_instance.m_pFubenBack:removeChildWindow(pWnd)
		CEGUI.System:getSingleton():getGUISheet():addChildWindow(pWnd)
	end
	if not _instance.m_pNodeTeam:isVisible() then
		_instance.m_pRenwuNode:setVisible(true)
	end
end


function Renwulistdialog:RefreshCellContentForBuffWithId(nTaskTypeId)
	LogInfo("Renwulistdialog:RefreshCellContentForBuff(nTaskTypeId)="..nTaskTypeId)
	
	for nIndex = 1, #self.m_mapCells do
		local unitCell = self.m_mapCells[nIndex]		
		local nCellId = unitCell.id
		local pQuest = GetTaskManager():GetSpecialQuest(nCellId)
		if pQuest then
			if nTaskTypeId==nCellId then
				self:RefreshCellContentForBuff(unitCell, pQuest)
			end
		end
	end
	
end


function Renwulistdialog:RefreshCellContentForBuff(unit, pQuest)
	LogInfo("Renwulistdialog:RefreshCellContentForBuff(unit, pQuest)")
	if pQuest == nil then
		return false
	end
	local nTaskTypeId = pQuest.questid
	local nTaskDetailId = pQuest.questtype
	local strTrackContent = self:GetTrackContent(nTaskDetailId)
	local sb = StringBuilder.new()
	require("logic.task.taskhelper").SetSbFormat_repeatTaskAll(pQuest,sb)
	local strContent = sb:GetString(strTrackContent)
	sb:delete()

	unit.pContent:Clear()
	unit.pContent:AppendParseText(CEGUI.String(strContent))
	unit.pContent:Refresh()
	
	local bHaveBuff = require("logic.task.taskhelperrepeat").IsRepeatTaskHaveBuff(nTaskTypeId)
	if bHaveBuff then
		LogInfo("bHaveBuff=true")
		local strBuff = require("logic.task.taskhelperrepeat").GetRepeatTaskBuffString(nTaskTypeId)
		unit.pContent:AppendParseText(CEGUI.String(strBuff))
	end
	unit.pContent:Refresh()
	unit:ResetHeight()
    self:RefreshCellYPosition()
	
	return true
	
end



function Renwulistdialog:Run(elapsed)
    
	if gGetDataManager():GetMainCharacterLevel() <= 10 then
		for i = 1, #self.m_mapCells do
			self.m_mapCells[i]:Run(elapsed)
		end
	end		

    self.nRefreshAnyeUICdDt = self.nRefreshAnyeUICdDt + elapsed
    if self.nRefreshAnyeUICdDt >= self.nRefreshAnyeUICd then
        self:updateAnyeUI()
        self.nRefreshAnyeUICdDt = 0
    end
end

function Renwulistdialog:updateAnyeUI()
    local taskmanager = require("logic.task.taskmanager").getInstance()
    for i = 1, #self.m_mapCells do
        local nTaskTypeId = self.m_mapCells[i].id
        local bAnyeTask = require("logic.task.taskhelper").isAnyeTaskId(nTaskTypeId)
        if bAnyeTask then
            local oneData = taskmanager.vAnyeTask[taskmanager.m_nAnyeFollowIndex]
            if oneData and  oneData.legend == 2 then
                self:refreshAnyeFollowTime()
            end 
        end 
	end
end

function Renwulistdialog.handleEventTeamApplyChange()
	if _instance then
		local applicantNum = GetTeamManager():GetApplicationNum()
		_instance.teamApplyTipDot:setVisible(applicantNum > 0)
	end
end

function Renwulistdialog.onInternetReconnected()
	if _instance then
		_instance.tryRefreshTeamInfo()
        _instance:ShowSmallTaskDialog()
	end
end

return Renwulistdialog
