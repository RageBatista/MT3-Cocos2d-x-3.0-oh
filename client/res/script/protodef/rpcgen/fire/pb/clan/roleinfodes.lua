require "utils.tableutil"
RoleInfoDes = {}
RoleInfoDes.__index = RoleInfoDes


function RoleInfoDes:new()
	local self = {}
	setmetatable(self, RoleInfoDes)
	self.moduletype = 0
	self.roleid = 0
	self.rolename = "" 
	self.shape = 0
	self.level = 0
	self.camp = 0
	self.school = 0
	self.clanname = "" 

	return self
end
function RoleInfoDes:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.moduletype)
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int32(self.shape)
	_os_:marshal_int32(self.level)
	_os_:marshal_int32(self.camp)
	_os_:marshal_int32(self.school)
	_os_:marshal_wstring(self.clanname)
	return _os_
end

function RoleInfoDes:unmarshal(_os_)
	self.moduletype = _os_:unmarshal_int32()
	self.roleid = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.shape = _os_:unmarshal_int32()
	self.level = _os_:unmarshal_int32()
	self.camp = _os_:unmarshal_int32()
	self.school = _os_:unmarshal_int32()
	self.clanname = _os_:unmarshal_wstring(self.clanname)
	return _os_
end

return RoleInfoDes
