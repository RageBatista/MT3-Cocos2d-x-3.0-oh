require "utils.tableutil"
CChangeBaseConfig = {}
CChangeBaseConfig.__index = CChangeBaseConfig



CChangeBaseConfig.PROTOCOL_TYPE = 806441

function CChangeBaseConfig.Create()
	print("enter CChangeBaseConfig create")
	return CChangeBaseConfig:new()
end
function CChangeBaseConfig:new()
	local self = {}
	setmetatable(self, CChangeBaseConfig)
	self.type = self.PROTOCOL_TYPE
	self.refusestrangermsg = 0

	return self
end
function CChangeBaseConfig:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CChangeBaseConfig:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.refusestrangermsg)
	return _os_
end

function CChangeBaseConfig:unmarshal(_os_)
	self.refusestrangermsg = _os_:unmarshal_char()
	return _os_
end

return CChangeBaseConfig
