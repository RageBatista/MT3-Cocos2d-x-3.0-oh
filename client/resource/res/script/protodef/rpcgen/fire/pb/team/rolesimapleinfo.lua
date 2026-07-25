require "utils.tableutil"
RoleSimapleInfo = {}
RoleSimapleInfo.__index = RoleSimapleInfo


function RoleSimapleInfo:new()
	local self = {}
	setmetatable(self, RoleSimapleInfo)
	self.rolename = "" 
	self.level = 0
	self.roleid = 0
	self.schoold = 0
	self.shape = 0

	return self
end
function RoleSimapleInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int32(self.level)
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int32(self.schoold)
	_os_:marshal_int32(self.shape)
	return _os_
end

function RoleSimapleInfo:unmarshal(_os_)
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.level = _os_:unmarshal_int32()
	self.roleid = _os_:unmarshal_int64()
	self.schoold = _os_:unmarshal_int32()
	self.shape = _os_:unmarshal_int32()
	return _os_
end

return RoleSimapleInfo
