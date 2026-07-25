require "utils.tableutil"
SOpenPack = {}
SOpenPack.__index = SOpenPack



SOpenPack.PROTOCOL_TYPE = 787739

function SOpenPack.Create()
	print("enter SOpenPack create")
	return SOpenPack:new()
end
function SOpenPack:new()
	local self = {}
	setmetatable(self, SOpenPack)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SOpenPack:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SOpenPack:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SOpenPack:unmarshal(_os_)
	return _os_
end

return SOpenPack
