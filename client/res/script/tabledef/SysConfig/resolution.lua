
require "utils.binutil"

ResolutionTable = {}
ResolutionTable.__index = ResolutionTable

function ResolutionTable:new()
	local self = {}
	setmetatable(self, ResolutionTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function ResolutionTable:getRecorder(id)
	return self.m_cache[id]
end

function ResolutionTable:getAllID()
	return self.allID
end

function ResolutionTable:getSize()
	return self.memberCount
end

function ResolutionTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=2950133 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.number = util:Load_int()
		if not status then return false end
		status,bean.longa = util:Load_int()
		if not status then return false end
		status,bean.wide = util:Load_int()
		if not status then return false end
		status,bean.description = util:Load_string()
		if not status then return false end
		status,bean.positionsByresolution = util:Load_Vstring()
		if not status then return false end
		status,bean.positionsBywatch = util:Load_Vstring()
		if not status then return false end
		status,bean.positionsByme = util:Load_string()
		if not status then return false end
		status,bean.positionsBytarget = util:Load_string()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return ResolutionTable
