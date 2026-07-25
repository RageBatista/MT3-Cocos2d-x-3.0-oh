require "utils.tableutil"
CRequestSelectType = {}
CRequestSelectType.__index = CRequestSelectType



CRequestSelectType.PROTOCOL_TYPE = 808505

function CRequestSelectType.Create()
	print("enter CRequestSelectType create")
	return CRequestSelectType:new()
end
function CRequestSelectType:new()
	local self = {}
	setmetatable(self, CRequestSelectType)
	self.type = self.PROTOCOL_TYPE
	self.selecttype = 0

	return self
end
function CRequestSelectType:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CRequestSelectType:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.selecttype)
	return _os_
end

function CRequestSelectType:unmarshal(_os_)
	self.selecttype = _os_:unmarshal_int32()
	return _os_
end

return CRequestSelectType
