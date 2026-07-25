
require "utils.binutil"

CRideTable = {}
CRideTable.__index = CRideTable

function CRideTable:new()
	local self = {}
	setmetatable(self, CRideTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CRideTable:getRecorder(id)
	return self.m_cache[id]
end

function CRideTable:getAllID()
	return self.allID
end

function CRideTable:getSize()
	return self.memberCount
end

function CRideTable:LoadBeanFromBinFile(filename)
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
		status,bean.ridemodel = util:Load_int()
		if not status then return false end
		status,bean.speed = util:Load_int()
		if not status then return false end
		status,bean.isstand = util:Load_int()
		if not status then return false end
		status,bean.effectId = util:Load_int()
		if not status then return false end
		status,bean.effectPosX = util:Load_int()
		if not status then return false end
		status,bean.effectPosY = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CRideTable
