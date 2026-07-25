require "utils.tableutil"
SChangeGem33 = {}
SChangeGem33.__index = SChangeGem33



SChangeGem33.PROTOCOL_TYPE = 817934

function SChangeGem33.Create()
	print("enter SChangeGem33 create")
	return SChangeGem33:new()
end
function SChangeGem33:new()
	local self = {}
	setmetatable(self, SChangeGem33)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SChangeGem33:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SChangeGem33:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SChangeGem33:unmarshal(_os_)
	return _os_
end

return SChangeGem33
