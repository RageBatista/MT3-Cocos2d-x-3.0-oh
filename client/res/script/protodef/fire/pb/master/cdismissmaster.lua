require "utils.tableutil"
CDismissMaster = {}
CDismissMaster.__index = CDismissMaster



CDismissMaster.PROTOCOL_TYPE = 816479

function CDismissMaster.Create()
	print("enter CDismissMaster create")
	return CDismissMaster:new()
end
function CDismissMaster:new()
	local self = {}
	setmetatable(self, CDismissMaster)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CDismissMaster:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CDismissMaster:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CDismissMaster:unmarshal(_os_)
	return _os_
end

return CDismissMaster
