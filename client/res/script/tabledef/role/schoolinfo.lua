
require "utils.binutil"

SchoolInfoTable = {}
SchoolInfoTable.__index = SchoolInfoTable

function SchoolInfoTable:new()
	local self = {}
	setmetatable(self, SchoolInfoTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function SchoolInfoTable:getRecorder(id)
	return self.m_cache[id]
end

function SchoolInfoTable:getAllID()
	return self.allID
end

function SchoolInfoTable:getSize()
	return self.memberCount
end

function SchoolInfoTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=2360049 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.name = util:Load_string()
		if not status then return false end
		status,bean.englishName = util:Load_string()
		if not status then return false end
		status,bean.describe = util:Load_string()
		if not status then return false end
		status,bean.schoolicon = util:Load_string()
		if not status then return false end
		status,bean.schoolback = util:Load_string()
		if not status then return false end
		status,bean.schoolmapid = util:Load_int()
		if not status then return false end
		status,bean.schooljobmapid = util:Load_int()
		if not status then return false end
		status,bean.scheme = util:Load_string()
		if not status then return false end
		status,bean.explain = util:Load_string()
		if not status then return false end
		status,bean.addpoint = util:Load_Vint()
		if not status then return false end
		status,bean.scheme2 = util:Load_string()
		if not status then return false end
		status,bean.explain2 = util:Load_string()
		if not status then return false end
		status,bean.addpoint2 = util:Load_Vint()
		if not status then return false end
		status,bean.scheme3 = util:Load_string()
		if not status then return false end
		status,bean.explain3 = util:Load_string()
		if not status then return false end
		status,bean.addpoint3 = util:Load_Vint()
		if not status then return false end
		status,bean.schooliconpath = util:Load_string()
		if not status then return false end
		status,bean.jobtype = util:Load_int()
		if not status then return false end
		status,bean.normalbtnimage = util:Load_string()
		if not status then return false end
		status,bean.pushbtnimage = util:Load_string()
		if not status then return false end
		status,bean.schoolpicpath = util:Load_string()
		if not status then return false end
		status,bean.namecc = util:Load_string()
		if not status then return false end
		status,bean.schoolpicpathc = util:Load_string()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return SchoolInfoTable
