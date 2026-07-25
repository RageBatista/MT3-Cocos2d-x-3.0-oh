require "utils.tableutil"
PvP3RoleSingleMatch = {}
PvP3RoleSingleMatch.__index = PvP3RoleSingleMatch


function PvP3RoleSingleMatch:new()
	local self = {}
	setmetatable(self, PvP3RoleSingleMatch)
	self.roleid = 0
	self.level = 0
	self.shape = 0
	self.school = 0

	return self
end
function PvP3RoleSingleMatch:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_short(self.level)
	_os_:marshal_int32(self.shape)
	_os_:marshal_int32(self.school)
	return _os_
end

function PvP3RoleSingleMatch:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.level = _os_:unmarshal_short()
	self.shape = _os_:unmarshal_int32()
	self.school = _os_:unmarshal_int32()
	return _os_
end

return PvP3RoleSingleMatch
