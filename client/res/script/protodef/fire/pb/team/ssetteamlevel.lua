require "utils.tableutil"
SSetTeamLevel = {}
SSetTeamLevel.__index = SSetTeamLevel



SSetTeamLevel.PROTOCOL_TYPE = 794463

function SSetTeamLevel.Create()
	print("enter SSetTeamLevel create")
	return SSetTeamLevel:new()
end
function SSetTeamLevel:new()
	local self = {}
	setmetatable(self, SSetTeamLevel)
	self.type = self.PROTOCOL_TYPE
	self.minlevel = 0
	self.maxlevel = 0

	return self
end
function SSetTeamLevel:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSetTeamLevel:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.minlevel)
	_os_:marshal_int32(self.maxlevel)
	return _os_
end

function SSetTeamLevel:unmarshal(_os_)
	self.minlevel = _os_:unmarshal_int32()
	self.maxlevel = _os_:unmarshal_int32()
	return _os_
end

return SSetTeamLevel
