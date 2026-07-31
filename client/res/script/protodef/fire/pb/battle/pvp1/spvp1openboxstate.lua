require "utils.tableutil"
SPvP1OpenBoxState = {}
SPvP1OpenBoxState.__index = SPvP1OpenBoxState



SPvP1OpenBoxState.PROTOCOL_TYPE = 793544

function SPvP1OpenBoxState.Create()
	print("enter SPvP1OpenBoxState create")
	return SPvP1OpenBoxState:new()
end
function SPvP1OpenBoxState:new()
	local self = {}
	setmetatable(self, SPvP1OpenBoxState)
	self.type = self.PROTOCOL_TYPE
	self.boxtype = 0
	self.state = 0

	return self
end
function SPvP1OpenBoxState:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SPvP1OpenBoxState:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.boxtype)
	_os_:marshal_char(self.state)
	return _os_
end

function SPvP1OpenBoxState:unmarshal(_os_)
	self.boxtype = _os_:unmarshal_char()
	self.state = _os_:unmarshal_char()
	return _os_
end

return SPvP1OpenBoxState
