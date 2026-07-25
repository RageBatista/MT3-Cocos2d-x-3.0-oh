require "utils.tableutil"
require "protodef.rpcgen.fire.pb.team.teaminfobasic"
require "protodef.rpcgen.fire.pb.team.teaminfobasicwithmembers"
require "protodef.rpcgen.fire.pb.team.teammembersimple"
SRequestClanFightTeamList = {}
SRequestClanFightTeamList.__index = SRequestClanFightTeamList



SRequestClanFightTeamList.PROTOCOL_TYPE = 794558

function SRequestClanFightTeamList.Create()
	print("enter SRequestClanFightTeamList create")
	return SRequestClanFightTeamList:new()
end
function SRequestClanFightTeamList:new()
	local self = {}
	setmetatable(self, SRequestClanFightTeamList)
	self.type = self.PROTOCOL_TYPE
	self.isfresh = 0
	self.teamlist = {}
	self.ret = 0

	return self
end
function SRequestClanFightTeamList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRequestClanFightTeamList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.isfresh)

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.teamlist))
	for k,v in ipairs(self.teamlist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	_os_:marshal_int32(self.ret)
	return _os_
end

function SRequestClanFightTeamList:unmarshal(_os_)
	self.isfresh = _os_:unmarshal_int32()
	----------------unmarshal list
	local sizeof_teamlist=0 ,_os_null_teamlist
	_os_null_teamlist, sizeof_teamlist = _os_: uncompact_uint32(sizeof_teamlist)
	for k = 1,sizeof_teamlist do
		----------------unmarshal bean
		self.teamlist[k]=TeamInfoBasicWithMembers:new()

		self.teamlist[k]:unmarshal(_os_)

	end
	self.ret = _os_:unmarshal_int32()
	return _os_
end

return SRequestClanFightTeamList
