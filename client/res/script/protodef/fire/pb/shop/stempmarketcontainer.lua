require "utils.tableutil"
require "protodef.rpcgen.fire.pb.shop.tempmarketcontainergoods"
STempMarketContainer = {}
STempMarketContainer.__index = STempMarketContainer



STempMarketContainer.PROTOCOL_TYPE = 810667

function STempMarketContainer.Create()
	print("enter STempMarketContainer create")
	return STempMarketContainer:new()
end
function STempMarketContainer:new()
	local self = {}
	setmetatable(self, STempMarketContainer)
	self.type = self.PROTOCOL_TYPE
	self.goodslist = {}

	return self
end
function STempMarketContainer:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function STempMarketContainer:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.goodslist))
	for k,v in ipairs(self.goodslist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function STempMarketContainer:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_goodslist=0,_os_null_goodslist
	_os_null_goodslist, sizeof_goodslist = _os_: uncompact_uint32(sizeof_goodslist)
	for k = 1,sizeof_goodslist do
		----------------unmarshal bean
		self.goodslist[k]=TempMarketContainerGoods:new()

		self.goodslist[k]:unmarshal(_os_)

	end
	return _os_
end

return STempMarketContainer
