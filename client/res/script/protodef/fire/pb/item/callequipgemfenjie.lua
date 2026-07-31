require "utils.tableutil"
CAllEquipGemFenJie = {}
CAllEquipGemFenJie.__index = CAllEquipGemFenJie



CAllEquipGemFenJie.PROTOCOL_TYPE = 817955

function CAllEquipGemFenJie.Create()
	print("enter CAllEquipGemFenJie create")
	return CAllEquipGemFenJie:new()
end
function CAllEquipGemFenJie:new()
	local self = {}
	setmetatable(self, CAllEquipGemFenJie)
	self.type = self.PROTOCOL_TYPE
	self.fenjietype = 0
	return self
end
function CAllEquipGemFenJie:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CAllEquipGemFenJie:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.fenjietype)
	return _os_
end

function CAllEquipGemFenJie:unmarshal(_os_)
	self.fenjietype = _os_:unmarshal_int32()
	return _os_
end

return CAllEquipGemFenJie
