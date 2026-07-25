require "utils.tableutil"
SPayServerType = {}
SPayServerType.__index = SPayServerType



SPayServerType.PROTOCOL_TYPE = 812592

function SPayServerType.Create()
	print("enter SPayServerType create")
	return SPayServerType:new()
end
function SPayServerType:new()
	local self = {}
	setmetatable(self, SPayServerType)
	self.type = self.PROTOCOL_TYPE
	self.paytype = 0
	self.opendy = 0

	return self
end
function SPayServerType:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SPayServerType:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.paytype)
	_os_:marshal_int32(self.opendy)
	return _os_
end

function SPayServerType:unmarshal(_os_)
	self.paytype = _os_:unmarshal_int32()
	self.opendy = _os_:unmarshal_int32()
	return _os_
end

return SPayServerType
