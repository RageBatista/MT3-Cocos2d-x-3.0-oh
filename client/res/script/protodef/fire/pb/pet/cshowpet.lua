require "utils.tableutil"
CShowPet = {}
CShowPet.__index = CShowPet



CShowPet.PROTOCOL_TYPE = 788433

function CShowPet.Create()
	print("enter CShowPet create")
	return CShowPet:new()
end
function CShowPet:new()
	local self = {}
	setmetatable(self, CShowPet)
	self.type = self.PROTOCOL_TYPE
	self.petkey = 0

	return self
end
function CShowPet:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CShowPet:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petkey)
	return _os_
end

function CShowPet:unmarshal(_os_)
	self.petkey = _os_:unmarshal_int32()
	return _os_
end

return CShowPet
