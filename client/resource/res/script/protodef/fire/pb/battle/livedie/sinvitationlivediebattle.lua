require "utils.tableutil"
SInvitationLiveDieBattle = {}
SInvitationLiveDieBattle.__index = SInvitationLiveDieBattle



SInvitationLiveDieBattle.PROTOCOL_TYPE = 793834

function SInvitationLiveDieBattle.Create()
	print("enter SInvitationLiveDieBattle create")
	return SInvitationLiveDieBattle:new()
end
function SInvitationLiveDieBattle:new()
	local self = {}
	setmetatable(self, SInvitationLiveDieBattle)
	self.type = self.PROTOCOL_TYPE
	self.objectid = 0
	self.objectname = "" 
	self.selecttype = 0
	self.costmoney = 0

	return self
end
function SInvitationLiveDieBattle:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SInvitationLiveDieBattle:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.objectid)
	_os_:marshal_wstring(self.objectname)
	_os_:marshal_int32(self.selecttype)
	_os_:marshal_int32(self.costmoney)
	return _os_
end

function SInvitationLiveDieBattle:unmarshal(_os_)
	self.objectid = _os_:unmarshal_int64()
	self.objectname = _os_:unmarshal_wstring(self.objectname)
	self.selecttype = _os_:unmarshal_int32()
	self.costmoney = _os_:unmarshal_int32()
	return _os_
end

return SInvitationLiveDieBattle
