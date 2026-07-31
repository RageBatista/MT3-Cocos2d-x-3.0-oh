
require "utils.binutil"

CAddPointResetItemConfigTable = {}
CAddPointResetItemConfigTable.__index = CAddPointResetItemConfigTable

function CAddPointResetItemConfigTable:new()
	local self = {}
	setmetatable(self, CAddPointResetItemConfigTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CAddPointResetItemConfigTable:getRecorder(id)
	return self.m_cache[id]
end

function CAddPointResetItemConfigTable:getAllID()
	return self.allID
end

function CAddPointResetItemConfigTable:getSize()
	return self.memberCount
end

function CAddPointResetItemConfigTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=458787 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.type = util:Load_int()
		if not status then return false end
		status,bean.tizhi = util:Load_int()
		if not status then return false end
		status,bean.moli = util:Load_int()
		if not status then return false end
		status,bean.liliang = util:Load_int()
		if not status then return false end
		status,bean.naili = util:Load_int()
		if not status then return false end
		status,bean.minjie = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CAddPointResetItemConfigTable
