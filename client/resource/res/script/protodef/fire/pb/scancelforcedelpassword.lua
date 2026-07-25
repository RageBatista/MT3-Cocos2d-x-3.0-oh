require "utils.tableutil"
SCancelForceDelPassword = {}
SCancelForceDelPassword.__index = SCancelForceDelPassword



SCancelForceDelPassword.PROTOCOL_TYPE = 786575

function SCancelForceDelPassword.Create()
	print("enter SCancelForceDelPassword create")
	return SCancelForceDelPassword:new()
end
function SCancelForceDelPassword:new()
	local self = {}
	setmetatable(self, SCancelForceDelPassword)
	self.type = self.PROTOCOL_TYPE
	self.status = 0

	return self
end
function SCancelForceDelPassword:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SCancelForceDelPassword:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.status)
	return _os_
end

function SCancelForceDelPassword:unmarshal(_os_)
	self.status = _os_:unmarshal_char()
	return _os_
end

return SCancelForceDelPassword
