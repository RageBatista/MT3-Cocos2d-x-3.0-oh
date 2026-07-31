require "utils.tableutil"
require "protodef.rpcgen.fire.pb.battle.pvp1.pvp1rolesinglescore"
require "protodef.rpcgen.fire.pb.battle.pvp1.pvp1rolesinglescoremid"
require "protodef.rpcgen.fire.pb.battle.pvp1.pvp1rolesinglewin"
SPvP1RankingList = {}
SPvP1RankingList.__index = SPvP1RankingList



SPvP1RankingList.PROTOCOL_TYPE = 793536

function SPvP1RankingList.Create()
	print("enter SPvP1RankingList create")
	return SPvP1RankingList:new()
end
function SPvP1RankingList:new()
	local self = {}
	setmetatable(self, SPvP1RankingList)
	self.type = self.PROTOCOL_TYPE
	self.rolescores = {}
	self.rolescores3 = {}
	self.rolewins = {}

	return self
end
function SPvP1RankingList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SPvP1RankingList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.rolescores))
	for k,v in ipairs(self.rolescores) do
		----------------marshal bean
		v:marshal(_os_) 
	end


	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.rolescores3))
	for k,v in ipairs(self.rolescores3) do
		----------------marshal bean
		v:marshal(_os_) 
	end


	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.rolewins))
	for k,v in ipairs(self.rolewins) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SPvP1RankingList:unmarshal(_os_)
	----------------unmarshal list
	local sizeof_rolescores=0 ,_os_null_rolescores
	_os_null_rolescores, sizeof_rolescores = _os_: uncompact_uint32(sizeof_rolescores)
	for k = 1,sizeof_rolescores do
		----------------unmarshal bean
		self.rolescores[k]=PvP1RoleSingleScore:new()

		self.rolescores[k]:unmarshal(_os_)

	end
	----------------unmarshal list
	local sizeof_rolescores3=0 ,_os_null_rolescores3
	_os_null_rolescores3, sizeof_rolescores3 = _os_: uncompact_uint32(sizeof_rolescores3)
	for k = 1,sizeof_rolescores3 do
		----------------unmarshal bean
		self.rolescores3[k]=PvP1RoleSingleScoreMid:new()

		self.rolescores3[k]:unmarshal(_os_)

	end
	----------------unmarshal list
	local sizeof_rolewins=0 ,_os_null_rolewins
	_os_null_rolewins, sizeof_rolewins = _os_: uncompact_uint32(sizeof_rolewins)
	for k = 1,sizeof_rolewins do
		----------------unmarshal bean
		self.rolewins[k]=PvP1RoleSingleWin:new()

		self.rolewins[k]:unmarshal(_os_)

	end
	return _os_
end

return SPvP1RankingList
