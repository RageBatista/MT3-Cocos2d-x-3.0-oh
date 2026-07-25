require "utils.tableutil"
SItemRecover = {}
SItemRecover.__index = SItemRecover



SItemRecover.PROTOCOL_TYPE = 787796

function SItemRecover.Create()
	print("enter SItemRecover create")
	return SItemRecover:new()
end
function SItemRecover:new()
	local self = {}
	setmetatable(self, SItemRecover)
	self.type = self.PROTOCOL_TYPE
	self.itemid = 0
	self.uniqid = 0

	return self
end
function SItemRecover:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SItemRecover:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.itemid)
	_os_:marshal_int64(self.uniqid)
	return _os_
end

function SItemRecover:unmarshal(_os_)
	self.itemid = _os_:unmarshal_int32()
	self.uniqid = _os_:unmarshal_int64()
	return _os_
end

return SItemRecover
