
require "utils.binutil"

CTeamListInfoTable = {}
CTeamListInfoTable.__index = CTeamListInfoTable

function CTeamListInfoTable:new()
	local self = {}
	setmetatable(self, CTeamListInfoTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CTeamListInfoTable:getRecorder(id)
	return self.m_cache[id]
end

function CTeamListInfoTable:getAllID()
	return self.allID
end

function CTeamListInfoTable:getSize()
	return self.memberCount
end

function CTeamListInfoTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=720985 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.content = util:Load_string()
		if not status then return false end
		status,bean.target = util:Load_string()
		if not status then return false end
		status,bean.type = util:Load_int()
		if not status then return false end
		status,bean.minlevel = util:Load_int()
		if not status then return false end
		status,bean.maxlevel = util:Load_int()
		if not status then return false end
		status,bean.minMember = util:Load_int()
		if not status then return false end
		status,bean.maxMember = util:Load_int()
		if not status then return false end
		status,bean.additional = util:Load_int()
		if not status then return false end
		status,bean.requirement = util:Load_string()
		if not status then return false end
		status,bean.opentime = util:Load_string()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CTeamListInfoTable
