
Jingjimanager = {}
Jingjimanager.__index = Jingjimanager
local _instance = nil


Jingjimanager.eJingjiType=
{
    oneVOne=1,
    threeVThree=2,
    fiveVFive=3
}

Jingjimanager.eCampType=
{
    campA=1,
    campB=2
    
}

function Jingjimanager:new()
    local self = {}
    setmetatable(self, Jingjimanager)
	self:ClearData()
    return self
end

function Jingjimanager:ClearData()
	self.vRoleData = {}
    self.myData = {}
    self.vBattleRecord = {}
    
    ------------------------------------3v3
    self.nBattleNum =  0
    self.nSuccessNum = 0
    self.nContinueNum = 0

    self.nFirstSuccessState = 0
    self.nTenBattleState = 0
    self.nEightSuccessState = 0


    self.vCurRoleRank = {}
    self.myDataCur = {}

    self.vHistoryRoleRank = {}
    self.myDataHistory = {}

    self.vBattleRecord3= {}

      -----------------------------------5v5
    self.nFirstSuccess5State =0
    self.nTenBattle5State =0
    self.vBattleRecord5 = {}

    self.vRankDataA = {}
    self.vRankDataB = {}
    self.myRankData5 = {}
    local oneRole = self.myRankData5
    oneRole.nRank =0
    oneRole.nnRoleId = 0
    oneRole.strName = ""
    oneRole.nScore = 0
    oneRole.nSuccess = 0
    oneRole.nBattleNum = 0

    self.nCampType = Jingjimanager.eCampType.campB
    self.nWaitAllTime = 30
    

    self.waitstarttime = -1

   

end

 function Jingjimanager:clearRecord1()
    for k,v in pairs(self.vBattleRecord) do
        if v.vParam then
             v.vParam = nil
        end
        v = nil
     end
     self.vBattleRecord = {}
end

 function Jingjimanager:clearRecord3()
    for k,v in pairs(self.vBattleRecord3) do
        if v.vParam then
             v.vParam = nil
        end
        v = nil
     end
     self.vBattleRecord3 = {}
end

function Jingjimanager:clearTableInSecond(objTable)
    for k,v in pairs(objTable) do
        v = nil
     end
     objTable = {}
end


function Jingjimanager:resetmyData3v3(myRankData)
 
    local nMyRoleId = -1 
    local strName = ""
    if gGetDataManager() then
       nMyRoleId = gGetDataManager():GetMainCharacterID()
       strName = gGetDataManager():GetMainCharacterName()
    end 

     myRankData.nRank = 0
     myRankData.nRoleId = nMyRoleId
     myRankData.strName = strName
     myRankData.nScore = 0

end

function Jingjimanager:resetMyData1v1()
    local nMyRoleId = -1 
    local strName = ""
    if gGetDataManager() then
       nMyRoleId = gGetDataManager():GetMainCharacterID()
       strName = gGetDataManager():GetMainCharacterName()
    end 

     self.myData.nRank = 0
     self.myData.strName = strName
     self.myData.lRoleId =  nMyRoleId
     self.myData.nScore =  0
     self.myData.nSuccess = 0
     self.myData.nBattleNum = 0
end

function Jingjimanager:ClearDataInClose()
    self:clearTableInSecond(self.vRoleData)
    self:clearRecord1()
    self.myData = {}
    --------------------------
    self.nBattleNum =  0
    self.nSuccessNum = 0
    self.nContinueNum = 0

    self.nFirstSuccessState = 0
    self.nTenBattleState = 0
    self.nEightSuccessState = 0
    -------------------------
    self:clearTableInSecond(self.vCurRoleRank)
    self:clearTableInSecond(self.vHistoryRoleRank)
    self:clearRecord3()
    self.myDataCur = {}
    self.myDataHistory = {}
    ------------------------

    self.nPiPei1 = 0
    self.nPiPei3 = 0

      -----------------------5v5
    self.nPiPei5 = 0
    self.nFirstSuccess5State =0
    self.nTenBattle5State =0
    self.vBattleRecord5 = {}

    self.vRankDataA = {}
    self.vRankDataB = {}

    -----------------------------
    self:clearCrossServerInfo()

     
end

function Jingjimanager:setPipei5(nPiPei5)
    self.nPiPei5 = nPiPei5
    self:refreshReady5(nPiPei5)
end

function Jingjimanager:refreshReady5(nPiPei5)
    local jingjidlg =  require("logic.jingji.jingjidialog5").getInstanceNotCreate()
    if jingjidlg then
        jingjidlg:refreshReady(nPiPei5)
    end    
end

