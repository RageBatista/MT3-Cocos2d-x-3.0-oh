require "utils.tableutil"
require "protodef.fire.pb.shop.blackmarketgoods"
SBlackMarketContainerBrowse = {}
SBlackMarketContainerBrowse.__index = SBlackMarketContainerBrowse



SBlackMarketContainerBrowse.PROTOCOL_TYPE = 800309

function SBlackMarketContainerBrowse.Create()
	print("enter SBlackMarketContainerBrowse create")
	return SBlackMarketContainerBrowse:new()
end
function SBlackMarketContainerBrowse:new()
	local self = {}
	setmetatable(self, SBlackMarketContainerBrowse)
	self.type = self.PROTOCOL_TYPE
	self.actiontype = 0
	self.goodslist = {}

	return self
end
function SBlackMarketContainerBrowse:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SBlackMarketContainerBrowse:marshal(ostream)
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

function SBlackMarketContainerBrowse:unmarshal(_os_)
	self.actiontype = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_goodslist=0,_os_null_goodslist
	_os_null_goodslist, sizeof_goodslist = _os_: uncompact_uint32(sizeof_goodslist)
	for k = 1,sizeof_goodslist do
		----------------unmarshal bean
		self.goodslist[k]=BlackMarketGoods:new()

		self.goodslist[k]:unmarshal(_os_)

	end
	return _os_
end

return SBlackMarketContainerBrowse
