
require "utils.binutil"

AnswerQuestionTable = {}
AnswerQuestionTable.__index = AnswerQuestionTable

function AnswerQuestionTable:new()
	local self = {}
	setmetatable(self, AnswerQuestionTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function AnswerQuestionTable:getRecorder(id)
	return self.m_cache[id]
end

function AnswerQuestionTable:getAllID()
	return self.allID
end

function AnswerQuestionTable:getSize()
	return self.memberCount
end

function AnswerQuestionTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=1048740 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.topic = util:Load_int()
		if not status then return false end
		status,bean.step = util:Load_int()
		if not status then return false end
		status,bean.title = util:Load_string()
		if not status then return false end
		status,bean.object1 = util:Load_string()
		if not status then return false end
		status,bean.image1 = util:Load_int()
		if not status then return false end
		status,bean.icon1 = util:Load_int()
		if not status then return false end
		status,bean.object2 = util:Load_string()
		if not status then return false end
		status,bean.image2 = util:Load_int()
		if not status then return false end
		status,bean.icon2 = util:Load_int()
		if not status then return false end
		status,bean.object3 = util:Load_string()
		if not status then return false end
		status,bean.image3 = util:Load_int()
		if not status then return false end
		status,bean.icon3 = util:Load_int()
		if not status then return false end
		status,bean.trueanswer = util:Load_int()
		if not status then return false end
		status,bean.truereward = util:Load_int()
		if not status then return false end
		status,bean.falsereward = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return AnswerQuestionTable
