require "utils.tableutil"
SResetPassword = {}
SResetPassword.__index = SResetPassword



SResetPassword.PROTOCOL_TYPE = 786567

function SResetPassword.Create()
	print("enter SResetPassword create")
	return SResetPassword:new()
end
function SResetPassword:new()
	local self = {}
	setmetatable(self, SResetPassword)
	self.type = self.PROTOCOL_TYPE
	self.status = 0

	return self
end
function SResetPassword:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SResetPassword:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.status)
	return _os_
end

function SResetPassword:unmarshal(_os_)
	self.status = _os_:unmarshal_char()
	return _os_
end

return SResetPassword
