require "utils.tableutil"
QCRoleInfoDes = {}
QCRoleInfoDes.__index = QCRoleInfoDes


function QCRoleInfoDes:new()
	local self = {}
	setmetatable(self, QCRoleInfoDes)
	self.roleid = 0
	self.rolename = "" 
	self.shape = 0
	self.level = 0
	self.school = 0
	self.teamnum = 0
	self.teamnummax = 0

	return self
end
function QCRoleInfoDes:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int32(self.shape)
	_os_:marshal_int32(self.level)
	_os_:marshal_int32(self.school)
	_os_:marshal_int32(self.teamnum)
	_os_:marshal_int32(self.teamnummax)
	return _os_
end

function QCRoleInfoDes:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.shape = _os_:unmarshal_int32()
	self.level = _os_:unmarshal_int32()
	self.school = _os_:unmarshal_int32()
	self.teamnum = _os_:unmarshal_int32()
	self.teamnummax = _os_:unmarshal_int32()
	return _os_
end

return QCRoleInfoDes
