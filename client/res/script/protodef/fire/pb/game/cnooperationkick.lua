require "utils.tableutil"
CNoOperationKick = {}
CNoOperationKick.__index = CNoOperationKick



CNoOperationKick.PROTOCOL_TYPE = 810375

function CNoOperationKick.Create()
	print("enter CNoOperationKick create")
	return CNoOperationKick:new()
end
function CNoOperationKick:new()
	local self = {}
	setmetatable(self, CNoOperationKick)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CNoOperationKick:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CNoOperationKick:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CNoOperationKick:unmarshal(_os_)
	return _os_
end

return CNoOperationKick
