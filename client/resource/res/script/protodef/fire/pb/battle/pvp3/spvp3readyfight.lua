require "utils.tableutil"
SPvP3ReadyFight = {}
SPvP3ReadyFight.__index = SPvP3ReadyFight



SPvP3ReadyFight.PROTOCOL_TYPE = 793644

function SPvP3ReadyFight.Create()
	print("enter SPvP3ReadyFight create")
	return SPvP3ReadyFight:new()
end
function SPvP3ReadyFight:new()
	local self = {}
	setmetatable(self, SPvP3ReadyFight)
	self.type = self.PROTOCOL_TYPE
	self.ready = 0

	return self
end
function SPvP3ReadyFight:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SPvP3ReadyFight:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.ready)
	return _os_
end

function SPvP3ReadyFight:unmarshal(_os_)
	self.ready = _os_:unmarshal_char()
	return _os_
end

return SPvP3ReadyFight
