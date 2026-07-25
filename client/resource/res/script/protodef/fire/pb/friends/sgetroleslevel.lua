require "utils.tableutil"
SGetRolesLevel = {}
SGetRolesLevel.__index = SGetRolesLevel



SGetRolesLevel.PROTOCOL_TYPE = 806646

function SGetRolesLevel.Create()
	print("enter SGetRolesLevel create")
	return SGetRolesLevel:new()
end
function SGetRolesLevel:new()
	local self = {}
	setmetatable(self, SGetRolesLevel)
	self.type = self.PROTOCOL_TYPE
	self.roleslevel = {}
	self.gettype = 0

	return self
end
function SGetRolesLevel:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SGetRolesLevel:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.roleslevel))
	for k,v in pairs(self.roleslevel) do
		_os_:marshal_int64(k)
		_os_:marshal_int32(v)
	end

	_os_:marshal_int32(self.gettype)
	return _os_
end

function SGetRolesLevel:unmarshal(_os_)
	----------------unmarshal map
	local sizeof_roleslevel=0,_os_null_roleslevel
	_os_null_roleslevel, sizeof_roleslevel = _os_: uncompact_uint32(sizeof_roleslevel)
	for k = 1,sizeof_roleslevel do
		local newkey, newvalue
		newkey = _os_:unmarshal_int64()
		newvalue = _os_:unmarshal_int32()
		self.roleslevel[newkey] = newvalue
	end
	self.gettype = _os_:unmarshal_int32()
	return _os_
end

return SGetRolesLevel
