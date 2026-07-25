require "utils.tableutil"
ClanMember = {}
ClanMember.__index = ClanMember

---玩家信息-队伍称谓
function ClanMember:new()
	local self = {}
	setmetatable(self, ClanMember)
	self.roleid = 0
	self.shapeid = 0
	self.rolename = "" 
	self.rolelevel = 0
	self.rolecontribution = 0
	self.weekcontribution = 0
	self.historycontribution = 0
	self.rolefreezedcontribution = 0
	self.preweekcontribution = 0
	self.lastonlinetime = 0
	self.position = 0
	self.school = 0
	self.jointime = 0
	self.weekaid = 0
	self.historyaid = 0
	self.isbannedtalk = 0
	self.fightvalue = 0
	self.claninstnum = 0
	self.clanfightnum = 0

	return self
end
function ClanMember:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int32(self.shapeid)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_short(self.rolelevel)
	_os_:marshal_int32(self.rolecontribution)
	_os_:marshal_int32(self.weekcontribution)
	_os_:marshal_int32(self.historycontribution)
	_os_:marshal_int32(self.rolefreezedcontribution)
	_os_:marshal_int32(self.preweekcontribution)
	_os_:marshal_int32(self.lastonlinetime)
	_os_:marshal_char(self.position)
	_os_:marshal_char(self.school)
	_os_:marshal_int32(self.jointime)
	_os_:marshal_short(self.weekaid)
	_os_:marshal_int32(self.historyaid)
	_os_:marshal_char(self.isbannedtalk)
	_os_:marshal_int32(self.fightvalue)
	_os_:marshal_short(self.claninstnum)
	_os_:marshal_short(self.clanfightnum)
	return _os_
end

function ClanMember:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.shapeid = _os_:unmarshal_int32()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.rolelevel = _os_:unmarshal_short()
	self.rolecontribution = _os_:unmarshal_int32()
	self.weekcontribution = _os_:unmarshal_int32()
	self.historycontribution = _os_:unmarshal_int32()
	self.rolefreezedcontribution = _os_:unmarshal_int32()
	self.preweekcontribution = _os_:unmarshal_int32()
	self.lastonlinetime = _os_:unmarshal_int32()
	self.position = _os_:unmarshal_char()
	self.school = _os_:unmarshal_char()
	self.jointime = _os_:unmarshal_int32()
	self.weekaid = _os_:unmarshal_short()
	self.historyaid = _os_:unmarshal_int32()
	self.isbannedtalk = _os_:unmarshal_char()
	self.fightvalue = _os_:unmarshal_int32()
	self.claninstnum = _os_:unmarshal_short()
	self.clanfightnum = _os_:unmarshal_short()
	return _os_
end

return ClanMember
