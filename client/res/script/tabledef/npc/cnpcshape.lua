
require "utils.binutil"

CNpcShapeTable = {}
CNpcShapeTable.__index = CNpcShapeTable

function CNpcShapeTable:new()
	local self = {}
	setmetatable(self, CNpcShapeTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CNpcShapeTable:getRecorder(id)
	return self.m_cache[id]
end

function CNpcShapeTable:getAllID()
	return self.allID
end

function CNpcShapeTable:getSize()
	return self.memberCount
end

function CNpcShapeTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=1507642 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.shape = util:Load_string()
		if not status then return false end
		status,bean.roleimage = util:Load_string()
		if not status then return false end
		status,bean.headID = util:Load_int()
		if not status then return false end
		status,bean.littleheadID = util:Load_int()
		if not status then return false end
		status,bean.mapheadID = util:Load_int()
		if not status then return false end
		status,bean.name = util:Load_string()
		if not status then return false end
		status,bean.dir = util:Load_int()
		if not status then return false end
		status,bean.hitmove = util:Load_int()
		if not status then return false end
		status,bean.shadow = util:Load_int()
		if not status then return false end
		status,bean.attack = util:Load_string()
		if not status then return false end
		status,bean.magic = util:Load_string()
		if not status then return false end
		status,bean.nearorfar = util:Load_int()
		if not status then return false end
		status,bean.shadertype = util:Load_int()
		if not status then return false end
		status,bean.part0 = util:Load_Vint()
		if not status then return false end
		status,bean.part1 = util:Load_Vint()
		if not status then return false end
		status,bean.part2 = util:Load_Vint()
		if not status then return false end
		status,bean.showWeaponId = util:Load_int()
		if not status then return false end
		status,bean.showHorseShape = util:Load_int()
		if not status then return false end
		status,bean.mapheadcID = util:Load_int()
		if not status then return false end
		status,bean.ccroleimage = util:Load_int()
		if not status then return false end
		status,bean.ccyuanimage = util:Load_int()
		if not status then return false end
		status,bean.mapheadccID = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CNpcShapeTable