function Jingjimanager:setPipei3(nPiPei3)
    self.nPiPei3 = nPiPei3
    self:refreshReady3(nPiPei3)
end

function Jingjimanager:refreshReady3(nPiPei3)
    local jingjidlg =  require("logic.jingji.jingjidialog3").getInstanceNotCreate()
    if jingjidlg then
        jingjidlg:refreshReady(nPiPei3)
    end
    
     local jingjidlgEnter =  require("logic.jingji.jingjienterdialog3").getInstanceNotCreate()
    if jingjidlgEnter then
        jingjidlgEnter:refreshReady(nPiPei3)
    end


end

function Jingjimanager:startWait()
    
     local nnTimeNowSecond = gGetServerTime()/1000
     local nnBeginTimeSecond = self.waitstarttime
     local nPassTime = nnTimeNowSecond - nnBeginTimeSecond
     if nPassTime < 0 then
        nPassTime = 0
     end
     local nLeftTime = self.nWaitAllTime - nPassTime
     if nLeftTime <= 0 then
           return
     end

    local timerData = {}
    local  Schedulermanager = require("logic.task.schedulermanager")
    require("logic.task.schedulermanager").getInstance():getTimerDataInit(timerData)
	--//=======================================
	timerData.eType = Schedulermanager.eTimerType.repeatEver
	timerData.fDurTime = 0.02
	timerData.nRepeatCount = -1
    timerData.pTarget= self
    timerData.callback= Jingjimanager.timerCallBack
	--//=======================================
	require("logic.task.schedulermanager").getInstance():addTimer(timerData)

end

function Jingjimanager:exitJingji5()
    require("logic.task.schedulermanager").getInstance():deleteTimerWithTargetAndCallBak(self,Jingjimanager.timerCallBack)
    self.waitstarttime = -1
end



function Jingjimanager:timerCallBack(timerData)
    local nNowTime = gGetServerTime() /1000
    local nDtTime = nNowTime - self.waitstarttime
    if nDtTime < 0 then
        nDtTime = 0
     end
    local fLeftSecond = self.nWaitAllTime - nDtTime
    
    local jingjidlg =  require("logic.jingji.jingjidialog5").getInstanceNotCreate()
    if fLeftSecond <= 0 then
        require("logic.task.schedulermanager").getInstance():deleteTimer(timerData.nId)
        if jingjidlg then
            jingjidlg:startRandomChat()
        end
    else
        if jingjidlg then
            
            if nNowTime < self.waitstarttime then
                jingjidlg:hideProgress()
            else
                jingjidlg:refreshPipei(fLeftSecond)
            end
        end
    end
end


function Jingjimanager:setPipei1(nPiPei1)
    self.nPiPei1 = nPiPei1
    self:refreshReady1(nPiPei1)

end

function Jingjimanager:refreshReady1(nPiPei1)
    local jingjidlg =  require("logic.jingji.jingjidialog").getInstanceNotCreate()
    if jingjidlg then
        jingjidlg:refreshReady(nPiPei1)
    end
    
     local jingjidlgEnter =  require("logic.jingji.jingjienterdialog").getInstanceNotCreate()
    if jingjidlgEnter then
        jingjidlgEnter:refreshReady(nPiPei1)
    end
end

function Jingjimanager.Destroy()
    if _instance then 
        require("logic.task.schedulermanager").getInstance():deleteTimerWithTarget(_instance)
		_instance:ClearDataInClose()
        _instance = nil
    end
end

function Jingjimanager.getInstance()
	if not _instance then
		_instance = Jingjimanager:new()
	end
	return _instance
end


function Jingjimanager:update(delta)
	--local dt = delta/1000
end

--huoban dialog call
function Jingjimanager:refreshHuoban()
    local jingjidlg =  require("logic.jingji.jingjidialog").getInstanceNotCreate()
    if not jingjidlg then
        return
    end
    jingjidlg:refreshHero()
end

---------------------------------------------
function Jingjimanager:getRandomHeadId()
    local randomRoleIns =  BeanConfigManager.getInstance():GetTableByName("npc.cjingjirandomrole")
    local vcAllId =  randomRoleIns:getAllID()
    local nAllNum = randomRoleIns:getSize()
    local nRandId = math.random(1, nAllNum) --1.2.3456
    local roleTable = randomRoleIns:getRecorder(nRandId)
    if not roleTable or roleTable.id == -1 then
        return -1
    end
    local nHeadId = roleTable.nheadid
    local nJobId = roleTable.njobid
    return nHeadId,nJobId

end

