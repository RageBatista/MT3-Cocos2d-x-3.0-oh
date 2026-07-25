require "utils.tableutil"
CSendInvitePlayPK = {}
CSendInvitePlayPK.__index = CSendInvitePlayPK



CSendInvitePlayPK.PROTOCOL_TYPE = 793564

function CSendInvitePlayPK.Create()
	print("enter CSendInvitePlayPK create")
	return CSendInvitePlayPK:new()
end
function CSendInvitePlayPK:new()
	local self = {}
	setmetatable(self, CSendInvitePlayPK)
	self.type = self.PROTOCOL_TYPE
	self.guestroleid = 0

	return self
end
function CSendInvitePlayPK:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSendInvitePlayPK:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.guestroleid)
	return _os_
end

function CSendInvitePlayPK:unmarshal(_os_)
	self.guestroleid = _os_:unmarshal_int64()
	return _os_
end

return CSendInvitePlayPK
