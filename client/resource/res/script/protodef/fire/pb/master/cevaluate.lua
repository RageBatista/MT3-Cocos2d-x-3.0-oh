require "utils.tableutil"
CEvaluate = {}
CEvaluate.__index = CEvaluate



CEvaluate.PROTOCOL_TYPE = 816475

function CEvaluate.Create()
	print("enter CEvaluate create")
	return CEvaluate:new()
end
function CEvaluate:new()
	local self = {}
	setmetatable(self, CEvaluate)
	self.type = self.PROTOCOL_TYPE
	self.flag = 0
	self.roleid = 0
	self.result = 0

	return self
end
function CEvaluate:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CEvaluate:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.flag)
	_os_:marshal_int64(self.roleid)
	_os_:marshal_int32(self.result)
	return _os_
end

function CEvaluate:unmarshal(_os_)
	self.flag = _os_:unmarshal_int32()
	self.roleid = _os_:unmarshal_int64()
	self.result = _os_:unmarshal_int32()
	return _os_
end

return CEvaluate
