
require "utils.binutil"

CPetSkillConfigTable = {}
CPetSkillConfigTable.__index = CPetSkillConfigTable

function CPetSkillConfigTable:new()
	local self = {}
	setmetatable(self, CPetSkillConfigTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CPetSkillConfigTable:getRecorder(id)
	return self.m_cache[id]
end

function CPetSkillConfigTable:getAllID()
	return self.allID
end

function CPetSkillConfigTable:getSize()
	return self.memberCount
end

function CPetSkillConfigTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=1245420 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.skillname = util:Load_string()
		if not status then return false end
		status,bean.param = util:Load_string()
		if not status then return false end
		status,bean.costnum = util:Load_int()
		if not status then return false end
		status,bean.costType = util:Load_int()
		if not status then return false end
		status,bean.icon = util:Load_int()
		if not status then return false end
		status,bean.skilltype = util:Load_int()
		if not status then return false end
		status,bean.littledes = util:Load_string()
		if not status then return false end
		status,bean.skilldescribe = util:Load_string()
		if not status then return false end
		status,bean.targettype = util:Load_int()
		if not status then return false end
		status,bean.effectid = util:Load_int()
		if not status then return false end
		status,bean.score = util:Load_int()
		if not status then return false end
		status,bean.color = util:Load_int()
		if not status then return false end
		status,bean.skillname1 = util:Load_string()
		if not status then return false end
		status,bean.skillname2 = util:Load_string()
		if not status then return false end
		status,bean.skillname3 = util:Load_string()
		if not status then return false end
		status,bean.skillname4 = util:Load_string()
		if not status then return false end
		status,bean.skillname5 = util:Load_string()
		if not status then return false end
		status,bean.isshow = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CPetSkillConfigTable
