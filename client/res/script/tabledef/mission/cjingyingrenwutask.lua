
require "utils.binutil"

CJingyingrenwuTaskTable = {}
CJingyingrenwuTaskTable.__index = CJingyingrenwuTaskTable

function CJingyingrenwuTaskTable:new()
	local self = {}
	setmetatable(self, CJingyingrenwuTaskTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CJingyingrenwuTaskTable:getRecorder(id)
	return self.m_cache[id]
end

function CJingyingrenwuTaskTable:getAllID()
	return self.allID
end

function CJingyingrenwuTaskTable:getSize()
	return self.memberCount
end

function CJingyingrenwuTaskTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=1507651 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.ntasktypeid = util:Load_int()
		if not status then return false end
		status,bean.nfubenid = util:Load_int()
		if not status then return false end
		status,bean.taskname = util:Load_string()
		if not status then return false end
		status,bean.tasklevel = util:Load_string()
		if not status then return false end
		status,bean.tasktext = util:Load_string()
		if not status then return false end
		status,bean.taskready = util:Load_int()
		if not status then return false end
		status,bean.nleveltype = util:Load_int()
		if not status then return false end
		status,bean.minlevel = util:Load_int()
		if not status then return false end
		status,bean.maxlevel = util:Load_int()
		if not status then return false end
		status,bean.ndifficult = util:Load_int()
		if not status then return false end
		status,bean.strkaiqitime = util:Load_string()
		if not status then return false end
		status,bean.strkaishitime = util:Load_string()
		if not status then return false end
		status,bean.strjieshutime = util:Load_string()
		if not status then return false end
		status,bean.nlunhuantype = util:Load_int()
		if not status then return false end
		status,bean.turngroup = util:Load_int()
		if not status then return false end
		status,bean.turnid = util:Load_int()
		if not status then return false end
		status,bean.awardtype = util:Load_int()
		if not status then return false end
		status,bean.awardtime = util:Load_int()
		if not status then return false end
		status,bean.nshowtype = util:Load_int()
		if not status then return false end
		status,bean.strbgname = util:Load_string()
		if not status then return false end
		status,bean.nbossid = util:Load_int()
		if not status then return false end
		status,bean.strdes = util:Load_string()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CJingyingrenwuTaskTable
