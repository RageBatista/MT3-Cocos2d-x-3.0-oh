require "utils.tableutil"
SDelPassword = {}
SDelPassword.__index = SDelPassword



SDelPassword.PROTOCOL_TYPE = 786569

function SDelPassword.Create()
	print("enter SDelPassword create")
	return SDelPassword:new()
end
function SDelPassword:new()
	local self = {}
	setmetatable(self, SDelPassword)
	self.type = self.PROTOCOL_TYPE
	self.status = 0

	return self
end
function SDelPassword:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SDelPassword:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.status)
	return _os_
end

function SDelPassword:unmarshal(_os_)
	self.status = _os_:unmarshal_char()
	return _os_
end

return SDelPassword
