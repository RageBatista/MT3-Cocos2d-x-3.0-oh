require "utils.tableutil"
SCleanTempPack = {}
SCleanTempPack.__index = SCleanTempPack



SCleanTempPack.PROTOCOL_TYPE = 787473

function SCleanTempPack.Create()
	print("enter SCleanTempPack create")
	return SCleanTempPack:new()
end
function SCleanTempPack:new()
	local self = {}
	setmetatable(self, SCleanTempPack)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SCleanTempPack:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SCleanTempPack:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SCleanTempPack:unmarshal(_os_)
	return _os_
end

return SCleanTempPack
