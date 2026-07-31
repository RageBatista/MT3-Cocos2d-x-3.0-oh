
require "utils.binutil"

CActivityQuestionTable = {}
CActivityQuestionTable.__index = CActivityQuestionTable

function CActivityQuestionTable:new()
	local self = {}
	setmetatable(self, CActivityQuestionTable)
	self.m_cache = {}
	self.allID = {}
	return self

end

function CActivityQuestionTable:getRecorder(id)
	return self.m_cache[id]
end

function CActivityQuestionTable:getAllID()
	return self.allID
end

function CActivityQuestionTable:getSize()
	return self.memberCount
end

function CActivityQuestionTable:LoadBeanFromBinFile(filename)
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
	if checkNumber~=589890 then
		return false
	end
	for i=0,memberCount-1 do
		local bean={}
		status,bean.id = util:Load_int()
		if not status then return false end
		status,bean.questionid = util:Load_int()
		if not status then return false end
		status,bean.step = util:Load_int()
		if not status then return false end
		status,bean.question = util:Load_string()
		if not status then return false end
		status,bean.answer1 = util:Load_string()
		if not status then return false end
		status,bean.answer2 = util:Load_string()
		if not status then return false end
		status,bean.answer3 = util:Load_string()
		if not status then return false end
		status,bean.rightrewardid = util:Load_int()
		if not status then return false end
		status,bean.errorrewardid = util:Load_int()
		if not status then return false end
		self.m_cache[bean.id]=bean
		table.insert(self.allID, bean.id)
	end
	util:release()
	return true
end

return CActivityQuestionTable
