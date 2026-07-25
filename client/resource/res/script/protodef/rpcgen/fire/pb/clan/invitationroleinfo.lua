require "utils.tableutil"
InvitationRoleInfo = {}
InvitationRoleInfo.__index = InvitationRoleInfo


function InvitationRoleInfo:new()
	local self = {}
	setmetatable(self, InvitationRoleInfo)
	self.roleid = 0
	self.rolename = "" 
	self.shape = 0
	self.level = 0
	self.sex = 0
	self.school = 0
	self.fightvalue = 0
	self.vip = 0
	self.components = {}

	return self
end
function InvitationRoleInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int32(self.shape)
	_os_:marshal_int32(self.level)
	_os_:marshal_int32(self.sex)
	_os_:marshal_int32(self.school)
	_os_:marshal_int32(self.fightvalue)
	_os_:marshal_int32(self.vip)

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.components))
	for k,v in pairs(self.components) do
		_os_:marshal_char(k)
		_os_:marshal_int32(v)
	end

	return _os_
end

function InvitationRoleInfo:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.shape = _os_:unmarshal_int32()
	self.level = _os_:unmarshal_int32()
	self.sex = _os_:unmarshal_int32()
	self.school = _os_:unmarshal_int32()
	self.fightvalue = _os_:unmarshal_int32()
	self.vip = _os_:unmarshal_int32()
	----------------unmarshal map
	local sizeof_components=0,_os_null_components
	_os_null_components, sizeof_components = _os_: uncompact_uint32(sizeof_components)
	for k = 1,sizeof_components do
		local newkey, newvalue
		newkey = _os_:unmarshal_char()
		newvalue = _os_:unmarshal_int32()
		self.components[newkey] = newvalue
	end
	return _os_
end

return InvitationRoleInfo
