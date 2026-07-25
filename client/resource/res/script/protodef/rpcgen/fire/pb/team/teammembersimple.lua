require "utils.tableutil"
TeamMemberSimple = {}
TeamMemberSimple.__index = TeamMemberSimple


function TeamMemberSimple:new()
	local self = {}
	setmetatable(self, TeamMemberSimple)
	self.roleid = 0
	self.rolename = "" 
	self.level = 0
	self.school = 0
	self.shape = 0

	return self
end
function TeamMemberSimple:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int32(self.level)
	_os_:marshal_int32(self.school)
	_os_:marshal_int32(self.shape)
	return _os_
end

function TeamMemberSimple:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.level = _os_:unmarshal_int32()
	self.school = _os_:unmarshal_int32()
	self.shape = _os_:unmarshal_int32()
	return _os_
end

return TeamMemberSimple
