
Jingjiprotocol = {}

Jingjiprotocol.nMaxBattleInfoCount = 100

function Jingjiprotocol.spvp1rankinglist_process(protocol)
     local jjManager = require("logic.jingji.jingjimanager").getInstance()
     for k,v in pairs(jjManager.vRoleData) do
        v= nil
     end
     jjManager.vRoleData = {}

     local nMyRoleId = -1 
    if gGetDataManager() then
       nMyRoleId = gGetDataManager():GetMainCharacterID()
    end 
     local nAllNum = #protocol.rolescores
     for nIndex=1,nAllNum do
        local oneRoleData = protocol.rolescores[nIndex]
       
        jjManager.vRoleData[nIndex] = {}
        jjManager.vRoleData[nIndex].nRank = nIndex
        jjManager.vRoleData[nIndex].nRoleId = oneRoleData.roleid
        jjManager.vRoleData[nIndex].strName = oneRoleData.rolename
        jjManager.vRoleData[nIndex].nScore = oneRoleData.score
        jjManager.vRoleData[nIndex].nSuccess = oneRoleData.winnum
        jjManager.vRoleData[nIndex].nBattleNum = oneRoleData.battlenum

        if oneRoleData.roleid == nMyRoleId then
            jjManager.myData.nRank = nIndex
         jjManager.myData.strName = oneRoleData.rolename
         jjManager.myData.lRoleId =  oneRoleData.roleid
         jjManager.myData.nScore =  oneRoleData.score
         jjManager.myData.nSuccess = oneRoleData.winnum
         jjManager.myData.nBattleNum = oneRoleData.battlenum
        end

     end

     ----------------------------------
     local nMayIndex = 1
     --rolescores3
     if nMayIndex <= #protocol.rolescores3  then
         local myServerData = protocol.rolescores3[nMayIndex]

         jjManager.myData.nRank = myServerData.index
         jjManager.myData.strName = myServerData.rolename
         jjManager.myData.lRoleId =  myServerData.roleid
         jjManager.myData.nScore =  myServerData.score
         jjManager.myData.nSuccess = myServerData.winnum
         jjManager.myData.nBattleNum = myServerData.battlenum
        --jjManager.myData.combowin = myServerData.combowin
     end
   

     ----------------------------------------
    local jingjidlg =  require("logic.jingji.jingjidialog").getInstanceNotCreate()
    if not jingjidlg then
        return
    end
    jingjidlg:refreshScrollRole()
    jingjidlg:refreshMyRankData()
end



function Jingjiprotocol.spvp1myinfo_process(protocol)
    local jjManager = require("logic.jingji.jingjimanager").getInstance()

    jjManager:setPipei1(protocol.ready)

    jjManager.firstwin = protocol.firstwin
    jjManager.tenfight = protocol.tenfight

   
    jjManager.myData.nScore =  protocol.score
    jjManager.myData.nSuccess = protocol.winnum
    jjManager.myData.nBattleNum = protocol.battlenum
    jjManager.myData.combowin = protocol.combowinnum --本场连胜
    jjManager.myData.formation = protocol.formation 

    local jingjidlg =  require("logic.jingji.jingjidialog").getInstanceNotCreate()
    if not jingjidlg then
        return
    end
    jingjidlg:refreshMyRankData()
    jingjidlg:refreshBoxState()

    
end


function Jingjiprotocol.spvp1readyfight_process(protocol)

    local nReady = protocol.ready
    local nTipId = 0
    if protocol.ready==1 then
        nTipId = 160335
        require("logic.jingji.jingjipipeidialog").getInstanceAndShow()
    else
        nTipId = 160336
        require("logic.jingji.jingjipipeidialog").DestroyDialog()
    end
    local strTip = require("utils.mhsdutils").get_msgtipstring(nTipId)
	GetCTipsManager():AddMessageTip(strTip)

    local jjManager = require("logic.jingji.jingjimanager").getInstance()
    jjManager:setPipei1(nReady)

end

function Jingjiprotocol.spvp1matchresult_process(protocol) 

    local jjManager = require("logic.jingji.jingjimanager").getInstance()

    local jingjipipeidlg =  require("logic.jingji.jingjipipeidialog").getInstanceAndShow()
    if not jingjipipeidlg then
        return
    end
    local oneTarget = protocol.target

    local nIndex = 2
    local nLevel = oneTarget.level
    local nShape = oneTarget.shape
    local nJob = oneTarget.school
    jingjipipeidlg:refreshCell(nIndex,nLevel,nShape,nJob)

    jingjipipeidlg:beginToBattle()
    
