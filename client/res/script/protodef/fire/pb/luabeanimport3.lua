require "utils.tableutil"
require "protodef.rpcgen.fire.pb.errorcodes"
require "protodef.rpcgen.fire.pb.funopenclosetype"
require "protodef.rpcgen.fire.pb.rolesex"
require "protodef.rpcgen.fire.pb.sysconfigtype"
require "protodef.rpcgen.fire.pb.circletask.refreshdatatype"
require "protodef.rpcgen.fire.pb.circletask.specialqueststate"
require "protodef.rpcgen.fire.pb.game.moneytype"
require "protodef.rpcgen.fire.pb.item.composegeminfobean"
require "protodef.rpcgen.fire.pb.mission.missionexetypes"
require "protodef.rpcgen.fire.pb.mission.missionfintypes"
require "protodef.rpcgen.fire.pb.mission.missionstatus"
require "protodef.rpcgen.fire.pb.mission.npcexecutetasktypes"
require "protodef.rpcgen.fire.pb.mission.readtimetype"
require "protodef.rpcgen.fire.pb.move.rolebasicoctets"
require "protodef.rpcgen.fire.pb.move.showpetoctets"
require "protodef.rpcgen.fire.pb.move.teaminfooctets"
require "protodef.rpcgen.fire.pb.npc.transmittypes"
require "protodef.rpcgen.fire.pb.pet.peterror"
require "protodef.rpcgen.fire.pb.ranklist.bingfengrankdata"
require "protodef.rpcgen.fire.pb.ranklist.clanfighthistroyrank"
require "protodef.rpcgen.fire.pb.ranklist.clanfightracerank"
require "protodef.rpcgen.fire.pb.ranklist.factionraidrankrecord"
require "protodef.rpcgen.fire.pb.ranklist.factionrankrecord"
require "protodef.rpcgen.fire.pb.ranklist.factionrankrecordex"
require "protodef.rpcgen.fire.pb.ranklist.flowerrankrecord"
require "protodef.rpcgen.fire.pb.ranklist.levelrankdata"
require "protodef.rpcgen.fire.pb.ranklist.petgraderankdata"
require "protodef.rpcgen.fire.pb.ranklist.pvp5rankdata"
require "protodef.rpcgen.fire.pb.ranklist.ranktype"
require "protodef.rpcgen.fire.pb.ranklist.redpackrankrecord"
require "protodef.rpcgen.fire.pb.ranklist.roleprofessionrankrecord"
require "protodef.rpcgen.fire.pb.ranklist.rolezongherankrecord"
require "protodef.rpcgen.fire.pb.shop.shopbuytype"
require "protodef.rpcgen.fire.pb.skill.assistskill"
require "protodef.rpcgen.fire.pb.talk.channeltype"
LuaBeanImport3 = {}
LuaBeanImport3.__index = LuaBeanImport3



LuaBeanImport3.PROTOCOL_TYPE = 786518

function LuaBeanImport3.Create()
	print("enter LuaBeanImport3 create")
	return LuaBeanImport3:new()
end
function LuaBeanImport3:new()
	local self = {}
	setmetatable(self, LuaBeanImport3)
	self.type = self.PROTOCOL_TYPE
	self.b1 = LevelRankData:new()
	self.b2 = PetGradeRankData:new()
	self.b122 = RankType:new()
	self.b5 = FactionRankRecord:new()
	self.b6 = RoleZongheRankRecord:new()
	self.b7 = RoleProfessionRankRecord:new()
	self.b8 = PvP5RankData:new()
	self.b42 = RoleSex:new()
	self.b999 = AssistSkill:new()
	self.b39 = BingFengRankData:new()
	self.b43 = ErrorCodes:new()
	self.b50 = FactionRankRecordEx:new()
	self.b51 = FactionRaidRankRecord:new()
	self.b52 = MissionExeTypes:new()
	self.b57 = SpecialQuestState:new()
	self.b59 = MissionFinTypes:new()
	self.b9 = SysConfigType:new()
	self.b77 = NpcExecuteTaskTypes:new()
	self.b109 = ReadTimeType:new()
	self.b93 = RefreshDataType:new()
	self.b89 = TransmitTypes:new()
	self.b3 = ChannelType:new()
	self.b53 = MissionStatus:new()
	self.b102 = RoleBasicOctets:new()
	self.b128 = TeamInfoOctets:new()
	self.b127 = ShowPetOctets:new()
	self.b217 = FunOpenCloseType:new()
	self.b13 = PetError:new()
	self.b192 = ShopBuyType:new()
	self.b199 = MoneyType:new()
	self.b201 = RedPackRankRecord:new()
	self.b202 = FlowerRankRecord:new()
	self.b203 = ClanFightRaceRank:new()
	self.b204 = ClanFightHistroyRank:new()
	self.b205 = ComposeGemInfoBean:new()

	return self
