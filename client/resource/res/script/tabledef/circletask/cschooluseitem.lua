
require "utils.binutil"

CSchoolUseItemTable = {}
CSchoolUseItemTable.__index = CSchoolUseItemTable

function CSchoolUseItemTable:new()
	local self = {}
	setmetatable(self, CSchoolUseItemTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CSchoolUseItemTable:getRecorder(id)
	return self.m_cache[id]
end

function CSchoolUseItemTable:getAllID()
	return self.allID
end

function CSchoolUseItemTable:getSize()
	return self.memberCount
end

function CSchoolUseItemTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=720973 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.nuseitemgroup = util:Load_int()
		if not status then return false end
		status,bean.nschoolid = util:Load_int()
		if not status then return false end
		status,bean.nlvmin = util:Load_int()
		if not status then return false end
		status,bean.nlvmax = util:Load_int()
		if not status then return false end
		status,bean.nmapid = util:Load_int()
		if not status then return false end
		status,bean.nposx = util:Load_int()
		if not status then return false end
		status,bean.nposy = util:Load_int()
		if not status then return false end
		status,bean.ndis = util:Load_int()
		if not status then return false end
		status,bean.nrand = util:Load_int()
		if not status then return false end
		status,bean.nitemid = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CSchoolUseItemTable
