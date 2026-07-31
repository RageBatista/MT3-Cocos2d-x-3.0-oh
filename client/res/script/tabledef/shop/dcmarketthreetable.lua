
require "utils.binutil"

DCMarketThreeTableTable = {}
DCMarketThreeTableTable.__index = DCMarketThreeTableTable

function DCMarketThreeTableTable:new()
	local self = {}
	setmetatable(self, DCMarketThreeTableTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function DCMarketThreeTableTable:getRecorder(id)
	return self.m_cache[id]
end

function DCMarketThreeTableTable:getAllID()
	return self.allID
end

function DCMarketThreeTableTable:getSize()
	return self.memberCount
end

function DCMarketThreeTableTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=1638753 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.itemid = util:Load_int()
		if not status then return false end
		status,bean.itemtype = util:Load_int()
		if not status then return false end
		status,bean.logictype = util:Load_int()
		if not status then return false end
		status,bean.israrity = util:Load_int()
		if not status then return false end
		status,bean.firstno = util:Load_int()
		if not status then return false end
		status,bean.twono = util:Load_int()
		if not status then return false end
		status,bean.limitlooklv = util:Load_int()
		if not status then return false end
		status,bean.buylvmin = util:Load_int()
		if not status then return false end
		status,bean.buylvmax = util:Load_int()
		if not status then return false end
		status,bean.value = util:Load_int()
		if not status then return false end
		status,bean.name = util:Load_string()
		if not status then return false end
		status,bean.valuerange = util:Load_Vint()
		if not status then return false end
		status,bean.cansale = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return DCMarketThreeTableTable
