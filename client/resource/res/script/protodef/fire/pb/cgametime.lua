require "utils.tableutil"
CGameTime = {}
CGameTime.__index = CGameTime



CGameTime.PROTOCOL_TYPE = 786549

function CGameTime.Create()
	print("enter CGameTime create")
	return CGameTime:new()
end
function CGameTime:new()
	local self = {}
	setmetatable(self, CGameTime)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CGameTime:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CGameTime:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CGameTime:unmarshal(_os_)
	return _os_
end

return CGameTime
