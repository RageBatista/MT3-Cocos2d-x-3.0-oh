require "utils.tableutil"
PvP5RoleSingleScoreMid = {}
PvP5RoleSingleScoreMid.__index = PvP5RoleSingleScoreMid


function PvP5RoleSingleScoreMid:new()
	local self = {}
	setmetatable(self, PvP5RoleSingleScoreMid)
	self.listid = 0
	self.index = 0
	self.roleid = 0
	self.rolename = "" 
	self.score = 0
	self.battlenum = 0
	self.winnum = 0

	return self
end
function PvP5RoleSingleScoreMid:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.listid)
	_os_:marshal_short(self.index)
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int32(self.score)
	_os_:marshal_char(self.battlenum)
	_os_:marshal_char(self.winnum)
	return _os_
end

function PvP5RoleSingleScoreMid:unmarshal(_os_)
	self.listid = _os_:unmarshal_char()
	self.index = _os_:unmarshal_short()
	self.roleid = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.score = _os_:unmarshal_int32()
	self.battlenum = _os_:unmarshal_char()
	self.winnum = _os_:unmarshal_char()
	return _os_
end

return PvP5RoleSingleScoreMid
