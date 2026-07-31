require "utils.tableutil"
CLiveDieBattleGiveRose = {}
CLiveDieBattleGiveRose.__index = CLiveDieBattleGiveRose



CLiveDieBattleGiveRose.PROTOCOL_TYPE = 793844

function CLiveDieBattleGiveRose.Create()
	print("enter CLiveDieBattleGiveRose create")
	return CLiveDieBattleGiveRose:new()
end
function CLiveDieBattleGiveRose:new()
	local self = {}
	setmetatable(self, CLiveDieBattleGiveRose)
	self.type = self.PROTOCOL_TYPE
	self.vedioid = "" 

	return self
end
function CLiveDieBattleGiveRose:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CLiveDieBattleGiveRose:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.vedioid)
	return _os_
end

function CLiveDieBattleGiveRose:unmarshal(_os_)
	self.vedioid = _os_:unmarshal_wstring(self.vedioid)
	return _os_
end

return CLiveDieBattleGiveRose
