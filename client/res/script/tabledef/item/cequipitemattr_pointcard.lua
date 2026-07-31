
require "utils.binutil"

CEquipItemAttr_PointCardTable = {}
CEquipItemAttr_PointCardTable.__index = CEquipItemAttr_PointCardTable

function CEquipItemAttr_PointCardTable:new()
	local self = {}
	setmetatable(self, CEquipItemAttr_PointCardTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CEquipItemAttr_PointCardTable:getRecorder(id)
	return self.m_cache[id]
end

function CEquipItemAttr_PointCardTable:getAllID()
	return self.allID
end

function CEquipItemAttr_PointCardTable:getSize()
	return self.memberCount
end

function CEquipItemAttr_PointCardTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=5836807 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.addhpmax = util:Load_int()
		if not status then return false end
		status,bean.addmpmax = util:Load_int()
		if not status then return false end
		status,bean.addwaigongshuanghai = util:Load_int()
		if not status then return false end
		status,bean.addniegongshanghai = util:Load_int()
		if not status then return false end
		status,bean.addniegongdefence = util:Load_int()
		if not status then return false end
		status,bean.addwaigongdefence = util:Load_int()
		if not status then return false end
		status,bean.addmingzhong = util:Load_int()
		if not status then return false end
		status,bean.addduoshan = util:Load_int()
		if not status then return false end
		status,bean.addspeed = util:Load_int()
		if not status then return false end
		status,bean.addfengyin = util:Load_int()
		if not status then return false end
		status,bean.fengyinkangxing = util:Load_int()
		if not status then return false end
		status,bean.equipqianzhui = util:Load_int()
		if not status then return false end
		status,bean.appendAttrid = util:Load_Vint()
		if not status then return false end
		status,bean.appendAttrValue = util:Load_Vint()
		if not status then return false end
		status,bean.roleNeed = util:Load_Vint()
		if not status then return false end
		status,bean.saleratio = util:Load_int()
		if not status then return false end
		status,bean.naijiuratio = util:Load_int()
		if not status then return false end
		status,bean.cuilianlv = util:Load_int()
		if not status then return false end
		status,bean.naijiumax = util:Load_int()
		if not status then return false end
		status,bean.ptxlfailrate = util:Load_int()
		if not status then return false end
		status,bean.ptxlcailiaoid = util:Load_int()
		if not status then return false end
		status,bean.ptxlcailiaonum = util:Load_int()
		if not status then return false end
		status,bean.commonidlist = util:Load_Vint()
		if not status then return false end
		status,bean.commonnumlist = util:Load_Vint()
		if not status then return false end
		status,bean.tsxlcailiaoid = util:Load_int()
		if not status then return false end
		status,bean.tsxlcailiaonum = util:Load_int()
		if not status then return false end
		status,bean.ptxlmoneynum = util:Load_int()
		if not status then return false end
		status,bean.ptxlmoneytype = util:Load_int()
		if not status then return false end
		status,bean.tsxlmoneynum = util:Load_int()
		if not status then return false end
		status,bean.tsxlmoneytype = util:Load_int()
		if not status then return false end
		status,bean.gemsLevel = util:Load_int()
		if not status then return false end
		status,bean.hols = util:Load_int()
		if not status then return false end
		status,bean.vgemboxlevel = util:Load_Vint()
		if not status then return false end
		status,bean.gems = util:Load_Vint()
		if not status then return false end
		status,bean.needSex = util:Load_int()
		if not status then return false end
		status,bean.equipcolor = util:Load_int()
		if not status then return false end
		status,bean.suiting = util:Load_int()
		if not status then return false end
		status,bean.skillid = util:Load_string()
		if not status then return false end
		status,bean.effectid = util:Load_string()
		if not status then return false end
		status,bean.jianding = util:Load_int()
		if not status then return false end
		status,bean.specialAttr = util:Load_int()
		if not status then return false end
		status,bean.baseAttrId = util:Load_int()
		if not status then return false end
		status,bean.randomAttrId = util:Load_string()
		if not status then return false end
		status,bean.randomSkillId = util:Load_int()
		if not status then return false end
		status,bean.randomEffectId = util:Load_int()
		if not status then return false end
		status,bean.vgemtype = util:Load_Vint()
		if not status then return false end
		status,bean.eequiptype = util:Load_int()
		if not status then return false end
		status,bean.treasureScore = util:Load_int()
		if not status then return false end
		status,bean.nautoeffect = util:Load_int()
		if not status then return false end
		status,bean.ncanfenjie = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CEquipItemAttr_PointCardTable
