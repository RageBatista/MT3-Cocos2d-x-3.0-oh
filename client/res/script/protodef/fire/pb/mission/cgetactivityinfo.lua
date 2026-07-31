require "utils.tableutil"
CGetActivityInfo = {}
CGetActivityInfo.__index = CGetActivityInfo



CGetActivityInfo.PROTOCOL_TYPE = 805536

function CGetActivityInfo.Create()
	print("enter CGetActivityInfo create")
	return CGetActivityInfo:new()
end
function CGetActivityInfo:new()
	local self = {}
	setmetatable(self, CGetActivityInfo)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CGetActivityInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetActivityInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CGetActivityInfo:unmarshal(_os_)
	return _os_
end

return CGetActivityInfo
