require "utils.tableutil"
SGetSysConfig = {}
SGetSysConfig.__index = SGetSysConfig



SGetSysConfig.PROTOCOL_TYPE = 786527

function SGetSysConfig.Create()
	print("enter SGetSysConfig create")
	return SGetSysConfig:new()
end
function SGetSysConfig:new()
	local self = {}
	setmetatable(self, SGetSysConfig)
	self.type = self.PROTOCOL_TYPE
	self.sysconfigmap = {}

	return self
end
function SGetSysConfig:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGetSysConfig:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.sysconfigmap))
	for k,v in pairs(self.sysconfigmap) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end

	return _os_
end

function SGetSysConfig:unmarshal(_os_)
	----------------unmarshal map
	local sizeof_sysconfigmap=0,_os_null_sysconfigmap
	_os_null_sysconfigmap, sizeof_sysconfigmap = _os_: uncompact_uint32(sizeof_sysconfigmap)
	for k = 1,sizeof_sysconfigmap do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.sysconfigmap[newkey] = newvalue
	end
	return _os_
end

return SGetSysConfig
