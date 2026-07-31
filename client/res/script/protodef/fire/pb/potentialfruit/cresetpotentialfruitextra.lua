require "utils.tableutil"
CResetPotentialFruitExtra = {}
CResetPotentialFruitExtra.__index = CResetPotentialFruitExtra



CResetPotentialFruitExtra.PROTOCOL_TYPE = 810498

function CResetPotentialFruitExtra.Create()
	print("enter CResetPotentialFruitExtra create")
	return CResetPotentialFruitExtra:new()
end
function CResetPotentialFruitExtra:new()
	local self = {}
	setmetatable(self, CResetPotentialFruitExtra)
	self.type = self.PROTOCOL_TYPE

	return self
end
function CResetPotentialFruitExtra:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CResetPotentialFruitExtra:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	return _os_
end

function CResetPotentialFruitExtra:unmarshal(_os_)
	return _os_
end

return CResetPotentialFruitExtra
