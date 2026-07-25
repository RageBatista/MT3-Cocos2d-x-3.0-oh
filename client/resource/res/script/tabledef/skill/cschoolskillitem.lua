
require "utils.binutil"

CSchoolSkillitemTable = {}
CSchoolSkillitemTable.__index = CSchoolSkillitemTable

function CSchoolSkillitemTable:new()
	local self = {}
	setmetatable(self, CSchoolSkillitemTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CSchoolSkillitemTable:getRecorder(id)
	return self.m_cache[id]
end

function CSchoolSkillitemTable:getAllID()
	return self.allID
end

function CSchoolSkillitemTable:getSize()
	return self.memberCount
end

function CSchoolSkillitemTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=2687882 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.skillname = util:Load_string()
		if not status then return false end
		status,bean.skillabbrname = util:Load_string()
		if not status then return false end
		status,bean.skillsort = util:Load_int()
		if not status then return false end
		status,bean.sType = util:Load_string()
		if not status then return false end
		status,bean.paramA = util:Load_double()
		if not status then return false end
		status,bean.paramB = util:Load_double()
		if not status then return false end
		status,bean.costA = util:Load_string()
		if not status then return false end
		status,bean.paramC = util:Load_double()
		if not status then return false end
		status,bean.paramD = util:Load_double()
		if not status then return false end
		status,bean.costB = util:Load_string()
		if not status then return false end
		status,bean.costTypeA = util:Load_int()
		if not status then return false end
		status,bean.costTypeB = util:Load_int()
		if not status then return false end
		status,bean.normalIcon = util:Load_int()
		if not status then return false end
		status,bean.levellimit = util:Load_Vint()
		if not status then return false end
		status,bean.leveldescribezero = util:Load_string()
		if not status then return false end
		status,bean.leveldescribe = util:Load_Vstring()
		if not status then return false end
		status,bean.skilldescribe = util:Load_string()
		if not status then return false end
		status,bean.skilldescribelist = util:Load_Vstring()
		if not status then return false end
		status,bean.targettype = util:Load_int()
		if not status then return false end
		status,bean.bCanUseInBattle = util:Load_int()
		if not status then return false end
		status,bean.effectid = util:Load_int()
		if not status then return false end
		status,bean.skillScript = util:Load_string()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CSchoolSkillitemTable
