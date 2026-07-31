require "utils.tableutil"
SClanFightOver = {}
SClanFightOver.__index = SClanFightOver



SClanFightOver.PROTOCOL_TYPE = 808543

function SClanFightOver.Create()
	print("enter SClanFightOver create")
	return SClanFightOver:new()
end
function SClanFightOver:new()
	local self = {}
	setmetatable(self, SClanFightOver)
	self.type = self.PROTOCOL_TYPE
	self.status = 0
	self.overtimestamp = 0

	return self
end
function SClanFightOver:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SClanFightOver:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.status)
	_os_:marshal_int64(self.overtimestamp)
	return _os_
end

function SClanFightOver:unmarshal(_os_)
	self.status = _os_:unmarshal_int32()
	self.overtimestamp = _os_:unmarshal_int64()
	return _os_
end

return SClanFightOver
