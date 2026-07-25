require "utils.tableutil"
CChangeWeapon2 = {}
CChangeWeapon2.__index = CChangeWeapon2



CChangeWeapon2.PROTOCOL_TYPE = 817957

function CChangeWeapon2.Create()
	print("enter CChangeWeapon2 create")
	return CChangeWeapon2:new()
end
function CChangeWeapon2:new()
	local self = {}
	setmetatable(self, CChangeWeapon2)
	self.type = self.PROTOCOL_TYPE
	self.srcweaponkey = 0
	self.newweapontypeid = 0

	return self
end
function CChangeWeapon2:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CChangeWeapon2:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.srcweaponkey)
	_os_:marshal_int32(self.newweapontypeid)
	return _os_
end

function CChangeWeapon2:unmarshal(_os_)
	self.srcweaponkey = _os_:unmarshal_int32()
	self.newweapontypeid = _os_:unmarshal_int32()
	return _os_
end

return CChangeWeapon2
