require "utils.tableutil"
require "protodef.rpcgen.fire.pb.fushi.goodinfo"
SReqCharge = {}
SReqCharge.__index = SReqCharge



SReqCharge.PROTOCOL_TYPE = 812455

function SReqCharge.Create()
	print("enter SReqCharge create")
	return SReqCharge:new()
end
function SReqCharge:new()
	local self = {}
	setmetatable(self, SReqCharge)
	self.type = self.PROTOCOL_TYPE
	self.goods = {}
	self.opendy = 0

	return self
end
function SReqCharge:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SReqCharge:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.goods))
	for k,v in ipairs(self.goods) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	_os_:marshal_int32(self.opendy)
	return _os_
end

function SReqCharge:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_goods=0,_os_null_goods
	_os_null_goods, sizeof_goods = _os_: uncompact_uint32(sizeof_goods)
	for k = 1,sizeof_goods do
		----------------unmarshal bean
		self.goods[k]=GoodInfo:new()

		self.goods[k]:unmarshal(_os_)

	end
	self.opendy = _os_:unmarshal_int32()
	return _os_
end

return SReqCharge
