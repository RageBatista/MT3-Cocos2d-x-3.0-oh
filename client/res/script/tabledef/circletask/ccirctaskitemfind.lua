
require "utils.binutil"

CCircTaskItemFindTable = {}
CCircTaskItemFindTable.__index = CCircTaskItemFindTable

function CCircTaskItemFindTable:new()
	local self = {}
	setmetatable(self, CCircTaskItemFindTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CCircTaskItemFindTable:getRecorder(id)
	return self.m_cache[id]
end

function CCircTaskItemFindTable:getAllID()
	return self.allID
end

function CCircTaskItemFindTable:getSize()
	return self.memberCount
end

function CCircTaskItemFindTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=786525 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.ctgroup = util:Load_int()
		if not status then return false end
		status,bean.school = util:Load_int()
		if not status then return false end
		status,bean.levelmin = util:Load_int()
		if not status then return false end
		status,bean.levelmax = util:Load_int()
		if not status then return false end
		status,bean.recycleitem = util:Load_string()
		if not status then return false end
		status,bean.itemnum = util:Load_int()
		if not status then return false end
		status,bean.islegend = util:Load_int()
		if not status then return false end
		status,bean.legendtime = util:Load_int()
		if not status then return false end
		status,bean.nneedquality = util:Load_int()
		if not status then return false end
		status,bean.nqualitya = util:Load_int()
		if not status then return false end
		status,bean.nqualityb = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CCircTaskItemFindTable
