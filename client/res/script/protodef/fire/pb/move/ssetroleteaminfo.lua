require "utils.tableutil"
SSetRoleTeamInfo = {}
SSetRoleTeamInfo.__index = SSetRoleTeamInfo



SSetRoleTeamInfo.PROTOCOL_TYPE = 790444

function SSetRoleTeamInfo.Create()
	print("enter SSetRoleTeamInfo create")
	return SSetRoleTeamInfo:new()
end
function SSetRoleTeamInfo:new()
	local self = {}
	setmetatable(self, SSetRoleTeamInfo)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.teamid = 0
	self.teamindex = 0
	self.teamstate = 0
	self.teamnormalnum = 0

	return self
end
function SSetRoleTeamInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSetRoleTeamInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int64(self.teamid)
	_os_:marshal_int32(self.teamindex)
	_os_:marshal_int32(self.teamstate)
	_os_:marshal_int32(self.teamnormalnum)
	return _os_
end

function SSetRoleTeamInfo:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.teamid = _os_:unmarshal_int64()
	self.teamindex = _os_:unmarshal_int32()
	self.teamstate = _os_:unmarshal_int32()
	self.teamnormalnum = _os_:unmarshal_int32()
	return _os_
end

return SSetRoleTeamInfo
