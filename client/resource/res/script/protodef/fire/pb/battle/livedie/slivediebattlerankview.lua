require "utils.tableutil"
require "protodef.rpcgen.fire.pb.battle.livedie.ldroleinfodes"
require "protodef.rpcgen.fire.pb.battle.livedie.ldteamroleinfodes"
require "protodef.rpcgen.fire.pb.battle.livedie.ldvideoroleinfodes"
SLiveDieBattleRankView = {}
SLiveDieBattleRankView.__index = SLiveDieBattleRankView



SLiveDieBattleRankView.PROTOCOL_TYPE = 793843

function SLiveDieBattleRankView.Create()
	print("enter SLiveDieBattleRankView create")
	return SLiveDieBattleRankView:new()
end
function SLiveDieBattleRankView:new()
	local self = {}
	setmetatable(self, SLiveDieBattleRankView)
	self.type = self.PROTOCOL_TYPE
	self.modeltype = 0
	self.rolefightlist = {}

	return self
end
function SLiveDieBattleRankView:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SLiveDieBattleRankView:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.modeltype)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.rolefightlist))
	for k,v in ipairs(self.rolefightlist) do
		----------------marshal bean
		v:marshal(_os_) 
	end

	return _os_
end

function SLiveDieBattleRankView:unmarshal(_os_)
	self.modeltype = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_rolefightlist=0,_os_null_rolefightlist
	_os_null_rolefightlist, sizeof_rolefightlist = _os_: uncompact_uint32(sizeof_rolefightlist)
	for k = 1,sizeof_rolefightlist do
		----------------unmarshal bean
		self.rolefightlist[k]=LDVideoRoleInfoDes:new()

		self.rolefightlist[k]:unmarshal(_os_)

	end
	return _os_
end

return SLiveDieBattleRankView
