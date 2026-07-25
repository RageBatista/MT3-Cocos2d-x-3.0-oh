
require "utils.binutil"

CItemAttrTable = {}
CItemAttrTable.__index = CItemAttrTable

function CItemAttrTable:new()
	local self = {}
	setmetatable(self, CItemAttrTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CItemAttrTable:getRecorder(id)
	return self.m_cache[id]
end

function CItemAttrTable:getAllID()
	return self.allID
end

function CItemAttrTable:getSize()
	return self.memberCount
end

function CItemAttrTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=2884655 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.itemtypeid = util:Load_int()
		if not status then return false end
		status,bean.name = util:Load_string()
		if not status then return false end
		status,bean.level = util:Load_int()
		if not status then return false end
		status,bean.icon = util:Load_int()
		if not status then return false end
		status,bean.battleuse = util:Load_int()
		if not status then return false end
		status,bean.battleuser = util:Load_int()
		if not status then return false end
		status,bean.outbattleuse = util:Load_int()
		if not status then return false end
		status,bean.destribe = util:Load_string()
		if not status then return false end
		status,bean.usemethod = util:Load_string()
		if not status then return false end
		status,bean.name1 = util:Load_string()
		if not status then return false end
		status,bean.namec = util:Load_string()
		if not status then return false end
		status,bean.maxNum = util:Load_int()
		if not status then return false end
		status,bean.bBind = util:Load_bool()
		if not status then return false end
		status,bean.needLevel = util:Load_int()
		if not status then return false end
		status,bean.bManuleDesrtrol = util:Load_bool()
		if not status then return false end
		status,bean.units = util:Load_string()
		if not status then return false end
		status,bean.bCanSale = util:Load_int()
		if not status then return false end
		status,bean.dbCanSale = util:Load_int()
		if not status then return false end
		status,bean.bCanSaleToNpc = util:Load_int()
		if not status then return false end
		status,bean.npcid2 = util:Load_int()
		if not status then return false end
		status,bean.colour = util:Load_string()
		if not status then return false end
		status,bean.effectdes = util:Load_string()
		if not status then return false end
		status,bean.vcomefrom = util:Load_Vint()
		if not status then return false end
		status,bean.nusetype = util:Load_int()
		if not status then return false end
		status,bean.vuseparam = util:Load_Vint()
		if not status then return false end
		status,bean.nshoptype = util:Load_int()
		if not status then return false end
		status,bean.nquality = util:Load_int()
		if not status then return false end
		status,bean.special = util:Load_int()
		if not status then return false end
		status,bean.namecc1 = util:Load_string()
		if not status then return false end
		status,bean.namecc2 = util:Load_string()
		if not status then return false end
		status,bean.namecc3 = util:Load_string()
		if not status then return false end
		status,bean.namecc4 = util:Load_string()
		if not status then return false end
		status,bean.namecc5 = util:Load_string()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CItemAttrTable
