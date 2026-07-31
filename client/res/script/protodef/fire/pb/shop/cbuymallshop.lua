require "utils.tableutil"
CBuyMallShop = {}
CBuyMallShop.__index = CBuyMallShop



CBuyMallShop.PROTOCOL_TYPE = 810632

function CBuyMallShop.Create()
	print("enter CBuyMallShop create")
	return CBuyMallShop:new()
end
function CBuyMallShop:new()
	local self = {}
	setmetatable(self, CBuyMallShop)
	self.type = self.PROTOCOL_TYPE
	self.shopid = 0
	self.taskid = 0
	self.goodsid = 0
	self.num = 0

	return self
end
function CBuyMallShop:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CBuyMallShop:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.shopid)
	_os_:marshal_int32(self.taskid)
	_os_:marshal_int32(self.goodsid)
	_os_:marshal_int32(self.num)
	return _os_
end

function CBuyMallShop:unmarshal(_os_)
	self.shopid = _os_:unmarshal_int32()
	self.taskid = _os_:unmarshal_int32()
	self.goodsid = _os_:unmarshal_int32()
	self.num = _os_:unmarshal_int32()
	return _os_
end

return CBuyMallShop
