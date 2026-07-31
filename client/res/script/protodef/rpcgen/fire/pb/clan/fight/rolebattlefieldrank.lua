require "utils.tableutil"
RoleBattleFieldRank = {}
RoleBattleFieldRank.__index = RoleBattleFieldRank


function RoleBattleFieldRank:new()
	local self = {}
	setmetatable(self, RoleBattleFieldRank)
	self.rolename = "" 
	self.rolescroe = 0

	return self
end
function RoleBattleFieldRank:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int32(self.rolescroe)
	return _os_
end

function RoleBattleFieldRank:unmarshal(_os_)
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.rolescroe = _os_:unmarshal_int32()
	return _os_
end

return RoleBattleFieldRank
