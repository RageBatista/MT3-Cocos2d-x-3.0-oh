require "utils.tableutil"
require "protodef.rpcgen.fire.pb.battle.pvp3.pvp3rolesinglescore"
require "protodef.rpcgen.fire.pb.battle.pvp3.pvp3rolesinglescoremid"
SPvP3RankingList = {}
SPvP3RankingList.__index = SPvP3RankingList



SPvP3RankingList.PROTOCOL_TYPE = 793636

function SPvP3RankingList.Create()
	print("enter SPvP3RankingList create")
	return SPvP3RankingList:new()
end
function SPvP3RankingList:new()
	local self = {}
	setmetatable(self, SPvP3RankingList)
	self.type = self.PROTOCOL_TYPE
	self.history = 0
	self.rolescores = {}
	self.myscore = {}

	return self
end
function SPvP3RankingList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SPvP3RankingList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.history)

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.rolescores))
	for k,v in ipairs(self.rolescores) do
		----------------marshal bean
		v:marshal(_os_) 
	end


	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.myscore))
	for k,v in ipairs(self.myscore) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SPvP3RankingList:unmarshal(_os_)
	self.history = _os_:unmarshal_char()
	----------------unmarshal list
	local sizeof_rolescores=0 ,_os_null_rolescores
	_os_null_rolescores, sizeof_rolescores = _os_: uncompact_uint32(sizeof_rolescores)
	for k = 1,sizeof_rolescores do
		----------------unmarshal bean
		self.rolescores[k]=PvP3RoleSingleScore:new()

		self.rolescores[k]:unmarshal(_os_)

	end
	----------------unmarshal list
	local sizeof_myscore=0 ,_os_null_myscore
	_os_null_myscore, sizeof_myscore = _os_: uncompact_uint32(sizeof_myscore)
	for k = 1,sizeof_myscore do
		----------------unmarshal bean
		self.myscore[k]=PvP3RoleSingleScoreMid:new()

		self.myscore[k]:unmarshal(_os_)

	end
	return _os_
end

return SPvP3RankingList
