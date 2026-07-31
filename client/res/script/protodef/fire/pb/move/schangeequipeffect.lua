require "utils.tableutil"
SChangeEquipEffect = {}
SChangeEquipEffect.__index = SChangeEquipEffect



SChangeEquipEffect.PROTOCOL_TYPE = 790491

function SChangeEquipEffect.Create()
	print("enter SChangeEquipEffect create")
	return SChangeEquipEffect:new()
end
function SChangeEquipEffect:new()
	local self = {}
	setmetatable(self, SChangeEquipEffect)
	self.type = self.PROTOCOL_TYPE
	self.playerid = 0
	self.effect = 0

	return self
end
function SChangeEquipEffect:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SChangeEquipEffect:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.playerid)
	_os_:marshal_int32(self.effect)
	return _os_
end

function SChangeEquipEffect:unmarshal(_os_)
	self.playerid = _os_:unmarshal_int64()
	self.effect = _os_:unmarshal_int32()
	return _os_
end

return SChangeEquipEffect
