require "utils.tableutil"
require "protodef.rpcgen.fire.pb.shop.marketgoods"
SMarketBrowse = {}
SMarketBrowse.__index = SMarketBrowse



SMarketBrowse.PROTOCOL_TYPE = 810640

function SMarketBrowse.Create()
	print("enter SMarketBrowse create")
	return SMarketBrowse:new()
end
function SMarketBrowse:new()
	local self = {}
	setmetatable(self, SMarketBrowse)
	self.type = self.PROTOCOL_TYPE
	self.browsetype = 0
	self.firstno = 0
	self.twono = 0
	self.threeno = {}
	self.itemtype = 0
	self.limitmin = 0
	self.limitmax = 0
	self.currpage = 0
	self.totalpage = 0
	self.goodslist = {}
	self.pricesort = 0

	return self
end
function SMarketBrowse:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SMarketBrowse:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.browsetype)
	_os_:marshal_int32(self.firstno)
	_os_:marshal_int32(self.twono)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.threeno))
	for k,v in ipairs(self.threeno) do
		_os_:marshal_int32(v)
	end

	_os_:marshal_int32(self.itemtype)
	_os_:marshal_int32(self.limitmin)
	_os_:marshal_int32(self.limitmax)
	_os_:marshal_int32(self.currpage)
	_os_:marshal_int32(self.totalpage)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.goodslist))
	for k,v in ipairs(self.goodslist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	_os_:marshal_int32(self.pricesort)
	return _os_
end

function SMarketBrowse:unmarshal(_os_)
	self.browsetype = _os_:unmarshal_int32()
	self.firstno = _os_:unmarshal_int32()
	self.twono = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_threeno=0,_os_null_threeno
	_os_null_threeno, sizeof_threeno = _os_: uncompact_uint32(sizeof_threeno)
	for k = 1,sizeof_threeno do
		self.threeno[k] = _os_:unmarshal_int32()
	end
	self.itemtype = _os_:unmarshal_int32()
	self.limitmin = _os_:unmarshal_int32()
	self.limitmax = _os_:unmarshal_int32()
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
	self.pricesort = _os_:unmarshal_int32()
	return _os_
end

return SMarketBrowse
