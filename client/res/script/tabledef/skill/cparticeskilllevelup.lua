
require "utils.binutil"

CParticeSkillLevelupTable = {}
CParticeSkillLevelupTable.__index = CParticeSkillLevelupTable

function CParticeSkillLevelupTable:new()
	local self = {}
	setmetatable(self, CParticeSkillLevelupTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CParticeSkillLevelupTable:getRecorder(id)
	return self.m_cache[id]
end

function CParticeSkillLevelupTable:getAllID()
	return self.allID
end

function CParticeSkillLevelupTable:getSize()
	return self.memberCount
end

function CParticeSkillLevelupTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=786522 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.vecskillexp = util:Load_Vint()
		if not status then return false end
		status,bean.playerlevel = util:Load_int()
		if not status then return false end
		status,bean.factionlevel = util:Load_int()
		if not status then return false end
		status,bean.maxcon = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CParticeSkillLevelupTable
