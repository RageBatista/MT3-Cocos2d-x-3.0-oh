
require "utils.binutil"

CEnChouLuNewConfigTable = {}
CEnChouLuNewConfigTable.__index = CEnChouLuNewConfigTable

function CEnChouLuNewConfigTable:new()
	local self = {}
	setmetatable(self, CEnChouLuNewConfigTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CEnChouLuNewConfigTable:getRecorder(id)
	return self.m_cache[id]
end

function CEnChouLuNewConfigTable:getAllID()
	return self.allID
end

function CEnChouLuNewConfigTable:getSize()
	return self.memberCount
end

function CEnChouLuNewConfigTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=1442097 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.minlevel = util:Load_int()
		if not status then return false end
		status,bean.maxlevel = util:Load_int()
		if not status then return false end
		status,bean.instzoneid = util:Load_int()
		if not status then return false end
		status,bean.levelall = util:Load_int()
		if not status then return false end
		status,bean.state = util:Load_int()
		if not status then return false end
		status,bean.Map = util:Load_int()
		if not status then return false end
		status,bean.ZuoBiao = util:Load_string()
		if not status then return false end
		status,bean.FocusNpc = util:Load_int()
		if not status then return false end
		status,bean.Fightid = util:Load_int()
		if not status then return false end
		status,bean.JiangyouNpc = util:Load_string()
		if not status then return false end
		status,bean.title = util:Load_string()
		if not status then return false end
		status,bean.describe = util:Load_string()
		if not status then return false end
		status,bean.boss = util:Load_int()
		if not status then return false end
		status,bean.level = util:Load_string()
		if not status then return false end
		status,bean.introduce = util:Load_string()
		if not status then return false end
		status,bean.name = util:Load_string()
		if not status then return false end
		status,bean.posX = util:Load_int()
		if not status then return false end
		status,bean.posY = util:Load_int()
		if not status then return false end
		status,bean.ccicon = util:Load_string()
		if not status then return false end
		status,bean.ccguanka = util:Load_string()
		if not status then return false end
		status,bean.ccintroduce = util:Load_string()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CEnChouLuNewConfigTable
