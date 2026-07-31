require "utils.tableutil"
CResetPotentialFruit = {}
CResetPotentialFruit.__index = CResetPotentialFruit



CResetPotentialFruit.PROTOCOL_TYPE = 810499

function CResetPotentialFruit.Create()
	print("enter CResetPotentialFruit create")
	return CResetPotentialFruit:new()
end
function CResetPotentialFruit:new()
	local self = {}
	setmetatable(self, CResetPotentialFruit)
	self.type = self.PROTOCOL_TYPE
	self.location = 0

	return self
end
function CResetPotentialFruit:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CResetPotentialFruit:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.location)
	return _os_
end

function CResetPotentialFruit:unmarshal(_os_)
	self.location = _os_:unmarshal_int32()
	return _os_
end

return CResetPotentialFruit
