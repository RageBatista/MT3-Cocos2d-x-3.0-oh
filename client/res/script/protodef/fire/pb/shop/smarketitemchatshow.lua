require "utils.tableutil"
require "protodef.rpcgen.fire.pb.shop.marketgoods"
SMarketItemChatShow = {}
SMarketItemChatShow.__index = SMarketItemChatShow



SMarketItemChatShow.PROTOCOL_TYPE = 810666

function SMarketItemChatShow.Create()
	print("enter SMarketItemChatShow create")
	return SMarketItemChatShow:new()
end
function SMarketItemChatShow:new()
	local self = {}
	setmetatable(self, SMarketItemChatShow)
	self.type = self.PROTOCOL_TYPE
	self.browsetype = 0
	self.firstno = 0
	self.twono = 0
	self.threeno = {}
	self.id = 0
	self.currpage = 0
	self.totalpage = 0
	self.goodslist = {}

	return self
end
function SMarketItemChatShow:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SMarketItemChatShow:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.browsetype)
	_os_:marshal_int32(self.firstno)
	_os_:marshal_int32(self.twono)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.threeno))
	for k,v in ipairs(self.threeno) do
		_os_:marshal_int32(v)
	end

	_os_:marshal_int64(self.id)
	_os_:marshal_int32(self.currpage)
	_os_:marshal_int32(self.totalpage)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.goodslist))
	for k,v in ipairs(self.goodslist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SMarketItemChatShow:unmarshal(_os_)
	self.browsetype = _os_:unmarshal_int32()
	self.firstno = _os_:unmarshal_int32()
	self.twono = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_threeno=0,_os_null_threeno
	_os_null_threeno, sizeof_threeno = _os_: uncompact_uint32(sizeof_threeno)
	for k = 1,sizeof_threeno do
		self.threeno[k] = _os_:unmarshal_int32()
	end
	self.id = _os_:unmarshal_int64()
	self.currpage = _os_:unmarshal_int32()
	self.totalpage = _os_:unmarshal_int32()
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

return SMarketItemChatShow
