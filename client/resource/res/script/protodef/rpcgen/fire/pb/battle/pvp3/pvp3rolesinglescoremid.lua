require "utils.tableutil"
PvP3RoleSingleScoreMid = {}
PvP3RoleSingleScoreMid.__index = PvP3RoleSingleScoreMid


function PvP3RoleSingleScoreMid:new()
	local self = {}
	setmetatable(self, PvP3RoleSingleScoreMid)
	self.index = 0
	self.roleid = 0
	self.rolename = "" 
	self.score = 0

	return self
end
function PvP3RoleSingleScoreMid:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_short(self.index)
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int32(self.score)
	return _os_
end

function PvP3RoleSingleScoreMid:unmarshal(_os_)
	self.index = _os_:unmarshal_short()
	self.roleid = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.score = _os_:unmarshal_int32()
	return _os_
end

return PvP3RoleSingleScoreMid
