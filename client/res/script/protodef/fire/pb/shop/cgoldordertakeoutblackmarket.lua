require "utils.tableutil"
CGoldOrderTakeOutBlackMarket = {}
CGoldOrderTakeOutBlackMarket.__index = CGoldOrderTakeOutBlackMarket



CGoldOrderTakeOutBlackMarket.PROTOCOL_TYPE = 810672

function CGoldOrderTakeOutBlackMarket.Create()
	print("enter CGoldOrderTakeOutBlackMarket create")
	return CGoldOrderTakeOutBlackMarket:new()
end
function CGoldOrderTakeOutBlackMarket:new()
	local self = {}
	setmetatable(self, CGoldOrderTakeOutBlackMarket)
	self.type = self.PROTOCOL_TYPE
	self.pid = 0

	return self
end
function CGoldOrderTakeOutBlackMarket:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGoldOrderTakeOutBlackMarket:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.pid)
	return _os_
end

function CGoldOrderTakeOutBlackMarket:unmarshal(_os_)
	self.pid = _os_:unmarshal_int64()
	return _os_
end

return CGoldOrderTakeOutBlackMarket
