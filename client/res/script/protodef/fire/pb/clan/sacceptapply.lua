require "utils.tableutil"
require "protodef.rpcgen.fire.pb.clan.clanmember"
SAcceptApply = {}
SAcceptApply.__index = SAcceptApply



SAcceptApply.PROTOCOL_TYPE = 808478

function SAcceptApply.Create()
	print("enter SAcceptApply create")
	return SAcceptApply:new()
end
function SAcceptApply:new()
	local self = {}
	setmetatable(self, SAcceptApply)
	self.type = self.PROTOCOL_TYPE
	self.memberinfo = ClanMember:new()

	return self
end
function SAcceptApply:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SAcceptApply:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.memberinfo:marshal(_os_) 
	return _os_
end

function SAcceptApply:unmarshal(_os_)
	----------------unmarshal bean

	self.memberinfo:unmarshal(_os_)

	return _os_
end

return SAcceptApply
