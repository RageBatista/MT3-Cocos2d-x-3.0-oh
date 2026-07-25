require "utils.tableutil"
SSetSpaceGift = {}
SSetSpaceGift.__index = SSetSpaceGift



SSetSpaceGift.PROTOCOL_TYPE = 806642

function SSetSpaceGift.Create()
	print("enter SSetSpaceGift create")
	return SSetSpaceGift:new()
end
function SSetSpaceGift:new()
	local self = {}
	setmetatable(self, SSetSpaceGift)
	self.type = self.PROTOCOL_TYPE
	self.result = 0

	return self
end
function SSetSpaceGift:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSetSpaceGift:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.result)
	return _os_
end

function SSetSpaceGift:unmarshal(_os_)
	self.result = _os_:unmarshal_char()
	return _os_
end

return SSetSpaceGift
