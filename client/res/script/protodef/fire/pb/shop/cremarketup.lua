require "utils.tableutil"
CReMarketUp = {}
CReMarketUp.__index = CReMarketUp



CReMarketUp.PROTOCOL_TYPE = 810656

function CReMarketUp.Create()
	print("enter CReMarketUp create")
	return CReMarketUp:new()
end
function CReMarketUp:new()
	local self = {}
	setmetatable(self, CReMarketUp)
	self.type = self.PROTOCOL_TYPE
	self.itemtype = 0
	self.id = 0
	self.money = 0

	return self
end
function CReMarketUp:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReMarketUp:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.itemtype)
	_os_:marshal_int64(self.id)
	_os_:marshal_int32(self.money)
	return _os_
end

function CReMarketUp:unmarshal(_os_)
	self.itemtype = _os_:unmarshal_int32()
	self.id = _os_:unmarshal_int64()
	self.money = _os_:unmarshal_int32()
	return _os_
end

return CReMarketUp
