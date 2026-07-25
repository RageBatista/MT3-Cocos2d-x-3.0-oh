require "utils.tableutil"
CRequestMatchInfo = {}
CRequestMatchInfo.__index = CRequestMatchInfo



CRequestMatchInfo.PROTOCOL_TYPE = 794512

function CRequestMatchInfo.Create()
	print("enter CRequestMatchInfo create")
	return CRequestMatchInfo:new()
end
function CRequestMatchInfo:new()
	local self = {}
	setmetatable(self, CRequestMatchInfo)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CRequestMatchInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestMatchInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CRequestMatchInfo:unmarshal(_os_)
	return _os_
end

return CRequestMatchInfo
