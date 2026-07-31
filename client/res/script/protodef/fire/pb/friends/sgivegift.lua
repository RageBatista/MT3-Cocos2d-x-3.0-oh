require "utils.tableutil"
SGiveGift = {}
SGiveGift.__index = SGiveGift



SGiveGift.PROTOCOL_TYPE = 806638

function SGiveGift.Create()
	print("enter SGiveGift create")
	return SGiveGift:new()
end
function SGiveGift:new()
	local self = {}
	setmetatable(self, SGiveGift)
	self.type = self.PROTOCOL_TYPE
	self.result = 0

	return self
end
function SGiveGift:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGiveGift:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.result)
	return _os_
end

function SGiveGift:unmarshal(_os_)
	self.result = _os_:unmarshal_char()
	return _os_
end

return SGiveGift
