require "utils.tableutil"
SRefreshMissionValue = {}
SRefreshMissionValue.__index = SRefreshMissionValue



SRefreshMissionValue.PROTOCOL_TYPE = 805449

function SRefreshMissionValue.Create()
	print("enter SRefreshMissionValue create")
	return SRefreshMissionValue:new()
end
function SRefreshMissionValue:new()
	local self = {}
	setmetatable(self, SRefreshMissionValue)
	self.type = self.PROTOCOL_TYPE
	self.missionid = 0
	self.missionidvalue = 0
	self.missionidround = 0

	return self
end
function SRefreshMissionValue:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRefreshMissionValue:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.missionid)
	_os_:marshal_int32(self.missionidvalue)
	_os_:marshal_int32(self.missionidround)
	return _os_
end

function SRefreshMissionValue:unmarshal(_os_)
	self.missionid = _os_:unmarshal_int32()
	self.missionidvalue = _os_:unmarshal_int32()
	self.missionidround = _os_:unmarshal_int32()
	return _os_
end

return SRefreshMissionValue
