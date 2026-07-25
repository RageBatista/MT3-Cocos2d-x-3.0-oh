require "utils.tableutil"
SSetCommander = {}
SSetCommander.__index = SSetCommander



SSetCommander.PROTOCOL_TYPE = 793888

function SSetCommander.Create()
	print("enter SSetCommander create")
	return SSetCommander:new()
end
function SSetCommander:new()
	local self = {}
	setmetatable(self, SSetCommander)
	self.type = self.PROTOCOL_TYPE
	self.roleid = 0

	return self
end
function SSetCommander:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SSetCommander:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int64(self.roleid)
	return _os_
end

function SSetCommander:unmarshal(_os_)
	self.roleid = _os_:unmarshal_int64()
	return _os_
end

return SSetCommander
