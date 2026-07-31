
require "utils.binutil"

CGuideCourseTable = {}
CGuideCourseTable.__index = CGuideCourseTable

function CGuideCourseTable:new()
	local self = {}
	setmetatable(self, CGuideCourseTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CGuideCourseTable:getRecorder(id)
	return self.m_cache[id]
end

function CGuideCourseTable:getAllID()
	return self.allID
end

function CGuideCourseTable:getSize()
	return self.memberCount
end

function CGuideCourseTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=2556714 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.group = util:Load_int()
		if not status then return false end
		status,bean.style = util:Load_int()
		if not status then return false end
		status,bean.image = util:Load_string()
		if not status then return false end
		status,bean.name = util:Load_string()
		if not status then return false end
		status,bean.sort = util:Load_int()
		if not status then return false end
		status,bean.info = util:Load_string()
		if not status then return false end
		status,bean.enterlevel = util:Load_int()
		if not status then return false end
		status,bean.enter = util:Load_int()
		if not status then return false end
		status,bean.enterlink = util:Load_int()
		if not status then return false end
		status,bean.finish = util:Load_int()
		if not status then return false end
		status,bean.ref1 = util:Load_string()
		if not status then return false end
		status,bean.ref2 = util:Load_string()
		if not status then return false end
		status,bean.item = util:Load_int()
		if not status then return false end
		status,bean.itemnum = util:Load_int()
		if not status then return false end
		status,bean.itemicons = util:Load_Vint()
		if not status then return false end
		status,bean.itemtexts = util:Load_Vstring()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CGuideCourseTable
