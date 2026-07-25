require "utils.tableutil"
CSetCharOpt = {}
CSetCharOpt.__index = CSetCharOpt



CSetCharOpt.PROTOCOL_TYPE = 810335

function CSetCharOpt.Create()
	print("enter CSetCharOpt create")
	return CSetCharOpt:new()
end
function CSetCharOpt:new()
	local self = {}
	setmetatable(self, CSetCharOpt)
	self.type = self.PROTOCOL_TYPE
	self.charoptype = 0
	self.charopid = 0

	return self
end
function CSetCharOpt:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSetCharOpt:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_short(self.charoptype)
	_os_:marshal_int32(self.charopid)
	return _os_
end

function CSetCharOpt:unmarshal(_os_)
	self.charoptype = _os_:unmarshal_short()
	self.charopid = _os_:unmarshal_int32()
	return _os_
end

return CSetCharOpt
