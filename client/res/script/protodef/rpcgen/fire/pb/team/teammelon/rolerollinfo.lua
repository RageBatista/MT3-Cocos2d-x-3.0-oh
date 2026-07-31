require "utils.tableutil"
RoleRollInfo = {}
RoleRollInfo.__index = RoleRollInfo


function RoleRollInfo:new()
	local self = {}
	setmetatable(self, RoleRollInfo)
	self.roleid = 0
	self.rolename = "" 
	self.roll = 0

	return self
end
function RoleRollInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int32(self.roll)
	return _os_
end

function RoleRollInfo:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.roll = _os_:unmarshal_int32()
	return _os_
end

return RoleRollInfo
