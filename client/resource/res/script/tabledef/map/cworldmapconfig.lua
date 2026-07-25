
require "utils.binutil"

CWorldMapConfigTable = {}
CWorldMapConfigTable.__index = CWorldMapConfigTable

function CWorldMapConfigTable:new()
	local self = {}
	setmetatable(self, CWorldMapConfigTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CWorldMapConfigTable:getRecorder(id)
	return self.m_cache[id]
end

function CWorldMapConfigTable:getAllID()
	return self.allID
end

function CWorldMapConfigTable:getSize()
	return self.memberCount
end

function CWorldMapConfigTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=1310979 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.mapName = util:Load_string()
		if not status then return false end
		status,bean.topx = util:Load_int()
		if not status then return false end
		status,bean.topy = util:Load_int()
		if not status then return false end
		status,bean.bottomx = util:Load_int()
		if not status then return false end
		status,bean.bottomy = util:Load_int()
		if not status then return false end
		status,bean.maptype = util:Load_int()
		if not status then return false end
		status,bean.bShowInWorld = util:Load_bool()
		if not status then return false end
		status,bean.LevelLimitMin = util:Load_int()
		if not status then return false end
		status,bean.LevelLimitMax = util:Load_int()
		if not status then return false end
		status,bean.sonmapid = util:Load_string()
		if not status then return false end
		status,bean.sonmapname = util:Load_string()
		if not status then return false end
		status,bean.sonmapnormal = util:Load_string()
		if not status then return false end
		status,bean.sonmappushed = util:Load_string()
		if not status then return false end
		status,bean.sonmapdisable = util:Load_string()
		if not status then return false end
		status,bean.sculptid = util:Load_int()
		if not status then return false end
		status,bean.sculptimgid = util:Load_string()
		if not status then return false end
		status,bean.smallmapRes = util:Load_string()
		if not status then return false end
		status,bean.smallmapSize = util:Load_string()
		if not status then return false end
		status,bean.mapbg = util:Load_string()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CWorldMapConfigTable
