require "utils.tableutil"
CClanInvitation = {}
CClanInvitation.__index = CClanInvitation



CClanInvitation.PROTOCOL_TYPE = 808461

function CClanInvitation.Create()
	print("enter CClanInvitation create")
	return CClanInvitation:new()
end
function CClanInvitation:new()
	local self = {}
	setmetatable(self, CClanInvitation)
	self.type = self.PROTOCOL_TYPE
	self.guestroleid = 0

	return self
end
function CClanInvitation:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CClanInvitation:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.guestroleid)
	return _os_
end

function CClanInvitation:unmarshal(_os_)
	self.guestroleid = _os_:unmarshal_int64()
	return _os_
end

return CClanInvitation
