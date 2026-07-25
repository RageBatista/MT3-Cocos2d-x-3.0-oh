require "utils.tableutil"
SInvitationPlayPKResult = {}
SInvitationPlayPKResult.__index = SInvitationPlayPKResult



SInvitationPlayPKResult.PROTOCOL_TYPE = 793690

function SInvitationPlayPKResult.Create()
	print("enter SInvitationPlayPKResult create")
	return SInvitationPlayPKResult:new()
end
function SInvitationPlayPKResult:new()
	local self = {}
	setmetatable(self, SInvitationPlayPKResult)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SInvitationPlayPKResult:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SInvitationPlayPKResult:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SInvitationPlayPKResult:unmarshal(_os_)
	return _os_
end

return SInvitationPlayPKResult
