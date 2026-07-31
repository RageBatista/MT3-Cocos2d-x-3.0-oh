require "utils.tableutil"
SReturnLogin = {}
SReturnLogin.__index = SReturnLogin



SReturnLogin.PROTOCOL_TYPE = 786483

function SReturnLogin.Create()
	print("enter SReturnLogin create")
	return SReturnLogin:new()
end
function SReturnLogin:new()
	local self = {}
	setmetatable(self, SReturnLogin)
	self.type = self.PROTOCOL_TYPE
	self.reason = 0

	return self
end
function SReturnLogin:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SReturnLogin:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.reason)
	return _os_
end

function SReturnLogin:unmarshal(_os_)
	self.reason = _os_:unmarshal_int32()
	return _os_
end

return SReturnLogin
