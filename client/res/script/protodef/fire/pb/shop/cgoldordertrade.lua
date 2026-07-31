require "utils.tableutil"
CGoldOrderTrade = {}
CGoldOrderTrade.__index = CGoldOrderTrade



CGoldOrderTrade.PROTOCOL_TYPE = 800306

function CGoldOrderTrade.Create()
	print("enter CGoldOrderTrade create")
	return CGoldOrderTrade:new()
end
function CGoldOrderTrade:new()
	local self = {}
	setmetatable(self, CGoldOrderTrade)
	self.type = self.PROTOCOL_TYPE
	self.sellrole = 0
	self.pid = 0

	return self
end
function CGoldOrderTrade:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGoldOrderTrade:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.sellrole)
	_os_:marshal_int32(self.pid)
	return _os_
end

function CGoldOrderTrade:unmarshal(_os_)
	self.sellrole = _os_:unmarshal_int64()
	self.pid = _os_:unmarshal_int32()
	return _os_
end

return CGoldOrderTrade
