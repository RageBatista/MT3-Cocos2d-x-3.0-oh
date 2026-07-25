require "utils.tableutil"
CMailRead = {}
CMailRead.__index = CMailRead



CMailRead.PROTOCOL_TYPE = 787701

function CMailRead.Create()
	print("enter CMailRead create")
	return CMailRead:new()
end
function CMailRead:new()
	local self = {}
	setmetatable(self, CMailRead)
	self.type = self.PROTOCOL_TYPE
	self.kind = 0
	self.id = 0

	return self
end
function CMailRead:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CMailRead:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.kind)
	_os_:marshal_int64(self.id)
	return _os_
end

function CMailRead:unmarshal(_os_)
	self.kind = _os_:unmarshal_char()
	self.id = _os_:unmarshal_int64()
	return _os_
end

return CMailRead
