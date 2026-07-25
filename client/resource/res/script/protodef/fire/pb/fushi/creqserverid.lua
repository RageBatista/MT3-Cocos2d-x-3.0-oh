require "utils.tableutil"
CReqServerId = {}
CReqServerId.__index = CReqServerId



CReqServerId.PROTOCOL_TYPE = 812472

function CReqServerId.Create()
	print("enter CReqServerId create")
	return CReqServerId:new()
end
function CReqServerId:new()
	local self = {}
	setmetatable(self, CReqServerId)
	self.type = self.PROTOCOL_TYPE
	self.flag = 0

	return self
end
function CReqServerId:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReqServerId:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.flag)
	return _os_
end

function CReqServerId:unmarshal(_os_)
	self.flag = _os_:unmarshal_int32()
	return _os_
end

return CReqServerId
