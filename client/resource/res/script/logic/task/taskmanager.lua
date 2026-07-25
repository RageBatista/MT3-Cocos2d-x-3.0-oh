
require "protodef.rpcgen.fire.pb.circletask.specialqueststate"
local spcQuestState = SpecialQuestState:new()


Taskmanager = {}
Taskmanager.__index = Taskmanager
local _instance = nil


function Taskmanager:new()
    local self = {}
    setmetatable(self, Taskmanager)
	self:ClearData()
    return self
end

function Taskmanager:ClearData()
	self.mapTaskBuff = {}
	self.bLockGoto = false
	self.vHaveShowGetBoublePoint = {}
	
	self.bPingDingTaskRedVis = false

    self.eOpenShopType = -1
    self.nLastSelTaskId = -1

    ---------------
    self.vAnyeTask = {}
    self.anyeTaskData = {}
    self.nRenxingNum = 0
    self.nAnyeTimes = 0

    self.fFactionHelpCd = 0.0

    self.vInvitePlayer = {}
    self.nAnyeCurSelIndex = -1

    self.nAnyeRewardExp = 0
    self.nAnyeRewardSliver =0
    self.nAnyeRewardGold = 0

    self.nnAnyetonpcshijian = 0
    
    self.m_nAnyeFollowIndex = 0
	
end

function Taskmanager:saveAnyeGotoTime()
    local nnTimeNowSecond = gGetServerTime()/1000
    local csetanyejointime = require "protodef.fire.pb.circletask.anye.csetanyejointime":new()
    csetanyejointime.jointime = nnTimeNowSecond
	require "manager.luaprotocolmanager":send(csetanyejointime)
end

function Taskmanager:isAnyeNeedToGotoNpc()
    
    local nnTimeNowSecond = gGetServerTime()/1000
    if self.nnAnyetonpcshijian <= 0 then
        return true
    end
	
    return false
    --[[
    local nnPreTimeSecond = self.nnAnyetonpcshijian/1000

    local bInSameWeek = self:isInSameWeek(nnPreTimeSecond,nnTimeNowSecond)
    if bInSameWeek then
        return false
    else
        if self.nAnyeTimes==0 then
            return true
        end
    end
    return false
    --]]

end




function Taskmanager:checkShowAnyeDlgWithCurIndex()
    if self.nAnyeCurSelIndex == -1 then
        return
    end
    local oneTaskData = self.vAnyeTask[self.nAnyeCurSelIndex]
    if not oneTaskData then
        return
    end
    local bNeedToNpc =  self:isAnyeNeedToGotoNpc()
    if bNeedToNpc then
        return
    end
    if oneTaskData.state == spcQuestState.DONE then
        require("logic.anye.anyemaxituandialog").getInstanceAndShow(self.nAnyeCurSelIndex)
        self.nAnyeCurSelIndex = -1
    end
end

function Taskmanager:isInSameWeek(nnSendTime,nnNowTime)
    local sendTimeData = StringCover.getTimeStruct(nnSendTime)
     
    local nWeekDay = sendTimeData.tm_wday
    if nWeekDay == 0 then
		nWeekDay = 7
	end
    local nSendTimeHour = sendTimeData.tm_hour
    local nSendTimeMinute = sendTimeData.tm_min
    local nSendTimeSecond = sendTimeData.tm_sec

    local nDisDay = nWeekDay -1

   local nnWeekBeginSecond = nnSendTime - nDisDay*24*60*60-nSendTimeHour*60*60 - nSendTimeMinute*60-nSendTimeSecond
   --local sendTimeDataBegin = StringCover.getTimeStruct(nnWeekBeginSecond)
   --self:printTimeData(sendTimeDataBegin)

   local nnWeekEndSecond = nnWeekBeginSecond+7*24*60*60 
   --local sendTimeDataEnd = StringCover.getTimeStruct(nnWeekEndSecond)
   --self:printTimeData(sendTimeDataEnd)

   if nnNowTime >= nnWeekBeginSecond and nnNowTime <= nnWeekEndSecond then
        return true 
   end
   return false

end
function Taskmanager.getAnyeFollowTask(taskid)
    local anyeIdMax = 1
    local anyeIdMin = 1
    local indexIDs = BeanConfigManager.getInstance():GetTableByName("circletask.canyemaxituanconf"):getAllID()
    local first = true
    --给每一个道具设置坐标和属性
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
    if taskid >= anyeIdMin and taskid <= anyeIdMax then
        local anyeTable = BeanConfigManager.getInstance():GetTableByName("circletask.canyemaxituanconf"):getRecorder(taskid)
        if anyeTable then
            return anyeTable
        end 
    end
    return nil
