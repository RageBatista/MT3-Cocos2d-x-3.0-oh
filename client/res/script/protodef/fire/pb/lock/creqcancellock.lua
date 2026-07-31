require "utils.tableutil"
CReqCancelLock = {}
CReqCancelLock.__index = CReqCancelLock



CReqCancelLock.PROTOCOL_TYPE = 818938

function CReqCancelLock.Create()
	print("enter CReqCancelLock create")
	return CReqCancelLock:new()
end
function CReqCancelLock:new()
	local self = {}
	setmetatable(self, CReqCancelLock)
	self.type = self.PROTOCOL_TYPE
	self.password = "" 

	return self
end
function CReqCancelLock:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReqCancelLock:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.password)
	return _os_
end

function CReqCancelLock:unmarshal(_os_)
	self.password = _os_:unmarshal_wstring(self.password)
	return _os_
end

return CReqCancelLock