end


function Jingjiprotocol.spvp1openboxstate_process(protocol)
     local jjManager = require("logic.jingji.jingjimanager").getInstance()

     if protocol.boxtype == 1 then
         jjManager.firstwin = protocol.state

     elseif protocol.boxtype == 2 then
         jjManager.tenfight = protocol.state
     end
    --jjManager.tenfight = protocol.tenfight

     local jingjidlg =  require("logic.jingji.jingjidialog").getInstanceNotCreate()
    if not jingjidlg then
        return
    end
    jingjidlg:refreshBoxState()
end



function Jingjiprotocol.spvp1battleinfo_process(protocol)
      local jjManager = require("logic.jingji.jingjimanager").getInstance()
      --local record = {}
      
      local nCurCount = #jjManager.vBattleRecord
      if nCurCount >= Jingjiprotocol.nMaxBattleInfoCount  then
            table.remove(jjManager.vBattleRecord,1)
      end


      local nIndex = #jjManager.vBattleRecord +1
      jjManager.vBattleRecord[nIndex] = {}
      jjManager.vBattleRecord[nIndex].ismine = protocol.ismine
      jjManager.vBattleRecord[nIndex].msgid = protocol.msgid
      jjManager.vBattleRecord[nIndex].vParam = {}

      
    local nAllNum = #protocol.parameters 
    for nIndexParam =1,nAllNum do
        local oct = protocol.parameters[nIndexParam]
        --local data = FireNet.Marshal.OctetsStream(oct)
        --local data  = FireNet.Marshal.OctetsStream:new(oct)

        local strRecord = ""
        strRecord = StringCover.OctectToWString(oct) --  StringCover::OctectToWString(*iter); -- data:net_tanchu_xuliehua_kuanchuan(strRecord)
        LogInfo("Jingjiprotocol=strRecord="..strRecord)
        jjManager.vBattleRecord[nIndex].vParam[nIndexParam] = strRecord
    end

     local jingjidlg =  require("logic.jingji.jingjidialog").getInstanceNotCreate()
    if not jingjidlg then
        return
    end
    local oneData =  jjManager.vBattleRecord[nIndex]
    jingjidlg:addBattleInfo1(oneData)

end
------------------------------------------------------
------------------------------------------------------

function Jingjiprotocol.spvp3myinfo_process(protocol)
      local jjManager = require("logic.jingji.jingjimanager").getInstance()

      jjManager.nBattleNum = protocol.battlenum
      jjManager.nSuccessNum = protocol.winnum
      jjManager.nContinueNum = protocol.combowinnum

      jjManager.nFirstSuccessState = protocol.firstwin
      jjManager.nTenBattleState = protocol.tenfight
      jjManager.nEightSuccessState = protocol.eightwin

      jjManager:setPipei3(protocol.ready)

       local jingjidlg =  require("logic.jingji.jingjidialog3").getInstanceNotCreate()
       if not jingjidlg then
           return
      end
      jingjidlg:refreshBattleInfo()
      jingjidlg:refreshBoxState()

