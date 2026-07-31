require "utils.tableutil"
CAddBlackRole = {}
CAddBlackRole.__index = CAddBlackRole



CAddBlackRole.PROTOCOL_TYPE = 819148

function CAddBlackRole.Create()
	print("enter CAddBlackRole create")
	return CAddBlackRole:new()
end
function CAddBlackRole:new()
	local self = {}
	setmetatable(self, CAddBlackRole)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0

	return self
end
function CAddBlackRole:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CAddBlackRole:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	return _os_
end

function CAddBlackRole:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	return _os_
end

return CAddBlackRole
