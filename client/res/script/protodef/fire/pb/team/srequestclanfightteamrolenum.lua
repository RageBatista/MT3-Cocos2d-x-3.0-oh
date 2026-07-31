require "utils.tableutil"
SRequestClanFightTeamRoleNum = {}
SRequestClanFightTeamRoleNum.__index = SRequestClanFightTeamRoleNum



SRequestClanFightTeamRoleNum.PROTOCOL_TYPE = 794562

function SRequestClanFightTeamRoleNum.Create()
	print("enter SRequestClanFightTeamRoleNum create")
	return SRequestClanFightTeamRoleNum:new()
end
function SRequestClanFightTeamRoleNum:new()
	local self = {}
	setmetatable(self, SRequestClanFightTeamRoleNum)
	self.type = self.PROTOCOL_TYPE
	self.teamnum = 0
	self.rolenum = 0

	return self
end
function SRequestClanFightTeamRoleNum:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRequestClanFightTeamRoleNum:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.teamnum)
	_os_:marshal_int32(self.rolenum)
	return _os_
end

function SRequestClanFightTeamRoleNum:unmarshal(_os_)
	self.teamnum = _os_:unmarshal_int32()
	self.rolenum = _os_:unmarshal_int32()
	return _os_
end

return SRequestClanFightTeamRoleNum
