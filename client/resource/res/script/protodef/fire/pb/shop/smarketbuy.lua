require "utils.tableutil"
SMarketBuy = {}
SMarketBuy.__index = SMarketBuy



SMarketBuy.PROTOCOL_TYPE = 810642

function SMarketBuy.Create()
	print("enter SMarketBuy create")
	return SMarketBuy:new()
end
function SMarketBuy:new()
	local self = {}
	setmetatable(self, SMarketBuy)
	self.type = self.PROTOCOL_TYPE
	self.id = 0
	self.surplusnum = 0

	return self
end
function SMarketBuy:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SMarketBuy:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.id)
	_os_:marshal_int32(self.surplusnum)
	return _os_
end

function SMarketBuy:unmarshal(_os_)
	self.id = _os_:unmarshal_int64()
	self.surplusnum = _os_:unmarshal_int32()
	return _os_
end

return SMarketBuy
