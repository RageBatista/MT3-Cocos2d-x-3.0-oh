require "utils.tableutil"
SSendRoleInitAttrs = {}
SSendRoleInitAttrs.__index = SSendRoleInitAttrs



SSendRoleInitAttrs.PROTOCOL_TYPE = 793455

function SSendRoleInitAttrs.Create()
	print("enter SSendRoleInitAttrs create")
	return SSendRoleInitAttrs:new()
end
function SSendRoleInitAttrs:new()
	local self = {}
	setmetatable(self, SSendRoleInitAttrs)
	self.type = self.PROTOCOL_TYPE
	self.roleinitattrs = {}

	return self
end
function SSendRoleInitAttrs:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSendRoleInitAttrs:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.roleinitattrs))
	for k,v in pairs(self.roleinitattrs) do
		_os_:marshal_int32(k)
		_os_:marshal_float(v)
	end

	return _os_
end

function SSendRoleInitAttrs:unmarshal(_os_)
	----------------unmarshal map
	local sizeof_roleinitattrs=0,_os_null_roleinitattrs
	_os_null_roleinitattrs, sizeof_roleinitattrs = _os_: uncompact_uint32(sizeof_roleinitattrs)
	for k = 1,sizeof_roleinitattrs do
		local newkey, newvalue
		newkey = _os_:unmarshal_int32()
		newvalue = _os_:unmarshal_float()
		self.roleinitattrs[newkey] = newvalue
	end
	return _os_
end

return SSendRoleInitAttrs
