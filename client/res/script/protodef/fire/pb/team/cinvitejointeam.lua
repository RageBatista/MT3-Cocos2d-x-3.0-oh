require "utils.tableutil"
CInviteJoinTeam = {}
CInviteJoinTeam.__index = CInviteJoinTeam



CInviteJoinTeam.PROTOCOL_TYPE = 794446

function CInviteJoinTeam.Create()
	print("enter CInviteJoinTeam create")
	return CInviteJoinTeam:new()
end
function CInviteJoinTeam:new()
	local self = {}
	setmetatable(self, CInviteJoinTeam)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.force = 0

	return self
end
function CInviteJoinTeam:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CInviteJoinTeam:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int32(self.force)
	return _os_
end

function CInviteJoinTeam:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.force = _os_:unmarshal_int32()
	return _os_
end

return CInviteJoinTeam
