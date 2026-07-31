
require "utils.binutil"

AcupointInfoTable = {}
AcupointInfoTable.__index = AcupointInfoTable

function AcupointInfoTable:new()
	local self = {}
	setmetatable(self, AcupointInfoTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function AcupointInfoTable:getRecorder(id)
	return self.m_cache[id]
end

function AcupointInfoTable:getAllID()
	return self.allID
end

function AcupointInfoTable:getSize()
	return self.memberCount
end

function AcupointInfoTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=2097743 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.isMain = util:Load_bool()
		if not status then return false end
		status,bean.name = util:Load_string()
		if not status then return false end
		status,bean.isJueji = util:Load_bool()
		if not status then return false end
		status,bean.maxlevel = util:Load_int()
		if not status then return false end
		status,bean.details = util:Load_string()
		if not status then return false end
		status,bean.describe = util:Load_string()
		if not status then return false end
		status,bean.iconNormal = util:Load_string()
		if not status then return false end
		status,bean.iconPushed = util:Load_string()
		if not status then return false end
		status,bean.iconHover = util:Load_string()
		if not status then return false end
		status,bean.iconDisable = util:Load_string()
		if not status then return false end
		status,bean.locX = util:Load_int()
		if not status then return false end
		status,bean.locY = util:Load_int()
		if not status then return false end
		status,bean.femalelocX = util:Load_int()
		if not status then return false end
		status,bean.femalelocY = util:Load_int()
		if not status then return false end
		status,bean.lvlocX = util:Load_int()
		if not status then return false end
		status,bean.lvlocY = util:Load_int()
		if not status then return false end
		status,bean.femalelvlocX = util:Load_int()
		if not status then return false end
		status,bean.femalelvlocY = util:Load_int()
		if not status then return false end
		status,bean.attribute = util:Load_int()
		if not status then return false end
		status,bean.paraA = util:Load_double()
		if not status then return false end
		status,bean.paraB = util:Load_double()
		if not status then return false end
		status,bean.paraC = util:Load_double()
		if not status then return false end
		status,bean.dependAcupoint = util:Load_string()
		if not status then return false end
		status,bean.dependLevel = util:Load_int()
		if not status then return false end
		status,bean.pointToSkillList = util:Load_Vint()
		if not status then return false end
		status,bean.studyCostRule = util:Load_int()
		if not status then return false end
		status,bean.juejiDependLevel = util:Load_string()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return AcupointInfoTable
