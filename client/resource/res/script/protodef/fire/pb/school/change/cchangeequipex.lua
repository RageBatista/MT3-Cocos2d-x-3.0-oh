require "utils.tableutil"
CChangeEquipEx = {}
CChangeEquipEx.__index = CChangeEquipEx



CChangeEquipEx.PROTOCOL_TYPE = 810495

function CChangeEquipEx.Create()
	print("enter CChangeEquipEx create")
	return CChangeEquipEx:new()
end
function CChangeEquipEx:new()
	local self = {}
	setmetatable(self, CChangeEquipEx)
	self.type = self.PROTOCOL_TYPE
	self.srcweaponkey = 0
	self.tonewitem = 0
	return self
end
function CChangeEquipEx:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CChangeEquipEx:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.srcweaponkey)
	_os_:marshal_int32(self.tonewitem)
	return _os_
end

function CChangeEquipEx:unmarshal(_os_)
	self.srcweaponkey = _os_:unmarshal_int32()
	self.tonewitem = _os_:unmarshal_int32()
	return _os_
end

return CChangeEquipEx
