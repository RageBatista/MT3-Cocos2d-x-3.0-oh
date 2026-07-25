require "utils.tableutil"
COpenClan = {}
COpenClan.__index = COpenClan



COpenClan.PROTOCOL_TYPE = 808446

function COpenClan.Create()
	print("enter COpenClan create")
	return COpenClan:new()
end
function COpenClan:new()
	local self = {}
	setmetatable(self, COpenClan)
	self.type = self.PROTOCOL_TYPE
	return self
end
function COpenClan:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function COpenClan:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function COpenClan:unmarshal(_os_)
	return _os_
end

return COpenClan
