
require "utils.binutil"

CVipInfoTable = {}
CVipInfoTable.__index = CVipInfoTable

function CVipInfoTable:new()
	local self = {}
	setmetatable(self, CVipInfoTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CVipInfoTable:getRecorder(id)
	return self.m_cache[id]
end

function CVipInfoTable:getAllID()
	return self.allID
end

function CVipInfoTable:getSize()
	return self.memberCount
end

function CVipInfoTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=1376517 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.exp = util:Load_int()
		if not status then return false end
		status,bean.itemids = util:Load_Vint()
		if not status then return false end
		status,bean.itemcounts = util:Load_Vint()
		if not status then return false end
		status,bean.type1 = util:Load_string()
		if not status then return false end
		status,bean.type2 = util:Load_string()
		if not status then return false end
		status,bean.type3 = util:Load_string()
		if not status then return false end
		status,bean.limitnumber1 = util:Load_int()
		if not status then return false end
		status,bean.limitnumber2 = util:Load_int()
		if not status then return false end
		status,bean.petextracount = util:Load_int()
		if not status then return false end
		status,bean.giftBagNum = util:Load_int()
		if not status then return false end
		status,bean.bagextracount = util:Load_int()
		if not status then return false end
		status,bean.dpotextracount = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CVipInfoTable
