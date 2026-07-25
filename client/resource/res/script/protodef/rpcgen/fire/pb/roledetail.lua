require "utils.tableutil"
require "protodef.rpcgen.fire.pb.bag"
require "protodef.rpcgen.fire.pb.basicfightproperties"
require "protodef.rpcgen.fire.pb.formbean"
require "protodef.rpcgen.fire.pb.item"
require "protodef.rpcgen.fire.pb.pet"
require "protodef.rpcgen.fire.pb.petskill"
require "protodef.rpcgen.fire.pb.rolebasicfightproperties"
require "protodef.rpcgen.fire.pb.title.titleinfo"
RoleDetail = {}
RoleDetail.__index = RoleDetail


function RoleDetail:new()
	local self = {}
	setmetatable(self, RoleDetail)
	self.roleid = 0
	self.rolename = "" 
	self.zhuansheng = 0
	self.level = 0
	self.school = 0
	self.shape = 0
	self.title = 0
	self.lastlogin = 0
	self.hp = 0
	self.uplimithp = 0
	self.maxhp = 0
	self.mp = 0
	self.magicattack = 0
	self.maxmp = 0
	self.magicdef = 0
	self.sp = 0
	self.seal = 0
	self.maxsp = 0
	self.hit = 0
	self.damage = 0
	self.heal_critc_level = 0
	self.defend = 0
	self.phy_critc_level = 0
	self.speed = 0
	self.magic_critc_level = 0
	self.dodge = 0
	self.anti_phy_critc_level = 0
	self.medical = 0
	self.unseal = 0
	self.anti_critc_level = 0
	self.phy_critc_pct = 0
	self.magic_critc_pct = 0
	self.heal_critc_pct = 0
	self.anti_magic_critc_level = 0
	self.energy = 0
	self.enlimit = 0
	self.bfp = RoleBasicFightProperties:new()
	self.point = {}
	self.pointscheme = 0
	self.schemechanges = 0
	self.schoolvalue = 0
	self.reputation = 0
	self.exp = 0
	self.nexp = 0
	self.showpet = 0
	self.petmaxnum = 0
	self.pets = {}
	self.sysconfigmap = {}
	self.lineconfigmap = {}
	self.titles = {}
	self.learnedformsmap = {}
	self.components = {}
	self.activeness = 0
	self.factionvalue = 0
	self.masterid = 0
	self.isprotected = 0
	self.wrongpwdtimes = 0
	self.petindex = 0
	self.kongzhijiacheng = 0
	self.kongzhimianyi = 0
	self.zhiliaojiashen = 0
	self.wulidikang = 0
	self.fashudikang = 0
	self.fashuchuantou = 0
	self.wulichuantou = 0
	self.baginfo = {}
	self.rolecreatetime = 0
	self.depotnameinfo = {}

	return self
