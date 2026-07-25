require "utils.tableutil"
SPvP1ReadyFight = {}
SPvP1ReadyFight.__index = SPvP1ReadyFight



SPvP1ReadyFight.PROTOCOL_TYPE = 793539

function SPvP1ReadyFight.Create()
	print("enter SPvP1ReadyFight create")
	return SPvP1ReadyFight:new()
end
function SPvP1ReadyFight:new()
	local self = {}
	setmetatable(self, SPvP1ReadyFight)
	self.type = self.PROTOCOL_TYPE
	self.ready = 0

	return self
end
function SPvP1ReadyFight:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SPvP1ReadyFight:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.ready)
	return _os_
end

function SPvP1ReadyFight:unmarshal(_os_)
	self.ready = _os_:unmarshal_char()
	return _os_
end

return SPvP1ReadyFight
