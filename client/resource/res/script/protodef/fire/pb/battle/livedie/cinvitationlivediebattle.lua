require "utils.tableutil"
CInvitationLiveDieBattle = {}
CInvitationLiveDieBattle.__index = CInvitationLiveDieBattle



CInvitationLiveDieBattle.PROTOCOL_TYPE = 793833

function CInvitationLiveDieBattle.Create()
	print("enter CInvitationLiveDieBattle create")
	return CInvitationLiveDieBattle:new()
end
function CInvitationLiveDieBattle:new()
	local self = {}
	setmetatable(self, CInvitationLiveDieBattle)
	self.type = self.PROTOCOL_TYPE
	self.idorname = "" 
	self.selecttype = 0

	return self
end
function CInvitationLiveDieBattle:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CInvitationLiveDieBattle:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.idorname)
	_os_:marshal_int32(self.selecttype)
	return _os_
end

function CInvitationLiveDieBattle:unmarshal(_os_)
	self.idorname = _os_:unmarshal_wstring(self.idorname)
	self.selecttype = _os_:unmarshal_int32()
	return _os_
end

return CInvitationLiveDieBattle