function Jingjimanager:getRandomChat5()
    local randomRoleIns =  BeanConfigManager.getInstance():GetTableByName("npc.cjingjirandomchat")
    local vcAllId =  randomRoleIns:getAllID()
    local nAllNum = randomRoleIns:getSize()
    local nRandId = math.random(1, nAllNum) --1.2.3456
    local roleTable = randomRoleIns:getRecorder(nRandId)
    if not roleTable or roleTable.id == -1 then
        return -1
    end
    
    return roleTable.strchat

end


function Jingjimanager:getRandomLevel(nJingjiType)
    if not gGetDataManager() then
        return 0
    end
    local nLevel = gGetDataManager():GetMainCharacterLevel()
    local nLevelRand = nLevel
    local nLevelSpace = 5
    
    local nAddLevel = math.random(1, nLevelSpace)
    local nAddOrNot = math.random(1, 2)
    if nAddOrNot==1 then
        nLevelRand = nLevel + nAddLevel
    else
        nLevelRand = nLevel - nAddLevel
    end

    local nGroup,nMin,nMax = self:getMinAndMaxLevel(nLevel,nJingjiType)

    if nLevelRand< nMin then
        nLevelRand = nMin
    end
    if nLevelRand> nMax then
        nLevelRand = nMax
    end

    return nLevelRand
end


function Jingjimanager:getGroupName()
    local strImagePath = "set:jingjichang image:jingjichang_tong"
    local nUserLevel = gGetDataManager():GetMainCharacterLevel()

    local nGroup = self:getMinAndMaxLevel(nUserLevel)
    local nIdzi = 11316
    if nGroup==1 then
        nIdzi = 11316
        strImagePath = "set:jingjichang image:jingjichang_tong"
    elseif nGroup==2 then
        nIdzi = 11317
        strImagePath = "set:jingjichang image:jingjichang_yin"
    elseif nGroup==3  then 
        nIdzi = 11318
        strImagePath = "set:jingjichang image:jingjichang_jin"
    end
    local strGroupzi =  require("utils.mhsdutils").get_resstring(nIdzi) 
    return strGroupzi,strImagePath
end

function Jingjimanager:getMinAndMaxLevel(nUserLevel,nJingjiType)
     if not nJingjiType then
        nJingjiType =1
    end
    local nMapId = -1

    if gGetScene() then
        nMapId = gGetScene():GetMapID()
    end
    local nGroup = 1

    if nJingjiType==1 then
        nGroup = getJingji1v1Group(nMapId)
    elseif nJingjiType==2 then
        nGroup = getJingji3v3Group(nMapId)
    elseif nJingjiType==3 then
        nGroup = getJingji5v5Group(nMapId)
    end

    local nMin = 40
    if nJingjiType==1 then
        nMin = 40
    elseif nJingjiType==2 then
        nMin = 45
    elseif nJingjiType==3 then
        nMin = 50
    end

    local nMax = 69
    if nGroup==1 then
        --nMin = nFirstMin
        nMax = 69
    elseif nGroup==2 then
        nMin = 70
        nMax = 89
    elseif nGroup==3  then 
        nMin = 90
        nMax = 99
    end
    return nGroup,nMin,nMax
end
function Jingjimanager:getRefreshTiemimageName(nBeginBattleImage)
    local strImageName = "set:teamui image:team_1"
    if nBeginBattleImage == 1 then
        strImageName = "set:teamui image:team_3"
    elseif nBeginBattleImage == 2 then
        strImageName = "set:teamui image:team_2"
    elseif nBeginBattleImage == 3 then
        strImageName = "set:teamui image:team_1"
    end
    return strImageName
   -- self.imageWait:setProperty("Image",strImageName)
end

function Jingjimanager:getCurTimeSecond()
    local time = StringCover.getTimeStruct(gGetServerTime() / 1000)
	local actnowAll  = time.tm_hour * 3600 + time.tm_min * 60 + time.tm_sec
    return actnowAll

end



function Jingjimanager:isInKuafu3v3()
    local nServerId = gGetLoginManager():getServerID()
    local tableName  = "timer.cscheculedactivity"
    local tableAllId = BeanConfigManager.getInstance():GetTableByName(tableName):getAllID()
    for _, v in pairs(tableAllId) do
		local actScheculed = BeanConfigManager.getInstance():GetTableByName(tableName):getRecorder(v)
        if actScheculed.activityid == 243  then
            local strServerIdArray = actScheculed.strserverid
            local vServerId = StringBuilder.Split(strServerIdArray, ";")
            for nIndex,strServerIdTable in pairs(vServerId) do
                if strServerIdTable == tostring(nServerId) then
                   return true
                end 
            end
            
        end
    end
    return false
end

