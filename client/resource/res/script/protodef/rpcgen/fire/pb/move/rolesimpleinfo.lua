require "utils.tableutil"
RoleSimpleInfo = {}
RoleSimpleInfo.__index = RoleSimpleInfo


function RoleSimpleInfo:new()
	local self = {}
	setmetatable(self, RoleSimpleInfo)
	self.roleid = 0
	self.name = "" 
	self.shape = 0
	self.school = 0
	self.level = 0
	self.camptype = 0

	return self
end
function RoleSimpleInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.name)
	_os_:marshal_int32(self.shape)
	_os_:marshal_int32(self.school)
	_os_:marshal_int32(self.level)
	_os_:marshal_int32(self.camptype)
	return _os_
end

function RoleSimpleInfo:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.name = _os_:unmarshal_wstring(self.name)
	self.shape = _os_:unmarshal_int32()
	self.school = _os_:unmarshal_int32()
	self.level = _os_:unmarshal_int32()
	self.camptype = _os_:unmarshal_int32()
	return _os_
end

return RoleSimpleInfo
