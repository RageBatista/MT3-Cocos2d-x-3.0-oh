require "utils.tableutil"
CReqRoleTeamState = {}
CReqRoleTeamState.__index = CReqRoleTeamState



CReqRoleTeamState.PROTOCOL_TYPE = 786464

function CReqRoleTeamState.Create()
	print("enter CReqRoleTeamState create")
	return CReqRoleTeamState:new()
end
function CReqRoleTeamState:new()
	local self = {}
	setmetatable(self, CReqRoleTeamState)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0

	return self
end
function CReqRoleTeamState:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReqRoleTeamState:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	return _os_
end

function CReqRoleTeamState:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	return _os_
end

return CReqRoleTeamState
