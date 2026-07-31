require "utils.tableutil"
CRequestEventInfo = {}
CRequestEventInfo.__index = CRequestEventInfo



CRequestEventInfo.PROTOCOL_TYPE = 808500

function CRequestEventInfo.Create()
	print("enter CRequestEventInfo create")
	return CRequestEventInfo:new()
end
function CRequestEventInfo:new()
	local self = {}
	setmetatable(self, CRequestEventInfo)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CRequestEventInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestEventInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CRequestEventInfo:unmarshal(_os_)
	return _os_
end

return CRequestEventInfo
