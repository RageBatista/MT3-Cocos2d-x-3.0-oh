
require "utils.binutil"

CFoodAndDrugFormulaTable = {}
CFoodAndDrugFormulaTable.__index = CFoodAndDrugFormulaTable

function CFoodAndDrugFormulaTable:new()
	local self = {}
	setmetatable(self, CFoodAndDrugFormulaTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CFoodAndDrugFormulaTable:getRecorder(id)
	return self.m_cache[id]
end

function CFoodAndDrugFormulaTable:getAllID()
	return self.allID
end

function CFoodAndDrugFormulaTable:getSize()
	return self.memberCount
end

function CFoodAndDrugFormulaTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=589889 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.neffectid1 = util:Load_int()
		if not status then return false end
		status,bean.nformulaa1 = util:Load_double()
		if not status then return false end
		status,bean.nformulab1 = util:Load_double()
		if not status then return false end
		status,bean.neffectid2 = util:Load_int()
		if not status then return false end
		status,bean.nformulaa2 = util:Load_double()
		if not status then return false end
		status,bean.nformulab2 = util:Load_double()
		if not status then return false end
		status,bean.ndupercent = util:Load_int()
		if not status then return false end
		status,bean.strformula = util:Load_string()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CFoodAndDrugFormulaTable
