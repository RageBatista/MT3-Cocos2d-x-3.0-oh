
require "utils.binutil"

CEquipCombinTable = {}
CEquipCombinTable.__index = CEquipCombinTable

function CEquipCombinTable:new()
	local self = {}
	setmetatable(self, CEquipCombinTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CEquipCombinTable:getRecorder(id)
	return self.m_cache[id]
end

function CEquipCombinTable:getAllID()
	return self.allID
end

function CEquipCombinTable:getSize()
	return self.memberCount
end

function CEquipCombinTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=1114291 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.itemname = util:Load_string()
		if not status then return false end
		status,bean.bangyin = util:Load_int()
		if not status then return false end
		status,bean.yinliang = util:Load_int()
		if not status then return false end
		status,bean.equipnum = util:Load_int()
		if not status then return false end
		status,bean.nextequipid = util:Load_int()
		if not status then return false end
		status,bean.characterlevel = util:Load_int()
		if not status then return false end
		status,bean.colorname = util:Load_string()
		if not status then return false end
		status,bean.hechengrate = util:Load_int()
		if not status then return false end
		status,bean.hechengfailreturn = util:Load_int()
		if not status then return false end
		status,bean.failreturnnum = util:Load_int()
		if not status then return false end
		status,bean.listid = util:Load_int()
		if not status then return false end
		status,bean.hammerid = util:Load_int()
		if not status then return false end
		status,bean.hammernum = util:Load_int()
		if not status then return false end
		status,bean.hammerrate = util:Load_int()
		if not status then return false end
		status,bean.colorafterqianghua = util:Load_string()
		if not status then return false end
		status,bean.lastequipid = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CEquipCombinTable
