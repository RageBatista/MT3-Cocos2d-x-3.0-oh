
require "utils.binutil"

CSetFumoInfoTable = {}
CSetFumoInfoTable.__index = CSetFumoInfoTable

function CSetFumoInfoTable:new()
	local self = {}
	setmetatable(self, CSetFumoInfoTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CSetFumoInfoTable:getRecorder(id)
	return self.m_cache[id]
end

function CSetFumoInfoTable:getAllID()
	return self.allID
end

function CSetFumoInfoTable:getSize()
	return self.memberCount
end

function CSetFumoInfoTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=1442112 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.name = util:Load_string()
		if not status then return false end
		status,bean.effect = util:Load_int()
		if not status then return false end
		status,bean.skill = util:Load_int()
		if not status then return false end
		status,bean.fujiaone = util:Load_int()
		if not status then return false end
		status,bean.fujiatwo = util:Load_int()
		if not status then return false end
		status,bean.itemid = util:Load_int()
		if not status then return false end
		status,bean.itemnum = util:Load_int()
		if not status then return false end
		status,bean.name1 = util:Load_string()
		if not status then return false end
		status,bean.name2 = util:Load_string()
		if not status then return false end
		status,bean.name3 = util:Load_string()
		if not status then return false end
		status,bean.name4 = util:Load_string()
		if not status then return false end
		status,bean.name5 = util:Load_string()
		if not status then return false end
		status,bean.name6 = util:Load_string()
		if not status then return false end
		status,bean.name7 = util:Load_string()
		if not status then return false end
		status,bean.name8 = util:Load_string()
		if not status then return false end
		status,bean.name9 = util:Load_string()
		if not status then return false end
		status,bean.name10 = util:Load_string()
		if not status then return false end
		status,bean.name11 = util:Load_string()
		if not status then return false end
		status,bean.name12 = util:Load_string()
		if not status then return false end
		status,bean.name13 = util:Load_string()
		if not status then return false end
		status,bean.name14 = util:Load_string()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CSetFumoInfoTable
