require "utils.tableutil"
CReqBattleFlag = {}
CReqBattleFlag.__index = CReqBattleFlag



CReqBattleFlag.PROTOCOL_TYPE = 793883

function CReqBattleFlag.Create()
	print("enter CReqBattleFlag create")
	return CReqBattleFlag:new()
end
function CReqBattleFlag:new()
	local self = {}
	setmetatable(self, CReqBattleFlag)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CReqBattleFlag:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReqBattleFlag:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CReqBattleFlag:unmarshal(_os_)
	return _os_
end

return CReqBattleFlag
