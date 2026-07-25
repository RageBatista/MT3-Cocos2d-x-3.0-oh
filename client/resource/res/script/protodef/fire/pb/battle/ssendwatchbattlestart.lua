require "utils.tableutil"
SSendWatchBattleStart = {}
SSendWatchBattleStart.__index = SSendWatchBattleStart



SSendWatchBattleStart.PROTOCOL_TYPE = 793444

function SSendWatchBattleStart.Create()
	print("enter SSendWatchBattleStart create")
	return SSendWatchBattleStart:new()
end
function SSendWatchBattleStart:new()
	local self = {}
	setmetatable(self, SSendWatchBattleStart)
	self.type = self.PROTOCOL_TYPE
	self.enemyside = 0
	self.leftcount = 0
	self.battletype = 0
	self.roundnum = 0
	self.friendsformation = 0
	self.enemyformation = 0
	self.friendsformationlevel = 0
	self.enemyformationlevel = 0
	self.background = 0
	self.backmusic = 0
	self.battlekey = 0

	return self
end
function SSendWatchBattleStart:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSendWatchBattleStart:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.enemyside)
	_os_:marshal_int32(self.leftcount)
	_os_:marshal_int32(self.battletype)
	_os_:marshal_int32(self.roundnum)
	_os_:marshal_int32(self.friendsformation)
	_os_:marshal_int32(self.enemyformation)
	_os_:marshal_int32(self.friendsformationlevel)
	_os_:marshal_int32(self.enemyformationlevel)
	_os_:marshal_char(self.background)
	_os_:marshal_char(self.backmusic)
	_os_:marshal_int64(self.battlekey)
	return _os_
end

function SSendWatchBattleStart:unmarshal(_os_)
	self.enemyside = _os_:unmarshal_int32()
	self.leftcount = _os_:unmarshal_int32()
	self.battletype = _os_:unmarshal_int32()
	self.roundnum = _os_:unmarshal_int32()
	self.friendsformation = _os_:unmarshal_int32()
	self.enemyformation = _os_:unmarshal_int32()
	self.friendsformationlevel = _os_:unmarshal_int32()
	self.enemyformationlevel = _os_:unmarshal_int32()
	self.background = _os_:unmarshal_char()
	self.backmusic = _os_:unmarshal_char()
	self.battlekey = _os_:unmarshal_int64()
	return _os_
end

return SSendWatchBattleStart
