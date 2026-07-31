require "utils.tableutil"
require "protodef.rpcgen.fire.pb.shop.goldorder"
SGoldOrderBrowseBlackMarket = {}
SGoldOrderBrowseBlackMarket.__index = SGoldOrderBrowseBlackMarket



SGoldOrderBrowseBlackMarket.PROTOCOL_TYPE = 810674

function SGoldOrderBrowseBlackMarket.Create()
	print("enter SGoldOrderBrowseBlackMarket create")
	return SGoldOrderBrowseBlackMarket:new()
end
function SGoldOrderBrowseBlackMarket:new()
	local self = {}
	setmetatable(self, SGoldOrderBrowseBlackMarket)
	self.type = self.PROTOCOL_TYPE
	self.salelist = {}
	self.buylist = {}

	return self
end
function SGoldOrderBrowseBlackMarket:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGoldOrderBrowseBlackMarket:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.salelist))
	for k,v in ipairs(self.salelist) do
		----------------marshal bean
		v:marshal(_os_) 
	end


	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.buylist))
	for k,v in ipairs(self.buylist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SGoldOrderBrowseBlackMarket:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_salelist=0,_os_null_salelist
	_os_null_salelist, sizeof_salelist = _os_: uncompact_uint32(sizeof_salelist)
	for k = 1,sizeof_salelist do
		----------------unmarshal bean
		self.salelist[k]=GoldOrder:new()

		self.salelist[k]:unmarshal(_os_)

	end
	----------------unmarshal vector
	local sizeof_buylist=0,_os_null_buylist
	_os_null_buylist, sizeof_buylist = _os_: uncompact_uint32(sizeof_buylist)
	for k = 1,sizeof_buylist do
		----------------unmarshal bean
		self.buylist[k]=GoldOrder:new()

		self.buylist[k]:unmarshal(_os_)

	end
	return _os_
end

return SGoldOrderBrowseBlackMarket
