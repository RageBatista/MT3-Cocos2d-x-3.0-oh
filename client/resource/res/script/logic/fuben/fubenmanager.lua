
Fubenmanager = {}
Fubenmanager.__index = Fubenmanager
local _instance = nil


function Fubenmanager:new()
    local self = {}
    setmetatable(self, Fubenmanager)
	self:ClearData()
    return self
end

function Fubenmanager:ClearData()
	self.mapFubenData = {}
	self.nUpdateSpace = 1
	self.nUpdateSpaceDt = 0
	self.mapFubenTable = {}
	self.bInFuben = false
end

function Fubenmanager:setInFuben(bIn)
	self.bInFuben = bIn
end

function Fubenmanager:isInFuben()
	return self.bInFuben
end

function Fubenmanager.Destroy()
    if _instance then 
		_instance:ClearData()
        _instance = nil
    end
end

function Fubenmanager.getInstance()
	if not _instance then
		_instance = Fubenmanager:new()
	end
	return _instance
end


function Fubenmanager:update(delta)
	local dt = delta / 1000
	
	self.nUpdateSpaceDt = self.nUpdateSpaceDt + dt
	if self.nUpdateSpaceDt >= self.nUpdateSpace then
		self.nUpdateSpaceDt = 0
		self:refreshAllFubenState(dt)
	end
end

function Fubenmanager:getTimeString_H_M_S(nSecond)
	
end

		
function Fubenmanager:refreshAllFubenState(dt)
	
	for nFubenId,funbenData in pairs(self.mapFubenData) do 
		local nServerTimeSecond = gGetServerTime() / 1000
		local nBeginTime = funbenData.starttime 
		local nEndTime = funbenData.endtime
		
		if nServerTimeSecond > nEndTime then
			funbenData.instancestate = 0 
		end
	end
end

function Fubenmanager:getLevelTypeMax()
	local nLevelTypeMax = 0
	local vcId =  BeanConfigManager.getInstance():GetTableByName("mission.cjingyingrenwutask"):getAllID()
    local nAllNum = #vcId
	
	for nIndex=1, nAllNum do 
		local nFubenId = vcId[nIndex]
		local funbenTable = BeanConfigManager.getInstance():GetTableByName("mission.cjingyingrenwutask"):getRecorder(nFubenId)
		if funbenTable and funbenTable.id ~= -1 then
			local nLevelType = funbenTable.nleveltype
			if nLevelType > nLevelTypeMax then
				nLevelTypeMax = nLevelType
			end
		end
	end
	
	return nLevelTypeMax
end


function Fubenmanager:isHaveFubenTableWithType(nFubenType)
	for nFubenId,fubenTableData in pairs(self.mapFubenTable) do 
		if nFubenType == fubenTableData.nfubenid then
			return true
		end
	end
	return false
end


--nLevelType 1 = 40--60 2 60

function Fubenmanager:getFubenDataWithId(nFubenId)
	for nId,funbenData in pairs(self.mapFubenData) do 
		if  nFubenId == nId then
			return funbenData
		end
	end
	return nil
end

function Fubenmanager:clearMapFuben()
	self.mapFubenData = {}
end

function Fubenmanager:sgetinstancestate_process(sgetinstancestate)
	LogInfo("Fubenmanager:sgetinstancestate_process(sgetinstancestate)")
	self:clearMapFuben()
	
	local mapData = sgetinstancestate.instances
	
	for nFubenId ,data in pairs(mapData) do 
		local fubenData = InstanceInfo:new()
		fubenData.id  = data.id
		fubenData.instancestate = data.instancestate
		fubenData.state  = data.state
		fubenData.finishedtimes  = data.finishedtimes
		fubenData.starttime  = data.starttime
		fubenData.endtime  = data.endtime
		fubenData.totaltimes  = data.totaltimes
		LogInfo("=======================")
		for k ,v in pairs(fubenData ) do
			LogInfo(k.."="..v)
		end
		self.mapFubenData[nFubenId] = fubenData
		
	end
	local fubenDlg = require("logic.fuben.fubendlg").getInstance()
	--fubenDlg:refreshUI()
	local nDiff = 1
	local nLevelType = 1
	fubenDlg:refreshUI(nDiff,nLevelType)
	--for k,v in pairs()
end

