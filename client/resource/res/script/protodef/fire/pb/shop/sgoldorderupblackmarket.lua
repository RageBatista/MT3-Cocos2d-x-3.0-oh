require "utils.tableutil"
require "protodef.rpcgen.fire.pb.shop.goldorder"
SGoldOrderUpBlackMarket = {}
SGoldOrderUpBlackMarket.__index = SGoldOrderUpBlackMarket



SGoldOrderUpBlackMarket.PROTOCOL_TYPE = 810675

function SGoldOrderUpBlackMarket.Create()
	print("enter SGoldOrderUpBlackMarket create")
	return SGoldOrderUpBlackMarket:new()
end
function SGoldOrderUpBlackMarket:new()
	local self = {}
	setmetatable(self, SGoldOrderUpBlackMarket)
	self.type = self.PROTOCOL_TYPE
	self.order = GoldOrder:new()

	return self
end
function SGoldOrderUpBlackMarket:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGoldOrderUpBlackMarket:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.order:marshal(_os_) 
	return _os_
end

function SGoldOrderUpBlackMarket:unmarshal(_os_)
	----------------unmarshal bean

	self.order:unmarshal(_os_)

	return _os_
end

return SGoldOrderUpBlackMarket
