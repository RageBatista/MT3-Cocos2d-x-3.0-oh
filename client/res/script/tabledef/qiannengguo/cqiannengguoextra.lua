
require "utils.binutil"

CQiannengguoextraTable = {}
CQiannengguoextraTable.__index = CQiannengguoextraTable

function CQiannengguoextraTable:new()
	local self = {}
	setmetatable(self, CQiannengguoextraTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CQiannengguoextraTable:getRecorder(id)
	return self.m_cache[id]
end

function CQiannengguoextraTable:getAllID()
	return self.allID
end

function CQiannengguoextraTable:getSize()
	return self.memberCount
end

function CQiannengguoextraTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=458792 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.needcount = util:Load_int()
		if not status then return false end
		status,bean.proppool = util:Load_string()
		if not status then return false end
		status,bean.mincountvalue = util:Load_int()
		if not status then return false end
		status,bean.maxcountvalue = util:Load_int()
		if not status then return false end
		status,bean.doublerate = util:Load_double()
		if not status then return false end
		status,bean.costmoney = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CQiannengguoextraTable
