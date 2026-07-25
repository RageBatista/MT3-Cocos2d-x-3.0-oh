require "utils.tableutil"
CRemoveBlackRole = {}
CRemoveBlackRole.__index = CRemoveBlackRole



CRemoveBlackRole.PROTOCOL_TYPE = 819147

function CRemoveBlackRole.Create()
	print("enter CRemoveBlackRole create")
	return CRemoveBlackRole:new()
end
function CRemoveBlackRole:new()
	local self = {}
	setmetatable(self, CRemoveBlackRole)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0

	return self
end
function CRemoveBlackRole:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRemoveBlackRole:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	return _os_
end

function CRemoveBlackRole:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	return _os_
end

return CRemoveBlackRole
