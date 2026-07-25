require "utils.tableutil"
SOpenGoodLocks = {}
SOpenGoodLocks.__index = SOpenGoodLocks



SOpenGoodLocks.PROTOCOL_TYPE = 786577

function SOpenGoodLocks.Create()
	print("enter SOpenGoodLocks create")
	return SOpenGoodLocks:new()
end
function SOpenGoodLocks:new()
	local self = {}
	setmetatable(self, SOpenGoodLocks)
	self.type = self.PROTOCOL_TYPE
	self.status = 0

	return self
end
function SOpenGoodLocks:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SOpenGoodLocks:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.status)
	return _os_
end

function SOpenGoodLocks:unmarshal(_os_)
	self.status = _os_:unmarshal_char()
	return _os_
end

return SOpenGoodLocks
