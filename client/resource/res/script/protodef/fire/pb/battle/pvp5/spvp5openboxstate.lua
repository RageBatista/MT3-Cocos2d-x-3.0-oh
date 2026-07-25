require "utils.tableutil"
SPvP5OpenBoxState = {}
SPvP5OpenBoxState.__index = SPvP5OpenBoxState



SPvP5OpenBoxState.PROTOCOL_TYPE = 793673

function SPvP5OpenBoxState.Create()
	print("enter SPvP5OpenBoxState create")
	return SPvP5OpenBoxState:new()
end
function SPvP5OpenBoxState:new()
	local self = {}
	setmetatable(self, SPvP5OpenBoxState)
	self.type = self.PROTOCOL_TYPE
	self.boxtype = 0
	self.state = 0

	return self
end
function SPvP5OpenBoxState:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SPvP5OpenBoxState:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.boxtype)
	_os_:marshal_char(self.state)
	return _os_
end

function SPvP5OpenBoxState:unmarshal(_os_)
	self.boxtype = _os_:unmarshal_char()
	self.state = _os_:unmarshal_char()
	return _os_
end

return SPvP5OpenBoxState
