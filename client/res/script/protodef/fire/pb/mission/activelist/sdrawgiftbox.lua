require "utils.tableutil"
SDrawGiftBox = {}
SDrawGiftBox.__index = SDrawGiftBox



SDrawGiftBox.PROTOCOL_TYPE = 805487

function SDrawGiftBox.Create()
	print("enter SDrawGiftBox create")
	return SDrawGiftBox:new()
end
function SDrawGiftBox:new()
	local self = {}
	setmetatable(self, SDrawGiftBox)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SDrawGiftBox:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SDrawGiftBox:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SDrawGiftBox:unmarshal(_os_)
	return _os_
end

return SDrawGiftBox
