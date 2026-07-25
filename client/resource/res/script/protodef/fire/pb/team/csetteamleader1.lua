require "utils.tableutil"
CSetTeamLeader1 = {}
CSetTeamLeader1.__index = CSetTeamLeader1



CSetTeamLeader1.PROTOCOL_TYPE = 820500

function CSetTeamLeader1.Create()
	print("enter CSetTeamLeader1 create")
	return CSetTeamLeader1:new()
end
function CSetTeamLeader1:new()
	local self = {}
	setmetatable(self, CSetTeamLeader1)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0

	return self
end
function CSetTeamLeader1:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSetTeamLeader1:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	return _os_
end

function CSetTeamLeader1:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	return _os_
end

return CSetTeamLeader1
