require "utils.tableutil"
CSetFightPetRest = {}
CSetFightPetRest.__index = CSetFightPetRest



CSetFightPetRest.PROTOCOL_TYPE = 788442

function CSetFightPetRest.Create()
	print("enter CSetFightPetRest create")
	return CSetFightPetRest:new()
end
function CSetFightPetRest:new()
	local self = {}
	setmetatable(self, CSetFightPetRest)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CSetFightPetRest:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSetFightPetRest:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CSetFightPetRest:unmarshal(_os_)
	return _os_
end

return CSetFightPetRest
