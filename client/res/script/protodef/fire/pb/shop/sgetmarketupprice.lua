require "utils.tableutil"
SGetMarketUpPrice = {}
SGetMarketUpPrice.__index = SGetMarketUpPrice



SGetMarketUpPrice.PROTOCOL_TYPE = 810652

function SGetMarketUpPrice.Create()
	print("enter SGetMarketUpPrice create")
	return SGetMarketUpPrice:new()
end
function SGetMarketUpPrice:new()
	local self = {}
	setmetatable(self, SGetMarketUpPrice)
	self.type = self.PROTOCOL_TYPE
	self.containertype = 0
	self.price = 0
	self.stallprice = 0
	self.recommendations = {}

	return self
end
function SGetMarketUpPrice:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGetMarketUpPrice:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.containertype)
	_os_:marshal_int32(self.price)
	_os_:marshal_int32(self.stallprice)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.recommendations))
	for k,v in ipairs(self.recommendations) do
		_os_:marshal_int32(v)
	end

	return _os_
end

function SGetMarketUpPrice:unmarshal(_os_)
	self.containertype = _os_:unmarshal_int32()
	self.price = _os_:unmarshal_int32()
	self.stallprice = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_recommendations=0,_os_null_recommendations
	_os_null_recommendations, sizeof_recommendations = _os_: uncompact_uint32(sizeof_recommendations)
	for k = 1,sizeof_recommendations do
		self.recommendations[k] = _os_:unmarshal_int32()
	end
	return _os_
end

return SGetMarketUpPrice
