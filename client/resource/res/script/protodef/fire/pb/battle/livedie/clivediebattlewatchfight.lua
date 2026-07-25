require "utils.tableutil"
CLiveDieBattleWatchFight = {}
CLiveDieBattleWatchFight.__index = CLiveDieBattleWatchFight



CLiveDieBattleWatchFight.PROTOCOL_TYPE = 793847

function CLiveDieBattleWatchFight.Create()
	print("enter CLiveDieBattleWatchFight create")
	return CLiveDieBattleWatchFight:new()
end
function CLiveDieBattleWatchFight:new()
	local self = {}
	setmetatable(self, CLiveDieBattleWatchFight)
	self.type = self.PROTOCOL_TYPE
	self.battleid = 0

	return self
end
function CLiveDieBattleWatchFight:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CLiveDieBattleWatchFight:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.battleid)
	return _os_
end

function CLiveDieBattleWatchFight:unmarshal(_os_)
	self.battleid = _os_:unmarshal_int64()
	return _os_
end

return CLiveDieBattleWatchFight
