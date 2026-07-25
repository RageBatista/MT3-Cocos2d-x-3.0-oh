require "utils.tableutil"
CPvP1OpenBox = {}
CPvP1OpenBox.__index = CPvP1OpenBox



CPvP1OpenBox.PROTOCOL_TYPE = 793541

function CPvP1OpenBox.Create()
	print("enter CPvP1OpenBox create")
	return CPvP1OpenBox:new()
end
function CPvP1OpenBox:new()
	local self = {}
	setmetatable(self, CPvP1OpenBox)
	self.type = self.PROTOCOL_TYPE
	self.boxtype = 0

	return self
end
function CPvP1OpenBox:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CPvP1OpenBox:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_char(self.boxtype)
	return _os_
end

function CPvP1OpenBox:unmarshal(_os_)
	self.boxtype = _os_:unmarshal_char()
	return _os_
end

return CPvP1OpenBox
