
require "utils.binutil"

CSchoolTaskTable = {}
CSchoolTaskTable.__index = CSchoolTaskTable

function CSchoolTaskTable:new()
	local self = {}
	setmetatable(self, CSchoolTaskTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CSchoolTaskTable:getRecorder(id)
	return self.m_cache[id]
end

function CSchoolTaskTable:getAllID()
	return self.allID
end

function CSchoolTaskTable:getSize()
	return self.memberCount
end

function CSchoolTaskTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=1704341 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.type = util:Load_int()
		if not status then return false end
		status,bean.levelgroup = util:Load_int()
		if not status then return false end
		status,bean.levelmin = util:Load_int()
		if not status then return false end
		status,bean.levelmax = util:Load_int()
		if not status then return false end
		status,bean.maxnum = util:Load_int()
		if not status then return false end
		status,bean.exp_round_level_coef = util:Load_double()
		if not status then return false end
		status,bean.exp_round_final = util:Load_double()
		if not status then return false end
		status,bean.exp_level_coef = util:Load_double()
		if not status then return false end
		status,bean.exp_final = util:Load_double()
		if not status then return false end
		status,bean.money_round_level_coef = util:Load_double()
		if not status then return false end
		status,bean.money_round_coef = util:Load_double()
		if not status then return false end
		status,bean.money_level_coef = util:Load_double()
		if not status then return false end
		status,bean.money_round_final = util:Load_double()
		if not status then return false end
		status,bean.s_round_level_coef = util:Load_double()
		if not status then return false end
		status,bean.s_round_coef = util:Load_double()
		if not status then return false end
		status,bean.s_level_coef = util:Load_double()
		if not status then return false end
		status,bean.s_round_final = util:Load_double()
		if not status then return false end
		status,bean.pet_exp_level_coef = util:Load_double()
		if not status then return false end
		status,bean.pet_exp_final = util:Load_double()
		if not status then return false end
		status,bean.nautodo = util:Load_int()
		if not status then return false end
		status,bean.nautonextlun = util:Load_int()
		if not status then return false end
		status,bean.nlunendmsgid = util:Load_int()
		if not status then return false end
		status,bean.ngaojianground = util:Load_int()
		if not status then return false end
		status,bean.ngaojiangmsgid = util:Load_int()
		if not status then return false end
		status,bean.doublepoint = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CSchoolTaskTable
