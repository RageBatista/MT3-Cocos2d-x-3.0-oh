require "utils.tableutil"
CClientLockScreen = {}
CClientLockScreen.__index = CClientLockScreen



CClientLockScreen.PROTOCOL_TYPE = 810344

function CClientLockScreen.Create()
	print("enter CClientLockScreen create")
	return CClientLockScreen:new()
end
function CClientLockScreen:new()
	local self = {}
	setmetatable(self, CClientLockScreen)
	self.type = self.PROTOCOL_TYPE
	self.lock = 0

	return self
end
function CClientLockScreen:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CClientLockScreen:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.lock)
	return _os_
end

function CClientLockScreen:unmarshal(_os_)
	self.lock = _os_:unmarshal_char()
	return _os_
end

return CClientLockScreen
