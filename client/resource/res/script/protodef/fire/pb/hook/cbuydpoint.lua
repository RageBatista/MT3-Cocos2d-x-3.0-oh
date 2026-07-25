require "utils.tableutil"
CBuyDPoint = {}
CBuyDPoint.__index = CBuyDPoint



CBuyDPoint.PROTOCOL_TYPE = 810345

function CBuyDPoint.Create()
	print("enter CBuyDPoint create")
	return CBuyDPoint:new()
end
function CBuyDPoint:new()
	local self = {}
	setmetatable(self, CBuyDPoint)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CBuyDPoint:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CBuyDPoint:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CBuyDPoint:unmarshal(_os_)
	return _os_
end

return CBuyDPoint
