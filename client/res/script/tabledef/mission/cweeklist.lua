
require "utils.binutil"

CWeekListTable = {}
CWeekListTable.__index = CWeekListTable

function CWeekListTable:new()
	local self = {}
	setmetatable(self, CWeekListTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CWeekListTable:getRecorder(id)
	return self.m_cache[id]
end

function CWeekListTable:getAllID()
	return self.allID
end

function CWeekListTable:getSize()
	return self.memberCount
end

function CWeekListTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=917659 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.week = util:Load_int()
		if not status then return false end
		status,bean.text1 = util:Load_string()
		if not status then return false end
		status,bean.time1 = util:Load_string()
		if not status then return false end
		status,bean.text2 = util:Load_string()
		if not status then return false end
		status,bean.time2 = util:Load_string()
		if not status then return false end
		status,bean.text3 = util:Load_string()
		if not status then return false end
		status,bean.time3 = util:Load_string()
		if not status then return false end
		status,bean.text4 = util:Load_string()
		if not status then return false end
		status,bean.time4 = util:Load_string()
		if not status then return false end
		status,bean.text5 = util:Load_string()
		if not status then return false end
		status,bean.time5 = util:Load_string()
		if not status then return false end
		status,bean.text6 = util:Load_string()
		if not status then return false end
		status,bean.time6 = util:Load_string()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CWeekListTable
