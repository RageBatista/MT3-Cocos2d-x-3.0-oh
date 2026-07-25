require "utils.tableutil"
SLengendAnYetask = {}
SLengendAnYetask.__index = SLengendAnYetask



SLengendAnYetask.PROTOCOL_TYPE = 807459

function SLengendAnYetask.Create()
	print("enter SLengendAnYetask create")
	return SLengendAnYetask:new()
end
function SLengendAnYetask:new()
	local self = {}
	setmetatable(self, SLengendAnYetask)
	self.type = self.PROTOCOL_TYPE
	self.result = 0

	return self
end
function SLengendAnYetask:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SLengendAnYetask:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.result)
	return _os_
end

function SLengendAnYetask:unmarshal(_os_)
	self.result = _os_:unmarshal_int32()
	return _os_
end

return SLengendAnYetask
