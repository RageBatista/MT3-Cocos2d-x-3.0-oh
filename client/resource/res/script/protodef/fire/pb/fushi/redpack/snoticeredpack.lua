require "utils.tableutil"
require "protodef.rpcgen.fire.pb.fushi.redpack.redpackroletip"
SNoticeRedPack = {}
SNoticeRedPack.__index = SNoticeRedPack



SNoticeRedPack.PROTOCOL_TYPE = 812542

function SNoticeRedPack.Create()
	print("enter SNoticeRedPack create")
	return SNoticeRedPack:new()
end
function SNoticeRedPack:new()
	local self = {}
	setmetatable(self, SNoticeRedPack)
	self.type = self.PROTOCOL_TYPE
	self.redpackroletip = RedPackRoleTip:new()

	return self
end
function SNoticeRedPack:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SNoticeRedPack:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.redpackroletip:marshal(_os_) 
	return _os_
end

function SNoticeRedPack:unmarshal(_os_)
	----------------unmarshal bean

	self.redpackroletip:unmarshal(_os_)

	return _os_
end

return SNoticeRedPack
