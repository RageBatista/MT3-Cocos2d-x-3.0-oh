require "utils.tableutil"
CItemLoseEffect = {}
CItemLoseEffect.__index = CItemLoseEffect



CItemLoseEffect.PROTOCOL_TYPE = 787439

function CItemLoseEffect.Create()
	print("enter CItemLoseEffect create")
	return CItemLoseEffect:new()
end
function CItemLoseEffect:new()
	local self = {}
	setmetatable(self, CItemLoseEffect)
	self.type = self.PROTOCOL_TYPE
	self.packid = 0
	self.itemkey = 0

	return self
end
function CItemLoseEffect:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CItemLoseEffect:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.packid)
	_os_:marshal_int32(self.itemkey)
	return _os_
end

function CItemLoseEffect:unmarshal(_os_)
	self.packid = _os_:unmarshal_int32()
	self.itemkey = _os_:unmarshal_int32()
	return _os_
end

return CItemLoseEffect
