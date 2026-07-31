require "utils.tableutil"
CShowPetOff = {}
CShowPetOff.__index = CShowPetOff



CShowPetOff.PROTOCOL_TYPE = 788435

function CShowPetOff.Create()
	print("enter CShowPetOff create")
	return CShowPetOff:new()
end
function CShowPetOff:new()
	local self = {}
	setmetatable(self, CShowPetOff)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CShowPetOff:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CShowPetOff:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CShowPetOff:unmarshal(_os_)
	return _os_
end

return CShowPetOff
