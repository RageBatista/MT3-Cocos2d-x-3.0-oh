
Tasktimermanager = {}
Tasktimermanager.__index = Tasktimermanager
local _instance = nil

Tasktimermanager.eTimerType=
{
	repeatCount =1,
	repeatEver =2,
}

Tasktimermanager.eTimerId=
{
	delayRepeatTask =1,
	lockGoto =2,
}


function Tasktimermanager:new()
    local self = {}
    setmetatable(self, Tasktimermanager)
	self:ClearData()
    return self
end

function Tasktimermanager:ClearData()
	self.mapTimer = {}
	self.mapTimerNeedToAdd = {}
	self.mapTimerNeedToDelete = {}
end

function Tasktimermanager.Destroy()
    if _instance then 
		_instance:ClearData()
        _instance = nil
    end
end


function Tasktimermanager:getTimerDataInit(timerData)
	
	timerData.nId = 0
	timerData.eType = 0
	timerData.nDurTime = 0
	timerData.nDurTimeDt =0
	timerData.repeatCount = 0
	timerData.repeatCountDt =0
	timerData.functionName = 0
	timerData.nParam1 = 0
end

function Tasktimermanager.getInstance()
	if not _instance then
		_instance = Tasktimermanager:new()
	end
	return _instance
end

function Tasktimermanager:getTimerDataWithId(nId)
	local timerData = self.mapTimer[nId]
	return timerData
end

function Tasktimermanager:addTimer(timerData)
	LogInfo("Tasktimermanager:addTimer(timerData)")
	local nId = timerData.nId
	self.mapTimerNeedToAdd[nId] = timerData
end

function Tasktimermanager:deleteTimer(nId)
	self.mapTimerNeedToDelete[#self.mapTimerNeedToDelete + 1] = nId
end

function Tasktimermanager:clearAllTimer()
	
end


function Tasktimermanager:updateToAdd(delta) --mao miao
	for nId,timerData in pairs(self.mapTimerNeedToAdd) do
		self.mapTimer[nId] = timerData
		LogInfo("Tasktimermanager:updateToAdd()=nId="..nId)
	end
	self.mapTimerNeedToAdd = {}
end


function Tasktimermanager:updateToDelete(delta) --hao miao
	for k,nId in pairs(self.mapTimerNeedToDelete) do
		table.remove(self.mapTimer,nId)
		self.mapTimer[nId] = nil
		LogInfo("Tasktimermanager:updateToDelete()=nId="..nId)
	end
	self.mapTimerNeedToDelete = {}
end

function Tasktimermanager:update(delta)
	--LogInfo("Tasktimermanager:update=delta="..delta)
	
	local nDt = delta/1000
	
	self:updateToAdd(delta)
	self:updateToDelete(delta)
	
	for nId,timerData in pairs(self.mapTimer) do
		if timerData.eType == Tasktimermanager.eTimerType.repeatCount then
			timerData.nDurTimeDt = timerData.nDurTimeDt  + nDt
			if timerData.nDurTimeDt >= timerData.nDurTime then
				timerData.nDurTimeDt = 0
				timerData.repeatCountDt = timerData.repeatCountDt +1
				if timerData.repeatCountDt > timerData.repeatCount then
					self:deleteTimer(nId)
				else
					
					LogInfo("Tasktimermanager=functionName=timerData.repeatCountDt="..timerData.repeatCountDt)
					timerData.functionName(timerData.nParam1)
				end
			end
		elseif timerData.eType == Tasktimermanager.eTimerType.repeatEver then
			timerData.nDurTimeDt = timerData.nDurTimeDt  + nDt
			if timerData.nDurTimeDt >= timerData.nDurTime then
				
				LogInfo("Tasktimermanager=functionName=timerData.nDurTimeDt="..timerData.nDurTimeDt)
				timerData.nDurTimeDt = 0
				timerData.functionName(timerData.nParam1)
			end
		end		
	end
	
end

return Tasktimermanager
