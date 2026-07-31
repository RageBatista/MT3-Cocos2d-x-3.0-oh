require "utils.tableutil"
CGetXshSpaceInfo = {}
CGetXshSpaceInfo.__index = CGetXshSpaceInfo



CGetXshSpaceInfo.PROTOCOL_TYPE = 806651

function CGetXshSpaceInfo.Create()
	print("enter CGetXshSpaceInfo create")
	return CGetXshSpaceInfo:new()
end
function CGetXshSpaceInfo:new()
	local self = {}
	setmetatable(self, CGetXshSpaceInfo)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CGetXshSpaceInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGetXshSpaceInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CGetXshSpaceInfo:unmarshal(_os_)
	return _os_
end

return CGetXshSpaceInfo
