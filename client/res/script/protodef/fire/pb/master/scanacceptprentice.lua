require "utils.tableutil"
SCanAcceptPrentice = {}
SCanAcceptPrentice.__index = SCanAcceptPrentice



SCanAcceptPrentice.PROTOCOL_TYPE = 816444

function SCanAcceptPrentice.Create()
	print("enter SCanAcceptPrentice create")
	return SCanAcceptPrentice:new()
end
function SCanAcceptPrentice:new()
	local self = {}
	setmetatable(self, SCanAcceptPrentice)
	self.type = self.PROTOCOL_TYPE
	return self
end
function SCanAcceptPrentice:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SCanAcceptPrentice:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function SCanAcceptPrentice:unmarshal(_os_)
	return _os_
end

return SCanAcceptPrentice
