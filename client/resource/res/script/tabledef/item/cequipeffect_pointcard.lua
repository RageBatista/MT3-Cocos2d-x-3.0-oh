
require "utils.binutil"

CEquipEffect_PointCardTable = {}
CEquipEffect_PointCardTable.__index = CEquipEffect_PointCardTable

function CEquipEffect_PointCardTable:new()
	local self = {}
	setmetatable(self, CEquipEffect_PointCardTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CEquipEffect_PointCardTable:getRecorder(id)
	return self.m_cache[id]
end

function CEquipEffect_PointCardTable:getAllID()
	return self.allID
end

function CEquipEffect_PointCardTable:getSize()
	return self.memberCount
end

function CEquipEffect_PointCardTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=2556710 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.equipcolor = util:Load_int()
		if not status then return false end
		status,bean.baseEffectType = util:Load_Vint()
		if not status then return false end
		status,bean.baseEffect = util:Load_Vint()
		if not status then return false end
		status,bean.sexNeed = util:Load_int()
		if not status then return false end
		status,bean.scorecolor = util:Load_Vint()
		if not status then return false end
		status,bean.roleNeed = util:Load_Vint()
		if not status then return false end
		status,bean.bCanSale = util:Load_int()
		if not status then return false end
		status,bean.dbCanSale = util:Load_int()
		if not status then return false end
		status,bean.sellpricecoef = util:Load_int()
		if not status then return false end
		status,bean.endurecoef = util:Load_int()
		if not status then return false end
		status,bean.suiting = util:Load_int()
		if not status then return false end
		status,bean.weaponid = util:Load_int()
		if not status then return false end
		status,bean.weaponeffectid = util:Load_int()
		if not status then return false end
		status,bean.modelpathleft = util:Load_Vstring()
		if not status then return false end
		status,bean.modelpathright = util:Load_Vstring()
		if not status then return false end
		status,bean.socketleft = util:Load_Vstring()
		if not status then return false end
		status,bean.socketright = util:Load_Vstring()
		if not status then return false end
		status,bean.needCareer = util:Load_string()
		if not status then return false end
		status,bean.eequiptype = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CEquipEffect_PointCardTable
