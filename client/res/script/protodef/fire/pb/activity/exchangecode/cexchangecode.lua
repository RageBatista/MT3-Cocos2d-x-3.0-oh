require "utils.tableutil"
CExchangeCode = {}
CExchangeCode.__index = CExchangeCode



CExchangeCode.PROTOCOL_TYPE = 819198

function CExchangeCode.Create()
	print("enter CExchangeCode create")
	return CExchangeCode:new()
end
function CExchangeCode:new()
	local self = {}
	setmetatable(self, CExchangeCode)
	self.type = self.PROTOCOL_TYPE
	self.exchangecode = "" 
	self.npckey = 0

	return self
end
function CExchangeCode:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CExchangeCode:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.exchangecode)
	_os_:marshal_int64(self.npckey)
	return _os_
end

function CExchangeCode:unmarshal(_os_)
	self.exchangecode = _os_:unmarshal_wstring(self.exchangecode)
	self.npckey = _os_:unmarshal_int64()
	return _os_
end

return CExchangeCode
