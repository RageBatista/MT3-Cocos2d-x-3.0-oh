require "utils.tableutil"
SEvaluate = {}
SEvaluate.__index = SEvaluate



SEvaluate.PROTOCOL_TYPE = 816474

function SEvaluate.Create()
	print("enter SEvaluate create")
	return SEvaluate:new()
end
function SEvaluate:new()
	local self = {}
	setmetatable(self, SEvaluate)
	self.type = self.PROTOCOL_TYPE
	self.flag = 0
	self.roleid = 0

	return self
end
function SEvaluate:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SEvaluate:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.flag)
	_os_:marshal_int64(self.roleid)
	return _os_
end

function SEvaluate:unmarshal(_os_)
	self.flag = _os_:unmarshal_int32()
	self.roleid = _os_:unmarshal_int64()
	return _os_
end

return SEvaluate
