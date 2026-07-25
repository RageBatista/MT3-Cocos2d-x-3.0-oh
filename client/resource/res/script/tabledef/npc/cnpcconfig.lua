
require "utils.binutil"

CNPCConfigTable = {}
CNPCConfigTable.__index = CNPCConfigTable

function CNPCConfigTable:new()
	local self = {}
	setmetatable(self, CNPCConfigTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CNPCConfigTable:getRecorder(id)
	return self.m_cache[id]
end

function CNPCConfigTable:getAllID()
	return self.allID
end

function CNPCConfigTable:getSize()
	return self.memberCount
end

function CNPCConfigTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=1835454 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.bodytype = util:Load_double()
		if not status then return false end
		status,bean.npctype = util:Load_int()
		if not status then return false end
		status,bean.modelID = util:Load_int()
		if not status then return false end
		status,bean.name = util:Load_string()
		if not status then return false end
		status,bean.minimapquery = util:Load_string()
		if not status then return false end
		status,bean.minimapshow = util:Load_string()
		if not status then return false end
		status,bean.foottitle = util:Load_string()
		if not status then return false end
		status,bean.headtitle = util:Load_string()
		if not status then return false end
		status,bean.title = util:Load_string()
		if not status then return false end
		status,bean.chitchatidlist = util:Load_Vint()
		if not status then return false end
		status,bean.area1colour = util:Load_int()
		if not status then return false end
		status,bean.area2colour = util:Load_int()
		if not status then return false end
		status,bean.mapid = util:Load_int()
		if not status then return false end
		status,bean.xPos = util:Load_int()
		if not status then return false end
		status,bean.yPos = util:Load_int()
		if not status then return false end
		status,bean.hide = util:Load_int()
		if not status then return false end
		status,bean.voices = util:Load_Vstring()
		if not status then return false end
		status,bean.ndir = util:Load_int()
		if not status then return false end
		status,bean.nstate = util:Load_int()
		if not status then return false end
		status,bean.time = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CNPCConfigTable
