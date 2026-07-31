require "utils.tableutil"
SAnswerRoleTeamState = {}
SAnswerRoleTeamState.__index = SAnswerRoleTeamState



SAnswerRoleTeamState.PROTOCOL_TYPE = 786465

function SAnswerRoleTeamState.Create()
	print("enter SAnswerRoleTeamState create")
	return SAnswerRoleTeamState:new()
end
function SAnswerRoleTeamState:new()
	local self = {}
	setmetatable(self, SAnswerRoleTeamState)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.level = 0
	self.teamstate = 0

	return self
end
function SAnswerRoleTeamState:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SAnswerRoleTeamState:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int32(self.level)
	_os_:marshal_int32(self.teamstate)
	return _os_
end

function SAnswerRoleTeamState:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.level = _os_:unmarshal_int32()
	self.teamstate = _os_:unmarshal_int32()
	return _os_
end

return SAnswerRoleTeamState
