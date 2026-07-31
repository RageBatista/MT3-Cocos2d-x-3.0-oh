require "utils.tableutil"
CEndSchoolWheel1 = {}
CEndSchoolWheel1.__index = CEndSchoolWheel1



CEndSchoolWheel1.PROTOCOL_TYPE = 800025

function CEndSchoolWheel1.Create()
	print("enter CEndSchoolWheel1 create")
	return CEndSchoolWheel1:new()
end
function CEndSchoolWheel1:new()
	local self = {}
	setmetatable(self, CEndSchoolWheel1)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CEndSchoolWheel1:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CEndSchoolWheel1:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CEndSchoolWheel1:unmarshal(_os_)
	return _os_
end

return CEndSchoolWheel1
