require "utils.tableutil"
PvP3RoleSingleScore = {}
PvP3RoleSingleScore.__index = PvP3RoleSingleScore


function PvP3RoleSingleScore:new()
	local self = {}
	setmetatable(self, PvP3RoleSingleScore)
	self.roleid = 0
	self.rolename = "" 
	self.score = 0

	return self
end
function PvP3RoleSingleScore:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int32(self.score)
	return _os_
end

function PvP3RoleSingleScore:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.score = _os_:unmarshal_int32()
	return _os_
end

return PvP3RoleSingleScore
