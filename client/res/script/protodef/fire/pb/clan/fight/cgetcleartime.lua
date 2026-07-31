require "utils.tableutil"
CGetClearTime = {}
CGetClearTime.__index = CGetClearTime



CGetClearTime.PROTOCOL_TYPE = 808545

function CGetClearTime.Create()
	print("enter CGetClearTime create")
	return CGetClearTime:new()
end
function CGetClearTime:new()
	local self = {}
	setmetatable(self, CGetClearTime)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CGetClearTime:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetClearTime:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CGetClearTime:unmarshal(_os_)
	return _os_
end

return CGetClearTime
