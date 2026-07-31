require "utils.tableutil"
CGetTeamLeader = {}
CGetTeamLeader.__index = CGetTeamLeader



CGetTeamLeader.PROTOCOL_TYPE = 794450

function CGetTeamLeader.Create()
	print("enter CGetTeamLeader create")
	return CGetTeamLeader:new()
end
function CGetTeamLeader:new()
	local self = {}
	setmetatable(self, CGetTeamLeader)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0

	return self
end
function CGetTeamLeader:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetTeamLeader:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	return _os_
end

function CGetTeamLeader:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	return _os_
end

return CGetTeamLeader
