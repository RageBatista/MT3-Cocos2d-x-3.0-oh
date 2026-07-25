require "utils.tableutil"
CRequestSearchRole = {}
CRequestSearchRole.__index = CRequestSearchRole



CRequestSearchRole.PROTOCOL_TYPE = 808522

function CRequestSearchRole.Create()
	print("enter CRequestSearchRole create")
	return CRequestSearchRole:new()
end
function CRequestSearchRole:new()
	local self = {}
	setmetatable(self, CRequestSearchRole)
	self.type = self.PROTOCOL_TYPE
	self.roleid = "" 

	return self
end
function CRequestSearchRole:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestSearchRole:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_wstring(self.roleid)
	return _os_
end

function CRequestSearchRole:unmarshal(_os_)
	self.roleid = _os_:unmarshal_wstring(self.roleid)
	return _os_
end

return CRequestSearchRole
