require "utils.tableutil"
SInvitationToMarry = {}
SInvitationToMarry.__index = SInvitationToMarry



SInvitationToMarry.PROTOCOL_TYPE = 817974

function SInvitationToMarry.Create()
	print("enter SInvitationToMarry create")
	return SInvitationToMarry:new()
end
function SInvitationToMarry:new()
	local self = {}
	setmetatable(self, SInvitationToMarry)
	self.type = self.PROTOCOL_TYPE
	self.leaderroleid = 0
	self.invitername = "" 
	self.inviterlevel = 0
	self.op = 0

	return self
end
function SInvitationToMarry:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SInvitationToMarry:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.leaderroleid)
	_os_:marshal_wstring(self.invitername)
	_os_:marshal_int32(self.inviterlevel)
	_os_:marshal_int32(self.op)
	return _os_
end

function SInvitationToMarry:unmarshal(_os_)
	self.leaderroleid = _os_:unmarshal_int64()
	self.invitername = _os_:unmarshal_wstring(self.invitername)
	self.inviterlevel = _os_:unmarshal_int32()
	self.op = _os_:unmarshal_int32()
	return _os_
end

return SInvitationToMarry
