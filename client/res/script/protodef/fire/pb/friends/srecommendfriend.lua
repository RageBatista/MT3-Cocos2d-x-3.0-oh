require "utils.tableutil"
require "protodef.rpcgen.fire.pb.friends.infobean"
SRecommendFriend = {}
SRecommendFriend.__index = SRecommendFriend



SRecommendFriend.PROTOCOL_TYPE = 806577

function SRecommendFriend.Create()
	print("enter SRecommendFriend create")
	return SRecommendFriend:new()
end
function SRecommendFriend:new()
	local self = {}
	setmetatable(self, SRecommendFriend)
	self.type = self.PROTOCOL_TYPE
	self.friendinfobeanlist = {}

	return self
end
function SRecommendFriend:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRecommendFriend:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.friendinfobeanlist))
	for k,v in ipairs(self.friendinfobeanlist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SRecommendFriend:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_friendinfobeanlist=0,_os_null_friendinfobeanlist
	_os_null_friendinfobeanlist, sizeof_friendinfobeanlist = _os_: uncompact_uint32(sizeof_friendinfobeanlist)
	for k = 1,sizeof_friendinfobeanlist do
		----------------unmarshal bean
		self.friendinfobeanlist[k]=InfoBean:new()

		self.friendinfobeanlist[k]:unmarshal(_os_)

	end
	return _os_
end

return SRecommendFriend
