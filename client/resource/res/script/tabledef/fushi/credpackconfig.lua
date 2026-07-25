
require "utils.binutil"

CRedPackConfigTable = {}
CRedPackConfigTable.__index = CRedPackConfigTable

function CRedPackConfigTable:new()
	local self = {}
	setmetatable(self, CRedPackConfigTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CRedPackConfigTable:getRecorder(id)
	return self.m_cache[id]
end

function CRedPackConfigTable:getAllID()
	return self.allID
end

function CRedPackConfigTable:getSize()
	return self.memberCount
end

function CRedPackConfigTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=655428 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.name = util:Load_string()
		if not status then return false end
		status,bean.fushimin = util:Load_int()
		if not status then return false end
		status,bean.fishimax = util:Load_int()
		if not status then return false end
		status,bean.daysendmax = util:Load_int()
		if not status then return false end
		status,bean.dayreceivemax = util:Load_int()
		if not status then return false end
		status,bean.dayfushisendmax = util:Load_int()
		if not status then return false end
		status,bean.packmin = util:Load_int()
		if not status then return false end
		status,bean.packmax = util:Load_int()
		if not status then return false end
		status,bean.level = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CRedPackConfigTable
