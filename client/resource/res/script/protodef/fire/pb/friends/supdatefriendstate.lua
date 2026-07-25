require "utils.tableutil"
SUpdateFriendState = {}
SUpdateFriendState.__index = SUpdateFriendState



SUpdateFriendState.PROTOCOL_TYPE = 806575

function SUpdateFriendState.Create()
	print("enter SUpdateFriendState create")
	return SUpdateFriendState:new()
end
function SUpdateFriendState:new()
	local self = {}
	setmetatable(self, SUpdateFriendState)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.relation = 0

	return self
end
function SUpdateFriendState:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SUpdateFriendState:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_short(self.relation)
	return _os_
end

function SUpdateFriendState:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.relation = _os_:unmarshal_short()
	return _os_
end

return SUpdateFriendState