function Fubenmanager:getFubenDataWithDiffAndLevelType(nDiff,nLevelType,vFubenId)
	
	LogInfo("Fubenmanager:getFubenDataWithDiffAndLevelType(nDiff,nLevelType,vFubenId)")
	
	for nFubenId,funbenData in pairs(self.mapFubenData) do 
		local funbenTable = BeanConfigManager.getInstance():GetTableByName("mission.cjingyingrenwutask"):getRecorder(nFubenId)
		if funbenTable and funbenTable.id ~= -1 then
			local nFubenType = funbenTable.nfubenid
			
			local bHaveType = self:isHaveFubenTypeWithType(vFubenId,nFubenType)
			if not bHaveType then
				if funbenTable.ndifficult == nDiff and
					funbenTable.nleveltype == nLevelType 
				then
					vFubenId[#vFubenId +1] = nFubenId
				end
			end			
		end
	end
	for k,v in pairs(vFubenId) do 
		LogInfo("fubenId="..v)
	end
end

function Fubenmanager:isHaveFubenTypeWithType(vFubenId,nFubenType)
	for nIndex, nFubenId in pairs(vFubenId) do 
		local funbenTable = BeanConfigManager.getInstance():GetTableByName("mission.cjingyingrenwutask"):getRecorder(nFubenId)
		if funbenTable and funbenTable.id ~= -1 then
			if funbenTable.nfubenid == nFubenType then
			   return true
			end
		end
	end
	return false
end


function Fubenmanager:getSameLunhuanzuId(nFubenIdCur,vFubenId)
	LogInfo("Fubenmanager:getSameLunhuanzuId(nFubenIdCur,vFubenId)")
	local funbenTableCur = BeanConfigManager.getInstance():GetTableByName("mission.cjingyingrenwutask"):getRecorder(nFubenIdCur)
	local nLunhuanzuId = funbenTableCur.turngroup
	
	--local vFuBenId = {}
	
	local vcId = BeanConfigManager.getInstance():GetTableByName("mission.cjingyingrenwutask"):getAllID()
    local nAllNum = #vcId
	for nIndex=1, nAllNum do 
		local nFubenId = vcId[nIndex]
		local funbenTable = BeanConfigManager.getInstance():GetTableByName("mission.cjingyingrenwutask"):getRecorder(nFubenId)
		if funbenTable and funbenTable.id ~= -1 then
			if funbenTable.turngroup == nLunhuanzuId then
				--local nOrder = funbenTable.turnid
				vFubenId[#vFubenId + 1] = nFubenId
				LogInfo("same groupnFubenId="..nFubenId)
			end
		end
	end
	
end 

function Fubenmanager:getOpenId(vFubenId)
	for nOrder,nFubenId in pairs(vFubenId) do 
		local fubenData = self:getFubenDataWithId(nFubenId)
		if fubenData.instancestate == 1 then
			return nFubenId
		end
	end
	return -1
end

function  Fubenmanager:getOrderWithFubenId(nFubenId)
	local funbenTable = BeanConfigManager.getInstance():GetTableByName("mission.cjingyingrenwutask"):getRecorder(nFubenId)
	if not funbenTable then
		return -1
	end
	local nOrder = funbenTable.turnid
	return nOrder
end

function Fubenmanager:getOrderSpace(nAllNum,nNum1,nNum2)
	LogInfo("Fubenmanager:getOrderSpace(nAllNum,nNum1,nNum2)")
	
	LogInfo("nNum1"..nNum1)
	LogInfo("nNum2"..nNum2)
	LogInfo("nAllNum"..nAllNum)
	local nSpace = 0
	if nNum1 < nNum2 then
		nSpace = nNum2 - nNum1
	else
		
		nSpace = nAllNum - nNum1 + nNum2
	end
	return nSpace
end

function Fubenmanager:getTimeTitleForWeek(nFubenId)
	
	local fubenData = self:getFubenDataWithId(nFubenId)
	if not fubenData then
		return
	end
	
	if fubenData.instancestate == 0 then --wei
		local vFubenId = {} --{456}
		self:getSameLunhuanzuId(nFubenId,vFubenId)
		
		local nOpenId = self:getOpenId(vFubenId)
		local nAllOrderNum = #vFubenId
		local nOpenIdOrder = self:getOrderWithFubenId(nOpenId)
		local nCurOrder = self:getOrderWithFubenId(nFubenId)
		
		local nSpace = self:getOrderSpace(nAllOrderNum,nOpenIdOrder,nCurOrder)
		
		
		if nSpace ==1 then --xia zhou
			strTitleDate =  require "utils.mhsdutils".get_resstring(11253)
		elseif  nSpace ==2 then
			strTitleDate =  require "utils.mhsdutils".get_resstring(11256)
		end
		
	elseif  fubenData.instancestate == 1 then
		strTitleDate =  require "utils.mhsdutils".get_resstring(11252)
	end

	return strTitleDate
	
	
end

function Fubenmanager:getTimeTitle(nFubenId)
	
	local fubenData = self:getFubenDataWithId(nFubenId)
	local funbenTable = BeanConfigManager.getInstance():GetTableByName("mission.cjingyingrenwutask"):getRecorder(nFubenId)
	if not fubenData then
		return
	end
	local strTitleDate = funbenTable.strkaiqitime
	if funbenTable.nlunhuantype == 1 then
		strTitleDate = funbenTable.strkaiqitime
	elseif  funbenTable.nlunhuantype == 2 then 
		strTitleDate = self:getTimeTitleForWeek(nFubenId)
		
	end
	return strTitleDate
end

function Fubenmanager:checkForSendExitFuben()
	local bInFuben = require("logic.fuben.fubenmanager").getInstance():isInFuben()
	if bInFuben then
		LogInfo("Fubenmanager=bInFuben=true")
		local actionReg = require("protodef.fire.pb.npc.cexitcopy").Create()
		actionReg.gototype = 1
		require("manager.luaprotocolmanager").getInstance():send(actionReg)
	end
end

return Fubenmanager
