require "utils.tableutil"
CEquipFuMo = {}
CEquipFuMo.__index = CEquipFuMo



CEquipFuMo.PROTOCOL_TYPE = 817954

function CEquipFuMo.Create()
	print("enter CEquipFuMo create")
	return CEquipFuMo:new()
end
function CEquipFuMo:new()
	local self = {}
	setmetatable(self, CEquipFuMo)
	self.type = self.PROTOCOL_TYPE
	self.skillid = 0
	self.effectid = 0
	self.newskillid = 0
	self.neweffectid = 0
	self.packid = 0
	self.keyinpack = 0

	return self
end
function CEquipFuMo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CEquipFuMo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.skillid)
	_os_:marshal_int32(self.effectid)
	_os_:marshal_int32(self.newskillid)
	_os_:marshal_int32(self.neweffectid)
	_os_:marshal_int32(self.packid)
	_os_:marshal_int32(self.keyinpack)
	return _os_
end

function CEquipFuMo:unmarshal(_os_)
	self.skillid = _os_:unmarshal_int32()
	self.effectid = _os_:unmarshal_int32()
	self.newskillid = _os_:unmarshal_int32()
	self.neweffectid = _os_:unmarshal_int32()
	self.packid = _os_:unmarshal_int32()
	self.keyinpack = _os_:unmarshal_int32()
	return _os_
end

return CEquipFuMo
