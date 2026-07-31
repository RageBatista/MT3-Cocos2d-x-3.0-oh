require "utils.tableutil"
require "protodef.rpcgen.fire.pb.team.teaminfobasic"
require "protodef.rpcgen.fire.pb.team.teaminfobasicwithmembers"
require "protodef.rpcgen.fire.pb.team.teammembersimple"
SRequestTeamMatchList = {}
SRequestTeamMatchList.__index = SRequestTeamMatchList



SRequestTeamMatchList.PROTOCOL_TYPE = 794510

function SRequestTeamMatchList.Create()
	print("enter SRequestTeamMatchList create")
	return SRequestTeamMatchList:new()
end
function SRequestTeamMatchList:new()
	local self = {}
	setmetatable(self, SRequestTeamMatchList)
	self.type = self.PROTOCOL_TYPE
	self.ret = 0
	self.targetid = 0
	self.teamlist = {}

	return self
end
function SRequestTeamMatchList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRequestTeamMatchList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.ret)
	_os_:marshal_int32(self.targetid)

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.teamlist))
	for k,v in ipairs(self.teamlist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SRequestTeamMatchList:unmarshal(_os_)
	self.ret = _os_:unmarshal_int32()
	self.targetid = _os_:unmarshal_int32()
	----------------unmarshal list
	local sizeof_teamlist=0 ,_os_null_teamlist
	_os_null_teamlist, sizeof_teamlist = _os_: uncompact_uint32(sizeof_teamlist)
	for k = 1,sizeof_teamlist do
		----------------unmarshal bean
		self.teamlist[k]=TeamInfoBasicWithMembers:new()

		self.teamlist[k]:unmarshal(_os_)

	end
	return _os_
end

return SRequestTeamMatchList
