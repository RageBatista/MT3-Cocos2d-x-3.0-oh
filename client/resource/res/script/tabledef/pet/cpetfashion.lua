
require "utils.binutil"

CPetFashionTable = {}
CPetFashionTable.__index = CPetFashionTable

function CPetFashionTable:new()
	local self = {}
	setmetatable(self, CPetFashionTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CPetFashionTable:getRecorder(id)
	return self.m_cache[id]
end

function CPetFashionTable:getAllID()
	return self.allID
end

function CPetFashionTable:getSize()
	return self.memberCount
end

function CPetFashionTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=1310938 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.defaultid = util:Load_int()
		if not status then return false end
		status,bean.fashionid = util:Load_Vint()
		if not status then return false end
		status,bean.fashionname = util:Load_Vstring()
		if not status then return false end
		status,bean.fashionshape = util:Load_Vint()
		if not status then return false end
		status,bean.fashionpath = util:Load_Vstring()
		if not status then return false end
		status,bean.fashiontitle = util:Load_Vint()
		if not status then return false end
		status,bean.fashioncost = util:Load_Vint()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CPetFashionTable
