require "utils.tableutil"
CRequstShopPrice = {}
CRequstShopPrice.__index = CRequstShopPrice



CRequstShopPrice.PROTOCOL_TYPE = 810635

function CRequstShopPrice.Create()
	print("enter CRequstShopPrice create")
	return CRequstShopPrice:new()
end
function CRequstShopPrice:new()
	local self = {}
	setmetatable(self, CRequstShopPrice)
	self.type = self.PROTOCOL_TYPE
	self.shopid = 0

	return self
end
function CRequstShopPrice:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequstShopPrice:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.shopid)
	return _os_
end

function CRequstShopPrice:unmarshal(_os_)
	self.shopid = _os_:unmarshal_int32()
	return _os_
end

return CRequstShopPrice
