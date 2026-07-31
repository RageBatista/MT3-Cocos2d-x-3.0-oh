
require "utils.binutil"

CBankConfigTable = {}
CBankConfigTable.__index = CBankConfigTable

function CBankConfigTable:new()
	local self = {}
	setmetatable(self, CBankConfigTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CBankConfigTable:getRecorder(id)
	return self.m_cache[id]
end

function CBankConfigTable:getAllID()
	return self.allID
end

function CBankConfigTable:getSize()
	return self.memberCount
end

function CBankConfigTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=720977 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.buynummin = util:Load_int()
		if not status then return false end
		status,bean.buynummax = util:Load_int()
		if not status then return false end
		status,bean.buyunitmin = util:Load_int()
		if not status then return false end
		status,bean.buyunitmax = util:Load_int()
		if not status then return false end
		status,bean.buyfee = util:Load_double()
		if not status then return false end
		status,bean.sellnummin = util:Load_int()
		if not status then return false end
		status,bean.sellnummax = util:Load_int()
		if not status then return false end
		status,bean.sellunitmin = util:Load_int()
		if not status then return false end
		status,bean.sellunitmax = util:Load_int()
		if not status then return false end
		status,bean.cellfee = util:Load_double()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CBankConfigTable
