require "utils.tableutil"
CDrawGiftBox = {}
CDrawGiftBox.__index = CDrawGiftBox



CDrawGiftBox.PROTOCOL_TYPE = 805488

function CDrawGiftBox.Create()
	print("enter CDrawGiftBox create")
	return CDrawGiftBox:new()
end
function CDrawGiftBox:new()
	local self = {}
	setmetatable(self, CDrawGiftBox)
	self.type = self.PROTOCOL_TYPE
	self.id = 0

	return self
end
function CDrawGiftBox:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CDrawGiftBox:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.id)
	return _os_
end

function CDrawGiftBox:unmarshal(_os_)
	self.id = _os_:unmarshal_int32()
	return _os_
end

return CDrawGiftBox
