require "utils.tableutil"
require "protodef.rpcgen.fire.pb.team.pos1"
require "protodef.rpcgen.fire.pb.team.teammemberbasic"
SUpdateTeamMemberBasic = {}
SUpdateTeamMemberBasic.__index = SUpdateTeamMemberBasic



SUpdateTeamMemberBasic.PROTOCOL_TYPE = 794485

function SUpdateTeamMemberBasic.Create()
	print("enter SUpdateTeamMemberBasic create")
	return SUpdateTeamMemberBasic:new()
end
function SUpdateTeamMemberBasic:new()
	local self = {}
	setmetatable(self, SUpdateTeamMemberBasic)
	self.type = self.PROTOCOL_TYPE
	self.data = TeamMemberBasic:new()

	return self
end
function SUpdateTeamMemberBasic:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SUpdateTeamMemberBasic:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.data:marshal(_os_) 
	return _os_
end

function SUpdateTeamMemberBasic:unmarshal(_os_)
	----------------unmarshal bean

	self.data:unmarshal(_os_)

	return _os_
end

return SUpdateTeamMemberBasic
