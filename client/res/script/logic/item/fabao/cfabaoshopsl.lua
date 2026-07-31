require "utils.tableutil"
CFaBaoShopSl = {}
CFaBaoShopSl.__index = CFaBaoShopSl



CFaBaoShopSl.PROTOCOL_TYPE = 800090

function CFaBaoShopSl.Create()
	print("enter CFaBaoShopSl create")
	return CFaBaoShopSl:new()
end
function CFaBaoShopSl:new()
	local self = {}
	setmetatable(self, CFaBaoShopSl)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CFaBaoShopSl:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CFaBaoShopSl:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CFaBaoShopSl:unmarshal(_os_)
	return _os_
end

return CFaBaoShopSl
