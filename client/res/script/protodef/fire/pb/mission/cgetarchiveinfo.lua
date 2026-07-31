require "utils.tableutil"
CGetArchiveInfo = {}
CGetArchiveInfo.__index = CGetArchiveInfo



CGetArchiveInfo.PROTOCOL_TYPE = 805540

function CGetArchiveInfo.Create()
	print("enter CGetArchiveInfo create")
	return CGetArchiveInfo:new()
end
function CGetArchiveInfo:new()
	local self = {}
	setmetatable(self, CGetArchiveInfo)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CGetArchiveInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetArchiveInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CGetArchiveInfo:unmarshal(_os_)
	return _os_
end

return CGetArchiveInfo
