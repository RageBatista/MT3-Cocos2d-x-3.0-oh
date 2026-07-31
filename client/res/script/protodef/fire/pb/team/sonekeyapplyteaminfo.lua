require "utils.tableutil"
require "protodef.rpcgen.fire.pb.team.teammembersimple"
SOneKeyApplyTeamInfo = {}
SOneKeyApplyTeamInfo.__index = SOneKeyApplyTeamInfo



SOneKeyApplyTeamInfo.PROTOCOL_TYPE = 794518

function SOneKeyApplyTeamInfo.Create()
	print("enter SOneKeyApplyTeamInfo create")
	return SOneKeyApplyTeamInfo:new()
end
function SOneKeyApplyTeamInfo:new()
	local self = {}
	setmetatable(self, SOneKeyApplyTeamInfo)
	self.type = self.PROTOCOL_TYPE
	self.teamid = 0
	self.memberlist = {}

	return self
end
function SOneKeyApplyTeamInfo:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SOneKeyApplyTeamInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.teamid)

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.memberlist))
	for k,v in ipairs(self.memberlist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SOneKeyApplyTeamInfo:unmarshal(_os_)
	self.teamid = _os_:unmarshal_int64()
	----------------unmarshal list
	local sizeof_memberlist=0 ,_os_null_memberlist
	_os_null_memberlist, sizeof_memberlist = _os_: uncompact_uint32(sizeof_memberlist)
	for k = 1,sizeof_memberlist do
		----------------unmarshal bean
		self.memberlist[k]=TeamMemberSimple:new()

		self.memberlist[k]:unmarshal(_os_)

	end
	return _os_
end

return SOneKeyApplyTeamInfo
