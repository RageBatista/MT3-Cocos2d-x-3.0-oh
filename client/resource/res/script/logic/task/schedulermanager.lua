
Schedulermanager = {}
Schedulermanager.__index = Schedulermanager
local _instance = nil

Schedulermanager.eTimerType=
{
	repeatCount =1,
	repeatEver =2,
}

local nSchedulerId = 0

function Schedulermanager:new()
    local self = {}
    setmetatable(self, Schedulermanager)
	self:ClearData()
    return self
end

function Schedulermanager:ClearData()
	self.mapTimer = {}
	self.mapTimerNeedToAdd = {}
    nSchedulerId = 0
end

function Schedulermanager.Destroy()
    if _instance then 
		_instance:ClearData()
        _instance = nil
    end
end


function Schedulermanager:getTimerDataInit(timerData)
	nSchedulerId = nSchedulerId +1

	timerData.nId = nSchedulerId
	timerData.eType = 0
	timerData.fDurTime = 0
	timerData.fDurTimeDt =0
	timerData.nRepeatCount = 0
	timerData.nRepeatCountDt =0
	
	timerData.nParam1 = 0

    timerData.pTarget= nil
    timerData.callback=nil

    timerData.bToDelete = false
    timerData.fDurTimeAllDt = 0
    
end

function Schedulermanager.getInstance()
	if not _instance then
		_instance = Schedulermanager:new()
	end
	return _instance
end

function Schedulermanager:getTimerDataWithId(nId)
	local timerData = self.mapTimer[nId]
	return timerData
end

function Schedulermanager:isHaveTiemr(pTarget,callback)

    for nId,timerData in pairs(self.mapTimerNeedToAdd) do
        if timerData.pTarget==pTarget and timerData.callback==callback then
            return nId
        end
    end 

    for nId,timerData in pairs(self.mapTimer) do
        if timerData.pTarget==pTarget and timerData.callback==callback then
            return nId
        end
    end 
    return -1
end

function Schedulermanager:addTimer(timerData)
    local nIdHave =self:isHaveTiemr(timerData.pTarget,timerData.callback)
    if nIdHave ~= -1 then
        return
    end
	local nId = timerData.nId
	self.mapTimerNeedToAdd[nId] = timerData
end

function Schedulermanager:deleteTimer(nId)
   self.mapTimer[nId].bToDelete = true

   for k,timerData in pairs(self.mapTimerNeedToAdd) do
        if timerData and timerData.nId == nId then
            self.mapTimerNeedToAdd[k] = nil
        end
	end

end



function Schedulermanager:deleteTimerWithTargetAndCallBak(pTarget,callBack)
    for nId,timerData in pairs(self.mapTimer) do
        if timerData.pTarget==pTarget and timerData.callback==callBack then
            timerData.bToDelete = true
            timerData.pTarget = nil
        end
    end 

    for k,timerData in pairs(self.mapTimerNeedToAdd) do
        if timerData and timerData.pTarget==pTarget and timerData.callback==callBack then
            self.mapTimerNeedToAdd[k] = nil
        end
	end
end

function Schedulermanager:deleteTimerWithTarget(pTarget)
    for nId,timerData in pairs(self.mapTimer) do
        if timerData.pTarget==pTarget then
            timerData.bToDelete = true
            timerData.pTarget = nil
        end
    end 

    for k,timerData in pairs(self.mapTimerNeedToAdd) do
        if timerData and timerData.pTarget==pTarget  then
            self.mapTimerNeedToAdd[k] = nil
        end
	end
end

function Schedulermanager:clearAllTimer()
	
end


function Schedulermanager:updateToAdd(delta) --mao miao
	for nId,timerData in pairs(self.mapTimerNeedToAdd) do
		self.mapTimer[nId] = timerData
		LogInfo("Schedulermanager:updateToAdd()=nId="..nId)
	end
	self.mapTimerNeedToAdd = {}
end


function Schedulermanager:updateToDelete(delta) --hao miao
    local vTimerNeedToDelete = {}
    for nId,timerData in pairs(self.mapTimer) do
        if timerData then
            if timerData.bToDelete == true then
                vTimerNeedToDelete[#vTimerNeedToDelete + 1] = nId
            end
        end
    end 
	for k,nId in pairs(vTimerNeedToDelete) do
        self.mapTimer[nId] = nil
	end
end

function Schedulermanager:update(delta)
	--LogInfo("Schedulermanager:update=delta="..delta)
	
	local fDt = delta/1000
	
	self:updateToAdd(delta)
	self:updateToDelete(delta)
	
	for nId,timerData in pairs(self.mapTimer) do
		self:updateTimer(fDt,timerData)
	end
	
end

function Schedulermanager:updateTimer(fDt,timerData)
    if not timerData then
        return
    end
    if timerData.bToDelete == true then
        return
    end

    local nId = timerData.nId
    timerData.fDurTimeAllDt = timerData.fDurTimeAllDt  + fDt
    if timerData.eType == Schedulermanager.eTimerType.repeatCount then
			timerData.fDurTimeDt = timerData.fDurTimeDt  + fDt

			if timerData.fDurTimeDt >= timerData.fDurTime then
				timerData.fDurTimeDt = 0
				timerData.nRepeatCountDt = timerData.nRepeatCountDt +1

				if timerData.nRepeatCountDt > timerData.nRepeatCount then
					--self:deleteTimer(nId)
				else
					LogInfo("Schedulermanager=functionName=timerData.repeatCountDt="..timerData.nRepeatCountDt)
                    if timerData.pTarget and timerData.callback then
					    timerData.callback(timerData.pTarget,timerData)
                    end
				end
			end
            if timerData.nRepeatCountDt >= timerData.nRepeatCount then
                   self.mapTimer[nId] = nil
			end
	elseif timerData.eType == Schedulermanager.eTimerType.repeatEver then
			timerData.fDurTimeDt = timerData.fDurTimeDt  + fDt
			if timerData.fDurTimeDt >= timerData.fDurTime then
				
				LogInfo("Schedulermanager=functionName=timerData.nDurTimeDt="..timerData.fDurTimeDt)
				timerData.fDurTimeDt = 0
                if timerData.pTarget and timerData.callback then
				    timerData.callback(timerData.pTarget,timerData)
                end
			end
	end	
end

return Schedulermanager
