require "utils.tableutil"
CPvP1ReadyFight = {}
CPvP1ReadyFight.__index = CPvP1ReadyFight



CPvP1ReadyFight.PROTOCOL_TYPE = 793538

function CPvP1ReadyFight.Create()
	print("enter CPvP1ReadyFight create")
	return CPvP1ReadyFight:new()
end
function CPvP1ReadyFight:new()
	local self = {}
	setmetatable(self, CPvP1ReadyFight)
	self.type = self.PROTOCOL_TYPE
	self.ready = 0

	return self
end
function CPvP1ReadyFight:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CPvP1ReadyFight:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.ready)
	return _os_
end

function CPvP1ReadyFight:unmarshal(_os_)
	self.ready = _os_:unmarshal_char()
	return _os_
end

return CPvP1ReadyFight
