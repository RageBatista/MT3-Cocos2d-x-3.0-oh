require "utils.tableutil"
RoleInfo = {}
RoleInfo.__index = RoleInfo


function RoleInfo:new()
	local self = {}
	setmetatable(self, RoleInfo)
	self.roleid = 0
	self.rolename = "" 
	self.school = 0
	self.shape = 0
	self.level = 0
	self.components = {}
	self.rolecreatetime = 0

	return self
end
function RoleInfo:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_wstring(self.rolename)
	_os_:marshal_int32(self.school)
	_os_:marshal_int32(self.shape)
	_os_:marshal_int32(self.level)

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.components))
	for k,v in pairs(self.components) do
		_os_:marshal_char(k)
		_os_:marshal_int32(v)
	end

	_os_:marshal_int64(self.rolecreatetime)
	return _os_
end

function RoleInfo:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.rolename = _os_:unmarshal_wstring(self.rolename)
	self.school = _os_:unmarshal_int32()
	self.shape = _os_:unmarshal_int32()
	self.level = _os_:unmarshal_int32()
	----------------unmarshal map
	local sizeof_components=0,_os_null_components
	_os_null_components, sizeof_components = _os_: uncompact_uint32(sizeof_components)
	for k = 1,sizeof_components do
		local newkey, newvalue
		newkey = _os_:unmarshal_char()
		newvalue = _os_:unmarshal_int32()
		self.components[newkey] = newvalue
	end
	self.rolecreatetime = _os_:unmarshal_int64()
	return _os_
end

return RoleInfo
