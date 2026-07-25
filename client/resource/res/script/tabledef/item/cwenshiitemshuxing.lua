
require "utils.binutil"

CWenShiItemShuXingTable = {}
CWenShiItemShuXingTable.__index = CWenShiItemShuXingTable

function CWenShiItemShuXingTable:new()
	local self = {}
	setmetatable(self, CWenShiItemShuXingTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CWenShiItemShuXingTable:getRecorder(id)
	return self.m_cache[id]
end

function CWenShiItemShuXingTable:getAllID()
	return self.allID
end

function CWenShiItemShuXingTable:getSize()
	return self.memberCount
end

function CWenShiItemShuXingTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=720973 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.icon = util:Load_int()
		if not status then return false end
		status,bean.level = util:Load_int()
		if not status then return false end
		status,bean.naijiu = util:Load_int()
		if not status then return false end
		status,bean.wenshitype = util:Load_int()
		if not status then return false end
		status,bean.shuxingid1 = util:Load_int()
		if not status then return false end
		status,bean.shuxingid2 = util:Load_int()
		if not status then return false end
		status,bean.shuxingid3 = util:Load_int()
		if not status then return false end
		status,bean.shuxingzhi1 = util:Load_int()
		if not status then return false end
		status,bean.shuxingzhi2 = util:Load_int()
		if not status then return false end
		status,bean.shuxingzhi3 = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CWenShiItemShuXingTable
