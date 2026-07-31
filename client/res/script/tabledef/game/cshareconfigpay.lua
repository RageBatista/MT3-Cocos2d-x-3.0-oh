
require "utils.binutil"

CShareConfigPayTable = {}
CShareConfigPayTable.__index = CShareConfigPayTable

function CShareConfigPayTable:new()
	local self = {}
	setmetatable(self, CShareConfigPayTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CShareConfigPayTable:getRecorder(id)
	return self.m_cache[id]
end

function CShareConfigPayTable:getAllID()
	return self.allID
end

function CShareConfigPayTable:getSize()
	return self.memberCount
end

function CShareConfigPayTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=1048773 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.iconWechat = util:Load_string()
		if not status then return false end
		status,bean.titleWechat = util:Load_string()
		if not status then return false end
		status,bean.describWechat = util:Load_string()
		if not status then return false end
		status,bean.iosUrlWechat = util:Load_string()
		if not status then return false end
		status,bean.androidUrlWechat = util:Load_string()
		if not status then return false end
		status,bean.iconMonents = util:Load_string()
		if not status then return false end
		status,bean.titleMonents = util:Load_string()
		if not status then return false end
		status,bean.describMonents = util:Load_string()
		if not status then return false end
		status,bean.iosUrlMonents = util:Load_string()
		if not status then return false end
		status,bean.androidUrlMonents = util:Load_string()
		if not status then return false end
		status,bean.iconWeibo = util:Load_string()
		if not status then return false end
		status,bean.titleWeibo = util:Load_string()
		if not status then return false end
		status,bean.describWeibo = util:Load_string()
		if not status then return false end
		status,bean.iosUrlWeibo = util:Load_string()
		if not status then return false end
		status,bean.androidUrlWeibo = util:Load_string()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CShareConfigPayTable
