
Buffmanager = {}
Buffmanager.__index = Buffmanager
local _instance = nil


function Buffmanager:new()
    local self = {}
    setmetatable(self, Buffmanager)
	self:ClearData()
    return self
end

function Buffmanager:ClearData()
	
	self.mapBuff = {}
end

function Buffmanager.getInstance()
	if not _instance then
		_instance = Buffmanager:new()
	end
	return _instance
end

function Buffmanager:sbuffchangeresult_process(sbuffchangeresult)
	LogInfo(" Buffmanager:sbuffchangeresult_process(sbuffchangeresult)")
	local agenttype = sbuffchangeresult.agenttype
	local id = sbuffchangeresult.id
	local petid = sbuffchangeresult.petid
	local addedbuffs = sbuffchangeresult.addedbuffs
	self:addBuff(addedbuffs)
	local deletedbuffs = sbuffchangeresult.deletedbuffs
	self:deleteBuff(deletedbuffs)
end

function Buffmanager:addBuff(addedbuffs)
	require "protodef.rpcgen.fire.pb.buff.buff"
	LogInfo("Buffmanager:addBuff(addedbuffs)")
	if not addedbuffs then
		return
	end
	for nBuffId,v in pairs(addedbuffs) do 
		LogInfo("Buffmanager:addBuff=buffid="..nBuffId)
		--//============================
		local newvalue = Buff:new()
		newvalue.time = v.time
		newvalue.count = v.count
		for kk,vv in pairs(v.tipargs) do 
			newvalue.tipargs[kk] = vv
		end
		--//============================
		self.mapBuff[nBuffId] = newvalue
		local nTimeEnd = newvalue.time
		LogInfo("Buffmanager:addBuff=time="..nTimeEnd)
	end
	require("logic.task.taskhelperrepeat").addBuff(addedbuffs)
end

function Buffmanager:deleteBuff(deletedbuffs)
	LogInfo("Buffmanager:deleteBuff(deletedBuffs)")
	local nNumBuff  = #deletedbuffs
	LogInfo("nNumBuff="..nNumBuff)
	
	for k,v in pairs(deletedbuffs) do 
		local nBuffId = v
		--local buffData = self.mapBuff[nBuffId]
		--buffData.tipargs = nil
		LogInfo("Buffmanager:deleteBuff=nBuffId="..nBuffId)
		--table.remove(self.mapBuff,nBuffId)
		self:removeBuff(nBuffId)
	end
	require("logic.task.taskhelperrepeat").deleteBuff(deletedbuffs)
end

function Buffmanager:removeBuff(nBuffId)
	
	for k,v in pairs(self.mapBuff) do 
		if k == nBuffId then
			LogInfo("Buffmanager:removeBuff(nBuffId)="..nBuffId)
			table.remove(self.mapBuff,k)
			self.mapBuff[k] = nil
		end
	end
	for k,v in pairs(self.mapBuff) do 
		LogInfo("Buffmanager:removeBuff(nBuffId)=mapbuff=buffid="..k)
	end
	
end


function Buffmanager:getBuffDataWithId(nBuffId)
	LogInfo("Buffmanager:getBuffDataWithId(nBuffId)=nBuffId"..nBuffId)
	local buffData = self.mapBuff[nBuffId]
	if buffData then
		LogInfo("Buffmanager:getBuffDataWithId(nBuffId)=buffData.time="..buffData.time)
	end
	return buffData
	
end



function Buffmanager:update(delta)
	local dt = delta/1000
	for k,buffData in pairs(self.mapBuff) do 
		buffData.time = buffData.time - dt
	end
end

return Buffmanager
