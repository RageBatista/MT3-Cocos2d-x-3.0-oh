require "utils.tableutil"
CReqLockInfo = {}
CReqLockInfo.__index = CReqLockInfo



CReqLockInfo.PROTOCOL_TYPE = 818933

function CReqLockInfo.Create()
	print("enter CReqLockInfo create")
	return CReqLockInfo:new()
end
function CReqLockInfo:new()
	local self = {}
	setmetatable(self, CReqLockInfo)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CReqLockInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReqLockInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CReqLockInfo:unmarshal(_os_)
	return _os_
end

return CReqLockInfo
