
require "utils.binutil"

CLifeSkillCostTable = {}
CLifeSkillCostTable.__index = CLifeSkillCostTable

function CLifeSkillCostTable:new()
	local self = {}
	setmetatable(self, CLifeSkillCostTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CLifeSkillCostTable:getRecorder(id)
	return self.m_cache[id]
end

function CLifeSkillCostTable:getAllID()
	return self.allID
end

function CLifeSkillCostTable:getSize()
	return self.memberCount
end

function CLifeSkillCostTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=3015783 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.needLevelList = util:Load_Vint()
		if not status then return false end
		status,bean.silverCostList = util:Load_Vint()
		if not status then return false end
		status,bean.guildContributeCostList = util:Load_Vint()
		if not status then return false end
		status,bean.strengthCostList = util:Load_Vint()
		if not status then return false end
		status,bean.silverCostListType = util:Load_Vint()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CLifeSkillCostTable
