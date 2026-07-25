
require "utils.binutil"

CFumoEffectFormulaTable = {}
CFumoEffectFormulaTable.__index = CFumoEffectFormulaTable

function CFumoEffectFormulaTable:new()
	local self = {}
	setmetatable(self, CFumoEffectFormulaTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CFumoEffectFormulaTable:getRecorder(id)
	return self.m_cache[id]
end

function CFumoEffectFormulaTable:getAllID()
	return self.allID
end

function CFumoEffectFormulaTable:getSize()
	return self.memberCount
end

function CFumoEffectFormulaTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=524343 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.strname = util:Load_string()
		if not status then return false end
		status,bean.npropertyid = util:Load_int()
		if not status then return false end
		status,bean.fmin = util:Load_double()
		if not status then return false end
		status,bean.fmax = util:Load_double()
		if not status then return false end
		status,bean.npropertyid2 = util:Load_int()
		if not status then return false end
		status,bean.fmin2 = util:Load_double()
		if not status then return false end
		status,bean.fmax2 = util:Load_double()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CFumoEffectFormulaTable
