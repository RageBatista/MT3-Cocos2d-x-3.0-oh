
require "utils.binutil"

CMapConfigTable = {}
CMapConfigTable.__index = CMapConfigTable

function CMapConfigTable:new()
	local self = {}
	setmetatable(self, CMapConfigTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CMapConfigTable:getRecorder(id)
	return self.m_cache[id]
end

function CMapConfigTable:getAllID()
	return self.allID
end

function CMapConfigTable:getSize()
	return self.memberCount
end

function CMapConfigTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=1704330 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.mapName = util:Load_string()
		if not status then return false end
		status,bean.mapIcon = util:Load_string()
		if not status then return false end
		status,bean.desc = util:Load_string()
		if not status then return false end
		status,bean.resdir = util:Load_string()
		if not status then return false end
		status,bean.battleground = util:Load_int()
		if not status then return false end
		status,bean.width = util:Load_int()
		if not status then return false end
		status,bean.height = util:Load_int()
		if not status then return false end
		status,bean.safemap = util:Load_int()
		if not status then return false end
		status,bean.xjPos = util:Load_int()
		if not status then return false end
		status,bean.yjPos = util:Load_int()
		if not status then return false end
		status,bean.qinggong = util:Load_int()
		if not status then return false end
		status,bean.bShowInWorld = util:Load_bool()
		if not status then return false end
		status,bean.LevelLimitMin = util:Load_int()
		if not status then return false end
		status,bean.LevelLimitMax = util:Load_int()
		if not status then return false end
		status,bean.fightinfor = util:Load_int()
		if not status then return false end
		status,bean.playerPosX = util:Load_int()
		if not status then return false end
		status,bean.playerPosY = util:Load_int()
		if not status then return false end
		status,bean.dynamic = util:Load_int()
		if not status then return false end
		status,bean.fubenType = util:Load_int()
		if not status then return false end
		status,bean.music = util:Load_string()
		if not status then return false end
		status,bean.flyPosX = util:Load_int()
		if not status then return false end
		status,bean.flyPosY = util:Load_int()
		if not status then return false end
		status,bean.sceneColor = util:Load_string()
		if not status then return false end
		status,bean.jumpmappoint = util:Load_int()
		if not status then return false end
		status,bean.isMemVisible = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CMapConfigTable
