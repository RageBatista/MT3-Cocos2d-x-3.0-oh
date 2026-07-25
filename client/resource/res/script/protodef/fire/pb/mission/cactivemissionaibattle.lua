require "utils.tableutil"
CActiveMissionAIBattle = {}
CActiveMissionAIBattle.__index = CActiveMissionAIBattle



CActiveMissionAIBattle.PROTOCOL_TYPE = 805452

function CActiveMissionAIBattle.Create()
	print("enter CActiveMissionAIBattle create")
	return CActiveMissionAIBattle:new()
end
function CActiveMissionAIBattle:new()
	local self = {}
	setmetatable(self, CActiveMissionAIBattle)
	self.type = self.PROTOCOL_TYPE
	self.missionid = 0
	self.npckey = 0
	self.activetype = 0

	return self
end
function CActiveMissionAIBattle:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CActiveMissionAIBattle:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.missionid)
	_os_:marshal_int64(self.npckey)
	_os_:marshal_int32(self.activetype)
	return _os_
end

function CActiveMissionAIBattle:unmarshal(_os_)
	self.missionid = _os_:unmarshal_int32()
	self.npckey = _os_:unmarshal_int64()
	self.activetype = _os_:unmarshal_int32()
	return _os_
end

return CActiveMissionAIBattle
