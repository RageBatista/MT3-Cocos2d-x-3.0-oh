
require "utils.binutil"

CEventConfigTable = {}
CEventConfigTable.__index = CEventConfigTable

function CEventConfigTable:new()
	local self = {}
	setmetatable(self, CEventConfigTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CEventConfigTable:getRecorder(id)
	return self.m_cache[id]
end

function CEventConfigTable:getAllID()
	return self.allID
end

function CEventConfigTable:getSize()
	return self.memberCount
end

function CEventConfigTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=655431 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.name = util:Load_string()
		if not status then return false end
		status,bean.iconId = util:Load_int()
		if not status then return false end
		status,bean.type = util:Load_int()
		if not status then return false end
		status,bean.enermyId = util:Load_int()
		if not status then return false end
		status,bean.battleId = util:Load_int()
		if not status then return false end
		status,bean.battleAward = util:Load_string()
		if not status then return false end
		status,bean.skillId = util:Load_int()
		if not status then return false end
		status,bean.personalNoticeId = util:Load_int()
		if not status then return false end
		status,bean.noticeId = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CEventConfigTable
