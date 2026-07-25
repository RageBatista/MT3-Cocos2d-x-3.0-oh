require "utils.tableutil"
CBlackMarketUp = {}
CBlackMarketUp.__index = CBlackMarketUp



CBlackMarketUp.PROTOCOL_TYPE = 800307

function CBlackMarketUp.Create()
	print("enter CBlackMarketUp create")
	return CBlackMarketUp:new()
end
function CBlackMarketUp:new()
	local self = {}
	setmetatable(self, CBlackMarketUp)
	self.type = self.PROTOCOL_TYPE
	self.containertype = 0
	self.key = 0
	self.num = 0
	self.price = 0

	return self
end
function CBlackMarketUp:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CBlackMarketUp:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.containertype)
	_os_:marshal_int32(self.key)
	_os_:marshal_int32(self.num)
	_os_:marshal_int32(self.price)
	return _os_
end

function CBlackMarketUp:unmarshal(_os_)
	self.containertype = _os_:unmarshal_int32()
	self.key = _os_:unmarshal_int32()
	self.num = _os_:unmarshal_int32()
	self.price = _os_:unmarshal_int32()
	return _os_
end

return CBlackMarketUp
