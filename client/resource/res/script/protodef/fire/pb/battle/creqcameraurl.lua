require "utils.tableutil"
CReqCameraUrl = {}
CReqCameraUrl.__index = CReqCameraUrl



CReqCameraUrl.PROTOCOL_TYPE = 793733

function CReqCameraUrl.Create()
	print("enter CReqCameraUrl create")
	return CReqCameraUrl:new()
end
function CReqCameraUrl:new()
	local self = {}
	setmetatable(self, CReqCameraUrl)
	self.type = self.PROTOCOL_TYPE
	self.battleid = 0

	return self
end
function CReqCameraUrl:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReqCameraUrl:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.battleid)
	return _os_
end

function CReqCameraUrl:unmarshal(_os_)
	self.battleid = _os_:unmarshal_int64()
	return _os_
end

return CReqCameraUrl
