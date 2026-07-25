
require "utils.binutil"

CXingYinComboTable = {}
CXingYinComboTable.__index = CXingYinComboTable

function CXingYinComboTable:new()
	local self = {}
	setmetatable(self, CXingYinComboTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CXingYinComboTable:getRecorder(id)
	return self.m_cache[id]
end

function CXingYinComboTable:getAllID()
	return self.allID
end

function CXingYinComboTable:getSize()
	return self.memberCount
end

function CXingYinComboTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=524335 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.name = util:Load_string()
		if not status then return false end
		status,bean.yuancount = util:Load_int()
		if not status then return false end
		status,bean.fangcount = util:Load_int()
		if not status then return false end
		status,bean.school = util:Load_int()
		if not status then return false end
		status,bean.skillid = util:Load_int()
		if not status then return false end
		status,bean.buffid = util:Load_int()
		if not status then return false end
		status,bean.buffskillid = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CXingYinComboTable
