
require "utils.binutil"

CItembuffidsTable = {}
CItembuffidsTable.__index = CItembuffidsTable

function CItembuffidsTable:new()
	local self = {}
	setmetatable(self, CItembuffidsTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CItembuffidsTable:getRecorder(id)
	return self.m_cache[id]
end

function CItembuffidsTable:getAllID()
	return self.allID
end

function CItembuffidsTable:getSize()
	return self.memberCount
end

function CItembuffidsTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=327700 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.buffids = util:Load_Vint()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CItembuffidsTable
