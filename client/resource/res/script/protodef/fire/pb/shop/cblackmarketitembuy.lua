require "utils.tableutil"
CBlackMarketItemBuy = {}
CBlackMarketItemBuy.__index = CBlackMarketItemBuy



CBlackMarketItemBuy.PROTOCOL_TYPE = 800313

function CBlackMarketItemBuy.Create()
	print("enter CBlackMarketItemBuy create")
	return CBlackMarketItemBuy:new()
end
function CBlackMarketItemBuy:new()
	local self = {}
	setmetatable(self, CBlackMarketItemBuy)
	self.type = self.PROTOCOL_TYPE
	self.itemtype = 0
	self.id = 0
	self.sallrole = 0

	return self
end
function CBlackMarketItemBuy:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CBlackMarketItemBuy:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.itemtype)
	_os_:marshal_int32(self.id)
	_os_:marshal_int64(self.sallrole)
 
	return _os_
end

function CBlackMarketItemBuy:unmarshal(_os_)
	self.itemtype = _os_:unmarshal_int32()
	self.id = _os_:unmarshal_int32()
	self.sallrole = _os_:unmarshal_int64()
	 
	return _os_
end

return CBlackMarketItemBuy
