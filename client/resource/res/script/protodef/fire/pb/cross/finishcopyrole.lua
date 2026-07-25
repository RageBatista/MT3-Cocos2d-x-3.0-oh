require "utils.tableutil"
FinishCopyRole = {}
FinishCopyRole.__index = FinishCopyRole



FinishCopyRole.PROTOCOL_TYPE = 819067

function FinishCopyRole.Create()
	print("enter FinishCopyRole create")
	return FinishCopyRole:new()
end
function FinishCopyRole:new()
	local self = {}
	setmetatable(self, FinishCopyRole)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0

	return self
end
function FinishCopyRole:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function FinishCopyRole:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	return _os_
end

function FinishCopyRole:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	return _os_
end

return FinishCopyRole
