require "utils.tableutil"
SBeginSchoolWheel1 = {}
SBeginSchoolWheel1.__index = SBeginSchoolWheel1



SBeginSchoolWheel1.PROTOCOL_TYPE = 800026

function SBeginSchoolWheel1.Create()
	print("enter SBeginSchoolWheel1 create")
	return SBeginSchoolWheel1:new()
end
function SBeginSchoolWheel1:new()
	local self = {}
	setmetatable(self, SBeginSchoolWheel1)
	self.type = self.PROTOCOL_TYPE
	self.wheelindex = 0

	return self
end
function SBeginSchoolWheel1:encode()
	local os = FireNet.Marshal.OctetsStream:new()
	os:compact_uint32(self.type)
	local pos = self:marshal(nil)
	os:marshal_octets(pos:getdata())
	pos:delete()
	return os
end
function SBeginSchoolWheel1:marshal(ostream)
	local _os_ = ostream or FireNet.Marshal.OctetsStream:new()
	_os_:marshal_int32(self.wheelindex)
	return _os_
end

function SBeginSchoolWheel1:unmarshal(_os_)
	self.wheelindex = _os_:unmarshal_int32()
	return _os_
end

return SBeginSchoolWheel1
