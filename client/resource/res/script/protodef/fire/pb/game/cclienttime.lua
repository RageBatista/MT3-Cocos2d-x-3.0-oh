require "utils.tableutil"
CClientTime = {}
CClientTime.__index = CClientTime



CClientTime.PROTOCOL_TYPE = 810376

function CClientTime.Create()
	print("enter CClientTime create")
	return CClientTime:new()
end
function CClientTime:new()
	local self = {}
	setmetatable(self, CClientTime)
	self.type = self.PROTOCOL_TYPE
	self.time = 0

	return self
end
function CClientTime:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CClientTime:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.time)
	return _os_
end

function CClientTime:unmarshal(_os_)
	self.time = _os_:unmarshal_int64()
	return _os_
end

return CClientTime
