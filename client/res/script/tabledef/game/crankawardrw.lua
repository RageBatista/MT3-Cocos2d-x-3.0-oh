
require "utils.binutil"

CrankawardrwTable = {}
CrankawardrwTable.__index = CrankawardrwTable

function CrankawardrwTable:new()
	local self = {}
	setmetatable(self, CrankawardrwTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CrankawardrwTable:getRecorder(id)
	return self.m_cache[id]
end

function CrankawardrwTable:getAllID()
	return self.allID
end

function CrankawardrwTable:getSize()
	return self.memberCount
end

function CrankawardrwTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=1179846 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.dayimg = util:Load_string()
		if not status then return false end
		status,bean.ganxie = util:Load_string()
		if not status then return false end
		status,bean.zhufu = util:Load_string()
		if not status then return false end
		status,bean.item1id = util:Load_int()
		if not status then return false end
		status,bean.item1num = util:Load_int()
		if not status then return false end
		status,bean.item2id = util:Load_int()
		if not status then return false end
		status,bean.item2num = util:Load_int()
		if not status then return false end
		status,bean.item3id = util:Load_int()
		if not status then return false end
		status,bean.item3num = util:Load_int()
		if not status then return false end
		status,bean.item4id = util:Load_int()
		if not status then return false end
		status,bean.item4num = util:Load_int()
		if not status then return false end
		status,bean.item5id = util:Load_int()
		if not status then return false end
		status,bean.item5num = util:Load_int()
		if not status then return false end
		status,bean.item6id = util:Load_int()
		if not status then return false end
		status,bean.item6num = util:Load_int()
		if not status then return false end
		status,bean.ptb = util:Load_int()
		if not status then return false end
		status,bean.needcapacity = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CrankawardrwTable
