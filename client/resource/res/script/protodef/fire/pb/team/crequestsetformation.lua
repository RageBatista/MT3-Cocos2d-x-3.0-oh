require "utils.tableutil"
CRequestSetFormation = {}
CRequestSetFormation.__index = CRequestSetFormation



CRequestSetFormation.PROTOCOL_TYPE = 794464

function CRequestSetFormation.Create()
	print("enter CRequestSetFormation create")
	return CRequestSetFormation:new()
end
function CRequestSetFormation:new()
	local self = {}
	setmetatable(self, CRequestSetFormation)
	self.type = self.PROTOCOL_TYPE
	self.formation = 0

	return self
end
function CRequestSetFormation:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestSetFormation:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.formation)
	return _os_
end

function CRequestSetFormation:unmarshal(_os_)
	self.formation = _os_:unmarshal_int32()
	return _os_
end

return CRequestSetFormation
