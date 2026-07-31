require "utils.tableutil"
CChangePointScheme = {}
CChangePointScheme.__index = CChangePointScheme



CChangePointScheme.PROTOCOL_TYPE = 786530

function CChangePointScheme.Create()
	print("enter CChangePointScheme create")
	return CChangePointScheme:new()
end
function CChangePointScheme:new()
	local self = {}
	setmetatable(self, CChangePointScheme)
	self.type = self.PROTOCOL_TYPE
	self.schemeid = 0

	return self
end
function CChangePointScheme:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CChangePointScheme:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.schemeid)
	return _os_
end

function CChangePointScheme:unmarshal(_os_)
	self.schemeid = _os_:unmarshal_int32()
	return _os_
end

return CChangePointScheme
