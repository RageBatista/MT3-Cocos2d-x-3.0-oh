require "utils.tableutil"
SChangeGem = {}
SChangeGem.__index = SChangeGem



SChangeGem.PROTOCOL_TYPE = 810492

function SChangeGem.Create()
	print("enter SChangeGem create")
	return SChangeGem:new()
end
function SChangeGem:new()
	local self = {}
	setmetatable(self, SChangeGem)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SChangeGem:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SChangeGem:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SChangeGem:unmarshal(_os_)
	return _os_
end

return SChangeGem
