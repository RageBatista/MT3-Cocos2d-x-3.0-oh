
require "utils.binutil"

CEquipItemAttrTable = {}
CEquipItemAttrTable.__index = CEquipItemAttrTable

function CEquipItemAttrTable:new()
	local self = {}
	setmetatable(self, CEquipItemAttrTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CEquipItemAttrTable:getRecorder(id)
	return self.m_cache[id]
end

function CEquipItemAttrTable:getAllID()
	return self.allID
end

function CEquipItemAttrTable:getSize()
	return self.memberCount
end

function CEquipItemAttrTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=7018249 then
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
		status,bean.newSkillId = util:Load_int()
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
		status,bean.chongzhuitemid = util:Load_int()
		if not status then return false end
		status,bean.chongzhuitemnum = util:Load_int()
		if not status then return false end
		status,bean.chongzhumoney = util:Load_int()
		if not status then return false end
		status,bean.equipitemid = util:Load_int()
		if not status then return false end
		status,bean.equipnum = util:Load_int()
		if not status then return false end
		status,bean.equipmoney = util:Load_int()
		if not status then return false end
		status,bean.fumoitemid = util:Load_int()
		if not status then return false end
		status,bean.fumoitemnum = util:Load_int()
		if not status then return false end
		status,bean.fumomoney = util:Load_int()
		if not status then return false end
		status,bean.ronglianitem = util:Load_int()
		if not status then return false end
		status,bean.rongliannum = util:Load_int()
		if not status then return false end
		status,bean.ronglianmoney = util:Load_int()
		if not status then return false end
		status,bean.jinjieid = util:Load_int()
		if not status then return false end
		status,bean.jinjieitemid = util:Load_int()
		if not status then return false end
		status,bean.jinjienum = util:Load_int()
		if not status then return false end
		status,bean.jinjiemoney = util:Load_int()
		if not status then return false end
		status,bean.doubleaddlimit = util:Load_string()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CEquipItemAttrTable
