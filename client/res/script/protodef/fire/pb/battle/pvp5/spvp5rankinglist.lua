require "utils.tableutil"
require "protodef.rpcgen.fire.pb.battle.pvp5.pvp5rolesinglescore"
require "protodef.rpcgen.fire.pb.battle.pvp5.pvp5rolesinglescoremid"
SPvP5RankingList = {}
SPvP5RankingList.__index = SPvP5RankingList



SPvP5RankingList.PROTOCOL_TYPE = 793666

function SPvP5RankingList.Create()
	print("enter SPvP5RankingList create")
	return SPvP5RankingList:new()
end
function SPvP5RankingList:new()
	local self = {}
	setmetatable(self, SPvP5RankingList)
	self.type = self.PROTOCOL_TYPE
	self.rolescores1 = {}
	self.rolescores2 = {}
	self.myscore = PvP5RoleSingleScoreMid:new()

	return self
end
function SPvP5RankingList:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SPvP5RankingList:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.rolescores1))
	for k,v in ipairs(self.rolescores1) do
		----------------marshal bean
		v:marshal(_os_) 
	end


	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.rolescores2))
	for k,v in ipairs(self.rolescores2) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	----------------marshal bean
	self.myscore:marshal(_os_) 
	return _os_
end

function SPvP5RankingList:unmarshal(_os_)
	----------------unmarshal list
	local sizeof_rolescores1=0 ,_os_null_rolescores1
	_os_null_rolescores1, sizeof_rolescores1 = _os_: uncompact_uint32(sizeof_rolescores1)
	for k = 1,sizeof_rolescores1 do
		----------------unmarshal bean
		self.rolescores1[k]=PvP5RoleSingleScore:new()

		self.rolescores1[k]:unmarshal(_os_)

	end
	----------------unmarshal list
	local sizeof_rolescores2=0 ,_os_null_rolescores2
	_os_null_rolescores2, sizeof_rolescores2 = _os_: uncompact_uint32(sizeof_rolescores2)
	for k = 1,sizeof_rolescores2 do
		----------------unmarshal bean
		self.rolescores2[k]=PvP5RoleSingleScore:new()

		self.rolescores2[k]:unmarshal(_os_)

	end
	----------------unmarshal bean

	self.myscore:unmarshal(_os_)

	return _os_
end

return SPvP5RankingList