end
function Taskmanager:startFactionHelpCd()
	local commonTable = GameTable.common.GetCCommonTableInstance():getRecorder(320)
    local fCd = tonumber(commonTable.value) 
    self.fFactionHelpCd = fCd * 1000
end


--anye task
function Taskmanager:getOneTaskDataWithTaskId(nTaskId)

    for nIndex,oneTaskData in pairs(self.vAnyeTask)  do
        if nTaskId ==oneTaskData.id  and  self.nAnyeCurSelIndex==nIndex  then
            return oneTaskData
        end
    end
    return nil

end


function Taskmanager:insertAnyeTask(oneTaskData)
    local nIndex = oneTaskData.pos +1
    self.vAnyeTask[nIndex] = oneTaskData  
end

function Taskmanager:updateAnyeTask(oneTaskData)
    local nIndex = oneTaskData.pos +1
    self.vAnyeTask[nIndex] = oneTaskData

    local nTaskDetailType = oneTaskData.kind
   
    if oneTaskData.state == spcQuestState.DONE then
        if nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ItemFind or 
	    nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_PetCatch then
            require("logic.task.taskmanager").getInstance():repeatTaskDoneCall()
        end
    elseif oneTaskData.state == spcQuestState.SUCCESS then
        if nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_Patrol then
            GetMainCharacter():StopPacingMove()
	        GetMainCharacter():RemoveAutoWalkingEffect()
        end
        local renwuListDlg = require("logic.task.renwulistdialog").getInstanceNotCreate()
        if renwuListDlg then
            renwuListDlg:refreshAnyeTaskAndUpdateTime()
        end
    end

    self:refreshNpcState(oneTaskData)
end

function Taskmanager:refreshNpcState(anyeTaskData)
    local nTaskDetailType = anyeTaskData.kind
    if nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_CatchIt  or 
        nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ChallengeNpc
    then
        local nNpcId = anyeTaskData.dstnpcid
        local nNpcKey = 0

        local pNpc = gGetScene():FindNpcByBaseID(nNpcId)
        if not pNpc then
            return
        end

        local nState = require("logic.task.taskhelpernpc").GetNpcStateByID(nNpcKey,nNpcId)
        if nState ==-1 then
            nState = eNpcMissionNoQuest
        end
        pNpc:SetQuestState(nState)

    end
end

--[[
self.pos = 0
	self.id = 0
	self.kind = 0
	self.state = 0
	self.dstitemid = 0
	self.dstitemnum = 0
	self.dstnpckey = 0
	self.dstnpcid = 0

--]]
--stype=8 --tasktype
--key ==pos 
--baseID =3==anye
--bind = 1=taskinfo 2=help other
function Taskmanager:showAnyeInfoForClickChat(roleID, stype, key, baseID, bind, pTipsOctes)
    local _os_ = FireNet.Marshal.OctetsStream(pTipsOctes)
    if  _os_:eos() then
        return
    end


    self.anyeTaskData = {}
    self.anyeTaskData.pos = _os_:unmarshal_int32()
    self.anyeTaskData.id = _os_:unmarshal_int32()
    self.anyeTaskData.kind = _os_:unmarshal_int32()
    self.anyeTaskData.state = _os_:unmarshal_int32()
    self.anyeTaskData.dstitemid = _os_:unmarshal_int32()
    self.anyeTaskData.dstitemnum = _os_:unmarshal_int32()
    self.anyeTaskData.dstnpcid = _os_:unmarshal_int32()
    self.anyeTaskData.dstnpckey = _os_:unmarshal_int64()
    --------------------

    self.anyeTaskData.nLevel = _os_:unmarshal_int32()
    self.anyeTaskData.nSchool = _os_:unmarshal_int32()
    self.anyeTaskData.nnRoleId = roleID

    local nTaskDetailType = self.anyeTaskData.kind
    local eTaskState = self.anyeTaskData.state

    if bind==1 then
        --self:showAnyeTaskInfo(self.anyeTaskData) 
    elseif bind==2 then
        if roleID == gGetDataManager():GetMainCharacterID() then 
            GetCTipsManager():AddMessageTipById(166082)
            return
        end
        self:showCommitAnyeTask(self.anyeTaskData)
    end

