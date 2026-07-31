require "utils.tableutil"
CMarketDown = {}
CMarketDown.__index = CMarketDown



CMarketDown.PROTOCOL_TYPE = 810644

function CMarketDown.Create()
	print("enter CMarketDown create")
	return CMarketDown:new()
end
function CMarketDown:new()
	local self = {}
	setmetatable(self, CMarketDown)
	self.type = self.PROTOCOL_TYPE
	self.downtype = 0
	self.key = 0

	return self
end
function CMarketDown:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CMarketDown:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.downtype)
	_os_:marshal_int32(self.key)
	return _os_
end

function CMarketDown:unmarshal(_os_)
	self.downtype = _os_:unmarshal_int32()
	self.key = _os_:unmarshal_int32()
	return _os_
end

return CMarketDown
