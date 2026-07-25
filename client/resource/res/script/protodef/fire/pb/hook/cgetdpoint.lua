require "utils.tableutil"
CGetDPoint = {}
CGetDPoint.__index = CGetDPoint



CGetDPoint.PROTOCOL_TYPE = 810337

function CGetDPoint.Create()
	print("enter CGetDPoint create")
	return CGetDPoint:new()
end
function CGetDPoint:new()
	local self = {}
	setmetatable(self, CGetDPoint)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CGetDPoint:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetDPoint:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CGetDPoint:unmarshal(_os_)
	return _os_
end

return CGetDPoint
