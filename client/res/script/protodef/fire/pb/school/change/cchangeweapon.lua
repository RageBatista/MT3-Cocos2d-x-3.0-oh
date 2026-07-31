require "utils.tableutil"
CChangeWeapon = {}
CChangeWeapon.__index = CChangeWeapon



CChangeWeapon.PROTOCOL_TYPE = 810486

function CChangeWeapon.Create()
	print("enter CChangeWeapon create")
	return CChangeWeapon:new()
end
function CChangeWeapon:new()
	local self = {}
	setmetatable(self, CChangeWeapon)
	self.type = self.PROTOCOL_TYPE
	self.srcweaponkey = 0
	self.newweapontypeid = 0

	return self
end
function CChangeWeapon:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CChangeWeapon:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.srcweaponkey)
	_os_:marshal_int32(self.newweapontypeid)
	return _os_
end

function CChangeWeapon:unmarshal(_os_)
	self.srcweaponkey = _os_:unmarshal_int32()
	self.newweapontypeid = _os_:unmarshal_int32()
	return _os_
end

return CChangeWeapon
