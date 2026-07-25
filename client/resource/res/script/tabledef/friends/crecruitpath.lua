
require "utils.binutil"

CRecruitPathTable = {}
CRecruitPathTable.__index = CRecruitPathTable

function CRecruitPathTable:new()
	local self = {}
	setmetatable(self, CRecruitPathTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CRecruitPathTable:getRecorder(id)
	return self.m_cache[id]
end

function CRecruitPathTable:getAllID()
	return self.allID
end

function CRecruitPathTable:getSize()
	return self.memberCount
end

function CRecruitPathTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=786555 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.path1 = util:Load_string()
		if not status then return false end
		status,bean.path2 = util:Load_string()
		if not status then return false end
		status,bean.path3 = util:Load_string()
		if not status then return false end
		status,bean.path4 = util:Load_string()
		if not status then return false end
		status,bean.path5 = util:Load_string()
		if not status then return false end
		status,bean.path6 = util:Load_string()
		if not status then return false end
		status,bean.path7 = util:Load_string()
		if not status then return false end
		status,bean.path8 = util:Load_string()
		if not status then return false end
		status,bean.path9 = util:Load_string()
		if not status then return false end
		status,bean.path10 = util:Load_string()
		if not status then return false end
		status,bean.path11 = util:Load_string()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CRecruitPathTable
