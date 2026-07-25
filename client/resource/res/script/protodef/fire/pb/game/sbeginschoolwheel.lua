require "utils.tableutil"
SBeginSchoolWheel = {}
SBeginSchoolWheel.__index = SBeginSchoolWheel



SBeginSchoolWheel.PROTOCOL_TYPE = 810364

function SBeginSchoolWheel.Create()
	print("enter SBeginSchoolWheel create")
	return SBeginSchoolWheel:new()
end
function SBeginSchoolWheel:new()
	local self = {}
	setmetatable(self, SBeginSchoolWheel)
	self.type = self.PROTOCOL_TYPE
	self.wheelindex = 0

	return self
end
function SBeginSchoolWheel:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SBeginSchoolWheel:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.wheelindex)
	return _os_
end

function SBeginSchoolWheel:unmarshal(_os_)
	self.wheelindex = _os_:unmarshal_int32()
	return _os_
end

return SBeginSchoolWheel
