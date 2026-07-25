require "utils.tableutil"
SRefreshCurrency = {}
SRefreshCurrency.__index = SRefreshCurrency



SRefreshCurrency.PROTOCOL_TYPE = 787450

function SRefreshCurrency.Create()
	print("enter SRefreshCurrency create")
	return SRefreshCurrency:new()
end
function SRefreshCurrency:new()
	local self = {}
	setmetatable(self, SRefreshCurrency)
	self.type = self.PROTOCOL_TYPE
	self.packid = 0
	self.currency = {}

	return self
end
function SRefreshCurrency:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRefreshCurrency:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.packid)

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.currency))
	for k,v in pairs(self.currency) do
		_os_:marshal_char(k)
		_os_:marshal_int64(v)
	end

	return _os_
end

function SRefreshCurrency:unmarshal(_os_)
	self.packid = _os_:unmarshal_int32()
	----------------unmarshal map
	local sizeof_currency=0,_os_null_currency
	_os_null_currency, sizeof_currency = _os_: uncompact_uint32(sizeof_currency)
	for k = 1,sizeof_currency do
		local newkey, newvalue
		newkey = _os_:unmarshal_char()
		newvalue = _os_:unmarshal_int64()
		self.currency[newkey] = newvalue
	end
	return _os_
end

return SRefreshCurrency
