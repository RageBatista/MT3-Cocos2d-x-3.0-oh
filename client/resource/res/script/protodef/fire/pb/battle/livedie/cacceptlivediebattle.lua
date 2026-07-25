require "utils.tableutil"
CAcceptLiveDieBattle = {}
CAcceptLiveDieBattle.__index = CAcceptLiveDieBattle



CAcceptLiveDieBattle.PROTOCOL_TYPE = 793839

function CAcceptLiveDieBattle.Create()
	print("enter CAcceptLiveDieBattle create")
	return CAcceptLiveDieBattle:new()
end
function CAcceptLiveDieBattle:new()
	local self = {}
	setmetatable(self, CAcceptLiveDieBattle)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CAcceptLiveDieBattle:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CAcceptLiveDieBattle:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CAcceptLiveDieBattle:unmarshal(_os_)
	return _os_
end

return CAcceptLiveDieBattle
