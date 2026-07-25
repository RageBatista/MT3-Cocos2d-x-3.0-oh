require "utils.tableutil"
SChangeWeapon2 = {}
SChangeWeapon2.__index = SChangeWeapon2



SChangeWeapon2.PROTOCOL_TYPE = 817958

function SChangeWeapon2.Create()
	print("enter SChangeWeapon2 create")
	return SChangeWeapon2:new()
end
function SChangeWeapon2:new()
	local self = {}
	setmetatable(self, SChangeWeapon2)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SChangeWeapon2:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SChangeWeapon2:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SChangeWeapon2:unmarshal(_os_)
	return _os_
end

return SChangeWeapon2
