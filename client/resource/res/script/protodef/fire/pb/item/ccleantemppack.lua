require "utils.tableutil"
CCleanTempPack = {}
CCleanTempPack.__index = CCleanTempPack



CCleanTempPack.PROTOCOL_TYPE = 787472

function CCleanTempPack.Create()
	print("enter CCleanTempPack create")
	return CCleanTempPack:new()
end
function CCleanTempPack:new()
	local self = {}
	setmetatable(self, CCleanTempPack)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CCleanTempPack:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CCleanTempPack:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CCleanTempPack:unmarshal(_os_)
	return _os_
end

return CCleanTempPack
