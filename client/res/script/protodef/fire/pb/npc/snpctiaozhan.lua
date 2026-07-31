require "utils.tableutil"
SNpctiaozhansl = {}
SNpctiaozhansl.__index = SNpctiaozhansl



SNpctiaozhansl.PROTOCOL_TYPE = 800102

function SNpctiaozhansl.Create()
	print("enter SNpctiaozhansl create")
	return SNpctiaozhansl:new()
end
function SNpctiaozhansl:new()
	local self = {}
	setmetatable(self, SNpctiaozhansl)
	self.type = self.PROTOCOL_TYPE
	self.tz1 = 0
	self.tz2 = 0
	self.tz3 = 0
	self.tz4 = 0
	self.tz5 = 0
	self.tz6 = 0
	self.tz7 = 0

	return self
end
function SNpctiaozhansl:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SNpctiaozhansl:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.tz1)
	_os_:marshal_int32(self.tz2)
	_os_:marshal_int32(self.tz3)
	_os_:marshal_int32(self.tz4)
	_os_:marshal_int32(self.tz5)
	_os_:marshal_int32(self.tz6)
	_os_:marshal_int32(self.tz7)
	return _os_
end

function SNpctiaozhansl:unmarshal(_os_)
	self.tz1 = _os_:unmarshal_int32()
	self.tz2 = _os_:unmarshal_int32()
	self.tz3 = _os_:unmarshal_int32()
	self.tz4 = _os_:unmarshal_int32()
	self.tz5 = _os_:unmarshal_int32()
	self.tz6 = _os_:unmarshal_int32()
	self.tz7 = _os_:unmarshal_int32()
	return _os_
end

return SNpctiaozhansl
