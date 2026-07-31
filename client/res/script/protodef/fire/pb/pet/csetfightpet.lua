require "utils.tableutil"
CSetFightPet = {}
CSetFightPet.__index = CSetFightPet



CSetFightPet.PROTOCOL_TYPE = 788440

function CSetFightPet.Create()
	print("enter CSetFightPet create")
	return CSetFightPet:new()
end
function CSetFightPet:new()
	local self = {}
	setmetatable(self, CSetFightPet)
	self.type = self.PROTOCOL_TYPE
	self.petkey = 0

	return self
end
function CSetFightPet:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSetFightPet:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petkey)
	return _os_
end

function CSetFightPet:unmarshal(_os_)
	self.petkey = _os_:unmarshal_int32()
	return _os_
end

return CSetFightPet
