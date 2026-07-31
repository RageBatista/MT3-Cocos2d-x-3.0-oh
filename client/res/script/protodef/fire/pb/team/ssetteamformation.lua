require "utils.tableutil"
SSetTeamFormation = {}
SSetTeamFormation.__index = SSetTeamFormation



SSetTeamFormation.PROTOCOL_TYPE = 794465

function SSetTeamFormation.Create()
	print("enter SSetTeamFormation create")
	return SSetTeamFormation:new()
end
function SSetTeamFormation:new()
	local self = {}
	setmetatable(self, SSetTeamFormation)
	self.type = self.PROTOCOL_TYPE
	self.formation = 0
	self.formationlevel = 0
	self.msg = 0

	return self
end
function SSetTeamFormation:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSetTeamFormation:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.formation)
	_os_:marshal_int32(self.formationlevel)
	_os_:marshal_char(self.msg)
	return _os_
end

function SSetTeamFormation:unmarshal(_os_)
	self.formation = _os_:unmarshal_int32()
	self.formationlevel = _os_:unmarshal_int32()
	self.msg = _os_:unmarshal_char()
	return _os_
end

return SSetTeamFormation
