
require "utils.binutil"

CLifeSkillTable = {}
CLifeSkillTable.__index = CLifeSkillTable

function CLifeSkillTable:new()
	local self = {}
	setmetatable(self, CLifeSkillTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CLifeSkillTable:getRecorder(id)
	return self.m_cache[id]
end

function CLifeSkillTable:getAllID()
	return self.allID
end

function CLifeSkillTable:getSize()
	return self.memberCount
end

function CLifeSkillTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=2622357 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.name = util:Load_string()
		if not status then return false end
		status,bean.paixuID = util:Load_int()
		if not status then return false end
		status,bean.icon = util:Load_int()
		if not status then return false end
		status,bean.skillType = util:Load_int()
		if not status then return false end
		status,bean.fumoItemID = util:Load_int()
		if not status then return false end
		status,bean.needGuild = util:Load_int()
		if not status then return false end
		status,bean.skillLevelMax = util:Load_int()
		if not status then return false end
		status,bean.studyLevelRule = util:Load_int()
		if not status then return false end
		status,bean.studyCostRule = util:Load_int()
		if not status then return false end
		status,bean.strengthCostRule = util:Load_int()
		if not status then return false end
		status,bean.upgradeDesc = util:Load_string()
		if not status then return false end
		status,bean.upgradeVariable = util:Load_int()
		if not status then return false end
		status,bean.upgradeDesc2 = util:Load_string()
		if not status then return false end
		status,bean.upgradeVariable2 = util:Load_int()
		if not status then return false end
		status,bean.upgradeDesc3 = util:Load_string()
		if not status then return false end
		status,bean.upgradeVariable3 = util:Load_int()
		if not status then return false end
		status,bean.upgradeDesc4 = util:Load_string()
		if not status then return false end
		status,bean.upgradeVariable4 = util:Load_int()
		if not status then return false end
		status,bean.skillId = util:Load_int()
		if not status then return false end
		status,bean.bCanStudy = util:Load_int()
		if not status then return false end
		status,bean.guidetips = util:Load_string()
		if not status then return false end
		status,bean.description = util:Load_string()
		if not status then return false end
		status,bean.brief = util:Load_string()
		if not status then return false end
		status,bean.effect = util:Load_string()
		if not status then return false end
		status,bean.effectnow = util:Load_string()
		if not status then return false end
		status,bean.ParaNum = util:Load_int()
		if not status then return false end
		status,bean.ParaIndexList = util:Load_Vint()
		if not status then return false end
		status,bean.bNeedSkilled = util:Load_int()
		if not status then return false end
		status,bean.gangdescription = util:Load_string()
		if not status then return false end
		status,bean.cureffect1 = util:Load_string()
		if not status then return false end
		status,bean.cureffect2 = util:Load_string()
		if not status then return false end
		status,bean.cureffect3 = util:Load_string()
		if not status then return false end
		status,bean.cureffect4 = util:Load_string()
		if not status then return false end
		status,bean.curid1 = util:Load_string()
		if not status then return false end
		status,bean.curid2 = util:Load_string()
		if not status then return false end
		status,bean.curid3 = util:Load_string()
		if not status then return false end
		status,bean.curid4 = util:Load_string()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CLifeSkillTable
