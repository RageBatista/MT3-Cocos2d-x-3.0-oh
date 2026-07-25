require "utils.tableutil"
require "protodef.rpcgen.fire.pb.friends.friendinfo"
require "protodef.rpcgen.fire.pb.friends.infobean"
SFriendsInfoInit = {}
SFriendsInfoInit.__index = SFriendsInfoInit



SFriendsInfoInit.PROTOCOL_TYPE = 806433

function SFriendsInfoInit.Create()
	print("enter SFriendsInfoInit create")
	return SFriendsInfoInit:new()
end
function SFriendsInfoInit:new()
	local self = {}
	setmetatable(self, SFriendsInfoInit)
	self.type = self.PROTOCOL_TYPE
	self.friends = {}
	self.friendnumlimit = 0
	self.refusestrangermsg = 0

	return self
end
function SFriendsInfoInit:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SFriendsInfoInit:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.friends))
	for k,v in ipairs(self.friends) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	_os_:marshal_short(self.friendnumlimit)
	_os_:marshal_char(self.refusestrangermsg)
	return _os_
end

function SFriendsInfoInit:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_friends=0,_os_null_friends
	_os_null_friends, sizeof_friends = _os_: uncompact_uint32(sizeof_friends)
	for k = 1,sizeof_friends do
		----------------unmarshal bean
		self.friends[k]=FriendInfo:new()

		self.friends[k]:unmarshal(_os_)

	end
	self.friendnumlimit = _os_:unmarshal_short()
	self.refusestrangermsg = _os_:unmarshal_char()
	return _os_
end

return SFriendsInfoInit
