require "utils.tableutil"
CRequestActivityAnswerQuestion = {}
CRequestActivityAnswerQuestion.__index = CRequestActivityAnswerQuestion



CRequestActivityAnswerQuestion.PROTOCOL_TYPE = 795527

function CRequestActivityAnswerQuestion.Create()
	print("enter CRequestActivityAnswerQuestion create")
	return CRequestActivityAnswerQuestion:new()
end
function CRequestActivityAnswerQuestion:new()
	local self = {}
	setmetatable(self, CRequestActivityAnswerQuestion)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CRequestActivityAnswerQuestion:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestActivityAnswerQuestion:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CRequestActivityAnswerQuestion:unmarshal(_os_)
	return _os_
end

return CRequestActivityAnswerQuestion
