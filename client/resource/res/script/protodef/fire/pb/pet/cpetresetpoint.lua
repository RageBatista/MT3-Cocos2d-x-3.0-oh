require "utils.tableutil"
CPetResetPoint = {}
CPetResetPoint.__index = CPetResetPoint



CPetResetPoint.PROTOCOL_TYPE = 788514

function CPetResetPoint.Create()
	print("enter CPetResetPoint create")
	return CPetResetPoint:new()
end
function CPetResetPoint:new()
	local self = {}
	setmetatable(self, CPetResetPoint)
	self.type = self.PROTOCOL_TYPE
	self.petkey = 0

	return self
end
function CPetResetPoint:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CPetResetPoint:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petkey)
	return _os_
end

function CPetResetPoint:unmarshal(_os_)
	self.petkey = _os_:unmarshal_int32()
	return _os_
end

return CPetResetPoint
