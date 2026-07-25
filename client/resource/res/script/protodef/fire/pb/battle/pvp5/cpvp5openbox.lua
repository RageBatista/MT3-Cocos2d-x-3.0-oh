require "utils.tableutil"
CPvP5OpenBox = {}
CPvP5OpenBox.__index = CPvP5OpenBox



CPvP5OpenBox.PROTOCOL_TYPE = 793672

function CPvP5OpenBox.Create()
	print("enter CPvP5OpenBox create")
	return CPvP5OpenBox:new()
end
function CPvP5OpenBox:new()
	local self = {}
	setmetatable(self, CPvP5OpenBox)
	self.type = self.PROTOCOL_TYPE
	self.boxtype = 0

	return self
end
function CPvP5OpenBox:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CPvP5OpenBox:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.boxtype)
	return _os_
end

function CPvP5OpenBox:unmarshal(_os_)
	self.boxtype = _os_:unmarshal_char()
	return _os_
end

return CPvP5OpenBox
