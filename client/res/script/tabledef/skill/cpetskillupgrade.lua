
require "utils.binutil"

CPetSkillupgradeTable = {}
CPetSkillupgradeTable.__index = CPetSkillupgradeTable

function CPetSkillupgradeTable:new()
	local self = {}
	setmetatable(self, CPetSkillupgradeTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CPetSkillupgradeTable:getRecorder(id)
	return self.m_cache[id]
end

function CPetSkillupgradeTable:getAllID()
	return self.allID
end

function CPetSkillupgradeTable:getSize()
	return self.memberCount
end

function CPetSkillupgradeTable:LoadBeanFromBinFile(filename)
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
		status,bean.nextid = util:Load_int()
		if not status then return false end
		status,bean.book = util:Load_int()
		if not status then return false end
		status,bean.needexp = util:Load_int()
		if not status then return false end
		status,bean.offerbaseexp = util:Load_int()
		if not status then return false end
		status,bean.skilllevel = util:Load_int()
		if not status then return false end
		status,bean.sign = util:Load_int()
		if not status then return false end
		status,bean.iscanremovable = util:Load_int()
		if not status then return false end
		status,bean.range = util:Load_int()
		if not status then return false end
		status,bean.iscancertification = util:Load_int()
		if not status then return false end
		status,bean.iscertificationappend = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CPetSkillupgradeTable
