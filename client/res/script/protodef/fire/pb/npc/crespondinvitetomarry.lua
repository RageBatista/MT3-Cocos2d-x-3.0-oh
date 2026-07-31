require "utils.tableutil"
CRespondInviteToMarry = {}
CRespondInviteToMarry.__index = CRespondInviteToMarry



CRespondInviteToMarry.PROTOCOL_TYPE = 817975

function CRespondInviteToMarry.Create()
	print("enter CRespondInviteToMarry create")
	return CRespondInviteToMarry:new()
end
function CRespondInviteToMarry:new()
	local self = {}
	setmetatable(self, CRespondInviteToMarry)
	self.type = self.PROTOCOL_TYPE
	self.agree = 0

	return self
end
function CRespondInviteToMarry:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRespondInviteToMarry:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.agree)
	return _os_
end

function CRespondInviteToMarry:unmarshal(_os_)
	self.agree = _os_:unmarshal_char()
	return _os_
end

return CRespondInviteToMarry
