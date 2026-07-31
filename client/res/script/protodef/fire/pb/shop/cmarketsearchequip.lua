require "utils.tableutil"
require "protodef.rpcgen.fire.pb.shop.marketsearchattr"
CMarketSearchEquip = {}
CMarketSearchEquip.__index = CMarketSearchEquip



CMarketSearchEquip.PROTOCOL_TYPE = 810661

function CMarketSearchEquip.Create()
	print("enter CMarketSearchEquip create")
	return CMarketSearchEquip:new()
end
function CMarketSearchEquip:new()
	local self = {}
	setmetatable(self, CMarketSearchEquip)
	self.type = self.PROTOCOL_TYPE
	self.euqiptype = 0
	self.level = 0
	self.pricemin = 0
	self.pricemax = 0
	self.effect = 0
	self.skill = 0
	self.color = {}
	self.basicattr = {}
	self.additionalattr = {}
	self.totalattr = 0
	self.score = 0
	self.sellstate = 0

	return self
end
function CMarketSearchEquip:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CMarketSearchEquip:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.euqiptype)
	_os_:marshal_int32(self.level)
	_os_:marshal_int32(self.pricemin)
	_os_:marshal_int32(self.pricemax)
	_os_:marshal_int32(self.effect)
	_os_:marshal_int32(self.skill)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.color))
	for k,v in ipairs(self.color) do
		_os_:marshal_int32(v)
	end


	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.basicattr))
	for k,v in ipairs(self.basicattr) do
		----------------marshal bean
		v:marshal(_os_) 
	end


	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.additionalattr))
	for k,v in ipairs(self.additionalattr) do
		_os_:marshal_int32(v)
	end

	_os_:marshal_int32(self.totalattr)
	_os_:marshal_int32(self.score)
	_os_:marshal_int32(self.sellstate)
	return _os_
end

function CMarketSearchEquip:unmarshal(_os_)
	self.euqiptype = _os_:unmarshal_int32()
	self.level = _os_:unmarshal_int32()
	self.pricemin = _os_:unmarshal_int32()
	self.pricemax = _os_:unmarshal_int32()
	self.effect = _os_:unmarshal_int32()
	self.skill = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_color=0,_os_null_color
	_os_null_color, sizeof_color = _os_: uncompact_uint32(sizeof_color)
	for k = 1,sizeof_color do
		self.color[k] = _os_:unmarshal_int32()
	end
	----------------unmarshal vector
	local sizeof_basicattr=0,_os_null_basicattr
	_os_null_basicattr, sizeof_basicattr = _os_: uncompact_uint32(sizeof_basicattr)
	for k = 1,sizeof_basicattr do
		----------------unmarshal bean
		self.basicattr[k]=MarketSearchAttr:new()

		self.basicattr[k]:unmarshal(_os_)

	end
	----------------unmarshal vector
	local sizeof_additionalattr=0,_os_null_additionalattr
	_os_null_additionalattr, sizeof_additionalattr = _os_: uncompact_uint32(sizeof_additionalattr)
	for k = 1,sizeof_additionalattr do
		self.additionalattr[k] = _os_:unmarshal_int32()
	end
	self.totalattr = _os_:unmarshal_int32()
	self.score = _os_:unmarshal_int32()
	self.sellstate = _os_:unmarshal_int32()
	return _os_
end

return CMarketSearchEquip
