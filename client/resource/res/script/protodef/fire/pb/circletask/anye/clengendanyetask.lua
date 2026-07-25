require "utils.tableutil"
CLengendAnYetask = {}
CLengendAnYetask.__index = CLengendAnYetask



CLengendAnYetask.PROTOCOL_TYPE = 807458

function CLengendAnYetask.Create()
	print("enter CLengendAnYetask create")
	return CLengendAnYetask:new()
end
function CLengendAnYetask:new()
	local self = {}
	setmetatable(self, CLengendAnYetask)
	self.type = self.PROTOCOL_TYPE
	self.taskpos = 0

	return self
end
function CLengendAnYetask:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CLengendAnYetask:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.taskpos)
	return _os_
end

function CLengendAnYetask:unmarshal(_os_)
	self.taskpos = _os_:unmarshal_int32()
	return _os_
end

return CLengendAnYetask
