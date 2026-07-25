require "utils.tableutil"
CExchangeShop = {}
CExchangeShop.__index = CExchangeShop



CExchangeShop.PROTOCOL_TYPE = 810655

function CExchangeShop.Create()
	print("enter CExchangeShop create")
	return CExchangeShop:new()
end
function CExchangeShop:new()
	local self = {}
	setmetatable(self, CExchangeShop)
	self.type = self.PROTOCOL_TYPE
	self.shopid = 0
	self.goodsid = 0
	self.num = 0
	self.buytype = 0

	return self
end
function CExchangeShop:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CExchangeShop:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.shopid)
	_os_:marshal_int32(self.goodsid)
	_os_:marshal_int32(self.num)
	_os_:marshal_int32(self.buytype)
	return _os_
end

function CExchangeShop:unmarshal(_os_)
	self.shopid = _os_:unmarshal_int32()
	self.goodsid = _os_:unmarshal_int32()
	self.num = _os_:unmarshal_int32()
	self.buytype = _os_:unmarshal_int32()
	return _os_
end

return CExchangeShop
