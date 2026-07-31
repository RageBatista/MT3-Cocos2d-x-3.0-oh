
require "utils.binutil"

CLoginImagesTable = {}
CLoginImagesTable.__index = CLoginImagesTable

function CLoginImagesTable:new()
	local self = {}
	setmetatable(self, CLoginImagesTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CLoginImagesTable:getRecorder(id)
	return self.m_cache[id]
end

function CLoginImagesTable:getAllID()
	return self.allID
end

function CLoginImagesTable:getSize()
	return self.memberCount
end

function CLoginImagesTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=589881 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.imagefilename = util:Load_string()
		if not status then return false end
		status,bean.width = util:Load_int()
		if not status then return false end
		status,bean.height = util:Load_int()
		if not status then return false end
		status,bean.minlevel = util:Load_int()
		if not status then return false end
		status,bean.maxlevel = util:Load_int()
		if not status then return false end
		status,bean.mapid = util:Load_int()
		if not status then return false end
		status,bean.taskid = util:Load_int()
		if not status then return false end
		status,bean.weight = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CLoginImagesTable
