require "utils.tableutil"
require "protodef.rpcgen.fire.pb.team.pos1"
require "protodef.rpcgen.fire.pb.team.teammemberbasic"
SAddTeamMember = {}
SAddTeamMember.__index = SAddTeamMember



SAddTeamMember.PROTOCOL_TYPE = 794436

function SAddTeamMember.Create()
	print("enter SAddTeamMember create")
	return SAddTeamMember:new()
end
function SAddTeamMember:new()
	local self = {}
	setmetatable(self, SAddTeamMember)
	self.type = self.PROTOCOL_TYPE
	self.memberlist = {}

	return self
end
function SAddTeamMember:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SAddTeamMember:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.memberlist))
	for k,v in ipairs(self.memberlist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SAddTeamMember:unmarshal(_os_)
	----------------unmarshal list
	local sizeof_memberlist=0 ,_os_null_memberlist
	_os_null_memberlist, sizeof_memberlist = _os_: uncompact_uint32(sizeof_memberlist)
	for k = 1,sizeof_memberlist do
		----------------unmarshal bean
		self.memberlist[k]=TeamMemberBasic:new()

		self.memberlist[k]:unmarshal(_os_)

	end
	return _os_
end

return SAddTeamMember
