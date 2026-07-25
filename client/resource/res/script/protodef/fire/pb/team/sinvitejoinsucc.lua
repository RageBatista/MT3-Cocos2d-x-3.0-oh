require "utils.tableutil"
SInviteJoinSucc = {}
SInviteJoinSucc.__index = SInviteJoinSucc



SInviteJoinSucc.PROTOCOL_TYPE = 794482

function SInviteJoinSucc.Create()
	print("enter SInviteJoinSucc create")
	return SInviteJoinSucc:new()
end
function SInviteJoinSucc:new()
	local self = {}
	setmetatable(self, SInviteJoinSucc)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0

	return self
end
function SInviteJoinSucc:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SInviteJoinSucc:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	return _os_
end

function SInviteJoinSucc:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	return _os_
end

return SInviteJoinSucc
