require "utils.tableutil"
CRequestClanFightTeamRoleNum = {}
CRequestClanFightTeamRoleNum.__index = CRequestClanFightTeamRoleNum



CRequestClanFightTeamRoleNum.PROTOCOL_TYPE = 794561

function CRequestClanFightTeamRoleNum.Create()
	print("enter CRequestClanFightTeamRoleNum create")
	return CRequestClanFightTeamRoleNum:new()
end
function CRequestClanFightTeamRoleNum:new()
	local self = {}
	setmetatable(self, CRequestClanFightTeamRoleNum)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CRequestClanFightTeamRoleNum:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestClanFightTeamRoleNum:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CRequestClanFightTeamRoleNum:unmarshal(_os_)
	return _os_
end

return CRequestClanFightTeamRoleNum
