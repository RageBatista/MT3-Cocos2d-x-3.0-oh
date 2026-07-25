require "utils.tableutil"
SInvitationLiveDieBattleOK = {}
SInvitationLiveDieBattleOK.__index = SInvitationLiveDieBattleOK



SInvitationLiveDieBattleOK.PROTOCOL_TYPE = 793836

function SInvitationLiveDieBattleOK.Create()
	print("enter SInvitationLiveDieBattleOK create")
	return SInvitationLiveDieBattleOK:new()
end
function SInvitationLiveDieBattleOK:new()
	local self = {}
	setmetatable(self, SInvitationLiveDieBattleOK)
	self.type = self.PROTOCOL_TYPE
	self.sourceid = 0
	self.sourcename = "" 
	self.selecttype = 0

	return self
end
function SInvitationLiveDieBattleOK:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SInvitationLiveDieBattleOK:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.sourceid)
	_os_:marshal_wstring(self.sourcename)
	_os_:marshal_int32(self.selecttype)
	return _os_
end

function SInvitationLiveDieBattleOK:unmarshal(_os_)
	self.sourceid = _os_:unmarshal_int64()
	self.sourcename = _os_:unmarshal_wstring(self.sourcename)
	self.selecttype = _os_:unmarshal_int32()
	return _os_
end

return SInvitationLiveDieBattleOK