function  Jingjimanager:getJingjiTimeStartEnd3()
    local nActiveId = 241
    local bInKuafu3v3 = self:isInKuafu3v3()
    if bInKuafu3v3 then
        nActiveId = 243
    end

    local nStartSecond,nEndSecond = Jingjimanager.getActiveStartEndTime(nActiveId)
    return nStartSecond,nEndSecond
end

function  Jingjimanager:getJingjiTimeStartEnd()
    local nActiveId = 240
    local nStartSecond,nEndSecond = Jingjimanager.getActiveStartEndTime(nActiveId)
    return nStartSecond,nEndSecond

end
function  Jingjimanager:getJingjiTimeStartEnd5()
    local nActiveId = 242
    local nStartSecond,nEndSecond = Jingjimanager.getActiveStartEndTime(nActiveId)
    return nStartSecond,nEndSecond
end


--119 wu dao hui
function Jingjimanager.getActiveStartEndTime(id) --2 lie huo dong id
    --如果是定时活动
	local time = StringCover.getTimeStruct(gGetServerTime() / 1000)
    --计算星期
	local curWeekDay = time.tm_wday
	if curWeekDay == 0 then
		curWeekDay = 7
	end
	
	local yearCur = time.tm_year + 1900
	local monthCur = time.tm_mon + 1
	local dayCur = time.tm_mday
    local tableName = ""
    if IsPointCardServer() then
        tableName = "timer.cscheculedactivitypay"
    else
        tableName = "timer.cscheculedactivity"
    end
    if id==243 then --kuafu 3v3
        tableName = "timer.cscheculedactivity"
    end

    local tableAllId = BeanConfigManager.getInstance():GetTableByName(tableName):getAllID()
    for _, v in pairs(tableAllId) do
		local actScheculed = BeanConfigManager.getInstance():GetTableByName(tableName):getRecorder(v)
		--去定时活动表找对应活动
		if actScheculed.activityid == id then
            
			--如果该活动为固定日期开放
			if actScheculed.weekrepeat == 0 then
				--判断一周的哪天
			elseif actScheculed.weekrepeat == curWeekDay then
				blntoday = true
				local actstarttimehour, actstarttimemin, actstarttimesec = string.match(actScheculed.startTime2, "(%d+):(%d+):(%d+)")
				local actendtimehour, actendtimemin, actendtimesec = string.match(actScheculed.endTime, "(%d+):(%d+):(%d+)")
				local actstartAll = actstarttimehour * 3600 + actstarttimemin * 60 + actstarttimesec
				local actendAll = actendtimehour * 3600 + actendtimemin * 60 + actendtimesec
				local actnowAll  = time.tm_hour * 3600 + time.tm_min * 60 + time.tm_sec
				--判断时间

                return actstartAll,actendAll
				--if actnowAll> actstartAll and actnowAll<actendAll then
				--	return true
				--end
			end
		end
	end 
    return 0,0   
end

function Jingjimanager:addCircleEffect(node)
     local strEffectPath = require ("utils.mhsdutils").get_effectpath(10068)
        local bCycle = true
        local nPosX = 0
        local nPosY = 0
        local bClicp = true
        local bBounds = true
		gGetGameUIManager():AddParticalEffect(node,strEffectPath,bCycle,nPosX,nPosY,bClicp,bBounds)

end



function Jingjimanager:clearCrossServerInfo()
    self.strAccount = ""
    self.strKey = ""
	self.strServerName = ""
	self.strArea = ""
    self.strHost =  ""
    self.strPort = ""
	
    self.nServerId = 0
    self.strChannelId = ""
end

function Jingjimanager:saveOldNormalServerInfo()
    self.strAccount = gGetLoginManager():GetAccount()
    self.strKey = gGetLoginManager():GetPassword()
	self.strServerName = gGetLoginManager():GetSelectServer()
	self.strArea = gGetLoginManager():GetSelectArea()
    self.strHost =  gGetLoginManager():GetHost()
    self.strPort = gGetLoginManager():GetPort()
	
    self.nServerId = gGetLoginManager():getServerID()
    self.strChannelId = gGetLoginManager():GetChannelId();

end

function Jingjimanager:connectToNormalServer()

    local account = self.strAccount
    local key = self.strKey
	local servername = self.strServerName
	local area = self.strArea
    local host =  self.strHost
    local port = self.strPort
	
    local serverid = self.nServerId
    local channelid = self.strChannelId
	--gGetLoginManager():ClearConnections()
    gGetGameApplication():CreateConnection(account, key, host, port, true, servername, area, serverid, channelid)
    if gGetNetConnection() then
        gGetNetConnection():setSecurityType(FireNet.enumSECURITY_ARCFOUR, FireNet.enumSECURITY_ARCFOUR)
    end


end




return Jingjimanager
