require "utils.tableutil"
CModPetName = {
	NAMELEN_MAX = 6,
	NAMELEN_MIN = 1
}
CModPetName.__index = CModPetName



CModPetName.PROTOCOL_TYPE = 788450

function CModPetName.Create()
	print("enter CModPetName create")
	return CModPetName:new()
end
function CModPetName:new()
	local self = {}
	setmetatable(self, CModPetName)
	self.type = self.PROTOCOL_TYPE
	self.petkey = 0
	self.petname = "" 

	return self
end
function CModPetName:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CModPetName:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petkey)
	_os_:marshal_wstring(self.petname)
	return _os_
end

function CModPetName:unmarshal(_os_)
	self.petkey = _os_:unmarshal_int32()
	self.petname = _os_:unmarshal_wstring(self.petname)
	return _os_
end

return CModPetName
