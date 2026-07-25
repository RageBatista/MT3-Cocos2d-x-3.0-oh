require "utils.tableutil"
CAnswerforGetLeader = {}
CAnswerforGetLeader.__index = CAnswerforGetLeader



CAnswerforGetLeader.PROTOCOL_TYPE = 794473

function CAnswerforGetLeader.Create()
	print("enter CAnswerforGetLeader create")
	return CAnswerforGetLeader:new()
end
function CAnswerforGetLeader:new()
	local self = {}
	setmetatable(self, CAnswerforGetLeader)
	self.type = self.PROTOCOL_TYPE
	self.agree = 0
	self.role = 0

	return self
end
function CAnswerforGetLeader:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CAnswerforGetLeader:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.agree)
	_os_:marshal_int64(self.role)
	return _os_
end

function CAnswerforGetLeader:unmarshal(_os_)
	self.agree = _os_:unmarshal_char()
	self.role = _os_:unmarshal_int64()
	return _os_
end

return CAnswerforGetLeader
