
require "utils.binutil"

CPetAttrTable = {}
CPetAttrTable.__index = CPetAttrTable

function CPetAttrTable:new()
	local self = {}
	setmetatable(self, CPetAttrTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CPetAttrTable:getRecorder(id)
	return self.m_cache[id]
end

function CPetAttrTable:getAllID()
	return self.allID
end

function CPetAttrTable:getSize()
	return self.memberCount
end

function CPetAttrTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=5311836 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.name = util:Load_string()
		if not status then return false end
		status,bean.colour = util:Load_string()
		if not status then return false end
		status,bean.quality = util:Load_int()
		if not status then return false end
		status,bean.unusualid = util:Load_int()
		if not status then return false end
		status,bean.modelid = util:Load_int()
		if not status then return false end
		status,bean.whethershow = util:Load_int()
		if not status then return false end
		status,bean.kind = util:Load_int()
		if not status then return false end
		status,bean.uselevel = util:Load_int()
		if not status then return false end
		status,bean.takelevel = util:Load_int()
		if not status then return false end
		status,bean.area1colour = util:Load_int()
		if not status then return false end
		status,bean.area2colour = util:Load_int()
		if not status then return false end
		status,bean.life = util:Load_int()
		if not status then return false end
		status,bean.attackaptmin = util:Load_int()
		if not status then return false end
		status,bean.attackaptmax = util:Load_int()
		if not status then return false end
		status,bean.defendaptmin = util:Load_int()
		if not status then return false end
		status,bean.defendaptmax = util:Load_int()
		if not status then return false end
		status,bean.phyforceaptmin = util:Load_int()
		if not status then return false end
		status,bean.phyforceaptmax = util:Load_int()
		if not status then return false end
		status,bean.magicaptmin = util:Load_int()
		if not status then return false end
		status,bean.magicaptmax = util:Load_int()
		if not status then return false end
		status,bean.speedaptmin = util:Load_int()
		if not status then return false end
		status,bean.speedaptmax = util:Load_int()
		if not status then return false end
		status,bean.growrate = util:Load_Vint()
		if not status then return false end
		status,bean.addpoint = util:Load_Vint()
		if not status then return false end
		status,bean.skillid = util:Load_Vint()
		if not status then return false end
		status,bean.skillrate = util:Load_Vint()
		if not status then return false end
		status,bean.washitemid = util:Load_int()
		if not status then return false end
		status,bean.washitemnum = util:Load_int()
		if not status then return false end
		status,bean.washnewpetid = util:Load_string()
		if not status then return false end
		status,bean.certificationcost = util:Load_int()
		if not status then return false end
		status,bean.cancelcertificationcost = util:Load_int()
		if not status then return false end
		status,bean.thewildid = util:Load_int()
		if not status then return false end
		status,bean.thebabyid = util:Load_int()
		if not status then return false end
		status,bean.thebianyiid = util:Load_int()
		if not status then return false end
		status,bean.bornmapid = util:Load_int()
		if not status then return false end
		status,bean.bornmapdes = util:Load_string()
		if not status then return false end
		status,bean.treasureScore = util:Load_int()
		if not status then return false end
		status,bean.nshoptype = util:Load_int()
		if not status then return false end
		status,bean.nshopnpcid = util:Load_int()
		if not status then return false end
		status,bean.treasureskillnums = util:Load_int()
		if not status then return false end
		status,bean.nskillnumfull = util:Load_int()
		if not status then return false end
		status,bean.dyelist = util:Load_string()
		if not status then return false end
		status,bean.marketfreezetime = util:Load_int()
		if not status then return false end
		status,bean.isbindskill = util:Load_Vint()
		if not status then return false end
		status,bean.pointcardisshow = util:Load_int()
		if not status then return false end
		status,bean.pointcardbornmapid = util:Load_int()
		if not status then return false end
		status,bean.pointcardbornmapdes = util:Load_string()
		if not status then return false end
		status,bean.needitemid = util:Load_int()
		if not status then return false end
		status,bean.needitemnum = util:Load_int()
		if not status then return false end
		status,bean.huanhuashow = util:Load_int()
		if not status then return false end
		status,bean.iszhenshou = util:Load_int()
		if not status then return false end
		status,bean.zmzsnd = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CPetAttrTable
