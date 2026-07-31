require "utils.tableutil"
CReturnPotentialFruit = {}
CReturnPotentialFruit.__index = CReturnPotentialFruit



CReturnPotentialFruit.PROTOCOL_TYPE = 810497

function CReturnPotentialFruit.Create()
	print("enter CReturnPotentialFruit create")
	return CReturnPotentialFruit:new()
end
function CReturnPotentialFruit:new()
	local self = {}
	setmetatable(self, CReturnPotentialFruit)
	self.type = self.PROTOCOL_TYPE
	self.location = 0

	return self
end
function CReturnPotentialFruit:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReturnPotentialFruit:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.location)
	return _os_
end

function CReturnPotentialFruit:unmarshal(_os_)
	self.location = _os_:unmarshal_int32()
	return _os_
end

return CReturnPotentialFruit
