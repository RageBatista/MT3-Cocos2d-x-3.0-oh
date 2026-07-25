require "utils.tableutil"
SDeadLess20 = {}
SDeadLess20.__index = SDeadLess20



SDeadLess20.PROTOCOL_TYPE = 793563

function SDeadLess20.Create()
	print("enter SDeadLess20 create")
	return SDeadLess20:new()
end
function SDeadLess20:new()
	local self = {}
	setmetatable(self, SDeadLess20)
	self.type = self.PROTOCOL_TYPE
	self.eventtype = 0

	return self
end
function SDeadLess20:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SDeadLess20:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.eventtype)
	return _os_
end

function SDeadLess20:unmarshal(_os_)
	self.eventtype = _os_:unmarshal_int32()
	return _os_
end

return SDeadLess20
