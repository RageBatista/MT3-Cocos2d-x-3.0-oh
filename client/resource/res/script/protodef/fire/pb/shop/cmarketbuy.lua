require "utils.tableutil"
CMarketBuy = {}
CMarketBuy.__index = CMarketBuy



CMarketBuy.PROTOCOL_TYPE = 810641

function CMarketBuy.Create()
	print("enter CMarketBuy create")
	return CMarketBuy:new()
end
function CMarketBuy:new()
	local self = {}
	setmetatable(self, CMarketBuy)
	self.type = self.PROTOCOL_TYPE
	self.id = 0
	self.saleroleid = 0
	self.itemid = 0
	self.num = 0

	return self
end
function CMarketBuy:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CMarketBuy:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.id)
	_os_:marshal_int64(self.saleroleid)
	_os_:marshal_int32(self.itemid)
	_os_:marshal_int32(self.num)
	return _os_
end

function CMarketBuy:unmarshal(_os_)
	self.id = _os_:unmarshal_int64()
	self.saleroleid = _os_:unmarshal_int64()
	self.itemid = _os_:unmarshal_int32()
	self.num = _os_:unmarshal_int32()
	return _os_
end

return CMarketBuy
