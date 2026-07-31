require "utils.tableutil"
SSetPassword = {}
SSetPassword.__index = SSetPassword



SSetPassword.PROTOCOL_TYPE = 786565

function SSetPassword.Create()
	print("enter SSetPassword create")
	return SSetPassword:new()
end
function SSetPassword:new()
	local self = {}
	setmetatable(self, SSetPassword)
	self.type = self.PROTOCOL_TYPE
	self.status = 0

	return self
end
function SSetPassword:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSetPassword:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.status)
	return _os_
end

function SSetPassword:unmarshal(_os_)
	self.status = _os_:unmarshal_char()
	return _os_
end

return SSetPassword
