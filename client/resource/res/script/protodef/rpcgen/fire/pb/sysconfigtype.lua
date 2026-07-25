require "utils.tableutil"
SysConfigType = {
	Music = 1,
	Volume = 2,
	SoundSpecEffect = 3,
	SceneEffect = 4,
	MaxScreenShowNum = 5,
	ScreenRefresh = 6,
	AutoVoiceGang = 7,
	AutoVoiceWorld = 8,
	AutoVoiceTeam = 9,
	AutoVoiceSchool = 10,
	RefuseFriend = 11,
	WorldChannel = 12,
	GangChannel = 13,
	SchoolChannel = 14,
	CurrentChannel = 15,
	TeamChannel = 16,
	PVPNotify = 17,
	friendchatencrypt = 18,
	friendmessage = 19,
	rolePointAdd = 20,
	petPointAdd = 21,
	skillPointAdd = 22,
	huoyueduAdd = 23,
	zhenfaAdd = 24,
	skillopen = 25,
	factionopen = 26,
	petopen = 27,
	patopen = 28,
	zuduichannel = 29,
	guajiopen = 30,
	zhiyinopen = 31,
	huodongopen = 32,
	refuseqiecuo = 33,
	ts_julonghuwei = 34,
	ts_julongjuntuan = 35,
	ts_guanjunshilian = 36,
	ts_renwentansuo = 37,
	ts_1v1 = 38,
	ts_gonghuifuben = 39,
	ts_3v3 = 40,
	ts_zhihuishilian = 41,
	refuseclan = 42,
	refuseotherseeequip = 43,
	screenrecord = 44,
	equipendure = 45,
	ts_gonghuizhan = 46,
	rolldianshezhi = 47,
	framesimplify = 48
}
SysConfigType.__index = SysConfigType


function SysConfigType:new()
	local self = {}
	setmetatable(self, SysConfigType)
	return self
end
function SysConfigType:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SysConfigType:unmarshal(_os_)
	return _os_
end

return SysConfigType
