require "utils.tableutil"
CFaBaoShopCd = {}
CFaBaoShopCd.__index = CFaBaoShopCd



CFaBaoShopCd.PROTOCOL_TYPE = 800091

function CFaBaoShopCd.Create()
	print("enter CFaBaoShopCd create")
	return CFaBaoShopCd:new()
end
function CFaBaoShopCd:new()
	local self = {}
	setmetatable(self, CFaBaoShopCd)
	self.type = self.PROTOCOL_TYPE
	self.itemid = 0
	self.gezi = 0
	return self
end
function CFaBaoShopCd:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CFaBaoShopCd:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.itemid)
	_os_:marshal_int32(self.gezi)
	return _os_
end

function CFaBaoShopCd:unmarshal(_os_)
	self.itemid = _os_:unmarshal_int32()
	self.gezi = _os_:unmarshal_int32()
	return _os_
end

return CFaBaoShopCd
