require "utils.tableutil"
COpenClanMedic = {}
COpenClanMedic.__index = COpenClanMedic



COpenClanMedic.PROTOCOL_TYPE = 808439

function COpenClanMedic.Create()
	print("enter COpenClanMedic create")
	return COpenClanMedic:new()
end
function COpenClanMedic:new()
	local self = {}
	setmetatable(self, COpenClanMedic)
	self.type = self.PROTOCOL_TYPE
	return self
end
function COpenClanMedic:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function COpenClanMedic:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function COpenClanMedic:unmarshal(_os_)
	return _os_
end

return COpenClanMedic
