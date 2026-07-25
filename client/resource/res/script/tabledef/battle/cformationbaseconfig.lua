
require "utils.binutil"

CFormationbaseConfigTable = {}
CFormationbaseConfigTable.__index = CFormationbaseConfigTable

function CFormationbaseConfigTable:new()
	local self = {}
	setmetatable(self, CFormationbaseConfigTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CFormationbaseConfigTable:getRecorder(id)
	return self.m_cache[id]
end

function CFormationbaseConfigTable:getAllID()
	return self.allID
end

function CFormationbaseConfigTable:getSize()
	return self.memberCount
end

function CFormationbaseConfigTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=2556744 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.name = util:Load_string()
		if not status then return false end
		status,bean.imagepath = util:Load_string()
		if not status then return false end
		status,bean.icon = util:Load_int()
		if not status then return false end
		status,bean.describe = util:Load_string()
		if not status then return false end
		status,bean.formation = util:Load_Vint()
		if not status then return false end
		status,bean.des = util:Load_string()
		if not status then return false end
		status,bean.fear1 = util:Load_string()
		if not status then return false end
		status,bean.fear2 = util:Load_string()
		if not status then return false end
		status,bean.path = util:Load_string()
		if not status then return false end
		status,bean.bookid = util:Load_int()
		if not status then return false end
		status,bean.bookaddexp = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CFormationbaseConfigTable
