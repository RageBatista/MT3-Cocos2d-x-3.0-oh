require "utils.tableutil"
SUseEnhancementItem = {}
SUseEnhancementItem.__index = SUseEnhancementItem



SUseEnhancementItem.PROTOCOL_TYPE = 787764

function SUseEnhancementItem.Create()
	print("enter SUseEnhancementItem create")
	return SUseEnhancementItem:new()
end
function SUseEnhancementItem:new()
	local self = {}
	setmetatable(self, SUseEnhancementItem)
	self.type = self.PROTOCOL_TYPE
	self.equippos = 0

	return self
end
function SUseEnhancementItem:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SUseEnhancementItem:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.equippos)
	return _os_
end

function SUseEnhancementItem:unmarshal(_os_)
	self.equippos = _os_:unmarshal_int32()
	return _os_
end

return SUseEnhancementItem
