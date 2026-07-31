require "utils.tableutil"
CInvitationPlayPK = {}
CInvitationPlayPK.__index = CInvitationPlayPK



CInvitationPlayPK.PROTOCOL_TYPE = 793687

function CInvitationPlayPK.Create()
	print("enter CInvitationPlayPK create")
	return CInvitationPlayPK:new()
end
function CInvitationPlayPK:new()
	local self = {}
	setmetatable(self, CInvitationPlayPK)
	self.type = self.PROTOCOL_TYPE
	self.objectid = 0

	return self
end
function CInvitationPlayPK:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CInvitationPlayPK:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.objectid)
	return _os_
end

function CInvitationPlayPK:unmarshal(_os_)
	self.objectid = _os_:unmarshal_int64()
	return _os_
end

return CInvitationPlayPK
