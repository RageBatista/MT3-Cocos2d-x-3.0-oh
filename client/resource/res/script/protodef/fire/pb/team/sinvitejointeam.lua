require "utils.tableutil"
SInviteJoinTeam = {}
SInviteJoinTeam.__index = SInviteJoinTeam



SInviteJoinTeam.PROTOCOL_TYPE = 794447

function SInviteJoinTeam.Create()
	print("enter SInviteJoinTeam create")
	return SInviteJoinTeam:new()
end
function SInviteJoinTeam:new()
	local self = {}
	setmetatable(self, SInviteJoinTeam)
	self.type = self.PROTOCOL_TYPE
	self.leaderroleid = 0
	self.invitername = "" 
	self.inviterlevel = 0
	self.op = 0

	return self
end
function SInviteJoinTeam:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SInviteJoinTeam:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.leaderroleid)
	_os_:marshal_wstring(self.invitername)
	_os_:marshal_int32(self.inviterlevel)
	_os_:marshal_int32(self.op)
	return _os_
end

function SInviteJoinTeam:unmarshal(_os_)
	self.leaderroleid = _os_:unmarshal_int64()
	self.invitername = _os_:unmarshal_wstring(self.invitername)
	self.inviterlevel = _os_:unmarshal_int32()
	self.op = _os_:unmarshal_int32()
	return _os_
end

return SInviteJoinTeam
