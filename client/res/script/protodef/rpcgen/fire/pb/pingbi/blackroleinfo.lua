require "utils.tableutil"
BlackRoleInfo = {}
BlackRoleInfo.__index = BlackRoleInfo


function BlackRoleInfo:new()
	local self = {}
	setmetatable(self, BlackRoleInfo)
	self.roleid = 0
	self.name = "" 
	self.level = 0
	self.shape = 0
	self.school = 0

	return self
end
function BlackRoleInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.name)
	_os_:marshal_short(self.level)
	_os_:marshal_int32(self.shape)
	_os_:marshal_char(self.school)
	return _os_
end

function BlackRoleInfo:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.name = _os_:unmarshal_wstring(self.name)
	self.level = _os_:unmarshal_short()
	self.shape = _os_:unmarshal_int32()
	self.school = _os_:unmarshal_char()
	return _os_
end

return BlackRoleInfo
