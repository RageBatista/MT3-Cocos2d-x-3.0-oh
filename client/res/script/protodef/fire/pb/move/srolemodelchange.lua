require "utils.tableutil"
SRoleModelChange = {}
SRoleModelChange.__index = SRoleModelChange



SRoleModelChange.PROTOCOL_TYPE = 790474

function SRoleModelChange.Create()
	print("enter SRoleModelChange create")
	return SRoleModelChange:new()
end
function SRoleModelChange:new()
	local self = {}
	setmetatable(self, SRoleModelChange)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.shape = 0

	return self
end
function SRoleModelChange:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRoleModelChange:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int32(self.shape)
	return _os_
end

function SRoleModelChange:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.shape = _os_:unmarshal_int32()
	return _os_
end

return SRoleModelChange
