require "utils.tableutil"
SRespondInvite = {}
SRespondInvite.__index = SRespondInvite



SRespondInvite.PROTOCOL_TYPE = 794486

function SRespondInvite.Create()
	print("enter SRespondInvite create")
	return SRespondInvite:new()
end
function SRespondInvite:new()
	local self = {}
	setmetatable(self, SRespondInvite)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.agree = 0

	return self
end
function SRespondInvite:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRespondInvite:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_char(self.agree)
	return _os_
end

function SRespondInvite:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.agree = _os_:unmarshal_char()
	return _os_
end

return SRespondInvite
