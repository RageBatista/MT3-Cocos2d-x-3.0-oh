require "utils.tableutil"
CCanAcceptPrentice = {}
CCanAcceptPrentice.__index = CCanAcceptPrentice



CCanAcceptPrentice.PROTOCOL_TYPE = 816443

function CCanAcceptPrentice.Create()
	print("enter CCanAcceptPrentice create")
	return CCanAcceptPrentice:new()
end
function CCanAcceptPrentice:new()
	local self = {}
	setmetatable(self, CCanAcceptPrentice)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CCanAcceptPrentice:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CCanAcceptPrentice:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CCanAcceptPrentice:unmarshal(_os_)
	return _os_
end

return CCanAcceptPrentice
