require "utils.tableutil"
PvP1RoleSingleScoreMid = {}
PvP1RoleSingleScoreMid.__index = PvP1RoleSingleScoreMid


function PvP1RoleSingleScoreMid:new()
	local self = {}
	setmetatable(self, PvP1RoleSingleScoreMid)
	self.index = 0
	self.roleid = 0
	self.rolename = "" 
	self.score = 0
	self.battlenum = 0
	self.winnum = 0

	return self
end
function PvP1RoleSingleScoreMid:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_short(self.index)
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int32(self.score)
	_os_:marshal_char(self.battlenum)
	_os_:marshal_char(self.winnum)
	return _os_
end

function PvP1RoleSingleScoreMid:unmarshal(_os_)
	self.index = _os_:unmarshal_short()
	self.roleid = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.score = _os_:unmarshal_int32()
	self.battlenum = _os_:unmarshal_char()
	self.winnum = _os_:unmarshal_char()
	return _os_
end

return PvP1RoleSingleScoreMid
