require "utils.tableutil"
SUpdateFriendLevel = {}
SUpdateFriendLevel.__index = SUpdateFriendLevel



SUpdateFriendLevel.PROTOCOL_TYPE = 806536

function SUpdateFriendLevel.Create()
	print("enter SUpdateFriendLevel create")
	return SUpdateFriendLevel:new()
end
function SUpdateFriendLevel:new()
	local self = {}
	setmetatable(self, SUpdateFriendLevel)
	self.type = self.PROTOCOL_TYPE
	self.currentfriendlevel = 0
	self.friendid = 0

	return self
end
function SUpdateFriendLevel:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SUpdateFriendLevel:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.currentfriendlevel)
	_os_:marshal_int64(self.friendid)
	return _os_
end

function SUpdateFriendLevel:unmarshal(_os_)
	self.currentfriendlevel = _os_:unmarshal_int32()
	self.friendid = _os_:unmarshal_int64()
	return _os_
end

return SUpdateFriendLevel
