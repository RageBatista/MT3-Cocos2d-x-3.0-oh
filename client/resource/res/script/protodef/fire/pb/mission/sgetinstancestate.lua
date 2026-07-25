require "utils.tableutil"
require "protodef.rpcgen.fire.pb.mission.instanceinfo"
SGetInstanceState = {}
SGetInstanceState.__index = SGetInstanceState



SGetInstanceState.PROTOCOL_TYPE = 805473

function SGetInstanceState.Create()
	print("enter SGetInstanceState create")
	return SGetInstanceState:new()
end
function SGetInstanceState:new()
	local self = {}
	setmetatable(self, SGetInstanceState)
	self.type = self.PROTOCOL_TYPE
	self.instances = {}

	return self
end
function SGetInstanceState:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGetInstanceState:marshal(ostream)
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

function SGetInstanceState:unmarshal(_os_)
	----------------unmarshal map
	local sizeof_instances=0,_os_null_instances
	_os_null_instances, sizeof_instances = _os_: uncompact_uint32(sizeof_instances)
	for k = 1,sizeof_instances do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		----------------unmarshal bean
		newvalue=InstanceInfo:new()

		newvalue:unmarshal(_os_)

		self.instances[newkey] = newvalue
	end
	return _os_
end

return SGetInstanceState
