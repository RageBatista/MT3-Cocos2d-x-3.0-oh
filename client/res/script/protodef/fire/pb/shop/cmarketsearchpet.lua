require "utils.tableutil"
require "protodef.rpcgen.fire.pb.shop.marketsearchattr"
CMarketSearchPet = {}
CMarketSearchPet.__index = CMarketSearchPet



CMarketSearchPet.PROTOCOL_TYPE = 810662

function CMarketSearchPet.Create()
	print("enter CMarketSearchPet create")
	return CMarketSearchPet:new()
end
function CMarketSearchPet:new()
	local self = {}
	setmetatable(self, CMarketSearchPet)
	self.type = self.PROTOCOL_TYPE
	self.pettype = 0
	self.levelmin = 0
	self.levelmax = 0
	self.pricemin = 0
	self.pricemax = 0
	self.zizhi = {}
	self.skills = {}
	self.totalskillnum = 0
	self.attr = {}
	self.score = 0
	self.sellstate = 0

	return self
end
function CMarketSearchPet:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CMarketSearchPet:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.pettype)
	_os_:marshal_int32(self.levelmin)
	_os_:marshal_int32(self.levelmax)
	_os_:marshal_int32(self.pricemin)
	_os_:marshal_int32(self.pricemax)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.zizhi))
	for k,v in ipairs(self.zizhi) do
		----------------marshal bean
		v:marshal(_os_) 
	end


	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.skills))
	for k,v in ipairs(self.skills) do
		_os_:marshal_int32(v)
	end

	_os_:marshal_int32(self.totalskillnum)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.attr))
	for k,v in ipairs(self.attr) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	_os_:marshal_int32(self.score)
	_os_:marshal_int32(self.sellstate)
	return _os_
end

function CMarketSearchPet:unmarshal(_os_)
	self.pettype = _os_:unmarshal_int32()
	self.levelmin = _os_:unmarshal_int32()
	self.levelmax = _os_:unmarshal_int32()
	self.pricemin = _os_:unmarshal_int32()
	self.pricemax = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_zizhi=0,_os_null_zizhi
	_os_null_zizhi, sizeof_zizhi = _os_: uncompact_uint32(sizeof_zizhi)
	for k = 1,sizeof_zizhi do
		----------------unmarshal bean
		self.zizhi[k]=MarketSearchAttr:new()

		self.zizhi[k]:unmarshal(_os_)

	end
	----------------unmarshal vector
	local sizeof_skills=0,_os_null_skills
	_os_null_skills, sizeof_skills = _os_: uncompact_uint32(sizeof_skills)
	for k = 1,sizeof_skills do
		self.skills[k] = _os_:unmarshal_int32()
	end
	self.totalskillnum = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_attr=0,_os_null_attr
	_os_null_attr, sizeof_attr = _os_: uncompact_uint32(sizeof_attr)
	for k = 1,sizeof_attr do
		----------------unmarshal bean
		self.attr[k]=MarketSearchAttr:new()

		self.attr[k]:unmarshal(_os_)

	end
	self.score = _os_:unmarshal_int32()
	self.sellstate = _os_:unmarshal_int32()
	return _os_
end

return CMarketSearchPet
