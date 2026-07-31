require "utils.tableutil"
SRequestSelectType = {}
SRequestSelectType.__index = SRequestSelectType



SRequestSelectType.PROTOCOL_TYPE = 808506

function SRequestSelectType.Create()
	print("enter SRequestSelectType create")
	return SRequestSelectType:new()
end
function SRequestSelectType:new()
	local self = {}
	setmetatable(self, SRequestSelectType)
	self.type = self.PROTOCOL_TYPE
	self.selecttype = 0

	return self
end
function SRequestSelectType:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SRequestSelectType:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.selecttype)
	return _os_
end

function SRequestSelectType:unmarshal(_os_)
	self.selecttype = _os_:unmarshal_int32()
	return _os_
end

return SRequestSelectType
