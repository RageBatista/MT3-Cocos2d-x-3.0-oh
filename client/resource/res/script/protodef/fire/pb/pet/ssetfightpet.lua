require "utils.tableutil"
SSetFightPet = {}
SSetFightPet.__index = SSetFightPet



SSetFightPet.PROTOCOL_TYPE = 788441

function SSetFightPet.Create()
	print("enter SSetFightPet create")
	return SSetFightPet:new()
end
function SSetFightPet:new()
	local self = {}
	setmetatable(self, SSetFightPet)
	self.type = self.PROTOCOL_TYPE
	self.petkey = 0
	self.isinbattle = 0

	return self
end
function SSetFightPet:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSetFightPet:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.petkey)
	_os_:marshal_char(self.isinbattle)
	return _os_
end

function SSetFightPet:unmarshal(_os_)
	self.petkey = _os_:unmarshal_int32()
	self.isinbattle = _os_:unmarshal_char()
	return _os_
end

return SSetFightPet
