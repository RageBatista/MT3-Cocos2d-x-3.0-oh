require "utils.tableutil"
SChangeBaseConfig = {}
SChangeBaseConfig.__index = SChangeBaseConfig



SChangeBaseConfig.PROTOCOL_TYPE = 806442

function SChangeBaseConfig.Create()
	print("enter SChangeBaseConfig create")
	return SChangeBaseConfig:new()
end
function SChangeBaseConfig:new()
	local self = {}
	setmetatable(self, SChangeBaseConfig)
	self.type = self.PROTOCOL_TYPE
	self.refusestrangermsg = 0

	return self
end
function SChangeBaseConfig:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SChangeBaseConfig:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.refusestrangermsg)
	return _os_
end

function SChangeBaseConfig:unmarshal(_os_)
	self.refusestrangermsg = _os_:unmarshal_int32()
	return _os_
end

return SChangeBaseConfig
