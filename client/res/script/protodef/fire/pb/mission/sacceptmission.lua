require "utils.tableutil"
require "protodef.rpcgen.fire.pb.mission.missioninfo"
SAcceptMission = {}
SAcceptMission.__index = SAcceptMission



SAcceptMission.PROTOCOL_TYPE = 805445

function SAcceptMission.Create()
	print("enter SAcceptMission create")
	return SAcceptMission:new()
end
function SAcceptMission:new()
	local self = {}
	setmetatable(self, SAcceptMission)
	self.type = self.PROTOCOL_TYPE
	self.missioninfo = MissionInfo:new()

	return self
end
function SAcceptMission:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SAcceptMission:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.missioninfo:marshal(_os_) 
	return _os_
end

function SAcceptMission:unmarshal(_os_)
	----------------unmarshal bean

	self.missioninfo:unmarshal(_os_)

	return _os_
end

return SAcceptMission
