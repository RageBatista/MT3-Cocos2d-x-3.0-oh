require "utils.tableutil"
CFaBaoShopUp = {}
CFaBaoShopUp.__index = CFaBaoShopUp



CFaBaoShopUp.PROTOCOL_TYPE = 800092

function CFaBaoShopUp.Create()
	print("enter CFaBaoShopUp create")
	return CFaBaoShopUp:new()
end
function CFaBaoShopUp:new()
	local self = {}
	setmetatable(self, CFaBaoShopUp)
	self.type = self.PROTOCOL_TYPE
	self.idx = 0
	self.leixing = 0
	return self
end
function CFaBaoShopUp:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CFaBaoShopUp:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.idx)
	_os_:marshal_int32(self.leixing)
	return _os_
end

function CFaBaoShopUp:unmarshal(_os_)
	self.idx = _os_:unmarshal_int32()
	self.leixing = _os_:unmarshal_int32()
	return _os_
end

return CFaBaoShopUp
