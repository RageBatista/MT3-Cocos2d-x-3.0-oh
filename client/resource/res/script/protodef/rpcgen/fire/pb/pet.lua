require "utils.tableutil"
require "protodef.rpcgen.fire.pb.basicfightproperties"
require "protodef.rpcgen.fire.pb.petskill"
Pet = {
	FLAG_LOCK = 1,
	FLAG_BIND = 2
}
Pet.__index = Pet


function Pet:new()
	local self = {}
	setmetatable(self, Pet)
	self.id = 0
	self.key = 0
	self.name = "" 
	--self.zhuansheng = 0
	self.level = 0
	self.uselevel = 0
	self.xuemai = 0
	self.gengu = 0
	self.colour = 0
	self.hp = 0
	self.maxhp = 0
	self.mp = 0
	self.maxmp = 0
	self.attack = 0
	self.defend = 0
	self.speed = 0
	self.magicattack = 0
	self.magicdef = 0
	self.scale = 0
	self.initbfp = BasicFightProperties:new()
	self.bfp = BasicFightProperties:new()
	self.point = 0
	self.autoaddcons = 0
	self.autoaddiq = 0
	self.autoaddstr = 0
	self.autoaddendu = 0
	self.autoaddagi = 0
	self.pointresetcount = 0
	self.exp = 0
	self.nexp = 0
	self.attackapt = 0
	self.defendapt = 0
	self.phyforceapt = 0
	self.magicapt = 0
	self.speedapt = 0
	self.dodgeapt = 0
	self.growrate = 0
	self.life = 0
	self.kind = 0
	self.skills = {}
	self.skillexpires = {}
	self.flag = 0
	self.timeout = 0
	self.ownerid = 0
	self.ownername = "" 
	self.rank = 0
	self.starid = 0
	self.practisetimes = 0
	self.zizhi = {}
	self.changegengu = 0
	self.skill_grids = 0
	self.aptaddcount = 0
	self.growrateaddcount = 0
	self.washcount = 0
	self.petscore = 0
	self.petbasescore = 0
	self.petdye1 = 0
	self.petdye2 = 0
	self.shenshouinccount = 0
	self.marketfreezeexpire = 0
	self.internals = {}
	self.qianye = 0
	return self
end
function Pet:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.id)
	_os_:marshal_int32(self.key)
	_os_:marshal_wstring(self.name)
	--_os_:marshal_int32(self.zhuansheng)
	_os_:marshal_int32(self.level)
	_os_:marshal_int32(self.uselevel)
	_os_:marshal_int32(self.xuemai)
	_os_:marshal_int32(self.gengu)
	_os_:marshal_int32(self.colour)
	_os_:marshal_int32(self.hp)
	_os_:marshal_int32(self.maxhp)
	_os_:marshal_int32(self.mp)
	_os_:marshal_int32(self.maxmp)
	_os_:marshal_int32(self.attack)
	_os_:marshal_int32(self.defend)
	_os_:marshal_int32(self.speed)
	_os_:marshal_int32(self.magicattack)
	_os_:marshal_int32(self.magicdef)
	_os_:marshal_char(self.scale)
	----------------marshal bean
	self.initbfp:marshal(_os_) 
	----------------marshal bean
	self.bfp:marshal(_os_) 
	_os_:marshal_short(self.point)
	_os_:marshal_char(self.autoaddcons)
	_os_:marshal_char(self.autoaddiq)
	_os_:marshal_char(self.autoaddstr)
	_os_:marshal_char(self.autoaddendu)
	_os_:marshal_char(self.autoaddagi)
	_os_:marshal_short(self.pointresetcount)
	_os_:marshal_int64(self.exp)
	_os_:marshal_int64(self.nexp)
	_os_:marshal_int32(self.attackapt)
	_os_:marshal_int32(self.defendapt)
	_os_:marshal_int32(self.phyforceapt)
	_os_:marshal_int32(self.magicapt)
	_os_:marshal_int32(self.speedapt)
	_os_:marshal_int32(self.dodgeapt)
	_os_:marshal_float(self.growrate)
	_os_:marshal_int32(self.life)
	_os_:marshal_int32(self.kind)

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.skills))
	for k,v in ipairs(self.skills) do
		----------------marshal bean
		v:marshal(_os_) 
	end


	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.skillexpires))
	for k,v in pairs(self.skillexpires) do
		_os_:marshal_int32(k)
		_os_:marshal_int64(v)
	end

	_os_:marshal_char(self.flag)
	_os_:marshal_int64(self.timeout)
	_os_:marshal_int64(self.ownerid)
	_os_:marshal_wstring(self.ownername)
	_os_:marshal_int32(self.rank)
	_os_:marshal_short(self.starid)
	_os_:marshal_short(self.practisetimes)

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.zizhi))
	for k,v in pairs(self.zizhi) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end

	_os_:marshal_int32(self.changegengu)
	_os_:marshal_int32(self.skill_grids)
	_os_:marshal_char(self.aptaddcount)
	_os_:marshal_char(self.growrateaddcount)
	_os_:marshal_short(self.washcount)
	_os_:marshal_int32(self.petscore)
	_os_:marshal_int32(self.petbasescore)
	_os_:marshal_int32(self.petdye1)
	_os_:marshal_int32(self.petdye2)
	_os_:marshal_int32(self.shenshouinccount)
	_os_:marshal_int64(self.marketfreezeexpire)
	
	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.internals))
	for k,v in ipairs(self.internals) do
		----------------marshal bean
		v:marshal(_os_) 
	end
	_os_:marshal_int32(self.qianye)
	return _os_
