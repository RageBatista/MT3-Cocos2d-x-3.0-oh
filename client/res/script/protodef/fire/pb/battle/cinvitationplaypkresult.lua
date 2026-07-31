require "utils.tableutil"
CInvitationPlayPKResult = {}
CInvitationPlayPKResult.__index = CInvitationPlayPKResult



CInvitationPlayPKResult.PROTOCOL_TYPE = 793689

function CInvitationPlayPKResult.Create()
	print("enter CInvitationPlayPKResult create")
	return CInvitationPlayPKResult:new()
end
function CInvitationPlayPKResult:new()
	local self = {}
	setmetatable(self, CInvitationPlayPKResult)
	self.type = self.PROTOCOL_TYPE
	self.sourceid = 0
	self.acceptresult = 0

	return self
end
function CInvitationPlayPKResult:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CInvitationPlayPKResult:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.sourceid)
	_os_:marshal_int32(self.acceptresult)
	return _os_
end

function CInvitationPlayPKResult:unmarshal(_os_)
	self.sourceid = _os_:unmarshal_int64()
	self.acceptresult = _os_:unmarshal_int32()
	return _os_
end

return CInvitationPlayPKResult
