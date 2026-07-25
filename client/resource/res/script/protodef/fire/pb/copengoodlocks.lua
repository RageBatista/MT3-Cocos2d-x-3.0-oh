require "utils.tableutil"
COpenGoodLocks = {}
COpenGoodLocks.__index = COpenGoodLocks



COpenGoodLocks.PROTOCOL_TYPE = 786576

function COpenGoodLocks.Create()
	print("enter COpenGoodLocks create")
	return COpenGoodLocks:new()
end
function COpenGoodLocks:new()
	local self = {}
	setmetatable(self, COpenGoodLocks)
	self.type = self.PROTOCOL_TYPE
	return self
end
function COpenGoodLocks:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function COpenGoodLocks:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function COpenGoodLocks:unmarshal(_os_)
	return _os_
end

return COpenGoodLocks
