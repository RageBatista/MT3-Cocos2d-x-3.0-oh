require "utils.tableutil"
CAcceptOrRefuseInvitation = {}
CAcceptOrRefuseInvitation.__index = CAcceptOrRefuseInvitation



CAcceptOrRefuseInvitation.PROTOCOL_TYPE = 808470

function CAcceptOrRefuseInvitation.Create()
	print("enter CAcceptOrRefuseInvitation create")
	return CAcceptOrRefuseInvitation:new()
end
function CAcceptOrRefuseInvitation:new()
	local self = {}
	setmetatable(self, CAcceptOrRefuseInvitation)
	self.type = self.PROTOCOL_TYPE
	self.hostroleid = 0
	self.accept = 0

	return self
end
function CAcceptOrRefuseInvitation:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CAcceptOrRefuseInvitation:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.hostroleid)
	_os_:marshal_char(self.accept)
	return _os_
end

function CAcceptOrRefuseInvitation:unmarshal(_os_)
	self.hostroleid = _os_:unmarshal_int64()
	self.accept = _os_:unmarshal_char()
	return _os_
end

return CAcceptOrRefuseInvitation
