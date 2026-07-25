require "utils.tableutil"
CSetLineConfig = {}
CSetLineConfig.__index = CSetLineConfig



CSetLineConfig.PROTOCOL_TYPE = 786551

function CSetLineConfig.Create()
	print("enter CSetLineConfig create")
	return CSetLineConfig:new()
end
function CSetLineConfig:new()
	local self = {}
	setmetatable(self, CSetLineConfig)
	self.type = self.PROTOCOL_TYPE
	self.configmap = {}

	return self
end
function CSetLineConfig:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSetLineConfig:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.configmap))
	for k,v in pairs(self.configmap) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end

	return _os_
end

function CSetLineConfig:unmarshal(_os_)
	----------------unmarshal map
	local sizeof_configmap=0,_os_null_configmap
	_os_null_configmap, sizeof_configmap = _os_: uncompact_uint32(sizeof_configmap)
	for k = 1,sizeof_configmap do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.configmap[newkey] = newvalue
	end
	return _os_
end

return CSetLineConfig
