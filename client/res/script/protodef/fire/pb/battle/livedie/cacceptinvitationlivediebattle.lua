require "utils.tableutil"
CAcceptInvitationLiveDieBattle = {}
CAcceptInvitationLiveDieBattle.__index = CAcceptInvitationLiveDieBattle



CAcceptInvitationLiveDieBattle.PROTOCOL_TYPE = 793837

function CAcceptInvitationLiveDieBattle.Create()
	print("enter CAcceptInvitationLiveDieBattle create")
	return CAcceptInvitationLiveDieBattle:new()
end
function CAcceptInvitationLiveDieBattle:new()
	local self = {}
	setmetatable(self, CAcceptInvitationLiveDieBattle)
	self.type = self.PROTOCOL_TYPE
	self.sourceid = 0
	self.acceptresult = 0

	return self
end
function CAcceptInvitationLiveDieBattle:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CAcceptInvitationLiveDieBattle:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.sourceid)
	_os_:marshal_int32(self.acceptresult)
	return _os_
end

function CAcceptInvitationLiveDieBattle:unmarshal(_os_)
	self.sourceid = _os_:unmarshal_int64()
	self.acceptresult = _os_:unmarshal_int32()
	return _os_
end

return CAcceptInvitationLiveDieBattle
