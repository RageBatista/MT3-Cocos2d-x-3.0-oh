require "utils.tableutil"
require "protodef.rpcgen.fire.pb.shop.goods"
SResponseShopPrice = {}
SResponseShopPrice.__index = SResponseShopPrice



SResponseShopPrice.PROTOCOL_TYPE = 810636

function SResponseShopPrice.Create()
	print("enter SResponseShopPrice create")
	return SResponseShopPrice:new()
end
function SResponseShopPrice:new()
	local self = {}
	setmetatable(self, SResponseShopPrice)
	self.type = self.PROTOCOL_TYPE
	self.shopid = 0
	self.goodslist = {}

	return self
end
function SResponseShopPrice:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SResponseShopPrice:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.shopid)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.goodslist))
	for k,v in ipairs(self.goodslist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SResponseShopPrice:unmarshal(_os_)
	self.shopid = _os_:unmarshal_int64()
	----------------unmarshal vector
	local sizeof_goodslist=0,_os_null_goodslist
	_os_null_goodslist, sizeof_goodslist = _os_: uncompact_uint32(sizeof_goodslist)
	for k = 1,sizeof_goodslist do
		----------------unmarshal bean
		self.goodslist[k]=Goods:new()

		self.goodslist[k]:unmarshal(_os_)

	end
	return _os_
end

return SResponseShopPrice