end

--[[
self.pos = 0
	self.id = 0
	self.kind = 0
	self.state = 0
	self.dstitemid = 0
	self.dstitemnum = 0
	self.dstnpckey = 0
	self.dstnpcid = 0

--]]
--[[
local nCurlevel = GetMainCharacter():GetLevel()
    local repeatTable = GameTable.circletask.GetCRepeatTaskTableInstance():getRecorder(nTaskDetailId)
	if repeatTable.id ==-1 then
		return 
	end
	local nSchoolId =  gGetDataManager():GetMainCharacterSchoolID()
	local nGroupId = repeatTable.ngroupid

--]]


function Taskmanager:getTaskInfoCorrectSbForAll(oneTaskData,sb)

    local nTaskId = oneTaskData.id
    local nTaskDetailType = oneTaskData.kind
    local nNpcId = oneTaskData.dstnpcid
    local nItemId = oneTaskData.dstitemid
    local nItemNum = oneTaskData.dstitemnum
    local nPetId = oneTaskData.nPetId
    local nMapId = oneTaskData.dstmapid


    local nNumber = oneTaskData.nNumber
    local nNumber1 = oneTaskData.nNumber1
    local nQuality = oneTaskData.nQuality


    ----------------------------------
    local strItemName = ""
    local strPetName = ""
    local strMapName = ""
    local strNpcName = ""
    local nHaveItemNum = 0
    local nNeedItemNum = nItemNum
    local nQualityNum = nQuality

    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local itemTable = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
    if itemTable then
        strItemName = itemTable.name
        nHaveItemNum  = require("logic.task.taskhelperprotocol").getItemNumForTask(nItemId)
	    --nQuality = require("logic.task.taskhelpertable").GetQuality()
    end
    local petTable = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(nPetId)
    if petTable then
        strPetName = petTable.name
        nHaveItemNum = require("logic.task.taskhelper").getHavePetNumWithInBattle(nPetId) 
    end
    local mapTable = BeanConfigManager.getInstance():GetTableByName("map.cmapconfig"):getRecorder(nMapId)
    if mapTable and mapTable ~= nil then
        strMapName = mapTable.mapName
    end
    local npcTable = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(nNpcId)
    if npcTable then
        strNpcName = npcTable.name
    end
    ----------------------------------
    --local sb = StringBuilder:new()
    sb:Set("NPCName",strNpcName)
    sb:Set("MapName",strMapName)
    sb:Set("ItemName",strItemName)
    sb:Set("PetName",strPetName)
	sb:SetNum("Number2", nHaveItemNum)
	sb:SetNum("Number3", nNeedItemNum)
	sb:SetNum("Number4", nQualityNum)

   

    sb:SetNum("Number", nNumber)
    sb:SetNum("Number1", nNumber1)

end

function Taskmanager:getTaskInfoCorrectSb(anyeTaskData,sb)
    local oneTaskData = {}
    oneTaskData.id = anyeTaskData.id
    oneTaskData.kind = anyeTaskData.kind
    oneTaskData.dstnpcid = anyeTaskData.dstnpcid
    oneTaskData.dstitemid = anyeTaskData.dstitemid
    oneTaskData.dstitemnum = anyeTaskData.dstitemnum
    oneTaskData.dstmapid = anyeTaskData.dstmapid
    oneTaskData.nPetId = anyeTaskData.dstitemid

    oneTaskData.nQuality = anyeTaskData.nQuality

    self:getTaskInfoCorrectSbForAll(oneTaskData,sb)

end

function Taskmanager:showAnyeTaskInfo(anyeTaskData)
    
    require("logic.task.showtaskdetail").getInstanceAndShow():ShowTaskAnye(anyeTaskData)
end


