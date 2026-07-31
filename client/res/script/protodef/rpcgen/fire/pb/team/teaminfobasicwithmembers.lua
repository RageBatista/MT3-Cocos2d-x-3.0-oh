require "utils.tableutil"
require "protodef.rpcgen.fire.pb.team.teaminfobasic"
require "protodef.rpcgen.fire.pb.team.teammembersimple"
TeamInfoBasicWithMembers = {}
TeamInfoBasicWithMembers.__index = TeamInfoBasicWithMembers


function TeamInfoBasicWithMembers:new()
	local self = {}
	setmetatable(self, TeamInfoBasicWithMembers)
	self.teaminfobasic = TeamInfoBasic:new()
	self.memberlist = {}
	self.status = 0

	return self
end
function TeamInfoBasicWithMembers:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.teaminfobasic:marshal(_os_) 

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.memberlist))
	for k,v in ipairs(self.memberlist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	_os_:marshal_int32(self.status)
	return _os_
end

function TeamInfoBasicWithMembers:unmarshal(_os_)
	----------------unmarshal bean

	self.teaminfobasic:unmarshal(_os_)

	----------------unmarshal list
	local sizeof_memberlist=0 ,_os_null_memberlist
	_os_null_memberlist, sizeof_memberlist = _os_: uncompact_uint32(sizeof_memberlist)
	for k = 1,sizeof_memberlist do
		----------------unmarshal bean
		self.memberlist[k]=TeamMemberSimple:new()

		self.memberlist[k]:unmarshal(_os_)

	end
	self.status = _os_:unmarshal_int32()
	return _os_
end

return TeamInfoBasicWithMembers
