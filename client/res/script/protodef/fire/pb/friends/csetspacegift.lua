require "utils.tableutil"
CSetSpaceGift = {}
CSetSpaceGift.__index = CSetSpaceGift



CSetSpaceGift.PROTOCOL_TYPE = 806641

function CSetSpaceGift.Create()
	print("enter CSetSpaceGift create")
	return CSetSpaceGift:new()
end
function CSetSpaceGift:new()
	local self = {}
	setmetatable(self, CSetSpaceGift)
	self.type = self.PROTOCOL_TYPE
	self.giftnum = 0

	return self
end
function CSetSpaceGift:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSetSpaceGift:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.giftnum)
	return _os_
end

function CSetSpaceGift:unmarshal(_os_)
	self.giftnum = _os_:unmarshal_int32()
	return _os_
end

return CSetSpaceGift
