
require "utils.binutil"

CNewFunctionOpenTable = {}
CNewFunctionOpenTable.__index = CNewFunctionOpenTable

function CNewFunctionOpenTable:new()
	local self = {}
	setmetatable(self, CNewFunctionOpenTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CNewFunctionOpenTable:getRecorder(id)
	return self.m_cache[id]
end

function CNewFunctionOpenTable:getAllID()
	return self.allID
end

function CNewFunctionOpenTable:getSize()
	return self.memberCount
end

function CNewFunctionOpenTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=589890 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.functionname = util:Load_string()
		if not status then return false end
		status,bean.needlevel = util:Load_int()
		if not status then return false end
		status,bean.taskfinish = util:Load_string()
		if not status then return false end
		status,bean.icon = util:Load_string()
		if not status then return false end
		status,bean.iseffect = util:Load_int()
		if not status then return false end
		status,bean.site = util:Load_int()
		if not status then return false end
		status,bean.index = util:Load_int()
		if not status then return false end
		status,bean.btn = util:Load_string()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CNewFunctionOpenTable