end
function LuaBeanImport3:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function LuaBeanImport3:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	----------------marshal bean
	self.b1:marshal(_os_) 
	----------------marshal bean
	self.b2:marshal(_os_) 
	----------------marshal bean
	self.b122:marshal(_os_) 
	----------------marshal bean
	self.b5:marshal(_os_) 
	----------------marshal bean
	self.b6:marshal(_os_) 
	----------------marshal bean
	self.b7:marshal(_os_) 
	----------------marshal bean
	self.b8:marshal(_os_) 
	----------------marshal bean
	self.b42:marshal(_os_) 
	----------------marshal bean
	self.b999:marshal(_os_) 
	----------------marshal bean
	self.b39:marshal(_os_) 
	----------------marshal bean
	self.b43:marshal(_os_) 
	----------------marshal bean
	self.b50:marshal(_os_) 
	----------------marshal bean
	self.b51:marshal(_os_) 
	----------------marshal bean
	self.b52:marshal(_os_) 
	----------------marshal bean
	self.b57:marshal(_os_) 
	----------------marshal bean
	self.b59:marshal(_os_) 
	----------------marshal bean
	self.b9:marshal(_os_) 
	----------------marshal bean
	self.b77:marshal(_os_) 
	----------------marshal bean
	self.b109:marshal(_os_) 
	----------------marshal bean
	self.b93:marshal(_os_) 
	----------------marshal bean
	self.b89:marshal(_os_) 
	----------------marshal bean
	self.b3:marshal(_os_) 
	----------------marshal bean
	self.b53:marshal(_os_) 
	----------------marshal bean
	self.b102:marshal(_os_) 
	----------------marshal bean
	self.b128:marshal(_os_) 
	----------------marshal bean
	self.b127:marshal(_os_) 
	----------------marshal bean
	self.b217:marshal(_os_) 
	----------------marshal bean
	self.b13:marshal(_os_) 
	----------------marshal bean
	self.b192:marshal(_os_) 
	----------------marshal bean
	self.b199:marshal(_os_) 
	----------------marshal bean
	self.b201:marshal(_os_) 
	----------------marshal bean
	self.b202:marshal(_os_) 
	----------------marshal bean
	self.b203:marshal(_os_) 
	----------------marshal bean
	self.b204:marshal(_os_) 
	----------------marshal bean
	self.b205:marshal(_os_) 
	return _os_
end

function LuaBeanImport3:unmarshal(_os_)
	----------------unmarshal bean

	self.b1:unmarshal(_os_)

	----------------unmarshal bean

	self.b2:unmarshal(_os_)

	----------------unmarshal bean

	self.b122:unmarshal(_os_)

	----------------unmarshal bean

	self.b5:unmarshal(_os_)

	----------------unmarshal bean

	self.b6:unmarshal(_os_)

	----------------unmarshal bean

	self.b7:unmarshal(_os_)

	----------------unmarshal bean

	self.b8:unmarshal(_os_)

	----------------unmarshal bean

	self.b42:unmarshal(_os_)

	----------------unmarshal bean

	self.b999:unmarshal(_os_)

	----------------unmarshal bean

	self.b39:unmarshal(_os_)

	----------------unmarshal bean

	self.b43:unmarshal(_os_)

	----------------unmarshal bean

	self.b50:unmarshal(_os_)

	----------------unmarshal bean

	self.b51:unmarshal(_os_)

	----------------unmarshal bean

	self.b52:unmarshal(_os_)

	----------------unmarshal bean

	self.b57:unmarshal(_os_)

	----------------unmarshal bean

	self.b59:unmarshal(_os_)

	----------------unmarshal bean

	self.b9:unmarshal(_os_)

	----------------unmarshal bean

	self.b77:unmarshal(_os_)

	----------------unmarshal bean

	self.b109:unmarshal(_os_)

	----------------unmarshal bean

	self.b93:unmarshal(_os_)

	----------------unmarshal bean

	self.b89:unmarshal(_os_)

	----------------unmarshal bean

	self.b3:unmarshal(_os_)

	----------------unmarshal bean

	self.b53:unmarshal(_os_)

	----------------unmarshal bean

	self.b102:unmarshal(_os_)

	----------------unmarshal bean

	self.b128:unmarshal(_os_)

	----------------unmarshal bean

	self.b127:unmarshal(_os_)

	----------------unmarshal bean

	self.b217:unmarshal(_os_)

	----------------unmarshal bean

	self.b13:unmarshal(_os_)

	----------------unmarshal bean

	self.b192:unmarshal(_os_)

	----------------unmarshal bean

	self.b199:unmarshal(_os_)

	----------------unmarshal bean

	self.b201:unmarshal(_os_)

	----------------unmarshal bean

	self.b202:unmarshal(_os_)

	----------------unmarshal bean

	self.b203:unmarshal(_os_)

	----------------unmarshal bean

	self.b204:unmarshal(_os_)

	----------------unmarshal bean

	self.b205:unmarshal(_os_)

	return _os_
end

return LuaBeanImport3
