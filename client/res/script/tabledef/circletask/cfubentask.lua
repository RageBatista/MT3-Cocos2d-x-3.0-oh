
require "utils.binutil"

CFubenTaskTable = {}
CFubenTaskTable.__index = CFubenTaskTable

function CFubenTaskTable:new()
	local self = {}
	setmetatable(self, CFubenTaskTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CFubenTaskTable:getRecorder(id)
	return self.m_cache[id]
end

function CFubenTaskTable:getAllID()
	return self.allID
end

function CFubenTaskTable:getSize()
	return self.memberCount
end

function CFubenTaskTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=524350 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.nfubentasktype = util:Load_int()
		if not status then return false end
		status,bean.taskpanelefttitle = util:Load_string()
		if not status then return false end
		status,bean.taskpanetitle = util:Load_string()
		if not status then return false end
		status,bean.taskpanedis = util:Load_string()
		if not status then return false end
		status,bean.taskpanedes = util:Load_string()
		if not status then return false end
		status,bean.tracetitle = util:Load_string()
		if not status then return false end
		status,bean.tracedes = util:Load_string()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CFubenTaskTable
