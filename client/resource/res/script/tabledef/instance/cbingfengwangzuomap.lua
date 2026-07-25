
require "utils.binutil"

CbingfengwangzuoMapTable = {}
CbingfengwangzuoMapTable.__index = CbingfengwangzuoMapTable

function CbingfengwangzuoMapTable:new()
	local self = {}
	setmetatable(self, CbingfengwangzuoMapTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CbingfengwangzuoMapTable:getRecorder(id)
	return self.m_cache[id]
end

function CbingfengwangzuoMapTable:getAllID()
	return self.allID
end

function CbingfengwangzuoMapTable:getSize()
	return self.memberCount
end

function CbingfengwangzuoMapTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=917656 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.level = util:Load_int()
		if not status then return false end
		status,bean.enemyNum = util:Load_int()
		if not status then return false end
		status,bean.mapName = util:Load_string()
		if not status then return false end
		status,bean.image1 = util:Load_string()
		if not status then return false end
		status,bean.image2 = util:Load_string()
		if not status then return false end
		status,bean.image3 = util:Load_string()
		if not status then return false end
		status,bean.image4 = util:Load_string()
		if not status then return false end
		status,bean.image5 = util:Load_string()
		if not status then return false end
		status,bean.image6 = util:Load_string()
		if not status then return false end
		status,bean.image7 = util:Load_string()
		if not status then return false end
		status,bean.image8 = util:Load_string()
		if not status then return false end
		status,bean.ccbiaoshi = util:Load_string()
		if not status then return false end
		status,bean.ccmapName = util:Load_string()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CbingfengwangzuoMapTable
