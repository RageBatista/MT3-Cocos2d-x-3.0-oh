
require "utils.binutil"

CRepeatTaskTable = {}
CRepeatTaskTable.__index = CRepeatTaskTable

function CRepeatTaskTable:new()
	local self = {}
	setmetatable(self, CRepeatTaskTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CRepeatTaskTable:getRecorder(id)
	return self.m_cache[id]
end

function CRepeatTaskTable:getAllID()
	return self.allID
end

function CRepeatTaskTable:getSize()
	return self.memberCount
end

function CRepeatTaskTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=1048746 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.eactivetype = util:Load_int()
		if not status then return false end
		status,bean.etasktype = util:Load_int()
		if not status then return false end
		status,bean.ngroupid = util:Load_int()
		if not status then return false end
		status,bean.strtypename = util:Load_string()
		if not status then return false end
		status,bean.strtaskname = util:Load_string()
		if not status then return false end
		status,bean.strtasktitle = util:Load_string()
		if not status then return false end
		status,bean.strtaskdes = util:Load_string()
		if not status then return false end
		status,bean.strtasktitletrack = util:Load_string()
		if not status then return false end
		status,bean.strtaskdestrack = util:Load_string()
		if not status then return false end
		status,bean.nflytype = util:Load_int()
		if not status then return false end
		status,bean.nautodone = util:Load_int()
		if not status then return false end
		status,bean.nacceptchatid = util:Load_int()
		if not status then return false end
		status,bean.nnpcchatid = util:Load_int()
		if not status then return false end
		status,bean.ncommitchatid = util:Load_int()
		if not status then return false end
		status,bean.nacceptnpcid = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CRepeatTaskTable
