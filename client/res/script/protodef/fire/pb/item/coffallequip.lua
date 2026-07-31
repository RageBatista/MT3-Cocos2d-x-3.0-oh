require "utils.tableutil"
COffAllEquip = {}
COffAllEquip.__index = COffAllEquip



COffAllEquip.PROTOCOL_TYPE = 817972

function COffAllEquip.Create()
	print("enter COffAllEquip create")
	return COffAllEquip:new()
end
function COffAllEquip:new()
	local self = {}
	setmetatable(self, COffAllEquip)
	self.type = self.PROTOCOL_TYPE
	return self
end
function COffAllEquip:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function COffAllEquip:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function COffAllEquip:unmarshal(_os_)
	return _os_
end

return COffAllEquip
