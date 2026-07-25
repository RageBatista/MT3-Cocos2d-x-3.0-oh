require "utils.tableutil"
CGetMarketUpPrice = {}
CGetMarketUpPrice.__index = CGetMarketUpPrice



CGetMarketUpPrice.PROTOCOL_TYPE = 810651

function CGetMarketUpPrice.Create()
	print("enter CGetMarketUpPrice create")
	return CGetMarketUpPrice:new()
end
function CGetMarketUpPrice:new()
	local self = {}
	setmetatable(self, CGetMarketUpPrice)
	self.type = self.PROTOCOL_TYPE
	self.containertype = 0
	self.key = 0

	return self
end
function CGetMarketUpPrice:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetMarketUpPrice:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.containertype)
	_os_:marshal_int32(self.key)
	return _os_
end

function CGetMarketUpPrice:unmarshal(_os_)
	self.containertype = _os_:unmarshal_int32()
	self.key = _os_:unmarshal_int32()
	return _os_
end

return CGetMarketUpPrice
