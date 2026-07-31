require "utils.tableutil"
require "protodef.rpcgen.fire.pb.friends.infobean"
FriendInfo = {}
FriendInfo.__index = FriendInfo


function FriendInfo:new()
	local self = {}
	setmetatable(self, FriendInfo)
	self.friendinfobean = InfoBean:new()
	self.friendlevel = 0

	return self
end
function FriendInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.friendinfobean:marshal(_os_) 
	_os_:marshal_int32(self.friendlevel)
	return _os_
end

function FriendInfo:unmarshal(_os_)
	----------------unmarshal bean

	self.friendinfobean:unmarshal(_os_)

	self.friendlevel = _os_:unmarshal_int32()
	return _os_
end

return FriendInfo
