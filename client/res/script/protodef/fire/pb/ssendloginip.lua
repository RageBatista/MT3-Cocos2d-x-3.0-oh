require "utils.tableutil"
SSendLoginIp = {}
SSendLoginIp.__index = SSendLoginIp



SSendLoginIp.PROTOCOL_TYPE = 786504

function SSendLoginIp.Create()
	print("enter SSendLoginIp create")
	return SSendLoginIp:new()
end
function SSendLoginIp:new()
	local self = {}
	setmetatable(self, SSendLoginIp)
	self.type = self.PROTOCOL_TYPE
	self.loginip = 0
	self.lastip = 0
	self.lasttime = 0

	return self
end
function SSendLoginIp:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSendLoginIp:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.loginip)
	_os_:marshal_int32(self.lastip)
	_os_:marshal_int64(self.lasttime)
	return _os_
end

function SSendLoginIp:unmarshal(_os_)
	self.loginip = _os_:unmarshal_int32()
	self.lastip = _os_:unmarshal_int32()
	self.lasttime = _os_:unmarshal_int64()
	return _os_
end

return SSendLoginIp
