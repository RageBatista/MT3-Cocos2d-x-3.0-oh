require "utils.tableutil"
CEndSchoolWheel = {}
CEndSchoolWheel.__index = CEndSchoolWheel



CEndSchoolWheel.PROTOCOL_TYPE = 810365

function CEndSchoolWheel.Create()
	print("enter CEndSchoolWheel create")
	return CEndSchoolWheel:new()
end
function CEndSchoolWheel:new()
	local self = {}
	setmetatable(self, CEndSchoolWheel)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CEndSchoolWheel:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CEndSchoolWheel:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CEndSchoolWheel:unmarshal(_os_)
	return _os_
end

return CEndSchoolWheel
