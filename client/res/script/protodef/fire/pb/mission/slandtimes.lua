require "utils.tableutil"
require "protodef.rpcgen.fire.pb.mission.instancetimes"
SLandTimes = {}
SLandTimes.__index = SLandTimes



SLandTimes.PROTOCOL_TYPE = 805470

function SLandTimes.Create()
	print("enter SLandTimes create")
	return SLandTimes:new()
end
function SLandTimes:new()
	local self = {}
	setmetatable(self, SLandTimes)
	self.type = self.PROTOCOL_TYPE
	self.instances = {}

	return self
end
function SLandTimes:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SLandTimes:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.instances))
	for k,v in pairs(self.instances) do
		_os_:marshal_int32(k)
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SLandTimes:unmarshal(_os_)
	----------------unmarshal map
	local sizeof_instances=0,_os_null_instances
	_os_null_instances, sizeof_instances = _os_: uncompact_uint32(sizeof_instances)
	for k = 1,sizeof_instances do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		----------------unmarshal bean
		newvalue=InstanceTimes:new()

		newvalue:unmarshal(_os_)

		self.instances[newkey] = newvalue
	end
	return _os_
end

return SLandTimes
