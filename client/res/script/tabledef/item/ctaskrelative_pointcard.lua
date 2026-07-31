
require "utils.binutil"

CTaskRelative_PointCardTable = {}
CTaskRelative_PointCardTable.__index = CTaskRelative_PointCardTable

function CTaskRelative_PointCardTable:new()
	local self = {}
	setmetatable(self, CTaskRelative_PointCardTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CTaskRelative_PointCardTable:getRecorder(id)
	return self.m_cache[id]
end

function CTaskRelative_PointCardTable:getAllID()
	return self.allID
end

function CTaskRelative_PointCardTable:getSize()
	return self.memberCount
end

function CTaskRelative_PointCardTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=1114288 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.task = util:Load_string()
		if not status then return false end
		status,bean.bCanSale = util:Load_int()
		if not status then return false end
		status,bean.dbCanSale = util:Load_int()
		if not status then return false end
		status,bean.readtime = util:Load_int()
		if not status then return false end
		status,bean.readtext = util:Load_string()
		if not status then return false end
		status,bean.usemap = util:Load_int()
		if not status then return false end
		status,bean.ltx = util:Load_int()
		if not status then return false end
		status,bean.lty = util:Load_int()
		if not status then return false end
		status,bean.rbx = util:Load_int()
		if not status then return false end
		status,bean.rby = util:Load_int()
		if not status then return false end
		status,bean.caiji = util:Load_int()
		if not status then return false end
		status,bean.neffectid = util:Load_int()
		if not status then return false end
		status,bean.treasure = util:Load_int()
		if not status then return false end
		status,bean.nroleeffectid = util:Load_int()
		if not status then return false end
		status,bean.neffectposx = util:Load_int()
		if not status then return false end
		status,bean.neffectposy = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CTaskRelative_PointCardTable
