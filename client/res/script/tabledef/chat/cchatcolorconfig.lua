
require "utils.binutil"

CchatColorConfigTable = {}
CchatColorConfigTable.__index = CchatColorConfigTable

function CchatColorConfigTable:new()
	local self = {}
	setmetatable(self, CchatColorConfigTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CchatColorConfigTable:getRecorder(id)
	return self.m_cache[id]
end

function CchatColorConfigTable:getAllID()
	return self.allID
end

function CchatColorConfigTable:getSize()
	return self.memberCount
end

function CchatColorConfigTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=2294367 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.color = util:Load_string()
		if not status then return false end
		status,bean.notifylist = util:Load_Vstring()
		if not status then return false end
		status,bean.chatlist = util:Load_Vstring()
		if not status then return false end
		status,bean.headpop = util:Load_string()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CchatColorConfigTable
