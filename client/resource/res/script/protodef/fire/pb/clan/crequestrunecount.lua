require "utils.tableutil"
CRequestRuneCount = {}
CRequestRuneCount.__index = CRequestRuneCount



CRequestRuneCount.PROTOCOL_TYPE = 808513

function CRequestRuneCount.Create()
	print("enter CRequestRuneCount create")
	return CRequestRuneCount:new()
end
function CRequestRuneCount:new()
	local self = {}
	setmetatable(self, CRequestRuneCount)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CRequestRuneCount:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestRuneCount:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CRequestRuneCount:unmarshal(_os_)
	return _os_
end

return CRequestRuneCount
