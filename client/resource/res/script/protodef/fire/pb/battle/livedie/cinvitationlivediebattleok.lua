require "utils.tableutil"
CInvitationLiveDieBattleOK = {}
CInvitationLiveDieBattleOK.__index = CInvitationLiveDieBattleOK



CInvitationLiveDieBattleOK.PROTOCOL_TYPE = 793835

function CInvitationLiveDieBattleOK.Create()
	print("enter CInvitationLiveDieBattleOK create")
	return CInvitationLiveDieBattleOK:new()
end
function CInvitationLiveDieBattleOK:new()
	local self = {}
	setmetatable(self, CInvitationLiveDieBattleOK)
	self.type = self.PROTOCOL_TYPE
	self.objectid = 0
	self.selecttype = 0

	return self
end
function CInvitationLiveDieBattleOK:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CInvitationLiveDieBattleOK:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.objectid)
	_os_:marshal_int32(self.selecttype)
	return _os_
end

function CInvitationLiveDieBattleOK:unmarshal(_os_)
	self.objectid = _os_:unmarshal_int64()
	self.selecttype = _os_:unmarshal_int32()
	return _os_
end

return CInvitationLiveDieBattleOK
