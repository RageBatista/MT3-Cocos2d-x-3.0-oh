require "utils.tableutil"
RedPackRoleRecord = {}
RedPackRoleRecord.__index = RedPackRoleRecord


function RedPackRoleRecord:new()
	local self = {}
	setmetatable(self, RedPackRoleRecord)
	self.modeltype = 0
	self.redpackid = "" 
	self.roleid = 0
	self.rolename = "" 
	self.school = 0
	self.shape = 0
	self.redpackmoney = 0
	self.time = 0

	return self
end
function RedPackRoleRecord:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.modeltype)
	_os_:marshal_wstring(self.redpackid)
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int32(self.school)
	_os_:marshal_int32(self.shape)
	_os_:marshal_int32(self.redpackmoney)
	_os_:marshal_int64(self.time)
	return _os_
end

function RedPackRoleRecord:unmarshal(_os_)
	self.modeltype = _os_:unmarshal_int32()
	self.redpackid = _os_:unmarshal_wstring(self.redpackid)
	self.roleid = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.school = _os_:unmarshal_int32()
	self.shape = _os_:unmarshal_int32()
	self.redpackmoney = _os_:unmarshal_int32()
	self.time = _os_:unmarshal_int64()
	return _os_
end

return RedPackRoleRecord
