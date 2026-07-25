require "utils.tableutil"
SGoldOrderDownBlackMarket = {}
SGoldOrderDownBlackMarket.__index = SGoldOrderDownBlackMarket



SGoldOrderDownBlackMarket.PROTOCOL_TYPE = 810677

function SGoldOrderDownBlackMarket.Create()
	print("enter SGoldOrderDownBlackMarket create")
	return SGoldOrderDownBlackMarket:new()
end
function SGoldOrderDownBlackMarket:new()
	local self = {}
	setmetatable(self, SGoldOrderDownBlackMarket)
	self.type = self.PROTOCOL_TYPE
	self.pid = 0

	return self
end
function SGoldOrderDownBlackMarket:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGoldOrderDownBlackMarket:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.pid)
	return _os_
end

function SGoldOrderDownBlackMarket:unmarshal(_os_)
	self.pid = _os_:unmarshal_int64()
	return _os_
end

return SGoldOrderDownBlackMarket
