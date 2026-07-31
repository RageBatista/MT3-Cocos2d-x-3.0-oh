
require "utils.binutil"

CShiguangzhixueNpcTable = {}
CShiguangzhixueNpcTable.__index = CShiguangzhixueNpcTable

function CShiguangzhixueNpcTable:new()
	local self = {}
	setmetatable(self, CShiguangzhixueNpcTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CShiguangzhixueNpcTable:getRecorder(id)
	return self.m_cache[id]
end

function CShiguangzhixueNpcTable:getAllID()
	return self.allID
end

function CShiguangzhixueNpcTable:getSize()
	return self.memberCount
end

function CShiguangzhixueNpcTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=1245393 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.taskid = util:Load_int()
		if not status then return false end
		status,bean.tasktype = util:Load_int()
		if not status then return false end
		status,bean.mapid = util:Load_int()
		if not status then return false end
		status,bean.solonpcid = util:Load_int()
		if not status then return false end
		status,bean.step = util:Load_int()
		if not status then return false end
		status,bean.steprate = util:Load_int()
		if not status then return false end
		status,bean.lefttopx = util:Load_int()
		if not status then return false end
		status,bean.lefttopy = util:Load_int()
		if not status then return false end
		status,bean.endtask = util:Load_int()
		if not status then return false end
		status,bean.decoratenpc1 = util:Load_int()
		if not status then return false end
		status,bean.x1 = util:Load_int()
		if not status then return false end
		status,bean.y1 = util:Load_int()
		if not status then return false end
		status,bean.decoratenpc2 = util:Load_int()
		if not status then return false end
		status,bean.x2 = util:Load_int()
		if not status then return false end
		status,bean.y2 = util:Load_int()
		if not status then return false end
		status,bean.decoratenpc3 = util:Load_int()
		if not status then return false end
		status,bean.x3 = util:Load_int()
		if not status then return false end
		status,bean.y3 = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CShiguangzhixueNpcTable
