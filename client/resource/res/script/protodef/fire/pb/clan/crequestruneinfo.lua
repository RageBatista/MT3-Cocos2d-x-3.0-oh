require "utils.tableutil"
CRequestRuneInfo = {}
CRequestRuneInfo.__index = CRequestRuneInfo



CRequestRuneInfo.PROTOCOL_TYPE = 808507

function CRequestRuneInfo.Create()
	print("enter CRequestRuneInfo create")
	return CRequestRuneInfo:new()
end
function CRequestRuneInfo:new()
	local self = {}
	setmetatable(self, CRequestRuneInfo)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CRequestRuneInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestRuneInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CRequestRuneInfo:unmarshal(_os_)
	return _os_
end

return CRequestRuneInfo
