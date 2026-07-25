require "utils.tableutil"
SInvitationPlayPK = {}
SInvitationPlayPK.__index = SInvitationPlayPK



SInvitationPlayPK.PROTOCOL_TYPE = 793688

function SInvitationPlayPK.Create()
	print("enter SInvitationPlayPK create")
	return SInvitationPlayPK:new()
end
function SInvitationPlayPK:new()
	local self = {}
	setmetatable(self, SInvitationPlayPK)
	self.type = self.PROTOCOL_TYPE
	self.sourceid = 0
	self.rolename = "" 
	self.rolelevel = 0
	self.teamnum = 0

	return self
end
function SInvitationPlayPK:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SInvitationPlayPK:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.sourceid)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int32(self.rolelevel)
	_os_:marshal_int32(self.teamnum)
	return _os_
end

function SInvitationPlayPK:unmarshal(_os_)
	self.sourceid = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.rolelevel = _os_:unmarshal_int32()
	self.teamnum = _os_:unmarshal_int32()
	return _os_
end

return SInvitationPlayPK
