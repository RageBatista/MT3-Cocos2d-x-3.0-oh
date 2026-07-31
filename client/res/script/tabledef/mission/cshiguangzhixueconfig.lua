
require "utils.binutil"

CShiGuangZhiXueConfigTable = {}
CShiGuangZhiXueConfigTable.__index = CShiGuangZhiXueConfigTable

function CShiGuangZhiXueConfigTable:new()
	local self = {}
	setmetatable(self, CShiGuangZhiXueConfigTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CShiGuangZhiXueConfigTable:getRecorder(id)
	return self.m_cache[id]
end

function CShiGuangZhiXueConfigTable:getAllID()
	return self.allID
end

function CShiGuangZhiXueConfigTable:getSize()
	return self.memberCount
end

function CShiGuangZhiXueConfigTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=1048746 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.fubenId = util:Load_int()
		if not status then return false end
		status,bean.name = util:Load_string()
		if not status then return false end
		status,bean.ccname = util:Load_string()
		if not status then return false end
		status,bean.ccname1 = util:Load_string()
		if not status then return false end
		status,bean.explain = util:Load_string()
		if not status then return false end
		status,bean.playerNum = util:Load_int()
		if not status then return false end
		status,bean.enterLevel = util:Load_int()
		if not status then return false end
		status,bean.image = util:Load_string()
		if not status then return false end
		status,bean.ccimage = util:Load_string()
		if not status then return false end
		status,bean.icon = util:Load_int()
		if not status then return false end
		status,bean.award1 = util:Load_int()
		if not status then return false end
		status,bean.award2 = util:Load_int()
		if not status then return false end
		status,bean.award3 = util:Load_int()
		if not status then return false end
		status,bean.award4 = util:Load_int()
		if not status then return false end
		status,bean.award5 = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CShiGuangZhiXueConfigTable