end

function Pet:unmarshal(_os_)
	self.id = _os_:unmarshal_int32()
	self.key = _os_:unmarshal_int32()
	self.name = _os_:unmarshal_wstring(self.name)
	--self.zhuansheng = _os_:unmarshal_int32()
	self.level = _os_:unmarshal_int32()
	self.uselevel = _os_:unmarshal_int32()
	self.xuemai = _os_:unmarshal_int32()
	self.gengu = _os_:unmarshal_int32()
	self.colour = _os_:unmarshal_int32()
	self.hp = _os_:unmarshal_int32()
	self.maxhp = _os_:unmarshal_int32()
	self.mp = _os_:unmarshal_int32()
	self.maxmp = _os_:unmarshal_int32()
	self.attack = _os_:unmarshal_int32()
	self.defend = _os_:unmarshal_int32()
	self.speed = _os_:unmarshal_int32()
	self.magicattack = _os_:unmarshal_int32()
	self.magicdef = _os_:unmarshal_int32()
	self.scale = _os_:unmarshal_char()
	----------------unmarshal bean

	self.initbfp:unmarshal(_os_)

	----------------unmarshal bean

	self.bfp:unmarshal(_os_)

	self.point = _os_:unmarshal_short()
	self.autoaddcons = _os_:unmarshal_char()
	self.autoaddiq = _os_:unmarshal_char()
	self.autoaddstr = _os_:unmarshal_char()
	self.autoaddendu = _os_:unmarshal_char()
	self.autoaddagi = _os_:unmarshal_char()
	self.pointresetcount = _os_:unmarshal_short()
	self.exp = _os_:unmarshal_int64()
	self.nexp = _os_:unmarshal_int64()
	self.attackapt = _os_:unmarshal_int32()
	self.defendapt = _os_:unmarshal_int32()
	self.phyforceapt = _os_:unmarshal_int32()
	self.magicapt = _os_:unmarshal_int32()
	self.speedapt = _os_:unmarshal_int32()
	self.dodgeapt = _os_:unmarshal_int32()
	self.growrate = _os_:unmarshal_float()
	self.life = _os_:unmarshal_int32()
	self.kind = _os_:unmarshal_int32()
	----------------unmarshal list
	local sizeof_skills=0 ,_os_null_skills
	_os_null_skills, sizeof_skills = _os_: uncompact_uint32(sizeof_skills)
	for k = 1,sizeof_skills do
		----------------unmarshal bean
		self.skills[k]=Petskill:new()

		self.skills[k]:unmarshal(_os_)

	end
	----------------unmarshal map
	local sizeof_skillexpires=0,_os_null_skillexpires
	_os_null_skillexpires, sizeof_skillexpires = _os_: uncompact_uint32(sizeof_skillexpires)
	for k = 1,sizeof_skillexpires do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int64()
		self.skillexpires[newkey] = newvalue
	end
	self.flag = _os_:unmarshal_char()
	self.timeout = _os_:unmarshal_int64()
	self.ownerid = _os_:unmarshal_int64()
	self.ownername = _os_:unmarshal_wstring(self.ownername)
	self.rank = _os_:unmarshal_int32()
	self.starid = _os_:unmarshal_short()
	self.practisetimes = _os_:unmarshal_short()
	----------------unmarshal map
	local sizeof_zizhi=0,_os_null_zizhi
	_os_null_zizhi, sizeof_zizhi = _os_: uncompact_uint32(sizeof_zizhi)
	for k = 1,sizeof_zizhi do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.zizhi[newkey] = newvalue
	end
	self.changegengu = _os_:unmarshal_int32()
	self.skill_grids = _os_:unmarshal_int32()
	self.aptaddcount = _os_:unmarshal_char()
	self.growrateaddcount = _os_:unmarshal_char()
	self.washcount = _os_:unmarshal_short()
	self.petscore = _os_:unmarshal_int32()
	self.petbasescore = _os_:unmarshal_int32()
	self.petdye1 = _os_:unmarshal_int32()
	self.petdye2 = _os_:unmarshal_int32()
	self.shenshouinccount = _os_:unmarshal_int32()
	self.marketfreezeexpire = _os_:unmarshal_int64()
	
	----------------unmarshal list
	local sizeof_internals=0 ,_os_null_internals
	_os_null_internals, sizeof_internals = _os_: uncompact_uint32(sizeof_internals)
	for k = 1,sizeof_internals do
		----------------unmarshal bean
		self.internals[k]=Petskill:new()

		self.internals[k]:unmarshal(_os_)

	end
	self.qianye =_os_:unmarshal_int32()
	return _os_
end

return Pet
