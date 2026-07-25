
require "utils.binutil"

CEquipIteminfoTable = {}
CEquipIteminfoTable.__index = CEquipIteminfoTable

function CEquipIteminfoTable:new()
	local self = {}
	setmetatable(self, CEquipIteminfoTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CEquipIteminfoTable:getRecorder(id)
	return self.m_cache[id]
end

function CEquipIteminfoTable:getAllID()
	return self.allID
end

function CEquipIteminfoTable:getSize()
	return self.memberCount
end

function CEquipIteminfoTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=3212538 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.shuxing1id = util:Load_int()
		if not status then return false end
		status,bean.shuxing1bodongduanmin = util:Load_Vint()
		if not status then return false end
		status,bean.shuxing1bodongduanmax = util:Load_Vint()
		if not status then return false end
		status,bean.shuxing1bodongquanzhong = util:Load_Vint()
		if not status then return false end
		status,bean.shuxing2id = util:Load_int()
		if not status then return false end
		status,bean.shuxing2bodongduanmin = util:Load_Vint()
		if not status then return false end
		status,bean.shuxing2bodongduanmax = util:Load_Vint()
		if not status then return false end
		status,bean.shuxing2bodongquanzhong = util:Load_Vint()
		if not status then return false end
		status,bean.shuxing3id = util:Load_int()
		if not status then return false end
		status,bean.shuxing3bodongduanmin = util:Load_Vint()
		if not status then return false end
		status,bean.shuxing3bodongduanmax = util:Load_Vint()
		if not status then return false end
		status,bean.shuxing3bodongquanzhong = util:Load_Vint()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CEquipIteminfoTable
