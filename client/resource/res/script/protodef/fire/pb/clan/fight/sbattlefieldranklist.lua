require "utils.tableutil"
require "protodef.rpcgen.fire.pb.clan.fight.rolebattlefieldrank"
SBattleFieldRankList = {}
SBattleFieldRankList.__index = SBattleFieldRankList



SBattleFieldRankList.PROTOCOL_TYPE = 808539

function SBattleFieldRankList.Create()
	print("enter SBattleFieldRankList create")
	return SBattleFieldRankList:new()
end
function SBattleFieldRankList:new()
	local self = {}
	setmetatable(self, SBattleFieldRankList)
	self.type = self.PROTOCOL_TYPE
	self.clanscore1 = 0
	self.clanscroe2 = 0
	self.ranklist1 = {}
	self.ranklist2 = {}
	self.myscore = 0
	self.myrank = 0

	return self
end
function SBattleFieldRankList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SBattleFieldRankList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.clanscore1)
	_os_:marshal_int32(self.clanscroe2)

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.ranklist1))
	for k,v in ipairs(self.ranklist1) do
		----------------marshal bean
		v:marshal(_os_) 
	end


	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.ranklist2))
	for k,v in ipairs(self.ranklist2) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	_os_:marshal_int32(self.myscore)
	_os_:marshal_int32(self.myrank)
	return _os_
end

function SBattleFieldRankList:unmarshal(_os_)
	self.clanscore1 = _os_:unmarshal_int32()
	self.clanscroe2 = _os_:unmarshal_int32()
	----------------unmarshal list
	local sizeof_ranklist1=0 ,_os_null_ranklist1
	_os_null_ranklist1, sizeof_ranklist1 = _os_: uncompact_uint32(sizeof_ranklist1)
	for k = 1,sizeof_ranklist1 do
		----------------unmarshal bean
		self.ranklist1[k]=RoleBattleFieldRank:new()

		self.ranklist1[k]:unmarshal(_os_)

	end
	----------------unmarshal list
	local sizeof_ranklist2=0 ,_os_null_ranklist2
	_os_null_ranklist2, sizeof_ranklist2 = _os_: uncompact_uint32(sizeof_ranklist2)
	for k = 1,sizeof_ranklist2 do
		----------------unmarshal bean
		self.ranklist2[k]=RoleBattleFieldRank:new()

		self.ranklist2[k]:unmarshal(_os_)

	end
	self.myscore = _os_:unmarshal_int32()
	self.myrank = _os_:unmarshal_int32()
	return _os_
end

return SBattleFieldRankList
