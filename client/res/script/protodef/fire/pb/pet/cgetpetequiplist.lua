require "utils.tableutil"
CGetPetEquipList = {
}
CGetPetEquipList.__index = CGetPetEquipList



CGetPetEquipList.PROTOCOL_TYPE = 817939

function CGetPetEquipList.Create()
	print("enter CGetPetEquipList create")
	return CGetPetEquipList:new()
end
function CGetPetEquipList:new()
	local self = {}
	setmetatable(self, CGetPetEquipList)
	self.type = self.PROTOCOL_TYPE
	self.petkey = 0
	return self
end
function CGetPetEquipList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetPetEquipList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petkey)
	return _os_
end

function CGetPetEquipList:unmarshal(_os_)
	self.petkey = _os_:unmarshal_int32()
	return _os_
end

return CGetPetEquipList
