require "utils.tableutil"
CQuerySubscribeInfo = {}
CQuerySubscribeInfo.__index = CQuerySubscribeInfo



CQuerySubscribeInfo.PROTOCOL_TYPE = 812597

function CQuerySubscribeInfo.Create()
	print("enter CQuerySubscribeInfo create")
	return CQuerySubscribeInfo:new()
end
function CQuerySubscribeInfo:new()
	local self = {}
	setmetatable(self, CQuerySubscribeInfo)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CQuerySubscribeInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CQuerySubscribeInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CQuerySubscribeInfo:unmarshal(_os_)
	return _os_
end

return CQuerySubscribeInfo
