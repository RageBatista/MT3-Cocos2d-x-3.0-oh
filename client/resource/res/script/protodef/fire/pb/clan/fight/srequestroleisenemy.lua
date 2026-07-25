require "utils.tableutil"
SRequestRoleIsEnemy = {}
SRequestRoleIsEnemy.__index = SRequestRoleIsEnemy



SRequestRoleIsEnemy.PROTOCOL_TYPE = 808542

function SRequestRoleIsEnemy.Create()
	print("enter SRequestRoleIsEnemy create")
	return SRequestRoleIsEnemy:new()
end
function SRequestRoleIsEnemy:new()
	local self = {}
	setmetatable(self, SRequestRoleIsEnemy)
	self.type = self.PROTOCOL_TYPE
	self.rolelist = {}

	return self
end
function SRequestRoleIsEnemy:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRequestRoleIsEnemy:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal map
	_os_:compact_uint32(TableUtil.tablelength(self.rolelist))
	for k,v in pairs(self.rolelist) do
		_os_:marshal_int64(k)
		_os_:marshal_int32(v)
	end

	return _os_
end

function SRequestRoleIsEnemy:unmarshal(_os_)
	----------------unmarshal map
	local sizeof_rolelist=0,_os_null_rolelist
	_os_null_rolelist, sizeof_rolelist = _os_: uncompact_uint32(sizeof_rolelist)
	for k = 1,sizeof_rolelist do
		local newkey, newvalue
		newkey = _os_:unmarshal_int64()
		newvalue = _os_:unmarshal_int32()
		self.rolelist[newkey] = newvalue
	end
	return _os_
end

return SRequestRoleIsEnemy
