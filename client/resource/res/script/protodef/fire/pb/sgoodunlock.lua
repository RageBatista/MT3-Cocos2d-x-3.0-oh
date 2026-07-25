require "utils.tableutil"
SGoodUnLock = {}
SGoodUnLock.__index = SGoodUnLock



SGoodUnLock.PROTOCOL_TYPE = 786583

function SGoodUnLock.Create()
	print("enter SGoodUnLock create")
	return SGoodUnLock:new()
end
function SGoodUnLock:new()
	local self = {}
	setmetatable(self, SGoodUnLock)
	self.type = self.PROTOCOL_TYPE
	self.status = 0

	return self
end
function SGoodUnLock:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGoodUnLock:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.status)
	return _os_
end

function SGoodUnLock:unmarshal(_os_)
	self.status = _os_:unmarshal_char()
	return _os_
end

return SGoodUnLock
