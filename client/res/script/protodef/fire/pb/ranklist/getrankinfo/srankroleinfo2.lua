require "utils.tableutil"
require "protodef.rpcgen.fire.pb.bag"
require "protodef.rpcgen.fire.pb.item"
SRankRoleInfo2 = {}
SRankRoleInfo2.__index = SRankRoleInfo2



SRankRoleInfo2.PROTOCOL_TYPE = 810261

function SRankRoleInfo2.Create()
	print("enter SRankRoleInfo2 create")
	return SRankRoleInfo2:new()
end
function SRankRoleInfo2:new()
	local self = {}
	setmetatable(self, SRankRoleInfo2)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.ranktype = 0
	self.rolename = "" 
	self.shape = 0
	self.school = 0
	self.level = 0
	self.baginfo = Bag:new()
	self.tips = {}
	self.footlogoid = 0
	self.rank = 0
	self.totalscore = 0
	self.rolescore = 0
	self.petscore = 0
	self.manypetscore = 0
	self.skillscore = 0
	self.levelscore = 0
	self.xiulianscore = 0
	self.equipscore = 0
	self.components = {}
	self.factionname = "" 

	return self
end
function SRankRoleInfo2:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRankRoleInfo2:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int32(self.ranktype)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int32(self.shape)
	_os_:marshal_int32(self.school)
	_os_:marshal_int32(self.level)
	----------------marshal bean
	self.baginfo:marshal(_os_) 

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.tips))
	for k,v in pairs(self.tips) do
		_os_:marshal_int32(k)
		_os_: marshal_octets(v)
	end

	_os_:marshal_int32(self.footlogoid)
	_os_:marshal_int32(self.rank)
	_os_:marshal_int32(self.totalscore)
	_os_:marshal_int32(self.rolescore)
	_os_:marshal_int32(self.petscore)
	_os_:marshal_int32(self.manypetscore)
	_os_:marshal_int32(self.skillscore)
	_os_:marshal_int32(self.levelscore)
	_os_:marshal_int32(self.xiulianscore)
	_os_:marshal_int32(self.equipscore)

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.components))
	for k,v in pairs(self.components) do
		_os_:marshal_char(k)
		_os_:marshal_int32(v)
	end

	_os_:marshal_wstring(self.factionname)
	return _os_
end

function SRankRoleInfo2:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.ranktype = _os_:unmarshal_int32()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.shape = _os_:unmarshal_int32()
	self.school = _os_:unmarshal_int32()
	self.level = _os_:unmarshal_int32()
	----------------unmarshal bean

	self.baginfo:unmarshal(_os_)

	----------------unmarshal map
	local sizeof_tips=0,_os_null_tips
	_os_null_tips, sizeof_tips = _os_: uncompact_uint32(sizeof_tips)
	for k = 1,sizeof_tips do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = FireNet.Octets()
		_os_:unmarshal_octets(newvalue)
		self.tips[newkey] = newvalue
	end
	self.footlogoid = _os_:unmarshal_int32()
	self.rank = _os_:unmarshal_int32()
	self.totalscore = _os_:unmarshal_int32()
	self.rolescore = _os_:unmarshal_int32()
	self.petscore = _os_:unmarshal_int32()
	self.manypetscore = _os_:unmarshal_int32()
	self.skillscore = _os_:unmarshal_int32()
	self.levelscore = _os_:unmarshal_int32()
	self.xiulianscore = _os_:unmarshal_int32()
	self.equipscore = _os_:unmarshal_int32()
	----------------unmarshal map
	local sizeof_components=0,_os_null_components
	_os_null_components, sizeof_components = _os_: uncompact_uint32(sizeof_components)
	for k = 1,sizeof_components do
		local newkey, newvalue
		newkey = _os_:unmarshal_char()
		newvalue = _os_:unmarshal_int32()
		self.components[newkey] = newvalue
	end
	self.factionname = _os_:unmarshal_wstring(self.factionname)
	return _os_
end

return SRankRoleInfo2
