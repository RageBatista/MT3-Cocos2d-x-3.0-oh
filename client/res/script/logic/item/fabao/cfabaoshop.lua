require "utils.tableutil"
CFaBaoShop = {}
CFaBaoShop.__index = CFaBaoShop



CFaBaoShop.PROTOCOL_TYPE = 800088

function CFaBaoShop.Create()
	print("enter CFaBaoShop create")
	return CFaBaoShop:new()
end
function CFaBaoShop:new()
	local self = {}
	setmetatable(self, CFaBaoShop)
	self.type = self.PROTOCOL_TYPE
	self.shopid = 0
	return self
end
function CFaBaoShop:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CFaBaoShop:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.shopid)
	return _os_
end

function CFaBaoShop:unmarshal(_os_)
	self.shopid = _os_:unmarshal_int32()
	return _os_
end

return CFaBaoShop
