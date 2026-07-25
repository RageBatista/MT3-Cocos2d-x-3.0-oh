require "utils.tableutil"
SLockInfo = {}
SLockInfo.__index = SLockInfo



SLockInfo.PROTOCOL_TYPE = 818939

function SLockInfo.Create()
	print("enter SLockInfo create")
	return SLockInfo:new()
end
function SLockInfo:new()
	local self = {}
	setmetatable(self, SLockInfo)
	self.type = self.PROTOCOL_TYPE
	self.status = 0

	return self
end
function SLockInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SLockInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.status)
	return _os_
end

function SLockInfo:unmarshal(_os_)
	self.status = _os_:unmarshal_int32()
	return _os_
end

return SLockInfo
