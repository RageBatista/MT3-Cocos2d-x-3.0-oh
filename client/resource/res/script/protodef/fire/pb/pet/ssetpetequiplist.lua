require "utils.tableutil"
SSetPetEquipList = {
}
SSetPetEquipList.__index = SSetPetEquipList



SSetPetEquipList.PROTOCOL_TYPE = 817940

function SSetPetEquipList.Create()
	print("enter SSetPetEquipList create")
	return SSetPetEquipList:new()
end
function SSetPetEquipList:new()
	local self = {}
	setmetatable(self, SSetPetEquipList)
	self.type = self.PROTOCOL_TYPE
	self.petkey = 0
	self.xiangquanid = 0
	self.hujiaid = 0
	self.hufuid = 0
	return self
end
function SSetPetEquipList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSetPetEquipList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petkey)
	_os_:marshal_int32(self.xiangquanid)
	_os_:marshal_int32(self.hujiaid)
	_os_:marshal_int32(self.hufuid)
	return _os_
end

function SSetPetEquipList:unmarshal(_os_)
	self.petkey = _os_:unmarshal_int32()
	self.xiangquanid = _os_:unmarshal_int32()
	self.hujiaid = _os_:unmarshal_int32()
	self.hufuid = _os_:unmarshal_int32()
	return _os_
end

return SSetPetEquipList
