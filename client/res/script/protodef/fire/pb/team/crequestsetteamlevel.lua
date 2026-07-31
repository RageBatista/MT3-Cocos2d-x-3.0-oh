require "utils.tableutil"
CRequestSetTeamLevel = {}
CRequestSetTeamLevel.__index = CRequestSetTeamLevel



CRequestSetTeamLevel.PROTOCOL_TYPE = 794462

function CRequestSetTeamLevel.Create()
	print("enter CRequestSetTeamLevel create")
	return CRequestSetTeamLevel:new()
end
function CRequestSetTeamLevel:new()
	local self = {}
	setmetatable(self, CRequestSetTeamLevel)
	self.type = self.PROTOCOL_TYPE
	self.minlevel = 0
	self.maxlevel = 0

	return self
end
function CRequestSetTeamLevel:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestSetTeamLevel:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.minlevel)
	_os_:marshal_int32(self.maxlevel)
	return _os_
end

function CRequestSetTeamLevel:unmarshal(_os_)
	self.minlevel = _os_:unmarshal_int32()
	self.maxlevel = _os_:unmarshal_int32()
	return _os_
end

return CRequestSetTeamLevel