function Taskmanager:clickCommitItem(commitDlg)
    
    if not gGetDataManager() then
        return
    end
    local oneTaskData = self.anyeTaskData
    local nRoleId = self.anyeTaskData.nnRoleId
    local nTaskId = oneTaskData.id
    local anyeTable = BeanConfigManager.getInstance():GetTableByName("circletask.canyemaxituanconf"):getRecorder(nTaskId)
	if anyeTable == nil then
		return 
	end

    local submitUnit  = require "protodef.rpcgen.fire.pb.circletask.anye.submitthing":new()
	local nItemKey = commitDlg.nCurItemKey
	submitUnit.key = nItemKey
	submitUnit.num = oneTaskData.dstitemnum

    local csubmitthings = require "protodef.fire.pb.circletask.anye.csubmitthings":new()
	csubmitthings.taskpos = oneTaskData.pos
    csubmitthings.taskid = anyeTable.nactivetype
    csubmitthings.taskrole = nRoleId
    csubmitthings.submittype = 1 --提交的类型 1道具 2宠物 3金钱
    csubmitthings.things[1] = submitUnit
	require "manager.luaprotocolmanager":send(csubmitthings)

    commitDlg:DestroyDialog()

end


function Taskmanager:clickCommitPet(commitDlg)
    
    if not gGetDataManager() then
        return
    end
    local oneTaskData = self.anyeTaskData
    local nRoleId = self.anyeTaskData.nnRoleId
    local nTaskId = oneTaskData.id
    local anyeTable = BeanConfigManager.getInstance():GetTableByName("circletask.canyemaxituanconf"):getRecorder(nTaskId)
	if anyeTable == nil then
		return 
	end

    local submitUnit  = require "protodef.rpcgen.fire.pb.circletask.anye.submitthing":new()
	local nItemKey = commitDlg.nCurItemKey
	submitUnit.key = nItemKey
	submitUnit.num = oneTaskData.dstitemnum
    local csubmitthings = require "protodef.fire.pb.circletask.anye.csubmitthings":new()
	csubmitthings.taskpos = oneTaskData.pos
    csubmitthings.taskid = anyeTable.nactivetype
    csubmitthings.taskrole = nRoleId
    csubmitthings.submittype = 2 --提交的类型 1道具 2宠物 3金钱
    csubmitthings.things[1] = submitUnit
	require "manager.luaprotocolmanager":send(csubmitthings)
end


--[[
NpcServiceManager.eItemOpenShopType = 
{
	npcShop =1,
	shangHui=2,
	baiTan=3,
	shangCheng=4,
}
--]]

function Taskmanager.getShopTypeWithNpcId(npcId)
	local ids = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cnpcsale")):getAllID()
	for _,id in pairs(ids) do
		local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cnpcsale")):getRecorder(id)
		if conf.npcId == npcId then
			ids = nil
			return conf.id
		end
	end
	ids = nil

end


function Taskmanager.openShopWithItemId(nItemId,nNeedItemNum)
    local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return
	end

    if NpcServiceManager.eItemOpenShopType.shangHui == itemAttrCfg.nshoptype then
        require("logic.shop.shoplabel").getInstance():showOnly(1)
		local commercedlg = require("logic.shop.commercedlg").getInstanceNotCreate()
		if commercedlg then
			commercedlg:selectGoodsByItemid(nItemId,nNeedItemNum)
		end
	elseif NpcServiceManager.eItemOpenShopType.baiTan == itemAttrCfg.nshoptype then
        if itemAttrCfg.special == 1 then  --特殊处理关于兽决的
            require("logic.shop.stalllabel").openStallToBuy()
            StallDlg.getInstance():openCatalog1ById(5)
        else
		    local stalldlg = require("logic.shop.stalllabel").openStallToBuy()
		    if stalldlg then
			    if stalldlg.buyArgs then
				    stalldlg.buyArgs:reset()
			    end
			    stalldlg:selectGoodsCatalogByItemid(nItemId)
		    end
        end

	elseif NpcServiceManager.eItemOpenShopType.shangCheng == itemAttrCfg.nshoptype then
		require("logic.shop.shoplabel").showMallShop()
		local mallshop = require("logic.shop.mallshop").getInstanceNotCreate()
		if mallshop then
			mallshop:selectGoodsByItemid(nItemId,nNeedItemNum)
		end
    elseif NpcServiceManager.eItemOpenShopType.npcShop == itemAttrCfg.nshoptype then
        local dlg = require("logic.shop.npcshop").getInstanceAndShow()
        local shopType = Taskmanager.getShopTypeWithNpcId(itemAttrCfg.npcid2)
	    dlg:setShopType(shopType)
        dlg:selectGoodsByItemid(nItemId,nNeedItemNum)
	end
end


function Taskmanager.openShopWithPetId(nItemId,nNeedItemNum)
    
    local petAttrCfg = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(nItemId)
    if not petAttrCfg then
        return
    end
    local dlg = require("logic.shop.npcpetshop").getInstanceAndShow()
    dlg:selectGoodsByPetId(nItemId)

