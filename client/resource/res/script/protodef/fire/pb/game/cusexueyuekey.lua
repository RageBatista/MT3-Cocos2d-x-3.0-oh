require "utils.tableutil"
CUseXueYueKey = {}
CUseXueYueKey.__index = CUseXueYueKey



CUseXueYueKey.PROTOCOL_TYPE = 810369

function CUseXueYueKey.Create()
	print("enter CUseXueYueKey create")
	return CUseXueYueKey:new()
end
function CUseXueYueKey:new()
	local self = {}
	setmetatable(self, CUseXueYueKey)
	self.type = self.PROTOCOL_TYPE
	self.npckid = 0

	return self
end
function CUseXueYueKey:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CUseXueYueKey:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.npckid)
	return _os_
end

function CUseXueYueKey:unmarshal(_os_)
	self.npckid = _os_:unmarshal_int32()
	return _os_
end

return CUseXueYueKey
