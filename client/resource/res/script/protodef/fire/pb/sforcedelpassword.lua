require "utils.tableutil"
SForceDelPassword = {}
SForceDelPassword.__index = SForceDelPassword



SForceDelPassword.PROTOCOL_TYPE = 786573

function SForceDelPassword.Create()
	print("enter SForceDelPassword create")
	return SForceDelPassword:new()
end
function SForceDelPassword:new()
	local self = {}
	setmetatable(self, SForceDelPassword)
	self.type = self.PROTOCOL_TYPE
	self.starttimepoint = 0
	self.finishtimepoint = 0

	return self
end
function SForceDelPassword:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SForceDelPassword:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.starttimepoint)
	_os_:marshal_int64(self.finishtimepoint)
	return _os_
end

function SForceDelPassword:unmarshal(_os_)
	self.starttimepoint = _os_:unmarshal_int64()
	self.finishtimepoint = _os_:unmarshal_int64()
	return _os_
end

return SForceDelPassword
