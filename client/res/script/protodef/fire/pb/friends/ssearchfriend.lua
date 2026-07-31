require "utils.tableutil"
require "protodef.rpcgen.fire.pb.friends.infobean"
SSearchFriend = {}
SSearchFriend.__index = SSearchFriend



SSearchFriend.PROTOCOL_TYPE = 806571

function SSearchFriend.Create()
	print("enter SSearchFriend create")
	return SSearchFriend:new()
end
function SSearchFriend:new()
	local self = {}
	setmetatable(self, SSearchFriend)
	self.type = self.PROTOCOL_TYPE
	self.friendinfobean = InfoBean:new()

	return self
end
function SSearchFriend:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSearchFriend:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.friendinfobean:marshal(_os_) 
	return _os_
end

function SSearchFriend:unmarshal(_os_)
	----------------unmarshal bean

	self.friendinfobean:unmarshal(_os_)

	return _os_
end

return SSearchFriend
