require "utils.tableutil"
SPvP5ReadyFight = {}
SPvP5ReadyFight.__index = SPvP5ReadyFight



SPvP5ReadyFight.PROTOCOL_TYPE = 793668

function SPvP5ReadyFight.Create()
	print("enter SPvP5ReadyFight create")
	return SPvP5ReadyFight:new()
end
function SPvP5ReadyFight:new()
	local self = {}
	setmetatable(self, SPvP5ReadyFight)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SPvP5ReadyFight:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SPvP5ReadyFight:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SPvP5ReadyFight:unmarshal(_os_)
	return _os_
end

return SPvP5ReadyFight
