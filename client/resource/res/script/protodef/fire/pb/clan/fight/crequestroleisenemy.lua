require "utils.tableutil"
CRequestRoleIsEnemy = {}
CRequestRoleIsEnemy.__index = CRequestRoleIsEnemy



CRequestRoleIsEnemy.PROTOCOL_TYPE = 808541

function CRequestRoleIsEnemy.Create()
	print("enter CRequestRoleIsEnemy create")
	return CRequestRoleIsEnemy:new()
end
function CRequestRoleIsEnemy:new()
	local self = {}
	setmetatable(self, CRequestRoleIsEnemy)
	self.type = self.PROTOCOL_TYPE
	self.roleidlist = {}

	return self
end
function CRequestRoleIsEnemy:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestRoleIsEnemy:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()

	----------------marshal list
	_os_:compact_uint32(TableUtil.tablelength(self.roleidlist))
	for k,v in ipairs(self.roleidlist) do
		_os_:marshal_int64(v)
	end

	return _os_
end

function CRequestRoleIsEnemy:unmarshal(_os_)
	----------------unmarshal list
	local sizeof_roleidlist=0 ,_os_null_roleidlist
	_os_null_roleidlist, sizeof_roleidlist = _os_: uncompact_uint32(sizeof_roleidlist)
	for k = 1,sizeof_roleidlist do
		self.roleidlist[k] = _os_:unmarshal_int64()
	end
	return _os_
end

return CRequestRoleIsEnemy
