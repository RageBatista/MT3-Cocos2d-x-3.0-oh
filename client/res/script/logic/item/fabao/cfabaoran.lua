require "utils.tableutil"
FaBaoRan = {}
FaBaoRan.__index = FaBaoRan



FaBaoRan.PROTOCOL_TYPE = 800093

function FaBaoRan.Create()
	print("enter FaBaoRan create")
	return FaBaoRan:new()
end
function FaBaoRan:new()
	local self = {}
	setmetatable(self, FaBaoRan)
	self.type = self.PROTOCOL_TYPE
	return self
end
function FaBaoRan:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function FaBaoRan:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function FaBaoRan:unmarshal(_os_)
	return _os_
end

return FaBaoRan
