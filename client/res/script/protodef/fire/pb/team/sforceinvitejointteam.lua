require "utils.tableutil"
SForceInviteJointTeam = {}
SForceInviteJointTeam.__index = SForceInviteJointTeam



SForceInviteJointTeam.PROTOCOL_TYPE = 794511

function SForceInviteJointTeam.Create()
	print("enter SForceInviteJointTeam create")
	return SForceInviteJointTeam:new()
end
function SForceInviteJointTeam:new()
	local self = {}
	setmetatable(self, SForceInviteJointTeam)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0

	return self
end
function SForceInviteJointTeam:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SForceInviteJointTeam:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	return _os_
end

function SForceInviteJointTeam:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	return _os_
end

return SForceInviteJointTeam
