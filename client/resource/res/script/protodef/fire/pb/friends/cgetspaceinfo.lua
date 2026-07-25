require "utils.tableutil"
CGetSpaceInfo = {}
CGetSpaceInfo.__index = CGetSpaceInfo



CGetSpaceInfo.PROTOCOL_TYPE = 806639

function CGetSpaceInfo.Create()
	print("enter CGetSpaceInfo create")
	return CGetSpaceInfo:new()
end
function CGetSpaceInfo:new()
	local self = {}
	setmetatable(self, CGetSpaceInfo)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0

	return self
end
function CGetSpaceInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetSpaceInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	return _os_
end

function CGetSpaceInfo:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	return _os_
end

return CGetSpaceInfo