end
--[[
self.vCurRoleRank = {}
    self.myDataCur = {}

    self.vHistoryRoleRank = {}
    self.myDataHistory = {}

    self.vBattleRecord3= {}


     local oneRole = vRoleData[nIndex]
        local nRank = oneRole.nRank
        local strName = oneRole.strName
        local nScore = oneRole.nScore
        local nSuccess = oneRole.nSuccess
        local nBattleNum = oneRole.nBattleNum

        	self.roleid = 0
	self.rolename = "" 
	self.score = 0


    self.index = 0
	self.roleid = 0
	self.rolename = "" 
	self.score = 0

--]]
--[[
	self.history = 0
	self.rolescores = {}
	self.myscore = {}
--]]
function Jingjiprotocol.spvp3rankinglist_process(protocol)
    local jjManager = require("logic.jingji.jingjimanager").getInstance()

    jjManager:clearTableInSecond(jjManager.vCurRoleRank)
    jjManager:clearTableInSecond(jjManager.vHistoryRoleRank)

     local nMyRoleId = -1 
    if gGetDataManager() then
       nMyRoleId = gGetDataManager():GetMainCharacterID()
    end 

    local vRank = nil
    local myRankData = nil
    if protocol.history == 0 then
        vRank = jjManager.vCurRoleRank
        myRankData = jjManager.myDataCur
    ----------------------------------
    elseif protocol.history == 1 then
        vRank = jjManager.vHistoryRoleRank
        myRankData = jjManager.myDataHistory
    end
    if vRank == nil then
        return
    end
    if not myRankData then
        return
    end
    
     local nAllNum =  #protocol.rolescores
     for nIndex=1,nAllNum do
            local oneRole = protocol.rolescores[nIndex]
            vRank[nIndex] = {}
            vRank[nIndex].nRank = nIndex
            vRank[nIndex].nRoleId = oneRole.roleid
            vRank[nIndex].strName = oneRole.rolename
            vRank[nIndex].nScore = oneRole.score

            if nMyRoleId == oneRole.roleid then
                myRankData.nRank = nIndex
                myRankData.nRoleId = oneRole.roleid
                myRankData.strName = oneRole.rolename
                myRankData.nScore = oneRole.score
            end
     end
     local nMyRankIndex = 1 --自己的索引位置是2

     if nMyRankIndex <= #protocol.myscore then
             local oneRole = protocol.myscore[nMyRankIndex]
            myRankData.nRank = oneRole.index
            myRankData.nRoleId = oneRole.roleid
            myRankData.strName = oneRole.rolename
            myRankData.nScore = oneRole.score
     end
     local jingjiscorerankdialog =  require("logic.jingji.jingjiscorerankdialog").getInstanceNotCreate()
       if not jingjiscorerankdialog then
           return
      end
     jingjiscorerankdialog:refreshScrollRole()
     jingjiscorerankdialog:refreshMyRank3()
end

function Jingjiprotocol.spvp3readyfight_process(protocol)
    local nTipId = 0
    local nReady3 = protocol.ready
    if protocol.ready==1 then
        nTipId = 160335
        require("logic.jingji.jingjipipeidialog3").getInstanceAndShow()
    else
        nTipId = 160336
        require("logic.jingji.jingjipipeidialog3").DestroyDialog()
    end
    local strTip = require("utils.mhsdutils").get_msgtipstring(nTipId)
	GetCTipsManager():AddMessageTip(strTip)

    local jjManager = require("logic.jingji.jingjimanager").getInstance()
    jjManager:setPipei3(nReady3)
end


function Jingjiprotocol.spvp3matchresult_process(protocol)
    local  vTargetRole =  protocol.targets

    
    local jingjipipeidialog3 =  require("logic.jingji.jingjipipeidialog3").getInstanceAndShow()
    if not jingjipipeidialog3 then
           return
    end

    local vTargetmMember = {}
    for nIndex=1,#vTargetRole do
         local oneMember = vTargetRole[nIndex]
         vTargetmMember[nIndex] = {}
         vTargetmMember[nIndex].nLevel = oneMember.level
         vTargetmMember[nIndex].nShape = oneMember.shape
         vTargetmMember[nIndex].nJob = oneMember.school
    end
    jingjipipeidialog3:resetTargetCell()
    jingjipipeidialog3:refreshTargetTeam(vTargetmMember)
    jingjipipeidialog3:beginToBattle()

end


function Jingjiprotocol.spvp3battleinfo_process(protocol)
      local jjManager = require("logic.jingji.jingjimanager").getInstance()
      --local record = {}
      local nCurCount = #jjManager.vBattleRecord3
      if nCurCount >= Jingjiprotocol.nMaxBattleInfoCount  then
            table.remove(jjManager.vBattleRecord3,1)
      end

      local nIndex = #jjManager.vBattleRecord3 +1
      jjManager.vBattleRecord3[nIndex] = {}
      jjManager.vBattleRecord3[nIndex].ismine = protocol.ismine
      jjManager.vBattleRecord3[nIndex].msgid = protocol.msgid
      jjManager.vBattleRecord3[nIndex].vParam = {}


    local nAllNum = #protocol.parameters 
    for nIndexParam =1,nAllNum do
        local oct = protocol.parameters[nIndexParam]

        local strRecord = ""
        strRecord = StringCover.OctectToWString(oct) --  StringCover::OctectToWString(*iter); -- data:net_tanchu_xuliehua_kuanchuan(strRecord)
        LogInfo("Jingjiprotocol=spvp3battleinfo_process=strRecord="..strRecord)
        jjManager.vBattleRecord3[nIndex].vParam[nIndexParam] = strRecord
    end

     local jingjidlg =  require("logic.jingji.jingjidialog3").getInstanceNotCreate()
    if not jingjidlg then
        return
    end

    local oneData =  jjManager.vBattleRecord3[nIndex]
    jingjidlg:addBattleInfo3(oneData)
