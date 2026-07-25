
require "utils.binutil"

CFormationRestrainTable = {}
CFormationRestrainTable.__index = CFormationRestrainTable

function CFormationRestrainTable:new()
	local self = {}
	setmetatable(self, CFormationRestrainTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CFormationRestrainTable:getRecorder(id)
	return self.m_cache[id]
end

function CFormationRestrainTable:getAllID()
	return self.allID
end

function CFormationRestrainTable:getSize()
	return self.memberCount
end

function CFormationRestrainTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=589902 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.restrain1 = util:Load_string()
		if not status then return false end
		status,bean.restrainArg1 = util:Load_string()
		if not status then return false end
		status,bean.restrain2 = util:Load_string()
		if not status then return false end
		status,bean.restrainArg2 = util:Load_string()
		if not status then return false end
		status,bean.beRestrained1 = util:Load_string()
		if not status then return false end
		status,bean.beRestrainedArg1 = util:Load_string()
		if not status then return false end
		status,bean.beRestrained2 = util:Load_string()
		if not status then return false end
		status,bean.beRestrainedArg2 = util:Load_string()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CFormationRestrainTable
