require "utils.tableutil"
require "protodef.rpcgen.fire.pb.team.pos1"
TeamMemberBasic = {}
TeamMemberBasic.__index = TeamMemberBasic


function TeamMemberBasic:new()
	local self = {}
	setmetatable(self, TeamMemberBasic)
	self.roleid = 0
	self.rolename = "" 
	self.level = 0
	self.sceneid = 0
	self.pos = Pos1:new()
	self.school = 0
	self.hp = 0
	self.maxhp = 0
	self.mp = 0
	self.maxmp = 0
	self.title = "" 
	self.state = 0
	self.shape = 0
	self.hugindex = 0
	self.components = {}
	self.camp = 0

	return self
end
function TeamMemberBasic:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int32(self.level)
	_os_:marshal_int64(self.sceneid)
	----------------marshal bean
	self.pos:marshal(_os_) 
	_os_:marshal_int32(self.school)
	_os_:marshal_int32(self.hp)
	_os_:marshal_int32(self.maxhp)
	_os_:marshal_int32(self.mp)
	_os_:marshal_int32(self.maxmp)
	_os_:marshal_wstring(self.title)
	_os_:marshal_int32(self.state)
	_os_:marshal_int32(self.shape)
	_os_:marshal_char(self.hugindex)

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.components))
	for k,v in pairs(self.components) do
		_os_:marshal_char(k)
		_os_:marshal_int32(v)
	end

	_os_:marshal_char(self.camp)
	return _os_
end

function TeamMemberBasic:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.level = _os_:unmarshal_int32()
	self.sceneid = _os_:unmarshal_int64()
	----------------unmarshal bean

	self.pos:unmarshal(_os_)

	self.school = _os_:unmarshal_int32()
	self.hp = _os_:unmarshal_int32()
	self.maxhp = _os_:unmarshal_int32()
	self.mp = _os_:unmarshal_int32()
	self.maxmp = _os_:unmarshal_int32()
	self.title = _os_:unmarshal_wstring(self.title)
	self.state = _os_:unmarshal_int32()
	self.shape = _os_:unmarshal_int32()
	self.hugindex = _os_:unmarshal_char()
	----------------unmarshal map
	local sizeof_components=0,_os_null_components
	_os_null_components, sizeof_components = _os_: uncompact_uint32(sizeof_components)
	for k = 1,sizeof_components do
		local newkey, newvalue
		newkey = _os_:unmarshal_char()
		newvalue = _os_:unmarshal_int32()
		self.components[newkey] = newvalue
	end
	self.camp = _os_:unmarshal_char()
	return _os_
end

return TeamMemberBasic
