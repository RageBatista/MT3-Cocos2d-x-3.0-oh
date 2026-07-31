require "utils.tableutil"
CAnswerforSetLeader = {}
CAnswerforSetLeader.__index = CAnswerforSetLeader



CAnswerforSetLeader.PROTOCOL_TYPE = 794455

function CAnswerforSetLeader.Create()
	print("enter CAnswerforSetLeader create")
	return CAnswerforSetLeader:new()
end
function CAnswerforSetLeader:new()
	local self = {}
	setmetatable(self, CAnswerforSetLeader)
	self.type = self.PROTOCOL_TYPE
	self.agree = 0

	return self
end
function CAnswerforSetLeader:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CAnswerforSetLeader:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.agree)
	return _os_
end

function CAnswerforSetLeader:unmarshal(_os_)
	self.agree = _os_:unmarshal_char()
	return _os_
end

return CAnswerforSetLeader
