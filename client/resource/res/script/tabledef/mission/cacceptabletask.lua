
require "utils.binutil"

CAcceptableTaskTable = {}
CAcceptableTaskTable.__index = CAcceptableTaskTable

function CAcceptableTaskTable:new()
	local self = {}
	setmetatable(self, CAcceptableTaskTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CAcceptableTaskTable:getRecorder(id)
	return self.m_cache[id]
end

function CAcceptableTaskTable:getAllID()
	return self.allID
end

function CAcceptableTaskTable:getSize()
	return self.memberCount
end

function CAcceptableTaskTable:LoadBeanFromBinFile(filename)
	local util = BINUtil:new()
	local ret = util:init(filename)
	if not ret then
		return false
	end
	local status=1
	local fileType,fileLength,version,memberCount,checkNumber
	status,fileType=util:Load_int()
	if not status then return false end
	if fileType~=1499087948 then
		return false
	end
	status,fileLength=util:Load_int()
	if not status then return false end
	status,version=util:Load_short()
	if not status then return false end
	if version~=101 then
		return false
	end
	status,memberCount=util:Load_short()
	if not status then return false end
	self.memberCount=memberCount
	status,checkNumber=util:Load_int()
	if not status then return false end
	if checkNumber~=983190 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.minilevel = util:Load_int()
		if not status then return false end
		status,bean.destnpcid = util:Load_int()
		if not status then return false end
		status,bean.miniicon = util:Load_string()
		if not status then return false end
		status,bean.name = util:Load_string()
		if not status then return false end
		status,bean.aim = util:Load_string()
		if not status then return false end
		status,bean.discribe = util:Load_string()
		if not status then return false end
		status,bean.rewardtext = util:Load_string()
		if not status then return false end
		status,bean.expreward = util:Load_int()
		if not status then return false end
		status,bean.moneyreward = util:Load_int()
		if not status then return false end
		status,bean.rmoneyreward = util:Load_int()
		if not status then return false end
		status,bean.itemsreward = util:Load_Vint()
		if not status then return false end
		status,bean.reputationreward = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CAcceptableTaskTable
