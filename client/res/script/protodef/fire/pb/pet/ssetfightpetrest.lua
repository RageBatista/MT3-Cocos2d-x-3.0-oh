require "utils.tableutil"
SSetFightPetRest = {}
SSetFightPetRest.__index = SSetFightPetRest



SSetFightPetRest.PROTOCOL_TYPE = 788443

function SSetFightPetRest.Create()
	print("enter SSetFightPetRest create")
	return SSetFightPetRest:new()
end
function SSetFightPetRest:new()
	local self = {}
	setmetatable(self, SSetFightPetRest)
	self.type = self.PROTOCOL_TYPE
	self.isinbattle = 0

	return self
end
function SSetFightPetRest:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSetFightPetRest:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.isinbattle)
	return _os_
end

function SSetFightPetRest:unmarshal(_os_)
	self.isinbattle = _os_:unmarshal_char()
	return _os_
end

return SSetFightPetRest
