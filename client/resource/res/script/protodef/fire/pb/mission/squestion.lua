require "utils.tableutil"
SQuestion = {}
SQuestion.__index = SQuestion



SQuestion.PROTOCOL_TYPE = 805527

function SQuestion.Create()
	print("enter SQuestion create")
	return SQuestion:new()
end
function SQuestion:new()
	local self = {}
	setmetatable(self, SQuestion)
	self.type = self.PROTOCOL_TYPE
	self.lastresult = 0
	self.npckey = 0
	self.questionid = 0
	self.flag = 0

	return self
end
function SQuestion:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SQuestion:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.lastresult)
	_os_:marshal_int64(self.npckey)
	_os_:marshal_int32(self.questionid)
	_os_:marshal_char(self.flag)
	return _os_
end

function SQuestion:unmarshal(_os_)
	self.lastresult = _os_:unmarshal_int32()
	self.npckey = _os_:unmarshal_int64()
	self.questionid = _os_:unmarshal_int32()
	self.flag = _os_:unmarshal_char()
	return _os_
end

return SQuestion
