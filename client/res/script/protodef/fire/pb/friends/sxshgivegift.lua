require "utils.tableutil"
SXshGiveGift = {}
SXshGiveGift.__index = SXshGiveGift



SXshGiveGift.PROTOCOL_TYPE = 806650

function SXshGiveGift.Create()
	print("enter SXshGiveGift create")
	return SXshGiveGift:new()
end
function SXshGiveGift:new()
	local self = {}
	setmetatable(self, SXshGiveGift)
	self.type = self.PROTOCOL_TYPE
	self.result = 0

	return self
end
function SXshGiveGift:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SXshGiveGift:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.result)
	return _os_
end

function SXshGiveGift:unmarshal(_os_)
	self.result = _os_:unmarshal_char()
	return _os_
end

return SXshGiveGift
