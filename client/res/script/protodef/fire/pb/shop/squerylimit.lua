require "utils.tableutil"
require "protodef.rpcgen.fire.pb.shop.goodslimit"
SQueryLimit = {}
SQueryLimit.__index = SQueryLimit



SQueryLimit.PROTOCOL_TYPE = 810638

function SQueryLimit.Create()
	print("enter SQueryLimit create")
	return SQueryLimit:new()
end
function SQueryLimit:new()
	local self = {}
	setmetatable(self, SQueryLimit)
	self.type = self.PROTOCOL_TYPE
	self.querytype = 0
	self.goodslimits = {}

	return self
end
function SQueryLimit:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SQueryLimit:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.querytype)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.goodslimits))
	for k,v in ipairs(self.goodslimits) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SQueryLimit:unmarshal(_os_)
	self.querytype = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_goodslimits=0,_os_null_goodslimits
	_os_null_goodslimits, sizeof_goodslimits = _os_: uncompact_uint32(sizeof_goodslimits)
	for k = 1,sizeof_goodslimits do
		----------------unmarshal bean
		self.goodslimits[k]=GoodsLimit:new()

		self.goodslimits[k]:unmarshal(_os_)

	end
	return _os_
end

return SQueryLimit
