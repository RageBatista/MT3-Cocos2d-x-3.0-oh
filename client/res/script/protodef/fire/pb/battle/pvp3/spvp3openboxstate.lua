require "utils.tableutil"
SPvP3OpenBoxState = {}
SPvP3OpenBoxState.__index = SPvP3OpenBoxState



SPvP3OpenBoxState.PROTOCOL_TYPE = 793654

function SPvP3OpenBoxState.Create()
	print("enter SPvP3OpenBoxState create")
	return SPvP3OpenBoxState:new()
end
function SPvP3OpenBoxState:new()
	local self = {}
	setmetatable(self, SPvP3OpenBoxState)
	self.type = self.PROTOCOL_TYPE
	self.boxtype = 0
	self.state = 0

	return self
end
function SPvP3OpenBoxState:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SPvP3OpenBoxState:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.boxtype)
	_os_:marshal_char(self.state)
	return _os_
end

function SPvP3OpenBoxState:unmarshal(_os_)
	self.boxtype = _os_:unmarshal_char()
	self.state = _os_:unmarshal_char()
	return _os_
end

return SPvP3OpenBoxState
