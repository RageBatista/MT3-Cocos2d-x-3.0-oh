require "utils.tableutil"
CSetPilotType = {}
CSetPilotType.__index = CSetPilotType



CSetPilotType.PROTOCOL_TYPE = 786543

function CSetPilotType.Create()
	print("enter CSetPilotType create")
	return CSetPilotType:new()
end
function CSetPilotType:new()
	local self = {}
	setmetatable(self, CSetPilotType)
	self.type = self.PROTOCOL_TYPE
	self.pilottype = 0

	return self
end
function CSetPilotType:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSetPilotType:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.pilottype)
	return _os_
end

function CSetPilotType:unmarshal(_os_)
	self.pilottype = _os_:unmarshal_int32()
	return _os_
end

return CSetPilotType
