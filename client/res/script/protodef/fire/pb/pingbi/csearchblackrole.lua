require "utils.tableutil"
CSearchBlackRole = {}
CSearchBlackRole.__index = CSearchBlackRole



CSearchBlackRole.PROTOCOL_TYPE = 819145

function CSearchBlackRole.Create()
	print("enter CSearchBlackRole create")
	return CSearchBlackRole:new()
end
function CSearchBlackRole:new()
	local self = {}
	setmetatable(self, CSearchBlackRole)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0

	return self
end
function CSearchBlackRole:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSearchBlackRole:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	return _os_
end

function CSearchBlackRole:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	return _os_
end

return CSearchBlackRole