end
function RoleDetail:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int32(self.zhuansheng)
	_os_:marshal_int32(self.level)
	_os_:marshal_int32(self.school)
	_os_:marshal_int32(self.shape)
	_os_:marshal_int32(self.title)
	_os_:marshal_int64(self.lastlogin)
	_os_:marshal_int32(self.hp)
	_os_:marshal_int32(self.uplimithp)
	_os_:marshal_int32(self.maxhp)
	_os_:marshal_int32(self.mp)
	_os_:marshal_int32(self.magicattack)
	_os_:marshal_int32(self.maxmp)
	_os_:marshal_int32(self.magicdef)
	_os_:marshal_int32(self.sp)
	_os_:marshal_int32(self.seal)
	_os_:marshal_int32(self.maxsp)
	_os_:marshal_int32(self.hit)
	_os_:marshal_int32(self.damage)
	_os_:marshal_int32(self.heal_critc_level)
	_os_:marshal_int32(self.defend)
	_os_:marshal_int32(self.phy_critc_level)
	_os_:marshal_int32(self.speed)
	_os_:marshal_int32(self.magic_critc_level)
	_os_:marshal_int32(self.dodge)
	_os_:marshal_int32(self.anti_phy_critc_level)
	_os_:marshal_int32(self.medical)
	_os_:marshal_int32(self.unseal)
	_os_:marshal_int32(self.anti_critc_level)
	_os_:marshal_float(self.phy_critc_pct)
	_os_:marshal_float(self.magic_critc_pct)
	_os_:marshal_float(self.heal_critc_pct)
	_os_:marshal_int32(self.anti_magic_critc_level)
	_os_:marshal_int32(self.energy)
	_os_:marshal_int32(self.enlimit)
	----------------marshal bean
	self.bfp:marshal(_os_) 

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.point))
	for k,v in pairs(self.point) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end

	_os_:marshal_int32(self.pointscheme)
	_os_:marshal_int32(self.schemechanges)
	_os_:marshal_int32(self.schoolvalue)
	_os_:marshal_int32(self.reputation)
	_os_:marshal_int64(self.exp)
	_os_:marshal_int64(self.nexp)
	_os_:marshal_int32(self.showpet)
	_os_:marshal_int32(self.petmaxnum)

	----------------marshal vector
	_os_:compact_uint32(TableUtil.tablelength(self.pets))
	for k,v in ipairs(self.pets) do
		----------------marshal bean
		v:marshal(_os_) 
	end


	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.sysconfigmap))
	for k,v in pairs(self.sysconfigmap) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end


	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.lineconfigmap))
	for k,v in pairs(self.lineconfigmap) do
		_os_:marshal_int32(k)
		_os_:marshal_int32(v)
	end


	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.titles))
	for k,v in pairs(self.titles) do
		_os_:marshal_int32(k)
		----------------marshal bean
		v:marshal(_os_) 
	end


	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.learnedformsmap))
	for k,v in pairs(self.learnedformsmap) do
		_os_:marshal_int32(k)
		----------------marshal bean
		v:marshal(_os_) 
	end


	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.components))
	for k,v in pairs(self.components) do
		_os_:marshal_char(k)
		_os_:marshal_int32(v)
	end

	_os_:marshal_int32(self.activeness)
	_os_:marshal_int32(self.factionvalue)
	_os_:marshal_int64(self.masterid)
	_os_:marshal_char(self.isprotected)
	_os_:marshal_char(self.wrongpwdtimes)
	_os_:marshal_int32(self.petindex)
	_os_:marshal_int32(self.kongzhijiacheng)
	_os_:marshal_int32(self.kongzhimianyi)
	_os_:marshal_int32(self.zhiliaojiashen)
	_os_:marshal_int32(self.wulidikang)
	_os_:marshal_int32(self.fashudikang)
	_os_:marshal_int32(self.fashuchuantou)
	_os_:marshal_int32(self.wulichuantou)

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.baginfo))
	for k,v in pairs(self.baginfo) do
		_os_:marshal_int32(k)
		----------------marshal bean
		v:marshal(_os_) 
	end

	_os_:marshal_int64(self.rolecreatetime)

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.depotnameinfo))
	for k,v in pairs(self.depotnameinfo) do
		_os_:marshal_int32(k)
		_os_:marshal_wstring(v)
	end

	return _os_
end

