require "utils.tableutil"
CTrackMission = {}
CTrackMission.__index = CTrackMission



CTrackMission.PROTOCOL_TYPE = 805450

function CTrackMission.Create()
	print("enter CTrackMission create")
	return CTrackMission:new()
end
function CTrackMission:new()
	local self = {}
	setmetatable(self, CTrackMission)
	self.type = self.PROTOCOL_TYPE
	self.missionid = 0
	self.track = 0

	return self
end
function CTrackMission:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CTrackMission:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.missionid)
	_os_:marshal_int32(self.track)
	return _os_
end

function CTrackMission:unmarshal(_os_)
	self.missionid = _os_:unmarshal_int32()
	self.track = _os_:unmarshal_int32()
	return _os_
end

return CTrackMission
