require "utils.tableutil"
CAcceptLiveDieBattleFirst = {}
CAcceptLiveDieBattleFirst.__index = CAcceptLiveDieBattleFirst



CAcceptLiveDieBattleFirst.PROTOCOL_TYPE = 793848

function CAcceptLiveDieBattleFirst.Create()
	print("enter CAcceptLiveDieBattleFirst create")
	return CAcceptLiveDieBattleFirst:new()
end
function CAcceptLiveDieBattleFirst:new()
	local self = {}
	setmetatable(self, CAcceptLiveDieBattleFirst)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CAcceptLiveDieBattleFirst:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CAcceptLiveDieBattleFirst:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CAcceptLiveDieBattleFirst:unmarshal(_os_)
	return _os_
end

return CAcceptLiveDieBattleFirst