end


function Jingjiprotocol.spvp3openboxstate_process(protocol)
     local jjManager = require("logic.jingji.jingjimanager").getInstance()

    if protocol.boxtype == 1 then
         jjManager.nFirstSuccessState = protocol.state
     elseif protocol.boxtype == 2 then
         jjManager.nTenBattleState = protocol.state
     elseif protocol.boxtype == 3 then
         jjManager.nEightSuccessState = protocol.state
     end

       local jingjidlg =  require("logic.jingji.jingjidialog3").getInstanceNotCreate()
       if not jingjidlg then
           return
      end
      jingjidlg:refreshBoxState()
end


-------------------------------------------------------5v5
function Jingjiprotocol.spvp5openboxstate_process(protocol)
     local jjManager = require("logic.jingji.jingjimanager").getInstance()

     if protocol.boxtype == 1 then
         jjManager.nFirstSuccess5State = protocol.state
     elseif protocol.boxtype == 2 then
         jjManager.nTenBattle5State = protocol.state
     end

     local jingjidlg =  require("logic.jingji.jingjidialog5").getInstanceNotCreate()
     if not jingjidlg then
           return
    end
     jingjidlg:refreshBoxState()
end

function Jingjiprotocol.spvp5battleinfo_process(protocol)
      local jjManager = require("logic.jingji.jingjimanager").getInstance()

      local nCurCount = #jjManager.vBattleRecord5
      if nCurCount >= Jingjiprotocol.nMaxBattleInfoCount  then
            table.remove(jjManager.vBattleRecord5,1)
      end

      local nIndex = #jjManager.vBattleRecord5 +1
      jjManager.vBattleRecord5[nIndex] = {}
      jjManager.vBattleRecord5[nIndex].ismine = protocol.ismine
      jjManager.vBattleRecord5[nIndex].msgid = protocol.msgid
      jjManager.vBattleRecord5[nIndex].vParam = {}


    local nAllNum = #protocol.parameters 
    for nIndexParam =1,nAllNum do
        local oct = protocol.parameters[nIndexParam]

        local strRecord = ""
        strRecord = StringCover.OctectToWString(oct) 
        jjManager.vBattleRecord5[nIndex].vParam[nIndexParam] = strRecord
    end

     local jingjidlg =  require("logic.jingji.jingjidialog5").getInstanceNotCreate()
    if not jingjidlg then
        return
    end
    --jingjidlg:refreshRichBox()
    local oneData = jjManager.vBattleRecord5[nIndex]
    jingjidlg:addBattleInfo5(oneData)
end

function Jingjiprotocol.spvp5matchresult_process(protocol)
    local jingjidlg =  require("logic.jingji.jingjidialog5").getInstanceNotCreate()
    if  jingjidlg then
          jingjidlg:stopRandomChat()
          jingjidlg:setPipeizhong()
    end
    require("logic.jingji.jingjidialog5").getInstanceAndShow()
end

function Jingjiprotocol.spvp5readyfight_process(protocol)
    local jingjidlg =  require("logic.jingji.jingjidialog5").getInstanceNotCreate()
    if  jingjidlg then
          jingjidlg:stopRandomChat()
    end

    local Jingjimanager = require("logic.jingji.jingjimanager")
    local jjManager = Jingjimanager.getInstance()
    jjManager.waitstarttime = gGetServerTime()/1000

    local nNowTime = gGetServerTime() /1000
    if nNowTime < jjManager.waitstarttime or jjManager.waitstarttime==-1 then
        if jingjidlg then
            jingjidlg:hideProgress()
        end
    elseif nNowTime -  jjManager.waitstarttime <  jjManager.nWaitAllTime then
        jjManager:startWait()
    elseif nNowTime -  jjManager.waitstarttime >=  jjManager.nWaitAllTime then
        if  jingjidlg then
          jingjidlg:showChatState()
        end
                
    end
    require("logic.jingji.jingjidialog5").getInstanceAndShow()
