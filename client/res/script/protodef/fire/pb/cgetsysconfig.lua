require "utils.tableutil"
CGetSysConfig = {}
CGetSysConfig.__index = CGetSysConfig



CGetSysConfig.PROTOCOL_TYPE = 786526

function CGetSysConfig.Create()
	print("enter CGetSysConfig create")
	return CGetSysConfig:new()
end
function CGetSysConfig:new()
	local self = {}
	setmetatable(self, CGetSysConfig)
	self.type = self.PROTOCOL_TYPE
	self.sysconfigmap = {}

	return self
end
function CGetSysConfig:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetSysConfig:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.sysconfigmap))
	for k,v in pairs(self.sysconfigmap) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end

	return _os_
end

function CGetSysConfig:unmarshal(_os_)
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

return CGetSysConfig
