require "utils.tableutil"
CBlackMarketDown = {}
CBlackMarketDown.__index = CBlackMarketDown



CBlackMarketDown.PROTOCOL_TYPE = 800310

function CBlackMarketDown.Create()
	print("enter CBlackMarketDown create")
	return CBlackMarketDown:new()
end
function CBlackMarketDown:new()
	local self = {}
	setmetatable(self, CBlackMarketDown)
	self.type = self.PROTOCOL_TYPE
	self.id = 0
	return self
end
function CBlackMarketDown:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CBlackMarketDown:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.id)
	return _os_
end

function CBlackMarketDown:unmarshal(_os_)
	self.id = _os_:unmarshal_int32()
	return _os_
end

return CBlackMarketDown
