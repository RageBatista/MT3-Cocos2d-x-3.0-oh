require "utils.tableutil"
SChangeWeapon = {}
SChangeWeapon.__index = SChangeWeapon



SChangeWeapon.PROTOCOL_TYPE = 810490

function SChangeWeapon.Create()
	print("enter SChangeWeapon create")
	return SChangeWeapon:new()
end
function SChangeWeapon:new()
	local self = {}
	setmetatable(self, SChangeWeapon)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SChangeWeapon:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SChangeWeapon:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SChangeWeapon:unmarshal(_os_)
	return _os_
end

return SChangeWeapon
