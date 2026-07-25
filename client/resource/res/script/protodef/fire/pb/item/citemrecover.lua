require "utils.tableutil"
CItemRecover = {}
CItemRecover.__index = CItemRecover



CItemRecover.PROTOCOL_TYPE = 787795

function CItemRecover.Create()
	print("enter CItemRecover create")
	return CItemRecover:new()
end
function CItemRecover:new()
	local self = {}
	setmetatable(self, CItemRecover)
	self.type = self.PROTOCOL_TYPE
	self.uniqid = 0

	return self
end
function CItemRecover:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CItemRecover:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.uniqid)
	return _os_
end

function CItemRecover:unmarshal(_os_)
	self.uniqid = _os_:unmarshal_int64()
	return _os_
end

return CItemRecover
