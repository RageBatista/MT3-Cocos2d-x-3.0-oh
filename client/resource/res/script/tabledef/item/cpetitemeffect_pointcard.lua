
require "utils.binutil"

CPetItemEffect_PointCardTable = {}
CPetItemEffect_PointCardTable.__index = CPetItemEffect_PointCardTable

function CPetItemEffect_PointCardTable:new()
	local self = {}
	setmetatable(self, CPetItemEffect_PointCardTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CPetItemEffect_PointCardTable:getRecorder(id)
	return self.m_cache[id]
end

function CPetItemEffect_PointCardTable:getAllID()
	return self.allID
end

function CPetItemEffect_PointCardTable:getSize()
	return self.memberCount
end

function CPetItemEffect_PointCardTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=1179840 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.petskillid = util:Load_int()
		if not status then return false end
		status,bean.effectdes = util:Load_string()
		if not status then return false end
		status,bean.effecttype = util:Load_Vint()
		if not status then return false end
		status,bean.effect = util:Load_Vint()
		if not status then return false end
		status,bean.bCanSale = util:Load_int()
		if not status then return false end
		status,bean.dbCanSale = util:Load_int()
		if not status then return false end
		status,bean.treasure = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CPetItemEffect_PointCardTable
