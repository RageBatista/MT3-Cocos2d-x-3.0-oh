require "utils.tableutil"
CActivityAnswerQuestionHelp = {}
CActivityAnswerQuestionHelp.__index = CActivityAnswerQuestionHelp



CActivityAnswerQuestionHelp.PROTOCOL_TYPE = 795532

function CActivityAnswerQuestionHelp.Create()
	print("enter CActivityAnswerQuestionHelp create")
	return CActivityAnswerQuestionHelp:new()
end
function CActivityAnswerQuestionHelp:new()
	local self = {}
	setmetatable(self, CActivityAnswerQuestionHelp)
	self.type = self.PROTOCOL_TYPE
	self.questionid = 0

	return self
end
function CActivityAnswerQuestionHelp:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CActivityAnswerQuestionHelp:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.questionid)
	return _os_
end

function CActivityAnswerQuestionHelp:unmarshal(_os_)
	self.questionid = _os_:unmarshal_int32()
	return _os_
end

return CActivityAnswerQuestionHelp
