require "utils.tableutil"
CFreezeDPoint = {}
CFreezeDPoint.__index = CFreezeDPoint



CFreezeDPoint.PROTOCOL_TYPE = 810338

function CFreezeDPoint.Create()
	print("enter CFreezeDPoint create")
	return CFreezeDPoint:new()
end
function CFreezeDPoint:new()
	local self = {}
	setmetatable(self, CFreezeDPoint)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CFreezeDPoint:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CFreezeDPoint:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CFreezeDPoint:unmarshal(_os_)
	return _os_
end

return CFreezeDPoint
