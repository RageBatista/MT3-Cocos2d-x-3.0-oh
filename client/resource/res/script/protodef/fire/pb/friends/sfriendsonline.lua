require "utils.tableutil"
SFriendsOnline = {}
SFriendsOnline.__index = SFriendsOnline



SFriendsOnline.PROTOCOL_TYPE = 806434

function SFriendsOnline.Create()
	print("enter SFriendsOnline create")
	return SFriendsOnline:new()
end
function SFriendsOnline:new()
	local self = {}
	setmetatable(self, SFriendsOnline)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.online = 0

	return self
end
function SFriendsOnline:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SFriendsOnline:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_char(self.online)
	return _os_
end

function SFriendsOnline:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.online = _os_:unmarshal_char()
	return _os_
end

return SFriendsOnline
