require "utils.tableutil"
SSendRedPack = {}
SSendRedPack.__index = SSendRedPack



SSendRedPack.PROTOCOL_TYPE = 812535

function SSendRedPack.Create()
	print("enter SSendRedPack create")
	return SSendRedPack:new()
end
function SSendRedPack:new()
	local self = {}
	setmetatable(self, SSendRedPack)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SSendRedPack:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSendRedPack:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SSendRedPack:unmarshal(_os_)
	return _os_
end

return SSendRedPack
