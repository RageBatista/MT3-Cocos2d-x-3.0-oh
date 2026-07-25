require "utils.tableutil"
CRespondInvite = {}
CRespondInvite.__index = CRespondInvite



CRespondInvite.PROTOCOL_TYPE = 794448

function CRespondInvite.Create()
	print("enter CRespondInvite create")
	return CRespondInvite:new()
end
function CRespondInvite:new()
	local self = {}
	setmetatable(self, CRespondInvite)
	self.type = self.PROTOCOL_TYPE
	self.agree = 0

	return self
end
function CRespondInvite:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRespondInvite:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.agree)
	return _os_
end

function CRespondInvite:unmarshal(_os_)
	self.agree = _os_:unmarshal_char()
	return _os_
end

return CRespondInvite
