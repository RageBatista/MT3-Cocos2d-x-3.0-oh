require "utils.tableutil"
ClanFight = {}
ClanFight.__index = ClanFight


function ClanFight:new()
	local self = {}
	setmetatable(self, ClanFight)
	self.clanid1 = 0
	self.clanname1 = "" 
	self.clanid2 = 0
	self.clanname2 = "" 
	self.winner = 0

	return self
end
function ClanFight:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.clanid1)
	_os_:marshal_wstring(self.clanname1)
	_os_:marshal_int64(self.clanid2)
	_os_:marshal_wstring(self.clanname2)
	_os_:marshal_int32(self.winner)
	return _os_
end

function ClanFight:unmarshal(_os_)
	self.clanid1 = _os_:unmarshal_int64()
	self.clanname1 = _os_:unmarshal_wstring(self.clanname1)
	self.clanid2 = _os_:unmarshal_int64()
	self.clanname2 = _os_:unmarshal_wstring(self.clanname2)
	self.winner = _os_:unmarshal_int32()
	return _os_
end

return ClanFight