end


function Jingjiprotocol.spvp5myinfo_process(protocol)
      local Jingjimanager = require("logic.jingji.jingjimanager")
      local jjManager = Jingjimanager.getInstance()

      jjManager.nFirstSuccess5State = protocol.firstwin
      jjManager.nTenBattle5State = protocol.fivefight
      jjManager.waitstarttime = protocol.waitstarttime 

      local oneRole = jjManager.myRankData5

      oneRole.nScore = protocol.score
      oneRole.nSuccess = protocol.winnum
      oneRole.nBattleNum = protocol.battlenum
      oneRole.nContinueWin = protocol.combowinnum


      if protocol.camp == 0 then
            jjManager.nCampType = Jingjimanager.eCampType.campA
      elseif protocol.camp == 1 then
            jjManager.nCampType = Jingjimanager.eCampType.campB
      end

       
      local jingjidlg =  require("logic.jingji.jingjidialog5").getInstanceNotCreate()
       if  jingjidlg then
           jingjidlg:refreshBoxState()
            jingjidlg:refreshRankMy()
      end

    local nNowTime = gGetServerTime() /1000
    if nNowTime < jjManager.waitstarttime or jjManager.waitstarttime==-1 then
        if jingjidlg then
            jingjidlg:hideProgress()
        end
    elseif nNowTime -  jjManager.waitstarttime <  jjManager.nWaitAllTime then
           jjManager:startWait()
    elseif nNowTime -  jjManager.waitstarttime >=  jjManager.nWaitAllTime then
        if jingjidlg then
           jingjidlg:showChatState()
        end
    end

end

function Jingjiprotocol.initRoleRankData(oneRole,serverRole)
        oneRole.nnRoleId = serverRole.roleid
        oneRole.strName = serverRole.rolename
        oneRole.nScore = serverRole.score
        oneRole.nSuccess = serverRole.winnum
        oneRole.nBattleNum = serverRole.battlenum
end


function Jingjiprotocol.spvp5rankinglist_process(protocol)
    local Jingjimanager = require("logic.jingji.jingjimanager")
    local jjManager = Jingjimanager.getInstance()  
    jjManager.vRankDataA = {}
    jjManager.vRankDataB = {}
    jjManager.myRankData5 = {}

    for nIndexA=1,#protocol.rolescores1 do
        jjManager.vRankDataA[nIndexA] = {}
        local oneRole = jjManager.vRankDataA[nIndexA]
        oneRole.nRank = nIndexA
        local serverRole = protocol.rolescores1[nIndexA]
        Jingjiprotocol.initRoleRankData(oneRole,serverRole)
    end

    for nIndexA=1,#protocol.rolescores2 do
        jjManager.vRankDataB[nIndexA] = {}
        local oneRole = jjManager.vRankDataB[nIndexA]
        oneRole.nRank = nIndexA
        local serverRole = protocol.rolescores2[nIndexA]
        Jingjiprotocol.initRoleRankData(oneRole,serverRole)
    end

    if protocol.myscore.listid == 1 then
        jjManager.nCampType = Jingjimanager.eCampType.campA
    elseif protocol.myscore.listid == 2 then
        jjManager.nCampType = Jingjimanager.eCampType.campB
    end

    local oneRole = jjManager.myRankData5
    oneRole.nRank = protocol.myscore.index
    oneRole.nnRoleId = protocol.myscore.index
    oneRole.strName = protocol.myscore.rolename
    oneRole.nScore = protocol.myscore.score
    oneRole.nSuccess = protocol.myscore.winnum
    oneRole.nBattleNum = protocol.myscore.battlenum

    local jingjidlg5 =  require("logic.jingji.jingjidialog5").getInstanceNotCreate()
    if not jingjidlg5 then
         return
    end
    jingjidlg5:refreshRankMy()
    jingjidlg5:refreshRankA()
    jingjidlg5:refreshRankB()

end


return Jingjiprotocol
