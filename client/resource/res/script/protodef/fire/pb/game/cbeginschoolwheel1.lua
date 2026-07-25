require "utils.tableutil"
CBeginSchoolWheel1 = {}
CBeginSchoolWheel1.__index = CBeginSchoolWheel1



CBeginSchoolWheel1.PROTOCOL_TYPE = 800024

function CBeginSchoolWheel1.Create()
	print("enter CBeginSchoolWheel create")
	return CBeginSchoolWheel:new()
end
function CBeginSchoolWheel1:new()
	local self = {}
	setmetatable(self, CBeginSchoolWheel1)
	self.type = self.PROTOCOL_TYPE
	return self
end
function CBeginSchoolWheel1:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function CBeginSchoolWheel1:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	return _os_
end

function CBeginSchoolWheel1:unmarshal(_os_)
	return _os_
end

return CBeginSchoolWheel1
