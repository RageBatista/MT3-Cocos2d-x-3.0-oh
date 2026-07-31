
require "utils.binutil"

CFactionGoldBankTable = {}
CFactionGoldBankTable.__index = CFactionGoldBankTable

function CFactionGoldBankTable:new()
	local self = {}
	setmetatable(self, CFactionGoldBankTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CFactionGoldBankTable:getRecorder(id)
	return self.m_cache[id]
end

function CFactionGoldBankTable:getAllID()
	return self.allID
end

function CFactionGoldBankTable:getSize()
	return self.memberCount
end

function CFactionGoldBankTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=393243 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.levelupcost = util:Load_int()
		if not status then return false end
		status,bean.bonus = util:Load_int()
		if not status then return false end
		status,bean.allbonus = util:Load_int()
		if not status then return false end
		status,bean.limitmoney = util:Load_int()
		if not status then return false end
		status,bean.costeveryday = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CFactionGoldBankTable
