require "utils.tableutil"
CRequestAddFriend = {}
CRequestAddFriend.__index = CRequestAddFriend



CRequestAddFriend.PROTOCOL_TYPE = 806439

function CRequestAddFriend.Create()
	print("enter CRequestAddFriend create")
	return CRequestAddFriend:new()
end
function CRequestAddFriend:new()
	local self = {}
	setmetatable(self, CRequestAddFriend)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0

	return self
end
function CRequestAddFriend:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestAddFriend:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	return _os_
end

function CRequestAddFriend:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	return _os_
end

return CRequestAddFriend
