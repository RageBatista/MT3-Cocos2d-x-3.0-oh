require "utils.tableutil"
CPvP3OpenBox = {}
CPvP3OpenBox.__index = CPvP3OpenBox



CPvP3OpenBox.PROTOCOL_TYPE = 793653

function CPvP3OpenBox.Create()
	print("enter CPvP3OpenBox create")
	return CPvP3OpenBox:new()
end
function CPvP3OpenBox:new()
	local self = {}
	setmetatable(self, CPvP3OpenBox)
	self.type = self.PROTOCOL_TYPE
	self.boxtype = 0

	return self
end
function CPvP3OpenBox:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CPvP3OpenBox:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.boxtype)
	return _os_
end

function CPvP3OpenBox:unmarshal(_os_)
	self.boxtype = _os_:unmarshal_char()
	return _os_
end

return CPvP3OpenBox
