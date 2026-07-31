require "utils.tableutil"
require "protodef.rpcgen.fire.pb.clan.fight.clanfight"
SGetClanFightList = {}
SGetClanFightList.__index = SGetClanFightList



SGetClanFightList.PROTOCOL_TYPE = 808533

function SGetClanFightList.Create()
	print("enter SGetClanFightList create")
	return SGetClanFightList:new()
end
function SGetClanFightList:new()
	local self = {}
	setmetatable(self, SGetClanFightList)
	self.type = self.PROTOCOL_TYPE
	self.clanfightlist = {}
	self.curweek = 0
	self.over = 0

	return self
end
function SGetClanFightList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGetClanFightList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.clanfightlist))
	for k,v in ipairs(self.clanfightlist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	_os_:marshal_int32(self.curweek)
	_os_:marshal_int32(self.over)
	return _os_
end

function SGetClanFightList:unmarshal(_os_)
	----------------unmarshal list
	local sizeof_clanfightlist=0 ,_os_null_clanfightlist
	_os_null_clanfightlist, sizeof_clanfightlist = _os_: uncompact_uint32(sizeof_clanfightlist)
	for k = 1,sizeof_clanfightlist do
		----------------unmarshal bean
		self.clanfightlist[k]=ClanFight:new()

		self.clanfightlist[k]:unmarshal(_os_)

	end
	self.curweek = _os_:unmarshal_int32()
	self.over = _os_:unmarshal_int32()
	return _os_
end

return SGetClanFightList
