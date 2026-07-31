require "utils.tableutil"
require "protodef.rpcgen.fire.pb.shop.marketgoods"
SMarketContainerBrowse = {}
SMarketContainerBrowse.__index = SMarketContainerBrowse



SMarketContainerBrowse.PROTOCOL_TYPE = 810648

function SMarketContainerBrowse.Create()
	print("enter SMarketContainerBrowse create")
	return SMarketContainerBrowse:new()
end
function SMarketContainerBrowse:new()
	local self = {}
	setmetatable(self, SMarketContainerBrowse)
	self.type = self.PROTOCOL_TYPE
	self.actiontype = 0
	self.goodslist = {}

	return self
end
function SMarketContainerBrowse:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SMarketContainerBrowse:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.actiontype)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.goodslist))
	for k,v in ipairs(self.goodslist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SMarketContainerBrowse:unmarshal(_os_)
	self.actiontype = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_goodslist=0,_os_null_goodslist
	_os_null_goodslist, sizeof_goodslist = _os_: uncompact_uint32(sizeof_goodslist)
	for k = 1,sizeof_goodslist do
		----------------unmarshal bean
		self.goodslist[k]=MarketGoods:new()

		self.goodslist[k]:unmarshal(_os_)

	end
	return _os_
end

return SMarketContainerBrowse
