require "utils.tableutil"
CFInviteJoinTeam = {}
CFInviteJoinTeam.__index = CFInviteJoinTeam



CFInviteJoinTeam.PROTOCOL_TYPE = 794493

function CFInviteJoinTeam.Create()
	print("enter CFInviteJoinTeam create")
	return CFInviteJoinTeam:new()
end
function CFInviteJoinTeam:new()
	local self = {}
	setmetatable(self, CFInviteJoinTeam)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0

	return self
end
function CFInviteJoinTeam:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CFInviteJoinTeam:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	return _os_
end

function CFInviteJoinTeam:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	return _os_
end

return CFInviteJoinTeam
