require "utils.tableutil"
SSetMyFormation = {}
SSetMyFormation.__index = SSetMyFormation



SSetMyFormation.PROTOCOL_TYPE = 794475

function SSetMyFormation.Create()
	print("enter SSetMyFormation create")
	return SSetMyFormation:new()
end
function SSetMyFormation:new()
	local self = {}
	setmetatable(self, SSetMyFormation)
	self.type = self.PROTOCOL_TYPE
	self.formation = 0
	self.entersend = 0

	return self
end
function SSetMyFormation:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSetMyFormation:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.formation)
	_os_:marshal_int32(self.entersend)
	return _os_
end

function SSetMyFormation:unmarshal(_os_)
	self.formation = _os_:unmarshal_int32()
	self.entersend = _os_:unmarshal_int32()
	return _os_
end

return SSetMyFormation
