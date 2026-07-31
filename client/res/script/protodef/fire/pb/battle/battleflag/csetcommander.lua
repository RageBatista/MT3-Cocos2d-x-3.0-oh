require "utils.tableutil"
CSetCommander = {}
CSetCommander.__index = CSetCommander



CSetCommander.PROTOCOL_TYPE = 793887

function CSetCommander.Create()
	print("enter CSetCommander create")
	return CSetCommander:new()
end
function CSetCommander:new()
	local self = {}
	setmetatable(self, CSetCommander)
	self.type = self.PROTOCOL_TYPE
	self.opttype = 0
	self.roleid = 0

	return self
end
function CSetCommander:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CSetCommander:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.opttype)
	_os_:marshal_int64(self.roleid)
	return _os_
end

function CSetCommander:unmarshal(_os_)
	self.opttype = _os_:unmarshal_char()
	self.roleid = _os_:unmarshal_int64()
	return _os_
end

return CSetCommander
