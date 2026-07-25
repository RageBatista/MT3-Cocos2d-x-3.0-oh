require "utils.tableutil"
require "protodef.rpcgen.fire.pb.mission.trackedmission"
STrackedMissions = {}
STrackedMissions.__index = STrackedMissions



STrackedMissions.PROTOCOL_TYPE = 805461

function STrackedMissions.Create()
	print("enter STrackedMissions create")
	return STrackedMissions:new()
end
function STrackedMissions:new()
	local self = {}
	setmetatable(self, STrackedMissions)
	self.type = self.PROTOCOL_TYPE
	self.trackedmissions = {}

	return self
end
function STrackedMissions:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function STrackedMissions:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.trackedmissions))
	for k,v in pairs(self.trackedmissions) do
		_os_:marshal_int32(k)
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function STrackedMissions:unmarshal(_os_)
	----------------unmarshal map
	local sizeof_trackedmissions=0,_os_null_trackedmissions
	_os_null_trackedmissions, sizeof_trackedmissions = _os_: uncompact_uint32(sizeof_trackedmissions)
	for k = 1,sizeof_trackedmissions do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		----------------unmarshal bean
		newvalue=TrackedMission:new()

		newvalue:unmarshal(_os_)

		self.trackedmissions[newkey] = newvalue
	end
	return _os_
end

return STrackedMissions
