require "utils.tableutil"
CUseTreasureMapEnd = {}
CUseTreasureMapEnd.__index = CUseTreasureMapEnd



CUseTreasureMapEnd.PROTOCOL_TYPE = 805534

function CUseTreasureMapEnd.Create()
	print("enter CUseTreasureMapEnd create")
	return CUseTreasureMapEnd:new()
end
function CUseTreasureMapEnd:new()
	local self = {}
	setmetatable(self, CUseTreasureMapEnd)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CUseTreasureMapEnd:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CUseTreasureMapEnd:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CUseTreasureMapEnd:unmarshal(_os_)
	return _os_
end

return CUseTreasureMapEnd
