require "utils.tableutil"
SUpdateLockInfo = {}
SUpdateLockInfo.__index = SUpdateLockInfo



SUpdateLockInfo.PROTOCOL_TYPE = 818946

function SUpdateLockInfo.Create()
	print("enter SUpdateLockInfo create")
	return SUpdateLockInfo:new()
end
function SUpdateLockInfo:new()
	local self = {}
	setmetatable(self, SUpdateLockInfo)
	self.type = self.PROTOCOL_TYPE
	self.status = 0

	return self
end
function SUpdateLockInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SUpdateLockInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.status)
	return _os_
end

function SUpdateLockInfo:unmarshal(_os_)
	self.status = _os_:unmarshal_int32()
	return _os_
end

return SUpdateLockInfo
