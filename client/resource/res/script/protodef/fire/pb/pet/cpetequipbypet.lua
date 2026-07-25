require "utils.tableutil"
CPetEquipbyPet = {}
CPetEquipbyPet.__index = CPetEquipbyPet



CPetEquipbyPet.PROTOCOL_TYPE = 817936

function CPetEquipbyPet.Create()
	print("enter CPetEquipbyPet create")
	return CPetEquipbyPet:new()
end
function CPetEquipbyPet:new()
	local self = {}
	setmetatable(self, CPetEquipbyPet)
	self.type = self.PROTOCOL_TYPE
	self.petkey = 0
	self.itemkey = 0

	return self
end
function CPetEquipbyPet:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CPetEquipbyPet:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petkey)
	_os_:marshal_int32(self.itemkey)
	return _os_
end

function CPetEquipbyPet:unmarshal(_os_)
	self.petkey = _os_:unmarshal_int32()
	self.itemkey = _os_:unmarshal_int32()
	return _os_
end

return CPetEquipbyPet
