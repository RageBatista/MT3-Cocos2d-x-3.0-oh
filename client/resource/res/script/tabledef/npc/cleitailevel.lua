
require "utils.binutil"

CLeitaiLevelTable = {}
CLeitaiLevelTable.__index = CLeitaiLevelTable

function CLeitaiLevelTable:new()
	local self = {}
	setmetatable(self, CLeitaiLevelTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CLeitaiLevelTable:getRecorder(id)
	return self.m_cache[id]
end

function CLeitaiLevelTable:getAllID()
	return self.allID
end

function CLeitaiLevelTable:getSize()
	return self.memberCount
end

function CLeitaiLevelTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=196617 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.levelmin = util:Load_int()
		if not status then return false end
		status,bean.levelmax = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CLeitaiLevelTable
