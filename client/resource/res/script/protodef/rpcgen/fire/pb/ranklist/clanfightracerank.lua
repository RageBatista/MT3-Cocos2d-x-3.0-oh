require "utils.tableutil"
ClanFightRaceRank = {}
ClanFightRaceRank.__index = ClanFightRaceRank


function ClanFightRaceRank:new()
	local self = {}
	setmetatable(self, ClanFightRaceRank)
	self.rank = 0
	self.clanid = 0
	self.clanname = "" 
	self.clanlevel = 0
	self.fightcount = 0
	self.wincount = 0
	self.scroe = 0

	return self
end
function ClanFightRaceRank:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.rank)
	_os_:marshal_int64(self.clanid)
	_os_:marshal_wstring(self.clanname)
	_os_:marshal_int32(self.clanlevel)
	_os_:marshal_int32(self.fightcount)
	_os_:marshal_int32(self.wincount)
	_os_:marshal_int32(self.scroe)
	return _os_
end

function ClanFightRaceRank:unmarshal(_os_)
	self.rank = _os_:unmarshal_int32()
	self.clanid = _os_:unmarshal_int64()
	self.clanname = _os_:unmarshal_wstring(self.clanname)
	self.clanlevel = _os_:unmarshal_int32()
	self.fightcount = _os_:unmarshal_int32()
	self.wincount = _os_:unmarshal_int32()
	self.scroe = _os_:unmarshal_int32()
	return _os_
end

return ClanFightRaceRank
