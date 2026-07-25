require "utils.tableutil"
CCommitMission = {}
CCommitMission.__index = CCommitMission



CCommitMission.PROTOCOL_TYPE = 805444

function CCommitMission.Create()
	print("enter CCommitMission create")
	return CCommitMission:new()
end
function CCommitMission:new()
	local self = {}
	setmetatable(self, CCommitMission)
	self.type = self.PROTOCOL_TYPE
	self.missionid = 0
	self.npckey = 0
	self.option = 0

	return self
end
function CCommitMission:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CCommitMission:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.missionid)
	_os_:marshal_int64(self.npckey)
	_os_:marshal_int32(self.option)
	return _os_
end

function CCommitMission:unmarshal(_os_)
	self.missionid = _os_:unmarshal_int32()
	self.npckey = _os_:unmarshal_int64()
	self.option = _os_:unmarshal_int32()
	return _os_
end

return CCommitMission
