require "utils.tableutil"
CGetPetEquipInfo = {
}
CGetPetEquipInfo.__index = CGetPetEquipInfo



CGetPetEquipInfo.PROTOCOL_TYPE = 817937

function CGetPetEquipInfo.Create()
	print("enter CGetPetEquipInfo create")
	return CGetPetEquipInfo:new()
end
function CGetPetEquipInfo:new()
	local self = {}
	setmetatable(self, CGetPetEquipInfo)
	self.type = self.PROTOCOL_TYPE
	self.petkey = 0
	self.pos = 0
	return self
end
function CGetPetEquipInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetPetEquipInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petkey)
	_os_:marshal_int32(self.pos)
	return _os_
end

function CGetPetEquipInfo:unmarshal(_os_)
	self.petkey = _os_:unmarshal_int32()
	self.pos = _os_:unmarshal_int32()
	return _os_
end

return CGetPetEquipInfo
