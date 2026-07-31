
require "utils.binutil"

CPresentConfigPayTable = {}
CPresentConfigPayTable.__index = CPresentConfigPayTable

function CPresentConfigPayTable:new()
	local self = {}
	setmetatable(self, CPresentConfigPayTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CPresentConfigPayTable:getRecorder(id)
	return self.m_cache[id]
end

function CPresentConfigPayTable:getAllID()
	return self.allID
end

function CPresentConfigPayTable:getSize()
	return self.memberCount
end

function CPresentConfigPayTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=2950201 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.itemid = util:Load_int()
		if not status then return false end
		status,bean.dutyallow = util:Load_int()
		if not status then return false end
		status,bean.careerallow = util:Load_int()
		if not status then return false end
		status,bean.maleallow = util:Load_int()
		if not status then return false end
		status,bean.clienttip = util:Load_int()
		if not status then return false end
		status,bean.rewardcfgid = util:Load_int()
		if not status then return false end
		status,bean.coinreward = util:Load_long()
		if not status then return false end
		status,bean.yuanbaoreward = util:Load_int()
		if not status then return false end
		status,bean.itemids = util:Load_Vint()
		if not status then return false end
		status,bean.itemnums = util:Load_Vint()
		if not status then return false end
		status,bean.itembinds = util:Load_Vint()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CPresentConfigPayTable
