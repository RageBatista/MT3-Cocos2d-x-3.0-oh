require "utils.tableutil"
SRoleComponentsChange = {}
SRoleComponentsChange.__index = SRoleComponentsChange



SRoleComponentsChange.PROTOCOL_TYPE = 790476

function SRoleComponentsChange.Create()
	print("enter SRoleComponentsChange create")
	return SRoleComponentsChange:new()
end
function SRoleComponentsChange:new()
	local self = {}
	setmetatable(self, SRoleComponentsChange)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.spritetype = 0
	self.components = {}

	return self
end
function SRoleComponentsChange:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRoleComponentsChange:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_char(self.spritetype)

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.components))
	for k,v in pairs(self.components) do
		_os_:marshal_char(k)
		_os_:marshal_int32(v)
	end

	return _os_
end

function SRoleComponentsChange:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.spritetype = _os_:unmarshal_char()
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

return SRoleComponentsChange
