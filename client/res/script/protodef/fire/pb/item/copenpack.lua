require "utils.tableutil"
COpenPack = {}
COpenPack.__index = COpenPack



COpenPack.PROTOCOL_TYPE = 787738

function COpenPack.Create()
	print("enter COpenPack create")
	return COpenPack:new()
end
function COpenPack:new()
	local self = {}
	setmetatable(self, COpenPack)
	self.type = self.PROTOCOL_TYPE
	self.packid = 0

	return self
end
function COpenPack:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function COpenPack:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.packid)
	return _os_
end

function COpenPack:unmarshal(_os_)
	self.packid = _os_:unmarshal_int32()
	return _os_
end

return COpenPack
