require "utils.tableutil"
CAbsentFairyland = {}
CAbsentFairyland.__index = CAbsentFairyland



CAbsentFairyland.PROTOCOL_TYPE = 805454

function CAbsentFairyland.Create()
	print("enter CAbsentFairyland create")
	return CAbsentFairyland:new()
end
function CAbsentFairyland:new()
	local self = {}
	setmetatable(self, CAbsentFairyland)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CAbsentFairyland:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CAbsentFairyland:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CAbsentFairyland:unmarshal(_os_)
	return _os_
end

return CAbsentFairyland
