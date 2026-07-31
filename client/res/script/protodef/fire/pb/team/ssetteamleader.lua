require "utils.tableutil"
SSetTeamLeader = {}
SSetTeamLeader.__index = SSetTeamLeader



SSetTeamLeader.PROTOCOL_TYPE = 794445

function SSetTeamLeader.Create()
	print("enter SSetTeamLeader create")
	return SSetTeamLeader:new()
end
function SSetTeamLeader:new()
	local self = {}
	setmetatable(self, SSetTeamLeader)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0

	return self
end
function SSetTeamLeader:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSetTeamLeader:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	return _os_
end

function SSetTeamLeader:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	return _os_
end

return SSetTeamLeader
