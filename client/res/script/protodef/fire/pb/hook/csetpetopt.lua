require "utils.tableutil"
CSetPetOpt = {}
CSetPetOpt.__index = CSetPetOpt



CSetPetOpt.PROTOCOL_TYPE = 810336

function CSetPetOpt.Create()
	print("enter CSetPetOpt create")
	return CSetPetOpt:new()
end
function CSetPetOpt:new()
	local self = {}
	setmetatable(self, CSetPetOpt)
	self.type = self.PROTOCOL_TYPE
	self.petoptype = 0
	self.petopid = 0

	return self
end
function CSetPetOpt:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSetPetOpt:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_short(self.petoptype)
	_os_:marshal_int32(self.petopid)
	return _os_
end

function CSetPetOpt:unmarshal(_os_)
	self.petoptype = _os_:unmarshal_short()
	self.petopid = _os_:unmarshal_int32()
	return _os_
end

return CSetPetOpt