end

function Taskmanager:showCommitAnyeTask(oneTaskData)
    local nTaskDetailType = oneTaskData.kind
    local nTaskTypeId = oneTaskData.id
    local nItemId = oneTaskData.dstitemid
    local nItemNum = oneTaskData.dstitemnum
    local nNpcKey = 0

    local eTaskState = oneTaskData.state
    if eTaskState == spcQuestState.SUCCESS then
       local strWanchengzi = require("utils.mhsdutils").get_msgtipstring(166066)
	   GetCTipsManager():AddMessageTip(strWanchengzi)
       return
    end
        local nItemId = oneTaskData.dstitemid

		if nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ItemFind then 
			local nItemId = oneTaskData.dstitemid
			local vItemKey = {}
			require("logic.task.taskhelperprotocol").GetItemKeyWithTableIdUseToItemTable(nItemId,vItemKey)
            if table.getn(vItemKey) == 0 then
                Taskmanager.openShopWithItemId(nItemId,nItemNum)
            
                return 
            end
            local Taskcommititemdialog = require "logic.task.taskcommititemdialog" 
	        local eType = Taskcommititemdialog.eCommitType.eAnye
			local commitItemDlg = require "logic.task.taskcommititemdialog".getInstance()
			commitItemDlg:SetCommitItemId(vItemKey,nNpcKey,eType,nTaskTypeId)
            commitItemDlg:setDelegateTarget(self,Taskmanager.clickCommitItem)
		elseif nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_PetCatch then
			local nPetId = oneTaskData.dstitemid
			local vPetKey = {}
			require("logic.task.taskhelperprotocol").GetHavePetWithIdUseToItemTable(nPetId,vPetKey)

            local nPeiKeyInBattle = gGetDataManager():GetBattlePetID()
	
	        local vItemKey = {}
	        for k,nPetKey in pairs(vPetKey) do 
		        if nPetKey ~= nPeiKeyInBattle then
			        vItemKey[#vItemKey +1] = nPetKey
		        end
            end
            if table.getn( vItemKey) == 0 then
                Taskmanager.openShopWithPetId(nItemId,nItemNum)
            
                return 
            end

            local commitItemDlg = require "logic.task.taskcommitpetdialog".getInstance()
			commitItemDlg:SetCommitItemId(vPetKey,nNpcKey,nTaskTypeId)
            commitItemDlg:setDelegateTarget(self,Taskmanager.clickCommitPet)
			
		end
end


function Taskmanager:setPingRedVisible(bVis)
	self.bPingDingTaskRedVis = bVis
	local logodlg = require("logic.logo.logoinfodlg").getInstanceNotCreate()
	if logodlg then
			logodlg:RefreshAllBtn()
	end
end

function Taskmanager:lockGoto()
	LogInfo(" Taskmanager:lockGoto()")
	if self.bLockGoto then
		return
	end
	self.bLockGoto = true
	
	LogInfo(" Taskmanager:lockGoto()=true")
	--Tasktimermanager.eTimerType.repeatCount =1,
	--repeatEver =2,
	local timerData = {}
    require("logic.task.tasktimermanager").getInstance():getTimerDataInit(timerData)
	--//=======================================
	timerData.nId = Tasktimermanager.eTimerId.lockGoto
	timerData.eType = Tasktimermanager.eTimerType.repeatCount
	timerData.nDurTime = 0.5
	timerData.nDurTimeDt = 0
	timerData.repeatCount = 1
	timerData.repeatCountDt = 0
	timerData.functionName = Taskmanager.timerCallBack
	--timerData.nParam1 = nTaskTypeId
	--//=======================================
	require("logic.task.tasktimermanager").getInstance():addTimer(timerData)
	
end

function Taskmanager.timerCallBack(nParam1)
	LogInfo("Taskmanager.timerCallBack(nParam1)")
	if not _instance then 
		return
	end
	LogInfo("Taskmanager.timerCallBack(nParam1)=bLockGoto=false")
	_instance.bLockGoto = false
end

function Taskmanager.Destroy()
    if _instance then 
		_instance:ClearData()
        _instance = nil
    end
end

function Taskmanager.getInstance()
	if not _instance then
		_instance = Taskmanager:new()
	end
	return _instance
end


function Taskmanager:addBuff(nBuffId)
	local buff = require("logic.task.taskbuff"):new()
	buff.nBuffId = nBuffId
	--buff.nTaskType =
	self.mapTaskBuff[nBuffId] = buff
	buff:beginBuff()
	
end

function Taskmanager:deleteBuff(nBuffId)
	for nId,buff in pairs(self.mapTaskBuff) do 
		if nBuffId==nId then
			buff:endBuff()
			table.remove(self.mapTaskBuff,nId)
			break
		end
	end
end

function Taskmanager:getBuffWithId(nBuffId)
	for nId,buff in pairs(self.mapTaskBuff) do 
		if nBuffId==nId then
			return buff
		end
	end
	return nil
end


function Taskmanager:updateInvite()
     if GetBattleManager():IsInBattle() then
        return
     end
     local oneInvite = self.vInvitePlayer[1]
     if not oneInvite then
        return
     end
     require("logic.task.taskhelpernpc").sgeneralsummoncommand_process(oneInvite)
     table.remove(self.vInvitePlayer,1)
end


function Taskmanager:update(delta)
    self:updateInvite()
    if self.fFactionHelpCd > 0 then
        self.fFactionHelpCd = self.fFactionHelpCd - delta
    end
    if self.fFactionHelpCd < 0 then
        self.fFactionHelpCd = 0
    end
	--local dt = delta/1000
	for nId,buff in pairs(self.mapTaskBuff) do 
		buff:update(delta)
	end
	
	require ("logic.task.tasktimermanager").getInstance():update(delta)
end

function Taskmanager:isRepeatTaskHaveShowGetDoublePoint(nTaskTypeId)
	for k,nTaskId in pairs(self.vHaveShowGetBoublePoint) do 
		if nTaskId == nTaskTypeId then
			return true
		end
	end
	return false
end


Taskmanager.eOpenShopType =
{ 
    petshop =1,
    npcshop =2,
    shanghui =3,
    baitan =4,
    shangcheng=5
}

function Taskmanager:repeatTaskDoneCall()
    if self.eOpenShopType == Taskmanager.eOpenShopType.petshop then
         require("logic.shop.npcpetshop").DestroyDialog()
    --[[
        local dlg = require("logic.shop.npcpetshop").getInstanceNotCreate()
        if dlg then
            dlg:OnClose()
        end
     --]]

    elseif  self.eOpenShopType == Taskmanager.eOpenShopType.npcshop then
        require("logic.shop.npcshop").DestroyDialog()

    elseif  self.eOpenShopType == Taskmanager.eOpenShopType.shanghui or
            self.eOpenShopType == Taskmanager.eOpenShopType.baitan or
            self.eOpenShopType == Taskmanager.eOpenShopType.shangcheng then
        require("logic.shop.shoplabel").hide()
    end

    self.eOpenShopType = -1
end

function Taskmanager:setTaskOpenShopType(nType)
    self.eOpenShopType = nType
end


function Taskmanager:getServerOpenCurDay()
    local nCurLevel = gGetDataManager():getServerLevel()
    local vAllId =  BeanConfigManager.getInstance():GetTableByName("role.cservicelevelconfig"):getAllID()
    for _, v in pairs(vAllId) do
        local record1 = BeanConfigManager.getInstance():GetTableByName("role.cservicelevelconfig"):getRecorder(v)
		if record1.slevel == nCurLevel then
             return record1.openday
        end
    end

    return -1
end

function Taskmanager:showTip(nCurDay)
    local nnSendTime = gGetServerTime()/1000
    local nAddSecondInOpen = (7-nCurDay+1)* 24*60*60 

    local timeData = StringCover.getTimeStruct(nnSendTime+nAddSecondInOpen)

    local nYear = timeData.tm_year + 1900
	local nMonth = timeData.tm_mon + 1
	local nDay = timeData.tm_mday
    --开服7天后($parameter1$年$parameter2$月$parameter3$日0点)开启暗夜马戏团
    local sb = StringBuilder:new()
    sb:Set("parameter1",tostring(nYear))
    sb:Set("parameter2",tostring(nMonth))
    sb:Set("parameter3",tostring(nDay))

    local strWanchengzi = require("utils.mhsdutils").get_resstring(11593)
    strWanchengzi = sb:GetString(strWanchengzi)
    sb:delete()

	 GetCTipsManager():AddMessageTip(strWanchengzi)

end

return Taskmanager
