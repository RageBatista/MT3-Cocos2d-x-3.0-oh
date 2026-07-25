require "utils.tableutil"
CAnsQuestion = {}
CAnsQuestion.__index = CAnsQuestion



CAnsQuestion.PROTOCOL_TYPE = 805528

function CAnsQuestion.Create()
	print("enter CAnsQuestion create")
	return CAnsQuestion:new()
end
function CAnsQuestion:new()
	local self = {}
	setmetatable(self, CAnsQuestion)
	self.type = self.PROTOCOL_TYPE
	self.npckey = 0
	self.questionid = 0
	self.answer = 0
	self.flag = 0

	return self
end
function CAnsQuestion:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CAnsQuestion:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.npckey)
	_os_:marshal_int32(self.questionid)
	_os_:marshal_int32(self.answer)
	_os_:marshal_char(self.flag)
	return _os_
end

function CAnsQuestion:unmarshal(_os_)
	self.npckey = _os_:unmarshal_int64()
	self.questionid = _os_:unmarshal_int32()
	self.answer = _os_:unmarshal_int32()
	self.flag = _os_:unmarshal_char()
	return _os_
end

return CAnsQuestion
