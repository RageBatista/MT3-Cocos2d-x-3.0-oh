require "utils.tableutil"
require "protodef.fire.pb.shop.blackmarketgoods"
SBlackMarketItemBrowse = {}
SBlackMarketItemBrowse.__index = SBlackMarketItemBrowse

SBlackMarketItemBrowse.PROTOCOL_TYPE = 800312

function SBlackMarketItemBrowse.Create()
	print("enter SBlackMarketItemBrowse create")
	return SBlackMarketItemBrowse:new()
end
function SBlackMarketItemBrowse:new()
	local self = {}
	setmetatable(self, SBlackMarketItemBrowse)
	self.type = self.PROTOCOL_TYPE
	self.itemlist = {}
	self.total=0
    self.hasmore=0
	self.itemtype=0
	self.reload=0
	return self
end
function SBlackMarketItemBrowse:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SBlackMarketItemBrowse:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.itemlist))
	for k,v in ipairs(self.itemlist) do
		----------------marshal bean
		v:marshal(_os_) 
	end
    _os_:marshal_int32(self.total)
    _os_:marshal_int32(self.hasmore)
    _os_:marshal_int32(self.itemtype)
    _os_:marshal_int32(self.reload)

	return _os_
end

function SBlackMarketItemBrowse:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_salelist=0,_os_null_salelist
	_os_null_salelist, sizeof_salelist = _os_: uncompact_uint32(sizeof_salelist)
	for k = 1,sizeof_salelist do
		----------------unmarshal bean
		self.itemlist[k]=BlackMarketGoods:new()

		self.itemlist[k]:unmarshal(_os_)

	end
    self.total = _os_:unmarshal_int32()
    self.hasmore = _os_:unmarshal_int32()
    self.itemtype = _os_:unmarshal_int32()
    self.reload = _os_:unmarshal_int32()
	return _os_
end

return SBlackMarketItemBrowse
