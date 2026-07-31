
require "utils.binutil"

CAnYeMaXiTuanConfTable = {}
CAnYeMaXiTuanConfTable.__index = CAnYeMaXiTuanConfTable

function CAnYeMaXiTuanConfTable:new()
	local self = {}
	setmetatable(self, CAnYeMaXiTuanConfTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CAnYeMaXiTuanConfTable:getRecorder(id)
	return self.m_cache[id]
end

function CAnYeMaXiTuanConfTable:getAllID()
	return self.allID
end

function CAnYeMaXiTuanConfTable:getSize()
	return self.memberCount
end

function CAnYeMaXiTuanConfTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=2556765 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.nactivetype = util:Load_int()
		if not status then return false end
		status,bean.levelgroup = util:Load_int()
		if not status then return false end
		status,bean.levelmin = util:Load_int()
		if not status then return false end
		status,bean.levelmax = util:Load_int()
		if not status then return false end
		status,bean.roundgroup = util:Load_int()
		if not status then return false end
		status,bean.roundmin = util:Load_int()
		if not status then return false end
		status,bean.roundmax = util:Load_int()
		if not status then return false end
		status,bean.roundrate = util:Load_int()
		if not status then return false end
		status,bean.period = util:Load_int()
		if not status then return false end
		status,bean.tasktype = util:Load_int()
		if not status then return false end
		status,bean.group = util:Load_int()
		if not status then return false end
		status,bean.isrenxing = util:Load_int()
		if not status then return false end
		status,bean.renxingcost = util:Load_int()
		if not status then return false end
		status,bean.normalaward = util:Load_int()
		if not status then return false end
		status,bean.extaward = util:Load_int()
		if not status then return false end
		status,bean.specialaward = util:Load_int()
		if not status then return false end
		status,bean.comtips = util:Load_int()
		if not status then return false end
		status,bean.strtasknameui = util:Load_string()
		if not status then return false end
		status,bean.ntaskicon = util:Load_int()
		if not status then return false end
		status,bean.strtaskdescui = util:Load_string()
		if not status then return false end
		status,bean.strtaskname = util:Load_string()
		if not status then return false end
		status,bean.strtaskdesc = util:Load_string()
		if not status then return false end
		status,bean.vrewardid = util:Load_Vint()
		if not status then return false end
		status,bean.strtasktypeicon = util:Load_string()
		if not status then return false end
		status,bean.titledes = util:Load_string()
		if not status then return false end
		status,bean.followtitle = util:Load_string()
		if not status then return false end
		status,bean.followtitledes = util:Load_string()
		if not status then return false end
		status,bean.dialogdes = util:Load_string()
		if not status then return false end
		status,bean.dialogdessuccess = util:Load_string()
		if not status then return false end
		status,bean.dialogdesfail = util:Load_string()
		if not status then return false end
		status,bean.followdes = util:Load_string()
		if not status then return false end
		status,bean.followdessuccess = util:Load_string()
		if not status then return false end
		status,bean.followdesfail = util:Load_string()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CAnYeMaXiTuanConfTable
