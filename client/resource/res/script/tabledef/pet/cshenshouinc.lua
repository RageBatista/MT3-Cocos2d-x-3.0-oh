
require "utils.binutil"

CShenShouIncTable = {}
CShenShouIncTable.__index = CShenShouIncTable

function CShenShouIncTable:new()
	local self = {}
	setmetatable(self, CShenShouIncTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CShenShouIncTable:getRecorder(id)
	return self.m_cache[id]
end

function CShenShouIncTable:getAllID()
	return self.allID
end

function CShenShouIncTable:getSize()
	return self.memberCount
end

function CShenShouIncTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=655425 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.petid = util:Load_int()
		if not status then return false end
		status,bean.inccount = util:Load_int()
		if not status then return false end
		status,bean.attinc = util:Load_int()
		if not status then return false end
		status,bean.atkinc = util:Load_int()
		if not status then return false end
		status,bean.definc = util:Load_int()
		if not status then return false end
		status,bean.hpinc = util:Load_int()
		if not status then return false end
		status,bean.mpinc = util:Load_int()
		if not status then return false end
		status,bean.spdinc = util:Load_int()
		if not status then return false end
		status,bean.inclv = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CShenShouIncTable
