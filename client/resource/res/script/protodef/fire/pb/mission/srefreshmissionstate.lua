require "utils.tableutil"
SRefreshMissionState = {}
SRefreshMissionState.__index = SRefreshMissionState



SRefreshMissionState.PROTOCOL_TYPE = 805447

function SRefreshMissionState.Create()
	print("enter SRefreshMissionState create")
	return SRefreshMissionState:new()
end
function SRefreshMissionState:new()
	local self = {}
	setmetatable(self, SRefreshMissionState)
	self.type = self.PROTOCOL_TYPE
	self.missionid = 0
	self.missionstatus = 0

	return self
end
function SRefreshMissionState:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRefreshMissionState:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.missionid)
	_os_:marshal_int32(self.missionstatus)
	return _os_
end

function SRefreshMissionState:unmarshal(_os_)
	self.missionid = _os_:unmarshal_int32()
	self.missionstatus = _os_:unmarshal_int32()
	return _os_
end

return SRefreshMissionState
