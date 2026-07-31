require "utils.tableutil"
CGetItemTips = {}
CGetItemTips.__index = CGetItemTips



CGetItemTips.PROTOCOL_TYPE = 787453

function CGetItemTips.Create()
	print("enter CGetItemTips create")
	return CGetItemTips:new()
end
function CGetItemTips:new()
	local self = {}
	setmetatable(self, CGetItemTips)
	self.type = self.PROTOCOL_TYPE
	self.packid = 0
	self.keyinpack = 0

	return self
end
function CGetItemTips:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetItemTips:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.packid)
	_os_:marshal_int32(self.keyinpack)
	return _os_
end

function CGetItemTips:unmarshal(_os_)
	self.packid = _os_:unmarshal_int32()
	self.keyinpack = _os_:unmarshal_int32()
	return _os_
end

return CGetItemTips
