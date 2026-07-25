require "utils.tableutil"
CLogPushToken = {}
CLogPushToken.__index = CLogPushToken



CLogPushToken.PROTOCOL_TYPE = 810374

function CLogPushToken.Create()
	print("enter CLogPushToken create")
	return CLogPushToken:new()
end
function CLogPushToken:new()
	local self = {}
	setmetatable(self, CLogPushToken)
	self.type = self.PROTOCOL_TYPE
	self.token = 0

	return self
end
function CLogPushToken:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CLogPushToken:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.token)
	return _os_
end

function CLogPushToken:unmarshal(_os_)
	self.token = _os_:unmarshal_int32()
	return _os_
end

return CLogPushToken
