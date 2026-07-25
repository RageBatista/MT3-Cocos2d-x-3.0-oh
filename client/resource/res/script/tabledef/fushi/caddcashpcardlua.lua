
require "utils.binutil"

CAddCashPCardluaTable = {}
CAddCashPCardluaTable.__index = CAddCashPCardluaTable

function CAddCashPCardluaTable:new()
	local self = {}
	setmetatable(self, CAddCashPCardluaTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CAddCashPCardluaTable:getRecorder(id)
	return self.m_cache[id]
end

function CAddCashPCardluaTable:getAllID()
	return self.allID
end

function CAddCashPCardluaTable:getSize()
	return self.memberCount
end

function CAddCashPCardluaTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=786540 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.sellpricenum = util:Load_int()
		if not status then return false end
		status,bean.itemicon = util:Load_string()
		if not status then return false end
		status,bean.kind = util:Load_int()
		if not status then return false end
		status,bean.roofid = util:Load_string()
		if not status then return false end
		status,bean.maxcash = util:Load_int()
		if not status then return false end
		status,bean.cashkind = util:Load_int()
		if not status then return false end
		status,bean.unititem = util:Load_string()
		if not status then return false end
		status,bean.foodid = util:Load_string()
		if not status then return false end
		status,bean.dayRes = util:Load_string()
		if not status then return false end
		status,bean.foodname = util:Load_string()
		if not status then return false end
		status,bean.credit = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CAddCashPCardluaTable
