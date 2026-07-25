require "utils.tableutil"
SAcceptInvitationLiveDieBattle = {}
SAcceptInvitationLiveDieBattle.__index = SAcceptInvitationLiveDieBattle



SAcceptInvitationLiveDieBattle.PROTOCOL_TYPE = 793838

function SAcceptInvitationLiveDieBattle.Create()
	print("enter SAcceptInvitationLiveDieBattle create")
	return SAcceptInvitationLiveDieBattle:new()
end
function SAcceptInvitationLiveDieBattle:new()
	local self = {}
	setmetatable(self, SAcceptInvitationLiveDieBattle)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SAcceptInvitationLiveDieBattle:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SAcceptInvitationLiveDieBattle:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SAcceptInvitationLiveDieBattle:unmarshal(_os_)
	return _os_
end

return SAcceptInvitationLiveDieBattle
