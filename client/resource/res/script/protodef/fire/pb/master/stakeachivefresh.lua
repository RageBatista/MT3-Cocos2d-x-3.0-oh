require "utils.tableutil"
STakeAchiveFresh = {}
STakeAchiveFresh.__index = STakeAchiveFresh



STakeAchiveFresh.PROTOCOL_TYPE = 816483

function STakeAchiveFresh.Create()
	print("enter STakeAchiveFresh create")
	return STakeAchiveFresh:new()
end
function STakeAchiveFresh:new()
	local self = {}
	setmetatable(self, STakeAchiveFresh)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0
	self.key = 0
	self.flag = 0

	return self
end
function STakeAchiveFresh:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function STakeAchiveFresh:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int32(self.key)
	_os_:marshal_int32(self.flag)
	return _os_
end

function STakeAchiveFresh:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	self.key = _os_:unmarshal_int32()
	self.flag = _os_:unmarshal_int32()
	return _os_
end

return STakeAchiveFresh
