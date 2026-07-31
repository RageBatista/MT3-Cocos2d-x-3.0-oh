require "utils.tableutil"
require "protodef.rpcgen.fire.pb.friends.infobean"
SAddFriend = {}
SAddFriend.__index = SAddFriend



SAddFriend.PROTOCOL_TYPE = 806440

function SAddFriend.Create()
	print("enter SAddFriend create")
	return SAddFriend:new()
end
function SAddFriend:new()
	local self = {}
	setmetatable(self, SAddFriend)
	self.type = self.PROTOCOL_TYPE
	self.friendinfobean = InfoBean:new()

	return self
end
function SAddFriend:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SAddFriend:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.friendinfobean:marshal(_os_) 
	return _os_
end

function SAddFriend:unmarshal(_os_)
	----------------unmarshal bean

	self.friendinfobean:unmarshal(_os_)

	return _os_
end

return SAddFriend
