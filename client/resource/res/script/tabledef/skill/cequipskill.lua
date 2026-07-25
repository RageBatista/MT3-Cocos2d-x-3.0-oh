
require "utils.binutil"

CEquipSkillTable = {}
CEquipSkillTable.__index = CEquipSkillTable

function CEquipSkillTable:new()
	local self = {}
	setmetatable(self, CEquipSkillTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CEquipSkillTable:getRecorder(id)
	return self.m_cache[id]
end

function CEquipSkillTable:getAllID()
	return self.allID
end

function CEquipSkillTable:getSize()
	return self.memberCount
end

function CEquipSkillTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=917634 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.name = util:Load_string()
		if not status then return false end
		status,bean.icon = util:Load_int()
		if not status then return false end
		status,bean.skilltype = util:Load_int()
		if not status then return false end
		status,bean.cost = util:Load_string()
		if not status then return false end
		status,bean.costnum = util:Load_int()
		if not status then return false end
		status,bean.costType = util:Load_int()
		if not status then return false end
		status,bean.describe = util:Load_string()
		if not status then return false end
		status,bean.targettype = util:Load_int()
		if not status then return false end
		status,bean.effectid = util:Load_int()
		if not status then return false end
		status,bean.isvisible = util:Load_int()
		if not status then return false end
		status,bean.needitem = util:Load_int()
		if not status then return false end
		status,bean.neednum = util:Load_int()
		if not status then return false end
		status,bean.jingmaizhi = util:Load_double()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CEquipSkillTable
