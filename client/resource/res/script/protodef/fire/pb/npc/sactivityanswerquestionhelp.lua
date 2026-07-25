require "utils.tableutil"
SActivityAnswerQuestionHelp = {}
SActivityAnswerQuestionHelp.__index = SActivityAnswerQuestionHelp



SActivityAnswerQuestionHelp.PROTOCOL_TYPE = 795535

function SActivityAnswerQuestionHelp.Create()
	print("enter SActivityAnswerQuestionHelp create")
	return SActivityAnswerQuestionHelp:new()
end
function SActivityAnswerQuestionHelp:new()
	local self = {}
	setmetatable(self, SActivityAnswerQuestionHelp)
	self.type = self.PROTOCOL_TYPE
	self.helpnum = 0

	return self
end
function SActivityAnswerQuestionHelp:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SActivityAnswerQuestionHelp:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.helpnum)
	return _os_
end

function SActivityAnswerQuestionHelp:unmarshal(_os_)
	self.helpnum = _os_:unmarshal_int32()
	return _os_
end

return SActivityAnswerQuestionHelp
