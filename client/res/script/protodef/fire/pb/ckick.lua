require "utils.tableutil"
CKick = {}
CKick.__index = CKick



CKick.PROTOCOL_TYPE = 786550

function CKick.Create()
	print("enter CKick create")
	return CKick:new()
end
function CKick:new()
	local self = {}
	setmetatable(self, CKick)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CKick:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CKick:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CKick:unmarshal(_os_)
	return _os_
end

return CKick
