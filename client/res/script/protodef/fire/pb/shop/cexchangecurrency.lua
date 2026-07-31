require "utils.tableutil"
CExchangeCurrency = {}
CExchangeCurrency.__index = CExchangeCurrency



CExchangeCurrency.PROTOCOL_TYPE = 810653

function CExchangeCurrency.Create()
	print("enter CExchangeCurrency create")
	return CExchangeCurrency:new()
end
function CExchangeCurrency:new()
	local self = {}
	setmetatable(self, CExchangeCurrency)
	self.type = self.PROTOCOL_TYPE
	self.srcmoneytype = 0
	self.dstmoneytype = 0
	self.money = 0

	return self
end
function CExchangeCurrency:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CExchangeCurrency:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.srcmoneytype)
	_os_:marshal_int32(self.dstmoneytype)
	_os_:marshal_int32(self.money)
	return _os_
end

function CExchangeCurrency:unmarshal(_os_)
	self.srcmoneytype = _os_:unmarshal_int32()
	self.dstmoneytype = _os_:unmarshal_int32()
	self.money = _os_:unmarshal_int32()
	return _os_
end

return CExchangeCurrency
