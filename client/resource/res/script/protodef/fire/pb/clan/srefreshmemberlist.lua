require "utils.tableutil"
require "protodef.rpcgen.fire.pb.clan.clanmember"
SRefreshMemberList = {}
SRefreshMemberList.__index = SRefreshMemberList



SRefreshMemberList.PROTOCOL_TYPE = 808493

function SRefreshMemberList.Create()
	print("enter SRefreshMemberList create")
	return SRefreshMemberList:new()
end
function SRefreshMemberList:new()
	local self = {}
	setmetatable(self, SRefreshMemberList)
	self.type = self.PROTOCOL_TYPE
	self.memberlist = {}

	return self
end
function SRefreshMemberList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRefreshMemberList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.memberlist))
	for k,v in ipairs(self.memberlist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SRefreshMemberList:unmarshal(_os_)
	----------------unmarshal vector
	local sizeof_memberlist=0,_os_null_memberlist
	_os_null_memberlist, sizeof_memberlist = _os_: uncompact_uint32(sizeof_memberlist)
	for k = 1,sizeof_memberlist do
		----------------unmarshal bean
		self.memberlist[k]=ClanMember:new()

		self.memberlist[k]:unmarshal(_os_)

	end
	return _os_
end

return SRefreshMemberList
