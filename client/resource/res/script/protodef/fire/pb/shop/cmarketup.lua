require "utils.tableutil"
CMarketUp = {}
CMarketUp.__index = CMarketUp



CMarketUp.PROTOCOL_TYPE = 810643

function CMarketUp.Create()
	print("enter CMarketUp create")
	return CMarketUp:new()
end
function CMarketUp:new()
	local self = {}
	setmetatable(self, CMarketUp)
	self.type = self.PROTOCOL_TYPE
	self.containertype = 0
	self.key = 0
	self.num = 0
	self.price = 0

	return self
end
function CMarketUp:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CMarketUp:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.containertype)
	_os_:marshal_int32(self.key)
	_os_:marshal_int32(self.num)
	_os_:marshal_int32(self.price)
	return _os_
end

function CMarketUp:unmarshal(_os_)
	self.containertype = _os_:unmarshal_int32()
	self.key = _os_:unmarshal_int32()
	self.num = _os_:unmarshal_int32()
	self.price = _os_:unmarshal_int32()
	return _os_
end

return CMarketUp
