require "utils.tableutil"
CUserOffline = {}
CUserOffline.__index = CUserOffline



CUserOffline.PROTOCOL_TYPE = 786479

function CUserOffline.Create()
	print("enter CUserOffline create")
	return CUserOffline:new()
end
function CUserOffline:new()
	local self = {}
	setmetatable(self, CUserOffline)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CUserOffline:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CUserOffline:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CUserOffline:unmarshal(_os_)
	return _os_
end

return CUserOffline
