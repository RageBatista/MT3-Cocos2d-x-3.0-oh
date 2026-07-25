
require "utils.binutil"

CActivityNewpayTable = {}
CActivityNewpayTable.__index = CActivityNewpayTable

function CActivityNewpayTable:new()
	local self = {}
	setmetatable(self, CActivityNewpayTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CActivityNewpayTable:getRecorder(id)
	return self.m_cache[id]
end

function CActivityNewpayTable:getAllID()
	return self.allID
end

function CActivityNewpayTable:getSize()
	return self.memberCount
end

function CActivityNewpayTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=2228890 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.type = util:Load_int()
		if not status then return false end
		status,bean.level = util:Load_int()
		if not status then return false end
		status,bean.name = util:Load_string()
		if not status then return false end
		status,bean.leveltext = util:Load_string()
		if not status then return false end
		status,bean.unleveltext = util:Load_string()
		if not status then return false end
		status,bean.maxlevel = util:Load_int()
		if not status then return false end
		status,bean.text = util:Load_string()
		if not status then return false end
		status,bean.times = util:Load_string()
		if not status then return false end
		status,bean.isshowmaxnum = util:Load_int()
		if not status then return false end
		status,bean.maxnum = util:Load_int()
		if not status then return false end
		status,bean.maxact = util:Load_double()
		if not status then return false end
		status,bean.link = util:Load_int()
		if not status then return false end
		status,bean.linkid1 = util:Load_int()
		if not status then return false end
		status,bean.linkid2 = util:Load_int()
		if not status then return false end
		status,bean.sort = util:Load_int()
		if not status then return false end
		status,bean.timetext = util:Load_string()
		if not status then return false end
		status,bean.activitylv = util:Load_string()
		if not status then return false end
		status,bean.markid = util:Load_string()
		if not status then return false end
		status,bean.imgid = util:Load_int()
		if not status then return false end
		status,bean.getfoodid1 = util:Load_int()
		if not status then return false end
		status,bean.getfoodid2 = util:Load_int()
		if not status then return false end
		status,bean.getfoodid3 = util:Load_int()
		if not status then return false end
		status,bean.getfoodid4 = util:Load_int()
		if not status then return false end
		status,bean.getfoodid5 = util:Load_int()
		if not status then return false end
		status,bean.protext = util:Load_string()
		if not status then return false end
		status,bean.actid = util:Load_string()
		if not status then return false end
		status,bean.starttuijian = util:Load_int()
		if not status then return false end
		status,bean.actvalue = util:Load_double()
		if not status then return false end
		status,bean.serversend = util:Load_int()
		if not status then return false end
		status,bean.infinitenum = util:Load_int()
		if not status then return false end
		status,bean.isopen = util:Load_int()
		if not status then return false end
		status,bean.linkredpackdis = util:Load_int()
		if not status then return false end
		status,bean.serverid = util:Load_string()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CActivityNewpayTable
