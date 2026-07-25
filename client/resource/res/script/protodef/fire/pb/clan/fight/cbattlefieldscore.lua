require "utils.tableutil"
CBattleFieldScore = {}
CBattleFieldScore.__index = CBattleFieldScore



CBattleFieldScore.PROTOCOL_TYPE = 808535

function CBattleFieldScore.Create()
	print("enter CBattleFieldScore create")
	return CBattleFieldScore:new()
end
function CBattleFieldScore:new()
	local self = {}
	setmetatable(self, CBattleFieldScore)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CBattleFieldScore:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CBattleFieldScore:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CBattleFieldScore:unmarshal(_os_)
	return _os_
end

return CBattleFieldScore
