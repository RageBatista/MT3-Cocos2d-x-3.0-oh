require "utils.tableutil"
RoleBaseInfo = {}
RoleBaseInfo.__index = RoleBaseInfo


function RoleBaseInfo:new()
	local self = {}
	setmetatable(self, RoleBaseInfo)
	self.roleid = 0
	self.rolename = "" 
	self.rolelevel = 0
	self.roleschool = 0
	self.applytime = 0
	self.fightvalue = 0

	return self
end
function RoleBaseInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int32(self.rolelevel)
	_os_:marshal_int32(self.roleschool)
	_os_:marshal_int64(self.applytime)
	_os_:marshal_int32(self.fightvalue)
	return _os_
end

function RoleBaseInfo:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.rolelevel = _os_:unmarshal_int32()
	self.roleschool = _os_:unmarshal_int32()
	self.applytime = _os_:unmarshal_int64()
	self.fightvalue = _os_:unmarshal_int32()
	return _os_
end

return RoleBaseInfo
