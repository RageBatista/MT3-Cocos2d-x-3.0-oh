require "utils.tableutil"
CGoldOrderUpBlackMarket = {}
CGoldOrderUpBlackMarket.__index = CGoldOrderUpBlackMarket



CGoldOrderUpBlackMarket.PROTOCOL_TYPE = 810670

function CGoldOrderUpBlackMarket.Create()
	print("enter CGoldOrderUpBlackMarket create")
	return CGoldOrderUpBlackMarket:new()
end
function CGoldOrderUpBlackMarket:new()
	local self = {}
	setmetatable(self, CGoldOrderUpBlackMarket)
	self.type = self.PROTOCOL_TYPE
	self.goldnumber = 0
	self.rmb = 0

	return self
end
function CGoldOrderUpBlackMarket:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGoldOrderUpBlackMarket:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.goldnumber)
	_os_:marshal_int64(self.rmb)
	return _os_
end

function CGoldOrderUpBlackMarket:unmarshal(_os_)
	self.goldnumber = _os_:unmarshal_int64()
	self.rmb = _os_:unmarshal_int64()
	return _os_
end

return CGoldOrderUpBlackMarket
