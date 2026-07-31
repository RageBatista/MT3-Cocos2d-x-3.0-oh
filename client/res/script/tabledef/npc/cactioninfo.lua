
require "utils.binutil"

CActionInfoTable = {}
CActionInfoTable.__index = CActionInfoTable

function CActionInfoTable:new()
	local self = {}
	setmetatable(self, CActionInfoTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CActionInfoTable:getRecorder(id)
	return self.m_cache[id]
end

function CActionInfoTable:getAllID()
	return self.allID
end

function CActionInfoTable:getSize()
	return self.memberCount
end

function CActionInfoTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=917659 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.model = util:Load_string()
		if not status then return false end
		status,bean.weapon = util:Load_int()
		if not status then return false end
		status,bean.attack = util:Load_string()
		if not status then return false end
		status,bean.magic = util:Load_string()
		if not status then return false end
		status,bean.attacked = util:Load_string()
		if not status then return false end
		status,bean.dying = util:Load_string()
		if not status then return false end
		status,bean.death = util:Load_string()
		if not status then return false end
		status,bean.defence = util:Load_string()
		if not status then return false end
		status,bean.run = util:Load_string()
		if not status then return false end
		status,bean.battlestand = util:Load_string()
		if not status then return false end
		status,bean.stand = util:Load_string()
		if not status then return false end
		status,bean.ridrun = util:Load_string()
		if not status then return false end
		status,bean.ridstand = util:Load_string()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CActionInfoTable
