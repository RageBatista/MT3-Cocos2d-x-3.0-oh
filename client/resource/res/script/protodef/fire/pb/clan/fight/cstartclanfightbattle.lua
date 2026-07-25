require "utils.tableutil"
CStartClanFightBattle = {}
CStartClanFightBattle.__index = CStartClanFightBattle



CStartClanFightBattle.PROTOCOL_TYPE = 808534

function CStartClanFightBattle.Create()
	print("enter CStartClanFightBattle create")
	return CStartClanFightBattle:new()
end
function CStartClanFightBattle:new()
	local self = {}
	setmetatable(self, CStartClanFightBattle)
	self.type = self.PROTOCOL_TYPE
	self.targetid = 0

	return self
end
function CStartClanFightBattle:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CStartClanFightBattle:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.targetid)
	return _os_
end

function CStartClanFightBattle:unmarshal(_os_)
	self.targetid = _os_:unmarshal_int64()
	return _os_
end

return CStartClanFightBattle
