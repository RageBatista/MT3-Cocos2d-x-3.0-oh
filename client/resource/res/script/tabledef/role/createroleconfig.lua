
require "utils.binutil"

CreateRoleConfigTable = {}
CreateRoleConfigTable.__index = CreateRoleConfigTable

function CreateRoleConfigTable:new()
	local self = {}
	setmetatable(self, CreateRoleConfigTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CreateRoleConfigTable:getRecorder(id)
	return self.m_cache[id]
end

function CreateRoleConfigTable:getAllID()
	return self.allID
end

function CreateRoleConfigTable:getSize()
	return self.memberCount
end

function CreateRoleConfigTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=2753544 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.sex = util:Load_int()
		if not status then return false end
		status,bean.name = util:Load_string()
		if not status then return false end
		status,bean.englishname = util:Load_string()
		if not status then return false end
		status,bean.describe = util:Load_string()
		if not status then return false end
		status,bean.schools = util:Load_Vint()
		if not status then return false end
		status,bean.weapons = util:Load_Vint()
		if not status then return false end
		status,bean.model = util:Load_int()
		if not status then return false end
		status,bean.roleimage = util:Load_string()
		if not status then return false end
		status,bean.schoolimg1 = util:Load_string()
		if not status then return false end
		status,bean.schoolimg2 = util:Load_string()
		if not status then return false end
		status,bean.schoolimg3 = util:Load_string()
		if not status then return false end
		status,bean.schoolimg4 = util:Load_string()
		if not status then return false end
		status,bean.schoolimg5 = util:Load_string()
		if not status then return false end
		status,bean.diwenimg1 = util:Load_string()
		if not status then return false end
		status,bean.diwenimg2 = util:Load_string()
		if not status then return false end
		status,bean.diwenimg3 = util:Load_string()
		if not status then return false end
		status,bean.diwenimg4 = util:Load_string()
		if not status then return false end
		status,bean.diwenimg5 = util:Load_string()
		if not status then return false end
		status,bean.headimg = util:Load_string()
		if not status then return false end
		status,bean.surebtnimg = util:Load_string()
		if not status then return false end
		status,bean.returnimg = util:Load_string()
		if not status then return false end
		status,bean.leftbtnimg = util:Load_string()
		if not status then return false end
		status,bean.rightbtnimg = util:Load_string()
		if not status then return false end
		status,bean.bgimg = util:Load_string()
		if not status then return false end
		status,bean.bgbandimg = util:Load_string()
		if not status then return false end
		status,bean.effectOnTop = util:Load_string()
		if not status then return false end
		status,bean.effectOnBottom = util:Load_string()
		if not status then return false end
		status,bean.xuanzezhiyeimg = util:Load_string()
		if not status then return false end
		status,bean.pagedotimg = util:Load_string()
		if not status then return false end
		status,bean.smallflag = util:Load_string()
		if not status then return false end
		status,bean.flageffect = util:Load_string()
		if not status then return false end
		status,bean.spine = util:Load_string()
		if not status then return false end
		status,bean.topflag = util:Load_string()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CreateRoleConfigTable
