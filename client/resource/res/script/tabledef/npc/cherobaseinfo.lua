
require "utils.binutil"

CHeroBaseInfoTable = {}
CHeroBaseInfoTable.__index = CHeroBaseInfoTable

function CHeroBaseInfoTable:new()
	local self = {}
	setmetatable(self, CHeroBaseInfoTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CHeroBaseInfoTable:getRecorder(id)
	return self.m_cache[id]
end

function CHeroBaseInfoTable:getAllID()
	return self.allID
end

function CHeroBaseInfoTable:getSize()
	return self.memberCount
end

function CHeroBaseInfoTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=1573196 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.name = util:Load_string()
		if not status then return false end
		status,bean.namec = util:Load_string()
		if not status then return false end
		status,bean.type = util:Load_int()
		if not status then return false end
		status,bean.acttype = util:Load_int()
		if not status then return false end
		status,bean.school = util:Load_int()
		if not status then return false end
		status,bean.shapeid = util:Load_int()
		if not status then return false end
		status,bean.headid = util:Load_int()
		if not status then return false end
		status,bean.skillid = util:Load_Vint()
		if not status then return false end
		status,bean.first_skill = util:Load_int()
		if not status then return false end
		status,bean.day7_money = util:Load_Vint()
		if not status then return false end
		status,bean.day30_money = util:Load_Vint()
		if not status then return false end
		status,bean.forever_money = util:Load_Vint()
		if not status then return false end
		status,bean.scalefactor = util:Load_double()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CHeroBaseInfoTable
