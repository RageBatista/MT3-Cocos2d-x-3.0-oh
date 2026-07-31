require "utils.tableutil"
CReqUnlock = {}
CReqUnlock.__index = CReqUnlock



CReqUnlock.PROTOCOL_TYPE = 818935

function CReqUnlock.Create()
	print("enter CReqUnlock create")
	return CReqUnlock:new()
end
function CReqUnlock:new()
	local self = {}
	setmetatable(self, CReqUnlock)
	self.type = self.PROTOCOL_TYPE
	self.password = "" 

	return self
end
function CReqUnlock:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CReqUnlock:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.password)
	return _os_
end

function CReqUnlock:unmarshal(_os_)
	self.password = _os_:unmarshal_wstring(self.password)
	return _os_
end

return CReqUnlock
