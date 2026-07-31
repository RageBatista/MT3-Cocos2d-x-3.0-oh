require "utils.tableutil"
CReturnFairyland = {}
CReturnFairyland.__index = CReturnFairyland



CReturnFairyland.PROTOCOL_TYPE = 805455

function CReturnFairyland.Create()
	print("enter CReturnFairyland create")
	return CReturnFairyland:new()
end
function CReturnFairyland:new()
	local self = {}
	setmetatable(self, CReturnFairyland)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CReturnFairyland:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReturnFairyland:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CReturnFairyland:unmarshal(_os_)
	return _os_
end

return CReturnFairyland
