require "utils.tableutil"
SSPetFashion = {}
SSPetFashion.__index = SSPetFashion



SSPetFashion.PROTOCOL_TYPE = 800551

function SSPetFashion.Create()
	print("enter SSPetFashion create")
	return SSPetFashion:new()
end
function SSPetFashion:new()
	local self = {}
	setmetatable(self, SSPetFashion)
	self.type = self.PROTOCOL_TYPE
	self.result = 0

	return self
end
function SSPetFashion:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSPetFashion:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.result)
	return _os_
end

function SSPetFashion:unmarshal(_os_)
	self.result = _os_:unmarshal_int32()
	return _os_
end

return SSPetFashion
