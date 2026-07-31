require "utils.tableutil"
PvP1RoleSingleWin = {}
PvP1RoleSingleWin.__index = PvP1RoleSingleWin


function PvP1RoleSingleWin:new()
	local self = {}
	setmetatable(self, PvP1RoleSingleWin)
	self.roleid = 0
	self.rolename = "" 
	self.combonum = 0

	return self
end
function PvP1RoleSingleWin:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int32(self.combonum)
	return _os_
end

function PvP1RoleSingleWin:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.combonum = _os_:unmarshal_int32()
	return _os_
end

return PvP1RoleSingleWin
