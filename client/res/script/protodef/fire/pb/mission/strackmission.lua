require "utils.tableutil"
STrackMission = {}
STrackMission.__index = STrackMission



STrackMission.PROTOCOL_TYPE = 805451

function STrackMission.Create()
	print("enter STrackMission create")
	return STrackMission:new()
end
function STrackMission:new()
	local self = {}
	setmetatable(self, STrackMission)
	self.type = self.PROTOCOL_TYPE
	self.missionid = 0
	self.track = 0

	return self
end
function STrackMission:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function STrackMission:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.missionid)
	_os_:marshal_int32(self.track)
	return _os_
end

function STrackMission:unmarshal(_os_)
	self.missionid = _os_:unmarshal_int32()
	self.track = _os_:unmarshal_int32()
	return _os_
end

return STrackMission