function RoleDetail:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.zhuansheng = _os_:unmarshal_int32()
	self.level = _os_:unmarshal_int32()
	self.school = _os_:unmarshal_int32()
	self.shape = _os_:unmarshal_int32()
	self.title = _os_:unmarshal_int32()
	self.lastlogin = _os_:unmarshal_int64()
	self.hp = _os_:unmarshal_int32()
	self.uplimithp = _os_:unmarshal_int32()
	self.maxhp = _os_:unmarshal_int32()
	self.mp = _os_:unmarshal_int32()
	self.magicattack = _os_:unmarshal_int32()
	self.maxmp = _os_:unmarshal_int32()
	self.magicdef = _os_:unmarshal_int32()
	self.sp = _os_:unmarshal_int32()
	self.seal = _os_:unmarshal_int32()
	self.maxsp = _os_:unmarshal_int32()
	self.hit = _os_:unmarshal_int32()
	self.damage = _os_:unmarshal_int32()
	self.heal_critc_level = _os_:unmarshal_int32()
	self.defend = _os_:unmarshal_int32()
	self.phy_critc_level = _os_:unmarshal_int32()
	self.speed = _os_:unmarshal_int32()
	self.magic_critc_level = _os_:unmarshal_int32()
	self.dodge = _os_:unmarshal_int32()
	self.anti_phy_critc_level = _os_:unmarshal_int32()
	self.medical = _os_:unmarshal_int32()
	self.unseal = _os_:unmarshal_int32()
	self.anti_critc_level = _os_:unmarshal_int32()
	self.phy_critc_pct = _os_:unmarshal_float()
	self.magic_critc_pct = _os_:unmarshal_float()
	self.heal_critc_pct = _os_:unmarshal_float()
	self.anti_magic_critc_level = _os_:unmarshal_int32()
	self.energy = _os_:unmarshal_int32()
	self.enlimit = _os_:unmarshal_int32()
	----------------unmarshal bean

	self.bfp:unmarshal(_os_)

	----------------unmarshal map
	local sizeof_point=0,_os_null_point
	_os_null_point, sizeof_point = _os_: uncompact_uint32(sizeof_point)
	for k = 1,sizeof_point do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.point[newkey] = newvalue
	end
	self.pointscheme = _os_:unmarshal_int32()
	self.schemechanges = _os_:unmarshal_int32()
	self.schoolvalue = _os_:unmarshal_int32()
	self.reputation = _os_:unmarshal_int32()
	self.exp = _os_:unmarshal_int64()
	self.nexp = _os_:unmarshal_int64()
	self.showpet = _os_:unmarshal_int32()
	self.petmaxnum = _os_:unmarshal_int32()
	----------------unmarshal vector
	local sizeof_pets=0,_os_null_pets
	_os_null_pets, sizeof_pets = _os_: uncompact_uint32(sizeof_pets)
	for k = 1,sizeof_pets do
		----------------unmarshal bean
		self.pets[k]=Pet:new()

		self.pets[k]:unmarshal(_os_)

	end
	----------------unmarshal map
	local sizeof_sysconfigmap=0,_os_null_sysconfigmap
	_os_null_sysconfigmap, sizeof_sysconfigmap = _os_: uncompact_uint32(sizeof_sysconfigmap)
	for k = 1,sizeof_sysconfigmap do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.sysconfigmap[newkey] = newvalue
	end
	----------------unmarshal map
	local sizeof_lineconfigmap=0,_os_null_lineconfigmap
	_os_null_lineconfigmap, sizeof_lineconfigmap = _os_: uncompact_uint32(sizeof_lineconfigmap)
	for k = 1,sizeof_lineconfigmap do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_int32()
		self.lineconfigmap[newkey] = newvalue
	end
	----------------unmarshal map
	local sizeof_titles=0,_os_null_titles
	_os_null_titles, sizeof_titles = _os_: uncompact_uint32(sizeof_titles)
	for k = 1,sizeof_titles do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		----------------unmarshal bean
		newvalue=TitleInfo:new()

		newvalue:unmarshal(_os_)

		self.titles[newkey] = newvalue
	end
	----------------unmarshal map
	local sizeof_learnedformsmap=0,_os_null_learnedformsmap
	_os_null_learnedformsmap, sizeof_learnedformsmap = _os_: uncompact_uint32(sizeof_learnedformsmap)
	for k = 1,sizeof_learnedformsmap do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		----------------unmarshal bean
		newvalue=FormBean:new()

		newvalue:unmarshal(_os_)

		self.learnedformsmap[newkey] = newvalue
	end
	----------------unmarshal map
	local sizeof_components=0,_os_null_components
	_os_null_components, sizeof_components = _os_: uncompact_uint32(sizeof_components)
	for k = 1,sizeof_components do
		local newkey, newvalue
		newkey = _os_:unmarshal_char()
		newvalue = _os_:unmarshal_int32()
		self.components[newkey] = newvalue
	end
	self.activeness = _os_:unmarshal_int32()
	self.factionvalue = _os_:unmarshal_int32()
	self.masterid = _os_:unmarshal_int64()
	self.isprotected = _os_:unmarshal_char()
	self.wrongpwdtimes = _os_:unmarshal_char()
	self.petindex = _os_:unmarshal_int32()
	self.kongzhijiacheng = _os_:unmarshal_int32()
	self.kongzhimianyi = _os_:unmarshal_int32()
	self.zhiliaojiashen = _os_:unmarshal_int32()
	self.wulidikang = _os_:unmarshal_int32()
	self.fashudikang = _os_:unmarshal_int32()
	self.fashuchuantou = _os_:unmarshal_int32()
	self.wulichuantou = _os_:unmarshal_int32()
	----------------unmarshal map
	local sizeof_baginfo=0,_os_null_baginfo
	_os_null_baginfo, sizeof_baginfo = _os_: uncompact_uint32(sizeof_baginfo)
	for k = 1,sizeof_baginfo do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		----------------unmarshal bean
		newvalue=Bag:new()

		newvalue:unmarshal(_os_)

		self.baginfo[newkey] = newvalue
	end
	self.rolecreatetime = _os_:unmarshal_int64()
	----------------unmarshal map
	local sizeof_depotnameinfo=0,_os_null_depotnameinfo
	_os_null_depotnameinfo, sizeof_depotnameinfo = _os_: uncompact_uint32(sizeof_depotnameinfo)
	for k = 1,sizeof_depotnameinfo do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_wstring(newvalue)
		self.depotnameinfo[newkey] = newvalue
	end
	return _os_
end

return RoleDetail
