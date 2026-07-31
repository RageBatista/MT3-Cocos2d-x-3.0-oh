require "utils.tableutil"
CPvP3ReadyFight = {}
CPvP3ReadyFight.__index = CPvP3ReadyFight



CPvP3ReadyFight.PROTOCOL_TYPE = 793643

function CPvP3ReadyFight.Create()
	print("enter CPvP3ReadyFight create")
	return CPvP3ReadyFight:new()
end
function CPvP3ReadyFight:new()
	local self = {}
	setmetatable(self, CPvP3ReadyFight)
	self.type = self.PROTOCOL_TYPE
	self.ready = 0

	return self
end
function CPvP3ReadyFight:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CPvP3ReadyFight:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.ready)
	return _os_
end

function CPvP3ReadyFight:unmarshal(_os_)
	self.ready = _os_:unmarshal_char()
	return _os_
end

return CPvP3ReadyFight
