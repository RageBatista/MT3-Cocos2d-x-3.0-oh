require "utils.tableutil"
CGoldOrderDownBlackMarket = {}
CGoldOrderDownBlackMarket.__index = CGoldOrderDownBlackMarket



CGoldOrderDownBlackMarket.PROTOCOL_TYPE = 810671

function CGoldOrderDownBlackMarket.Create()
	print("enter CGoldOrderDownBlackMarket create")
	return CGoldOrderDownBlackMarket:new()
end
function CGoldOrderDownBlackMarket:new()
	local self = {}
	setmetatable(self, CGoldOrderDownBlackMarket)
	self.type = self.PROTOCOL_TYPE
	self.pid = 0

	return self
end
function CGoldOrderDownBlackMarket:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGoldOrderDownBlackMarket:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.pid)
	return _os_
end

function CGoldOrderDownBlackMarket:unmarshal(_os_)
	self.pid = _os_:unmarshal_int64()
	return _os_
end

return CGoldOrderDownBlackMarket
