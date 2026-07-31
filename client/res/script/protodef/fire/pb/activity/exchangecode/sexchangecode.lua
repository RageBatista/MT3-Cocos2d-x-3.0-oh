require "utils.tableutil"
require "protodef.rpcgen.fire.pb.activity.exchangecode.exchangecoderetinfo"
SExchangeCode = {}
SExchangeCode.__index = SExchangeCode



SExchangeCode.PROTOCOL_TYPE = 819199

function SExchangeCode.Create()
	print("enter SExchangeCode create")
	return SExchangeCode:new()
end
function SExchangeCode:new()
	local self = {}
	setmetatable(self, SExchangeCode)
	self.type = self.PROTOCOL_TYPE
	self.flag = 0
	self.iteminfos = {}

	return self
end
function SExchangeCode:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SExchangeCode:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.flag)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.iteminfos))
	for k,v in ipairs(self.iteminfos) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SExchangeCode:unmarshal(_os_)
	self.flag = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_iteminfos=0,_os_null_iteminfos
	_os_null_iteminfos, sizeof_iteminfos = _os_: uncompact_uint32(sizeof_iteminfos)
	for k = 1,sizeof_iteminfos do
		----------------unmarshal bean
		self.iteminfos[k]=ExchangeCodeRetInfo:new()

		self.iteminfos[k]:unmarshal(_os_)

	end
	return _os_
end

return SExchangeCode
