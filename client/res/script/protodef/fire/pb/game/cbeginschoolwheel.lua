require "utils.tableutil"
CBeginSchoolWheel = {}
CBeginSchoolWheel.__index = CBeginSchoolWheel



CBeginSchoolWheel.PROTOCOL_TYPE = 810363

function CBeginSchoolWheel.Create()
	print("enter CBeginSchoolWheel create")
	return CBeginSchoolWheel:new()
end
function CBeginSchoolWheel:new()
	local self = {}
	setmetatable(self, CBeginSchoolWheel)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CBeginSchoolWheel:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CBeginSchoolWheel:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CBeginSchoolWheel:unmarshal(_os_)
	return _os_
end

return CBeginSchoolWheel
