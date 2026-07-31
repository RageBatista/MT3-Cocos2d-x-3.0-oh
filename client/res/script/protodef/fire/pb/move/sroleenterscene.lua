require "utils.tableutil"
require "protodef.rpcgen.fire.pb.move.pos"
SRoleEnterScene = {
	CHANNEAL = 516012,
	ITEM = 516013,
	SYSTEM_DRAG = 516014,
	ENTER = 516015,
	DEATH = 516016,
	CHEFU = 516017,
	QUEST_CG = 516018,
	FORCE_GOTO = 516019,
	SKILL = 516020,
	MARRIAGE = 516021,
	QUEST = 516022,
	DRAGONBOAT = 516023,
	GM_HOLD = 516025,
	INSTANCE = 516026,
	ENTER_COMMON_SCENCE = 516028,
	ENTER_LINE_SCENCE = 516029,
	CLAN_GOTO = 516030,
	BING_FENG_GOTO = 516031
}
SRoleEnterScene.__index = SRoleEnterScene



SRoleEnterScene.PROTOCOL_TYPE = 790441

function SRoleEnterScene.Create()
	print("enter SRoleEnterScene create")
	return SRoleEnterScene:new()
end
function SRoleEnterScene:new()
	local self = {}
	setmetatable(self, SRoleEnterScene)
	self.type = self.PROTOCOL_TYPE
	self.ownername = "" 
	self.destpos = Pos:new()
	self.destz = 0
	self.changetype = 0
	self.sceneid = 0
	self.weatherid = 0
	self.tipsparm = "" 

	return self
end
function SRoleEnterScene:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRoleEnterScene:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.ownername)
	----------------marshal bean
	self.destpos:marshal(_os_) 
	_os_:marshal_char(self.destz)
	_os_:marshal_int32(self.changetype)
	_os_:marshal_int64(self.sceneid)
	_os_:marshal_char(self.weatherid)
	_os_:marshal_wstring(self.tipsparm)
	return _os_
end

function SRoleEnterScene:unmarshal(_os_)
	self.ownername = _os_:unmarshal_wstring(self.ownername)
	----------------unmarshal bean

	self.destpos:unmarshal(_os_)

	self.destz = _os_:unmarshal_char()
	self.changetype = _os_:unmarshal_int32()
	self.sceneid = _os_:unmarshal_int64()
	self.weatherid = _os_:unmarshal_char()
	self.tipsparm = _os_:unmarshal_wstring(self.tipsparm)
	return _os_
end

return SRoleEnterScene
