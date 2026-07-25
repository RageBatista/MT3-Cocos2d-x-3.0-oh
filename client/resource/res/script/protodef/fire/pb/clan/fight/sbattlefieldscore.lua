require "utils.tableutil"
SBattleFieldScore = {}
SBattleFieldScore.__index = SBattleFieldScore



SBattleFieldScore.PROTOCOL_TYPE = 808536

function SBattleFieldScore.Create()
	print("enter SBattleFieldScore create")
	return SBattleFieldScore:new()
end
function SBattleFieldScore:new()
	local self = {}
	setmetatable(self, SBattleFieldScore)
	self.type = self.PROTOCOL_TYPE
	self.clanscore1 = 0
	self.clanscroe2 = 0
	self.myscore = 0
	self.myrank = 0

	return self
end
function SBattleFieldScore:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SBattleFieldScore:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.clanscore1)
	_os_:marshal_int32(self.clanscroe2)
	_os_:marshal_int32(self.myscore)
	_os_:marshal_int32(self.myrank)
	return _os_
end

function SBattleFieldScore:unmarshal(_os_)
	self.clanscore1 = _os_:unmarshal_int32()
	self.clanscroe2 = _os_:unmarshal_int32()
	self.myscore = _os_:unmarshal_int32()
	self.myrank = _os_:unmarshal_int32()
	return _os_
end

return SBattleFieldScore
